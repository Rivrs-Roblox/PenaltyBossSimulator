local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local FunnelsModule = require(Packages.funnelsModule)

local DataService
local DataCacheService
local TrailsService
local FightService

local CharactersFolder = ReplicatedStorage.Assets.SoccerCharacters

local IDLE_ANIMATION_ID = "rbxassetid://97024548119401"
local RUN_ANIMATION_ID = "rbxassetid://105106002784990"
local JUMP_ANIMATION_ID = "rbxassetid://97546612840798"

local function isRegularPurchasableCharacter(characterEntry: table?): boolean
	return characterEntry ~= nil
		and not characterEntry.VIP
		and not characterEntry.Reward
		and not characterEntry.StarterPack
		and not characterEntry.RejoinReward
end

local function getPreviousRegularCharacterId(charactersTemplate: table, id: number): number?
	local previousId = nil

	for characterId, characterEntry in pairs(charactersTemplate) do
		if
			type(characterId) == "number"
			and characterId < id
			and isRegularPurchasableCharacter(characterEntry)
		then
			if previousId == nil or characterId > previousId then
				previousId = characterId
			end
		end
	end

	return previousId
end

local CharactersService = Knit.CreateService({
	Name = "CharactersService",
	Client = {
		CharactersUpdated = Knit.CreateSignal(),
	},

	Template = {},

	IsChanging = {},
})

-- #region Local Functions
local function setFootballTransparancy(player: Player, transparancy: number)
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local football = hrp:FindFirstChild("Football")
		if football then
			local meshPart = football.BallRoot:FindFirstChildOfClass("MeshPart")
			if meshPart then
				meshPart.Transparency = transparancy
			end
		end
	end
end

local function setCustomAnimate(animMap, player)
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		track:Stop(0) -- 0 = tanpa fade, bisa pakai 0.2 kalau mau smooth
	end

	local animate = player.Character and player.Character:FindFirstChild("Animate")
	if not animate then
		return
	end

	for state, animId in pairs(animMap) do
		if state == "idle" and animate:FindFirstChild("idle") then
			local idleAnim1 = animate.idle:FindFirstChild("Animation1")
			local idleAnim2 = animate.idle:FindFirstChild("Animation2")
			if idleAnim1 then
				if idleAnim1:IsA("StringValue") then
					idleAnim1.Value = animId
				elseif idleAnim1:IsA("Animation") then
					idleAnim1.AnimationId = animId
				end
			end

			if idleAnim2 then
				if idleAnim2:IsA("StringValue") then
					idleAnim2.Value = animId
				elseif idleAnim2:IsA("Animation") then
					idleAnim2.AnimationId = animId
				end
			end
		elseif state == "run" and animate:FindFirstChild("run") then
			local runAnim = animate.run:FindFirstChild("RunAnim")
			if runAnim then
				runAnim.AnimationId = animId
			end
		elseif state == "walk" and animate:FindFirstChild("walk") then
			local walkAnim = animate.walk:FindFirstChild("WalkAnim")
			if walkAnim then
				walkAnim.AnimationId = animId
			end
		elseif state == "jump" and animate:FindFirstChild("jump") then
			local jumpAnim = animate.jump:FindFirstChild("JumpAnim")
			if jumpAnim then
				jumpAnim.AnimationId = animId
			end
		end
	end
end

local function changeCharacter(player: Player, characterName: string)
	local character = CharactersFolder:FindFirstChild(characterName, true)
	if not character then
		return false
	end

	local oldCharacter = player.Character
	local characterClone = character:Clone()
	characterClone.Name = player.Name

	if oldCharacter then
		characterClone:PivotTo(oldCharacter:GetPivot())
		characterClone.Parent = oldCharacter.Parent
	else
		characterClone.Parent = workspace
	end

	player.Character = characterClone

	if oldCharacter then
		oldCharacter:Destroy()
	end

	setCustomAnimate({
		idle = IDLE_ANIMATION_ID,
		run = RUN_ANIMATION_ID,
		walk = RUN_ANIMATION_ID,
		jump = JUMP_ANIMATION_ID,
	}, player)

	setFootballTransparancy(player, 0)

	print("Successfully change character for player", player)
	return true
end
-- #endregion Local Functions

-- #region Client Functions
function CharactersService.Client:Buy(player: Player, id: number)
	return self.Server:Buy(player, id)
end

function CharactersService.Client:Equip(player: Player, id: number)
	return self.Server:Equip(player, id)
end

-- #endregion Client Functions

-- #region Server Functions

--|| Functions ||--
function CharactersService:Buy(player: Player, id: number, bypassPrice: boolean?)
	local data = DataService:GetData(player)
	if data == nil then
		return warn("[SNIPERS SERVICE] Player has no data: " .. player.Name)
	end

	local characterEntry = self.Template.Characters[id]
	if characterEntry == nil then
		return { text = "This character doesn't exist!", type = "ERROR" }
	end

	if table.find(data.Characters.Unlocked, id) then
		return { text = "You already own this character!", type = "ERROR" }
	end

	if not bypassPrice and isRegularPurchasableCharacter(characterEntry) then
		local previousCharacterId = getPreviousRegularCharacterId(self.Template.Characters, id)
		if previousCharacterId ~= nil and not table.find(data.Characters.Unlocked, previousCharacterId) then
			local previousCharacter = self.Template.Characters[previousCharacterId]
			local previousCharacterName = previousCharacter
				and (previousCharacter.DisplayName or previousCharacter.Name)
				or "previous character"

			return {
				text = self.Template.Messages.Notifications.Buy_Previous_Character_First(previousCharacterName),
				type = "ERROR",
			}
		end
	end

	if
		not bypassPrice
		and (characterEntry.VIP or characterEntry.Reward or characterEntry.StarterPack or characterEntry.RejoinReward)
	then
		return { text = "This character can't be bought by Wins!", type = "ERROR" }
	end

	local price = characterEntry.Price

	if data.Wins < price and not bypassPrice then
		return { text = "Not enough Wins!", type = "ERROR" }
	end

	if not bypassPrice then
		FunnelsModule:LogIGPEconomyEvent(player, "Wins", price, data.Wins - price, characterEntry.Name)
		DataService:ChangeValue(player, "Wins", -price, true)
	end

	table.insert(data.Characters.Unlocked, id)

	self:Equip(player, id)

	self.Client.CharactersUpdated:Fire(player, {
		Unlocked = data.Characters.Unlocked,
		Current = data.Characters.Current,
	})

	return { text = `Successfully bought {characterEntry.DisplayName}!`, type = "SUCCESS" }
end

function CharactersService:Equip(player: Player, id: number)
	if player == nil or id == nil then
		warn("[SOCCER CHARACTERS SERVICE] Invalid player or id")
		return
	end

	if FightService.Sessions[player] then
		return { text = "You can't change character while in a fight!", type = "ERROR" }
	end

	local data = DataService:GetData(player)
	if not data then
		warn("[SOCCER CHARACTERS SERVICE] Player has no data: " .. player.Name)
		return
	end

	local characterEntry = self.Template.Characters[id]
	if characterEntry == nil then
		warn("Character not exist in template")
		return { text = "This character doesn't exist", type = "ERROR" }
	end

	if not table.find(data.Characters.Unlocked, id) then
		warn("Player don't own this character")
		return { text = "You don't own this character", type = "ERROR" }
	end

	self.IsChanging[player] = true

	local success = changeCharacter(player, characterEntry.Name)
	if not success then
		self.IsChanging[player] = false
		warn("Failed to change character")
		return { text = "Failed to equip character", type = "ERROR" }
	end

	if data.Trails and data.Trails.Current then
		TrailsService:Equip(player, data.Trails.Current)
	end

	data.Characters.Current = id

	self.Client.CharactersUpdated:Fire(player, {
		Unlocked = data.Characters.Unlocked,
		Current = data.Characters.Current,
	})

	self.IsChanging[player] = false

	return {
		text = self.Template.Messages.Notifications.SoccerCharacter_Equipped(characterEntry.Name),
		type = "SUCCESS",
	}
end

function CharactersService:Setup(player)
	local data = DataService:GetData(player)
	if not data then
		return
	end

	local equippedId = data.Characters.Current
	if equippedId == nil then
		return
	end

	self:Equip(player, equippedId)
end

-- #endregion Server Functions

-- #region Knit Lifecycle
function CharactersService:KnitInit()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")
	TrailsService = Knit.GetService("TrailsService")
	FightService = Knit.GetService("FightService")

	self.Template = DataCacheService:GetFile("Template")

	print("CharactersService Initialized")
end

function CharactersService:KnitStart()
	for _, player in pairs(Players:GetPlayers()) do
		self:Setup(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:Setup(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.IsChanging[player] = nil
	end)

	print("CharactersService Started")
end
-- #endregion Knit Lifecycle

return CharactersService
