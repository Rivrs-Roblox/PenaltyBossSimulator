--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")
local Template = DataCacheController:GetFile("Template")

-- Frames
local Buttons = require(script.Parent.Buttons)
local Gifts = require(script.Parent.Gifts)
local Gamepasses = require(script.Parent.Gamepasses)
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)
local CTA = require(script.Parent.CTAbutton)
local AutoWin = require(script.Parent.AutoWin)
local AutoTrain = require(script.Parent.AutoTrain)
local Click = require(script.Parent.Click)
local ExclusivePack = require(script.Parent.ExclusivePack)
local Christmas = require(script.Parent.Christmas)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- RightFrame
function RightFrame(_, hooks)
	local function IsPlayerOnMobile()
		return UserInputService.TouchEnabled
	end
	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	local StarterPacks = Template.Shop.StarterPacks
	local StarterPacksReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.StarterPacksReducer
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = if IsPlayerOnMobile() then UDim2.fromScale(0.9, 0.4) else UDim2.fromScale(0.915, 0.5),
		Size = if IsPlayerOnMobile() then UDim2.fromScale(0.2, 0.34) else UDim2.fromScale(0.148, 0.272),
		ZIndex = 1,
	}, {

		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),
		StarterPack = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.6, -0.35),
			Size = UDim2.fromScale(0.9, 0.9),
			BackgroundTransparency = 1,
		}, {
			UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
			StarterPack = Roact.createElement(CTA, {
				upperText = "LIMITED!",
				bottomText = "",
				image = StarterPacks[StarterPacksReducer.BoughtStarterPacks].ShopIcon,
				frame = FramesConstants.Store,
				link = function()
					Sound:PlaySound("UI_Open")
					UIController:ShowFrame({ frame = "StarterPack" })
				end,
				size = styles.sizeAlpha:map(function(sizeAlpha)
					return Vector2.fromScale(sizeAlpha * 0.9, sizeAlpha * 0.9)
				end),
				position = Vector2.new(0.1, 0),
			}),
		}),
		Main = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),

			Gifts = Roact.createElement(Gifts),
			Gamepasses = Roact.createElement(Gamepasses),
			Buttons = Roact.createElement(Buttons),
			AutoWin = Roact.createElement(AutoWin),
			AutoTrain = Roact.createElement(AutoTrain),
			Click = Roact.createElement(Click),
			ExclusivePack = Roact.createElement(ExclusivePack),
			-- Christmas = Roact.createElement(Christmas),
		}),
	})
end

RightFrame = RoactHooks.new(Roact)(RightFrame)
return RightFrame
