-- AllRewards/Frames/SpinWheels/SpinWheels.lua
-- Container SpinWheels untuk AllRewards. Logic visibilitas mengikuti reducer AllRewards.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Roact = require(ReplicatedStorage.Packages.roact)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Components = script.Parent.Parent.Components
local Title = require(Components.Title)
local Wheel = require(script.Parent.Wheel)

local AllRewardsConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.AllRewardsConstants)

local DataCacheController = Knit.GetController("DataCacheController")

local UI = DataCacheController:GetFile("Images")

return function(hooks)
	local AllRewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.AllRewardsReducer
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5,0.5),
		Size = UDim2.fromScale(0.95,0.815),
		ZIndex = 3,
	}, {
		Title = Title({ text = "Spin Wheels", icon = UI.Rewards }),

		Container = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.98),
			Size = UDim2.fromScale(0.95, 0.705),
			ZIndex = 4,
		}, {
			List = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.02, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Free = Roact.createElement(Wheel, {
				layoutOrder = 1,
				type = "Free",
				hooks = hooks,
			}),

			Premium = Roact.createElement(Wheel, {
				layoutOrder = 2,
				type = "Premium",
				hooks = hooks,
			}),
		}),
	})
end
