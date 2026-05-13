local Players = game:GetService("Players")

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local VFXServ = Knit.CreateService({
	Name = "VFXServ",
	Client = {
		StopVFXSignal = Knit.CreateSignal(),
		DestroyVFXSignal = Knit.CreateSignal(),
		PlayVFXSignal = Knit.CreateSignal(),
	},

	-- Store active VFX by player and type
	_activeVFX = {}, -- Format: [userId] = { singles = {}, groups = {}, auras = {} }
})

-- Helper function to initialize player VFX storage
function VFXServ:InitializePlayerVFX(player)
	self._activeVFX[player.UserId] = {
		singles = {},
		groups = {},
		auras = {},
		stopped = { -- New table to track stopped state
			singles = {},
			groups = {},
			auras = false,
		},
	}
end

-- Helper function to cleanup all VFX for a player
function VFXServ:CleanupPlayerVFX(player)
	if self._activeVFX[player.UserId] then
		-- Notify clients to destroy all VFX for this player
		local character = player.Character
		if character then
			-- Clean up singles
			for emitter, _ in pairs(self._activeVFX[player.UserId].singles) do
				self.Client.DestroyVFXSignal:FireAll("Single", emitter, character)
			end

			-- Clean up groups
			for folder, _ in pairs(self._activeVFX[player.UserId].groups) do
				self.Client.DestroyVFXSignal:FireAll("Group", folder, character)
			end

			-- Clean up auras
			if self._activeVFX[player.UserId].auras.current then
				self.Client.DestroyVFXSignal:FireAll("Aura", nil, character)
			end
		end

		-- Clear the storage
		self._activeVFX[player.UserId] = {
			singles = {},
			groups = {},
			auras = {},
		}
	end
end

function VFXServ.Client:StopSingle(player, emitter, part)
	if not self.Server._activeVFX[player.UserId] then
		self.Server:InitializePlayerVFX(player)
	end

	-- Mark the emitter as stopped
	self.Server._activeVFX[player.UserId].stopped.singles[emitter] = true

	-- Fire to all clients
	self.Server.Client.StopVFXSignal:FireAll("Single", emitter, part)
	return true
end

function VFXServ.Client:StopGroup(player, vfxFolder, part)
	if not self.Server._activeVFX[player.UserId] then
		self.Server:InitializePlayerVFX(player)
	end

	-- Mark the group as stopped
	self.Server._activeVFX[player.UserId].stopped.groups[vfxFolder] = true

	-- Fire to all clients
	self.Server.Client.StopVFXSignal:FireAll("Group", vfxFolder, part)
	return true
end

function VFXServ.Client:StopAura(player)
	if not self.Server._activeVFX[player.UserId] then
		self.Server:InitializePlayerVFX(player)
	end

	-- Mark the aura as stopped
	self.Server._activeVFX[player.UserId].stopped.auras = true

	-- Fire to all clients
	self.Server.Client.StopVFXSignal:FireAll("Aura", nil, player.Character)
	return true
end

-- Handle character events
function VFXServ:HandleCharacterEvents(player)
	local function onCharacterAdded(character)
		-- Wait for humanoid
		local humanoid = character:WaitForChild("Humanoid")

		-- Connect to death event
		humanoid.Died:Connect(function()
			-- Clean up all VFX when character dies
			self:CleanupPlayerVFX(player)
		end)
	end

	-- Connect to character events
	player.CharacterAdded:Connect(onCharacterAdded)

	-- Handle existing character
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

-- Existing VFX methods with storage
function VFXServ.Client:PlaySingle(player, emitter, part)
	if not self.Server._activeVFX[player.UserId] then
		self.Server:InitializePlayerVFX(player)
	end

	-- Store the emitter
	self.Server._activeVFX[player.UserId].singles[emitter] = true

	-- Fire to all clients
	self.Server.Client.PlayVFXSignal:FireAll("Single", emitter, part)
	return true
end

function VFXServ.Client:PlayGroup(player, vfxFolder, part)
	if not self.Server._activeVFX[player.UserId] then
		self.Server:InitializePlayerVFX(player)
	end

	-- Store the group
	self.Server._activeVFX[player.UserId].groups[vfxFolder] = true

	-- Fire to all clients
	self.Server.Client.PlayVFXSignal:FireAll("Group", vfxFolder, part)
	return true
end

function VFXServ.Client:PlayAura(player, auraFolder)
	if not self.Server._activeVFX[player.UserId] then
		self.Server:InitializePlayerVFX(player)
	end

	-- Store the aura
	self.Server._activeVFX[player.UserId].auras.current = auraFolder

	-- Fire to all clients
	self.Server.Client.PlayVFXSignal:FireAll("Aura", auraFolder, player.Character)
	return true
end

function VFXServ.Client:DestroyAura(player)
	if self.Server._activeVFX[player.UserId] then
		-- Clear the stored aura
		self.Server._activeVFX[player.UserId].auras.current = nil

		-- Fire to all clients
		self.Server.Client.DestroyVFXSignal:FireAll("Aura", nil, player.Character)
	end
	return true
end

-- Validation method for auras
function VFXServ.Client:ValidateAura(player, auraFolder, character)
	-- Check if the aura is still active for the player
	if self.Server._activeVFX[player.UserId] and self.Server._activeVFX[player.UserId].auras.current == auraFolder then
		return true
	end
	return false
end

function VFXServ:KnitInit()
	-- Set up player handling
	Players.PlayerAdded:Connect(function(player)
		self:InitializePlayerVFX(player)
		self:HandleCharacterEvents(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:CleanupPlayerVFX(player)
		self._activeVFX[player.UserId] = nil
	end)

	-- Initialize for existing players
	for _, player in ipairs(Players:GetPlayers()) do
		self:InitializePlayerVFX(player)
		self:HandleCharacterEvents(player)
	end
end

return VFXServ
