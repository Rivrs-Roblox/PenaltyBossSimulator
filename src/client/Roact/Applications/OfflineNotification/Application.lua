--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)
local Text = require(Components.Text)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- UI
local UI = DataCacheController:GetFile("Images")

-- OfflineNotification
function OfflineNotification(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Content = Blue_Background({
			title = "Offline Farm",
			size = UDim2.fromScale(0.5, 0.5),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.7,
			condition = UIReducer.CurrentUI == FramesConstants.OfflineNotification,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {
			Container = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.52),
				Size = UDim2.fromScale(0.95, 0.87),
				BackgroundTransparency = 1,
			}, {
				Text = Text({
					text = "⚽ Your character will train while offline! (up to 24h)",
					backgroundTransparency = 1,
					color = Color3.fromRGB(4, 175, 236),
					position = UDim2.fromScale(0.5, 0.5),
					size = UDim2.fromScale(0.83, 0.597),
					stroke = 2,
				}),
			}),
		}),
	})
end

OfflineNotification = RoactHooks.new(Roact)(OfflineNotification)
return OfflineNotification
