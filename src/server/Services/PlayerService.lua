--[=[
	Owner: JustStop__
	Version: 0.0.2
	Collision group setup for player characters and client-side coaches.
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Helpers
local AddOutline = require(ReplicatedStorage.Shared.Helpers.AddOutline)

local CHARACTER_COLLISION_GROUP = "Characters"
local COACH_COLLISION_GROUP = "Coaches"

-- PlayerService
local PlayerService = Knit.CreateService({
	Name = "PlayerService",
})

--|| Private Functions ||--
local function safeRegisterCollisionGroup(groupName: string)
	local success, err = pcall(function()
		PhysicsService:RegisterCollisionGroup(groupName)
	end)

	if not success and not tostring(err):find("already exists") then
		warn(`[PLAYER SERVICE] Failed to register collision group {groupName}: {err}`)
	end
end

local function safeSetCollidable(groupA: string, groupB: string, canCollide: boolean)
	local success, err = pcall(function()
		PhysicsService:CollisionGroupSetCollidable(groupA, groupB, canCollide)
	end)

	if not success then
		warn(`[PLAYER SERVICE] Failed to set collision rule {groupA} <-> {groupB}: {err}`)
	end
end

--|| Functions ||--
function PlayerService:SetupCollisionGroups()
	safeRegisterCollisionGroup(CHARACTER_COLLISION_GROUP)
	safeRegisterCollisionGroup(COACH_COLLISION_GROUP)

	-- Player characters should not push each other.
	safeSetCollidable(CHARACTER_COLLISION_GROUP, CHARACTER_COLLISION_GROUP, false)

	-- Coaches should not push player characters or other coaches.
	safeSetCollidable(COACH_COLLISION_GROUP, CHARACTER_COLLISION_GROUP, false)
	safeSetCollidable(COACH_COLLISION_GROUP, COACH_COLLISION_GROUP, false)
end

function PlayerService:SetPartCollisionGroup(part: BasePart, groupName: string)
	local success, err = pcall(function()
		part.CollisionGroup = groupName
	end)

	if not success then
		warn(`[PLAYER SERVICE] Failed to set {part:GetFullName()} collision group to {groupName}: {err}`)
	end
end

function PlayerService:SetModelCollisionGroup(model: Model, groupName: string)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			self:SetPartCollisionGroup(descendant, groupName)
		end
	end
end

function PlayerService:CharacterAdded(character: Model)
	AddOutline(character)
	self:SetModelCollisionGroup(character, CHARACTER_COLLISION_GROUP)

	character.DescendantAdded:Connect(function(descendant: Instance)
		if descendant:IsA("BasePart") then
			self:SetPartCollisionGroup(descendant, CHARACTER_COLLISION_GROUP)
		end
	end)
end

function PlayerService:SetupPlayer(player: Player)
	if player.Character then
		task.defer(function()
			if player.Character then
				self:CharacterAdded(player.Character)
			end
		end)
	end

	player.CharacterAdded:Connect(function(character: Model)
		self:CharacterAdded(character)
	end)
end

--|| Knit Lifecycle ||--
function PlayerService:KnitInit()
	self:SetupCollisionGroups()

	Players.PlayerAdded:Connect(function(player: Player)
		self:SetupPlayer(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:SetupPlayer(player)
	end

	print("[PLAYER SERVICE] Service loaded successfully.")
end

return PlayerService
