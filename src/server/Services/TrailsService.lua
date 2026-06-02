local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local FunnelsModule = require(Packages.funnelsModule)

local DataService
local DataCacheService
local FightService

local TrailsFolder = ReplicatedStorage.Assets.Trails

local DEFAULT_WALK_SPEED = StarterPlayer.CharacterWalkSpeed

local TrailsService = Knit.CreateService({
	Name = "TrailsService",

	Client = {
		TrailsUpdated = Knit.CreateSignal(),
		MoveSpeedUpdated = Knit.CreateSignal(),
	},

	Template = {},
})

-- #region Local Functions
local function weldTrail(trailName, character)
	local targetTrail = TrailsFolder:FindFirstChild(trailName, true)
	if not targetTrail then
		return warn("[TRAILS SERVICE] Trail not found: " .. trailName)
	end

	local trail = targetTrail:Clone()
	trail.Name = "Trail"

	local charPart = character:WaitForChild("RightFoot")
	trail.PrimaryPart.CFrame = charPart.CFrame
	trail.Parent = charPart

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = charPart
	weld.Part1 = trail.PrimaryPart
	weld.Parent = trail

	trail.PrimaryPart.Anchored = false
end

local function removeTrail(character)
	local charPart = character:WaitForChild("RightFoot")
	for _, child in ipairs(charPart:GetChildren()) do
		if child:IsA("Model") and child.Name == "Trail" then
			child:Destroy()
		end
	end
end
-- #endregion Local Functions

-- #region Client Functions
function TrailsService.Client:Equip(player: Player, id: number)
	return self.Server:Equip(player, id)
end

function TrailsService.Client:Buy(player: Player, id: number, bypassPrice: boolean?)
	return self.Server:Buy(player, id, bypassPrice)
end

function TrailsService.Client:GetCurrentSpeed(player: Player)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[TRAILS SERVICE] Player has no data: " .. player.Name)
	end

	local trail = self.Server.Template.Trails[data.Trails.Current]
	if trail == nil then
		return DEFAULT_WALK_SPEED
	end

	return DEFAULT_WALK_SPEED * trail.Multiplier
end

-- #endregion Client Functions

-- #region Server Functions
function TrailsService:Buy(player: Player, id: number, bypassPrice: boolean?)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[TRAILS SERVICE] Player has no data: " .. player.Name)
	end

	local trail = self.Template.Trails[id]
	if trail == nil then
		return { text = "This trail doesn't exist", type = "ERROR" }
	end

	local price = trail.Price

	if data.Wins < price and not bypassPrice then
		return { text = "Not enough wins", type = "ERROR" }
	end

	if not bypassPrice then
		FunnelsModule:LogIGPEconomyEvent(player, "Wins", price, data.Wins - price, trail.Name)
		DataService:ChangeValue(player, "Wins", -price, true)
	end

	table.insert(data.Trails.Unlocked, id)
	self:Equip(player, id)

	self.Client.TrailsUpdated:Fire(player, {
		Unlocked = data.Trails.Unlocked,
		Current = data.Trails.Current,
	})

	return { text = `Successfully bought {trail.DisplayName} trail!`, type = "SUCCESS" }
end

function TrailsService:Equip(player: Player, id: number)
	if FightService.Sessions[player] then
		return { text = "You can't equip trails while in a fight!", type = "ERROR" }
	end

	local data = DataService:GetData(player)
	if data == nil then
		return warn("[TRAILS SERVICE] Player has no data: " .. player.Name)
	end

	local trail
	local character = player.Character
	if not character then
		return { text = "Character not found", type = "ERROR" }
	end

	if id ~= 0 then
		trail = self.Template.Trails[id]
		if trail == nil then
			return { text = "This trail doesn't exist", type = "ERROR" }
		end

		if not table.find(data.Trails.Unlocked, id) then
			return { text = "You don't own this trail", type = "ERROR" }
		end

		removeTrail(character)
		weldTrail(trail.Name, character)

		local humanoid = character:WaitForChild("Humanoid")
		humanoid.WalkSpeed = DEFAULT_WALK_SPEED * trail.Multiplier
		self.Client.MoveSpeedUpdated:Fire(player, humanoid.WalkSpeed)
	else
		removeTrail(character)

		local humanoid = character:WaitForChild("Humanoid")
		humanoid.WalkSpeed = DEFAULT_WALK_SPEED
		self.Client.MoveSpeedUpdated:Fire(player, humanoid.WalkSpeed)
	end

	data.Trails.Current = id

	self.Client.TrailsUpdated:Fire(player, {
		Unlocked = data.Trails.Unlocked,
		Current = data.Trails.Current,
	})

	return {
		text = if data.Trails.Current == 0 then `Unequipped trail` else `Equipped {trail.DisplayName} trail`,
		type = "SUCCESS",
	}
end
-- #endregion Server Functions

-- #region Knit Lifecycle
function TrailsService:KnitInit()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")
	FightService = Knit.GetService("FightService")

	self.Template = DataCacheService:GetFile("Template")

	print("TrailsService Initialized")
end

function TrailsService:KnitStart()
	print("TrailsService Started")

	local function onCharacterAdded(player, character)
		local data = DataService:GetData(player)
		if data then
			self:Equip(player, data.Trails.Current)
		end
	end

	local function onPlayerAdded(player)
		player.CharacterAdded:Connect(function(character)
			onCharacterAdded(player, character)
		end)

		if player.Character then
			onCharacterAdded(player, player.Character)
		end
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
end
-- #endregion Knit Lifecycle

return TrailsService
