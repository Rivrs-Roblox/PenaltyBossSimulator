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
local UIController = Knit.GetController("UIController")

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Frames
local Frames = script.Parent.Frames
local VolumeSlider = require(Frames.Slider)
local Item = require(Frames.Item)

local SETTINGS_ICON = "rbxassetid://125225286754597"
local CLOSE_ICON = "rbxassetid://120045489184571"
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
		Popup = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.6, 0.6),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BorderSizePixel = 0,
			ZIndex = 2,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),

			UICorner = Roact.createElement("UICorner", {}),

			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("1e314b")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("0a0e27")),
				}),
				Rotation = 90,
			}),

			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 5,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("3369e6")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("1e388d")),
					}),
					Rotation = 90,
				}),
			}),

			Title = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.04, 0.08),
				Size = UDim2.fromScale(0.55, 0.09),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 5,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0.02, 0),
				}),

				Icon = Roact.createElement("ImageLabel", {
					LayoutOrder = 1,
					Size = UDim2.fromScale(1.2, 1.2),
					BackgroundTransparency = 1,
					Image = SETTINGS_ICON,
					ScaleType = Enum.ScaleType.Fit,
					ZIndex = 5,
				}, {
					Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
				}),

				TitleText = Roact.createElement("TextLabel", {
					LayoutOrder = 2,
					Size = UDim2.fromScale(0.8, 1),
					BackgroundTransparency = 1,
					Text = "Settings",
					TextColor3 = Color3.fromHex("fafafa"),
					TextScaled = true,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
					ZIndex = 5,
				}),
			}),

			Close = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.93, 0.08),
				Size = UDim2.fromScale(0.09, 0.09),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				AutoButtonColor = true,
				ZIndex = 5,
				[Roact.Event.MouseButton1Click] = function()
					UIController:HideFrame()
				end,
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("8f0000"),
					Thickness = 3,
				}),
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ff362f")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("8d1414")),
					}),
					Rotation = 90,
				}),
				Icon = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = CLOSE_ICON,
					ScaleType = Enum.ScaleType.Fit,
					ZIndex = 6,
				}),
			}),

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
