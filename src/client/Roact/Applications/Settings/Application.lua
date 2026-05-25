--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

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

local SETTINGS_ICON = "rbxassetid://125225286754597"
local SOUND_ICON = "rbxassetid://126045313881885"
local TRADE_ICON = "rbxassetid://129162351030527"

function Settings(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	local SettingsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.SettingsReducer
	end)

	local isOpen = UIReducer.CurrentUI == FramesConstants.Settings

	local SettingsItems = {}

	SettingsItems["UI_Volume"] = VolumeSlider({
		Name = "UI",
		Icon = SOUND_ICON,
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
	})

	SettingsItems["Music_Volume"] = VolumeSlider({
		Name = "Ambients",
		Icon = SOUND_ICON,
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
		Order = 2,
	})

	SettingsItems["Effects_Volume"] = VolumeSlider({
		Name = "Effect & Music",
		Icon = SOUND_ICON,
		Value = SettingsReducer.MISC_Volume,
		OnChange = function(value)
			SoundController:SetGlobalVolume("MISC", value)
		end,
		OnToggle = function(enabled)
			SoundController:ToggleGlobalVolume("MISC", enabled)
		end,
		hooks = hooks,
		Order = 3,
	})

	SettingsItems["Trade"] = Item({
		Name = "Trade",
		Icon = TRADE_ICON,
		Value = SettingsReducer.Trade,
		Action = function()
			SettingsController:Toggle("Trade")
		end,
		hooks = hooks,
		Order = 4,
	})

	return Roact.createElement("Frame", {
		Visible = isOpen,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromHex("000000"),
		ZIndex = 2,
	}, {
		Content = Blue_Background({
			title = "Settings",
			titleIcon = SETTINGS_ICON,
			size = UDim2.fromScale(0.6, 0.6),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1,
			condition = isOpen,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {

			Center = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.564),
				Size = UDim2.fromScale(0.9, 0.803),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 3,
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
