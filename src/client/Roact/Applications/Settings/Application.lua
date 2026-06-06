--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Controllers
local SettingsController = Knit.GetController("SettingsController")
local SoundController = Knit.GetController("SoundController")

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)

-- Frames
local Frames = script.Parent.Frames
local VolumeSlider = require(Frames.Slider)
local Item = require(Frames.Item)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")

local SETTINGS_ICON = "rbxassetid://125225286754597"
local AMBIENTS_ICON = "rbxassetid://126045313881885"
local MUSIC_ICON = "rbxassetid://135360238783529"
local SOUND_ICON = "rbxassetid://126045313881885"
local TRADE_ICON = "rbxassetid://129162351030527"
local UI_ICON = "rbxassetid://88047742281813"
local PET_ICON = "rbxassetid://102865255751549"
local DESKTOP_PANEL_SIZE = UDim2.fromScale(0.6, 0.6)
local MOBILE_PANEL_SIZE = UDim2.fromScale(0.9, 0.9)
local SETTINGS_Z_INDEX = 200

function Settings(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	local SettingsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.SettingsReducer
	end)

	local isOpen = UIReducer.CurrentUI == FramesConstants.Settings
	local panelSize = if UserInputService.TouchEnabled then MOBILE_PANEL_SIZE else DESKTOP_PANEL_SIZE

	local SettingsItems = {}

	SettingsItems["UI_Volume"] = VolumeSlider({
		Name = "UI",
		Icon = UI_ICON,
		Value = SettingsReducer.UI_Volume,
		OnChange = function(value)
			SoundController:SetGlobalVolume("UI", value)
		end,
		OnToggle = function(enabled)
			if enabled then
				SoundController:SetGlobalVolume("UI", 100)
			else
				SoundController:SetGlobalVolume("UI", 0)
			end
		end,
		hooks = hooks,
		Order = 1,
		ZIndexBase = SETTINGS_Z_INDEX + 3,
	})

	SettingsItems["Music_Volume"] = VolumeSlider({
		Name = "Ambients",
		Icon = AMBIENTS_ICON,
		Value = SettingsReducer.Music_Volume,
		OnChange = function(value)
			SoundController:SetGlobalVolume("MUSIC", value)
		end,
		OnToggle = function(enabled)
			if enabled then
				SoundController:SetGlobalVolume("MUSIC", 100)
			else
				SoundController:SetGlobalVolume("MUSIC", 0)
			end
		end,
		hooks = hooks,
		Order = 1,
		ZIndexBase = SETTINGS_Z_INDEX + 3,
	})

	SettingsItems["Effects_Volume"] = VolumeSlider({
		Name = "Effect & Music",
		Icon = MUSIC_ICON,
		Value = SettingsReducer.MISC_Volume,
		OnChange = function(value)
			SoundController:SetGlobalVolume("MISC", value)
		end,
		OnToggle = function(enabled)
			SoundController:ToggleGlobalVolume("MISC", enabled)
		end,
		hooks = hooks,
		Order = 2,
		ZIndexBase = SETTINGS_Z_INDEX + 3,
	})

	SettingsItems["UI_Volume"] = VolumeSlider({
		Name = "UI",
		Icon = UI_ICON,
		Value = SettingsReducer.UI_Volume,
		OnChange = function(value)
			SoundController:SetGlobalVolume("UI", value)
		end,
		OnToggle = function(enabled)
			if enabled then
				SoundController:SetGlobalVolume("UI", 100)
			else
				SoundController:SetGlobalVolume("UI", 0)
			end
		end,
		hooks = hooks,
		Order = 3,
		ZIndexBase = SETTINGS_Z_INDEX + 3,
	})

	SettingsItems["Pets_Visible"] = Item({
		Name = "Pet Visible",
		Icon = PET_ICON,
		Value = SettingsReducer.Pets_Visible,
		Action = function()
			SettingsController:Toggle("Pets_Visible")
		end,
		hooks = hooks,
		Order = 4,
		ZIndexBase = SETTINGS_Z_INDEX + 3,
	})

	SettingsItems["Trade"] = Item({
		Name = "Trade",
		Icon = TRADE_ICON,
		Value = SettingsReducer.Trade,
		Action = function()
			SettingsController:Toggle("Trade")
		end,
		hooks = hooks,
		Order = 5,
		ZIndexBase = SETTINGS_Z_INDEX + 3,
	})

	return Roact.createElement("Frame", {
		Visible = isOpen,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromHex("000000"),
		ZIndex = SETTINGS_Z_INDEX,
	}, {
		Content = Blue_Background({
			title = "Settings",
			titleIcon = UI.Settings or SETTINGS_ICON,
			size = panelSize,
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1,
			condition = isOpen,
			align = Enum.TextXAlignment.Left,
			zIndex = SETTINGS_Z_INDEX + 1,
			hooks = hooks,
		}, {

			Center = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.564),
				Size = UDim2.fromScale(0.9, 0.803),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = SETTINGS_Z_INDEX + 2,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					Padding = UDim.new(0.03, 0),
				}),

				Roact.createFragment(SettingsItems),
			}),
		}),
	})
end

Settings = RoactHooks.new(Roact)(Settings)
return Settings
