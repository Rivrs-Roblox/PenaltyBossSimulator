local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local Helpers = ReplicatedStorage.Shared.Helpers
local SetupArea = require(Helpers.SetupArea)

local player = Players.LocalPlayer

local CharactersService
local DataService

local NotificationController
local DataCacheController
local UIController

local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local Actions = StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions
local CharacterActions = require(Actions.CharacterActions)

local CharactersController = Knit.CreateController({
	Name = "CharactersController",

	_currentCharacterId = 0,
	Template = {},
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
-- #endregion Local Functions

-- #region Functions
function CharactersController:GetSpecialKickAnimation(): string
	if self._currentCharacterId == 0 then
		return "SpecialKick"
	end

	local character = self.Template.Characters[self._currentCharacterId]
	if not character then
		return "SpecialKick"
	end

	return character.SpecialKick or "SpecialKick"
end

function CharactersController:SetFootballTransparancy(plr: Player, transparancy: number)
	setFootballTransparancy(plr, transparancy)
end

function CharactersController:Equip(id: number)
	return CharactersService:Equip(id):andThen(function(result)
		if result.type == "SUCCESS" then
			Store:dispatch(CharacterActions.setCharacter(id))
		end
		NotificationController:Notify({
			text = result.text,
			type = result.type,
			tag = "EquipCharacter",
		})
		return result
	end)
end

function CharactersController:Buy(id: number)
	return CharactersService:Buy(id):andThen(function(result)
		if result.type == "SUCCESS" then
			Store:dispatch(CharacterActions.setCharacter(id))
		end
		NotificationController:Notify({
			text = result.text,
			type = result.type,
			tag = "BuyCharacter",
		})
		return result
	end)
end
-- #endregion Functions

-- #region Knit Lifecycle
function CharactersController:KnitInit()
	CharactersService = Knit.GetService("CharactersService")
	DataService = Knit.GetService("DataService")

	NotificationController = Knit.GetController("NotificationController")
	UIController = Knit.GetController("UIController")
	DataCacheController = Knit.GetController("DataCacheController")

	print("CharactersController Initialized")
end

function CharactersController:KnitStart()
	self.Template = DataCacheController:GetFile("Template")

	CharactersService.CharactersUpdated:Connect(function(characters)
		self._currentCharacterId = characters.Current
	end)

	DataService:GetData():andThen(function(data)
		if data and data.Characters then
			self._currentCharacterId = data.Characters.Current
		end
	end)

	SetupArea("CharactersArea", {
		onEnter = function(plr)
			if plr == player then
				UIController:ShowFrame({ frame = FramesConstants.Characters })
			end
		end,
		onExit = function(plr)
			if plr == player then
				UIController:HideFrame()
			end
		end,
	})

	print("CharactersController Started")
end
-- #endregion Knit Lifecycle

return CharactersController
