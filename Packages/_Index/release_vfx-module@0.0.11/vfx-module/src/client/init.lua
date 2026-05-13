--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--|| Imports ||--
local ImportFolder = ReplicatedStorage:FindFirstChild("Packages")

local src = script
while src and src.Name ~= "src" do
	src = src:FindFirstAncestorWhichIsA("Folder")
end

local function importPackage(name: string)
	local RootFolder = src and src:FindFirstAncestorWhichIsA("Folder") or nil
	return RootFolder and require(RootFolder[name]) or require(ImportFolder:FindFirstChild(name))
end

local Knit = importPackage("knit")
local Streamable = importPackage("Streamable").Streamable
local Modules = script.Modules

local VFXServ
local SingleEmitter = require(Modules.SingleEmitter)
local GroupEmitter = require(Modules.GroupEmitter)
local Aura = require(Modules.Aura)

local VFXCtrl = Knit.CreateController({
	Name = "VFXCtrl",
	SingleEmitters = {},
	GroupEmitters = {},
	CharacterAuras = {},
	StreamableCharacters = {}, -- New table to track character streamables
})

-- Helper function to generate unique keys
local function getKey(identifier, part)
	return tostring(identifier) .. "_" .. part:GetFullName()
end

-- Helper function to handle streamed character
function VFXCtrl:HandleStreamedCharacter(character, auraFolder)
	-- First validate if the aura is still valid on the server
	local isValid = VFXServ:ValidateAura(auraFolder, character)

	if isValid then
		-- If valid, play the aura
		self:PlayAura(auraFolder, character)
	else
		warn("Aura no longer valid for character:", character:GetFullName())
	end
end

function VFXCtrl:PlaySingle(emitter, part)
	local key = getKey(emitter, part)
	local singleEmitter = SingleEmitter.new(emitter, part)
	self.SingleEmitters[key] = self.SingleEmitters[key] or {}
	table.insert(self.SingleEmitters[key], singleEmitter)
	singleEmitter:play()
	return singleEmitter
end

function VFXCtrl:StopSingle(emitter, part)
	local key = getKey(emitter, part)
	if self.SingleEmitters[key] then
		for _, instance in ipairs(self.SingleEmitters[key]) do
			instance:stop()
		end
	end
end

function VFXCtrl:DestroySingle(emitter, part)
	local key = getKey(emitter, part)
	if self.SingleEmitters[key] then
		for _, instance in ipairs(self.SingleEmitters[key]) do
			instance:destroy()
		end
		self.SingleEmitters[key] = nil
	end
end

function VFXCtrl:PlayGroup(vfxFolder, part)
	local key = getKey(vfxFolder, part)
	if not self.GroupEmitters[key] then
		local groupEmitter = GroupEmitter.new(vfxFolder, part)
		self.GroupEmitters[key] = groupEmitter
		groupEmitter:play()
		return groupEmitter
	else 
		self.GroupEmitters[key]:play()
		return self.GroupEmitters[key]
	end
end

function VFXCtrl:StopGroup(vfxFolder, part)
	local key = getKey(vfxFolder, part)
	if self.GroupEmitters[key] then
		self.GroupEmitters[key]:stop()
	end
end

function VFXCtrl:DestroyGroup(vfxFolder, part)
	local key = getKey(vfxFolder, part)
	if self.GroupEmitters[key] then
		self.GroupEmitters[key]:destroy()
		self.GroupEmitters[key] = nil
	end
end

function VFXCtrl:PlayAura(auraFolder, character)
	if self.CharacterAuras[character] then
		self:DestroyAura(character)
	end

	local aura = Aura.new(auraFolder, character)
	self.CharacterAuras[character] = aura
	aura:play()
	return aura
end

function VFXCtrl:StopAura(character)
	if self.CharacterAuras[character] then
		self.CharacterAuras[character]:stop()
	end
end

function VFXCtrl:DestroyAura(character)
	if self.CharacterAuras[character] then
		self.CharacterAuras[character]:destroy()
		self.CharacterAuras[character] = nil
	end
end

-- Server-side VFX methods
function VFXCtrl:PlayServerSingle(emitter, part)
	self:PlaySingle(emitter, part)
	return VFXServ:PlaySingle(emitter, part)
end

function VFXCtrl:PlayServerGroup(vfxFolder, part)
	self:PlayGroup(vfxFolder, part)
	return VFXServ:PlayGroup(vfxFolder, part)
end

function VFXCtrl:PlayServerAura(auraFolder)
	local character = Players.LocalPlayer.Character
	self:PlayAura(auraFolder, character)
	return VFXServ:PlayAura(auraFolder, character)
end

function VFXCtrl:StopServerSingle(emitter, part)
	self:StopSingle(emitter, part)
	return VFXServ:StopSingle(emitter, part)
end

function VFXCtrl:StopServerGroup(vfxFolder, part)
	self:StopGroup(vfxFolder, part)
	return VFXServ:StopGroup(vfxFolder, part)
end

function VFXCtrl:StopServerAura()
	local character = Players.LocalPlayer.Character
	self:StopAura(character)
	return VFXServ:StopAura(character)
end

function VFXCtrl:DestroyServerAura()
	local character = Players.LocalPlayer.Character
	return VFXServ:DestroyAura(character)
end

function VFXCtrl:Emit(emitterOrFolder, counts: { number } | number?, part, keepEmitter: boolean?)
	local key
	local emitter

	if emitterOrFolder:IsA("ParticleEmitter") then
		-- Handle single emitter
		key = getKey(emitterOrFolder, part)
		if self.SingleEmitters[key] then
			-- Emit using existing emitter
			for _, instance in ipairs(self.SingleEmitters[key]) do
				instance:emit(counts)
			end
		else
			-- Create temporary emitter
			emitter = self:PlaySingle(emitterOrFolder, part)
			emitter:stop()
			emitter:emit(counts)

			if not keepEmitter then
				task.delay(3, function()
					self:DestroySingle(emitterOrFolder, part)
				end)
			end
		end
	else
		-- Handle group emitter
		key = getKey(emitterOrFolder, part)
		if self.GroupEmitters[key] then
			-- Emit using existing group
			self.GroupEmitters[key]:emit(counts)
		else
			-- Create temporary group
			emitter = self:PlayGroup(emitterOrFolder, part)
			emitter:stop()
			emitter:emit(counts)

			if not keepEmitter then
				task.delay(3, function()
					self:DestroyGroup(emitterOrFolder, part)
				end)
			end
		end
	end

	return emitter
end

-- Add cleanup for streamables
function VFXCtrl:CleanupPlayerVFX(player)
	if player.Character then
		self:HandleCharacterCleanup(player.Character)
	end
end

function VFXCtrl:HandleCharacterEvents(player)
	-- Handle when the character is removed (including death)
	local function onCharacterRemoving(character)
		if character then
			self:HandleCharacterCleanup(character)
		end
	end

	-- Handle when a new character is added
	local function onCharacterAdded(character)
		-- Wait for the character to be fully loaded
		character:WaitForChild("Humanoid")

		-- Connect to character death
		character.Humanoid.Died:Connect(function()
			self:HandleCharacterCleanup(character)
		end)
	end

	-- Connect to the player's character events
	player.CharacterRemoving:Connect(onCharacterRemoving)
	player.CharacterAdded:Connect(onCharacterAdded)

	-- Handle the current character if it exists
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

function VFXCtrl:HandleCharacterCleanup(character)
	-- Clean up streamable
	local streamableKey = character and character:GetFullName()
	if streamableKey and self.StreamableCharacters[streamableKey] then
		self.StreamableCharacters[streamableKey]:Destroy()
		self.StreamableCharacters[streamableKey] = nil
	end

	-- Clean up any auras
	if self.CharacterAuras[character] then
		self:DestroyAura(character)
	end

	-- Clean up any single emitters attached to this character
	for key, emitters in pairs(self.SingleEmitters) do
		if key:find(character:GetFullName()) then
			for _, emitter in ipairs(emitters) do
				emitter:destroy()
			end
			self.SingleEmitters[key] = nil
		end
	end

	-- Clean up any group emitters attached to this character
	for key, groupEmitter in pairs(self.GroupEmitters) do
		if key:find(character:GetFullName()) then
			groupEmitter:destroy()
			self.GroupEmitters[key] = nil
		end
	end
end

function VFXCtrl:HandleServerVFX(vfxType, ...)
	if vfxType == "Single" then
		self:PlaySingle(...)
	elseif vfxType == "Group" then
		self:PlayGroup(...)
	elseif vfxType == "Aura" then
		local auraFolder, character = ...

		-- Only handle streaming for other players' characters
		if character ~= Players.LocalPlayer.Character then
			local streamableKey = character:GetFullName()
			local characterStreamable = self.StreamableCharacters[streamableKey]

			if not characterStreamable then
				characterStreamable = Streamable.new(character, "HumanoidRootPart")
				self.StreamableCharacters[streamableKey] = characterStreamable

				-- Set up the observer
				characterStreamable:Observe(function(hrp, trove)

					-- Handle the streamed character
					self:HandleStreamedCharacter(character, auraFolder)

					-- Cleanup when the part is removed
					trove:Add(function()
						if self.CharacterAuras[character] then
							self:DestroyAura(auraFolder, character)
						end
					end)
				end)
			end

			-- If the character is already streamed in, play immediately
			if characterStreamable.Instance then
				self:HandleStreamedCharacter(character, auraFolder)
			end
		else
			-- For local player, just play the aura directly
			self:PlayAura(auraFolder, character)
		end
	end
end

function VFXCtrl:KnitStart()
	VFXServ = Knit.GetService("VFXServ")

	-- Listen for VFX play signals
	VFXServ.PlayVFXSignal:Connect(function(vfxType, ...)
		self:HandleServerVFX(vfxType, ...)
	end)

	-- Listen for VFX stop signals
	VFXServ.StopVFXSignal:Connect(function(vfxType, ...)
		if vfxType == "Single" then
			local emitter, part = ...
			self:StopSingle(emitter, part)
		elseif vfxType == "Group" then
			local vfxFolder, part = ...
			self:StopGroup(vfxFolder, part)
		elseif vfxType == "Aura" then
			local _, character = ...
			self:StopAura(character)
		end
	end)

	-- Listen for VFX destroy signals
	VFXServ.DestroyVFXSignal:Connect(function(vfxType, ...)
		if vfxType == "Aura" then
			local _, character = ...

			-- If this is another player's character
			if character ~= Players.LocalPlayer.Character then
				-- Clean up streamable if it exists
				local streamableKey = character:GetFullName()
				local characterStreamable = self.StreamableCharacters[streamableKey]
				if characterStreamable then
					characterStreamable:Destroy()
					self.StreamableCharacters[streamableKey] = nil
				end

				-- Remove the aura if it's currently playing
				if self.CharacterAuras[character] then
					self:DestroyAura(character)
				end
			else
				-- For local player, just destroy the aura
				self:DestroyAura(character)
			end
		end
	end)

	-- Connect to player events
	Players.PlayerRemoving:Connect(function(player)
		self:CleanupPlayerVFX(player)
	end)

	-- Setup character handling for all current players
	for _, player in ipairs(Players:GetPlayers()) do
		self:HandleCharacterEvents(player)
	end

	-- Setup character handling for new players
	Players.PlayerAdded:Connect(function(player)
		self:HandleCharacterEvents(player)
	end)
end

return VFXCtrl
