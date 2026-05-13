--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Frames
local Frames = script.Parent
local Reward = require(Frames.Reward)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

-- Rewards
return function(hooks)
	local rewards = {}

	for id, reward in pairs(Template.Friends.Rewards) do
		rewards[id] = Reward({
			title = reward.Title,
			icon = UI[reward.Icon],
			price = reward.Price,
			order = id,
			hooks = hooks,
		})
	end

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.344),
		LayoutOrder = 1,
		Size = UDim2.fromScale(0.95, 0.351),
		ZIndex = 3,
	}, {
		List = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Roact.createFragment(rewards),
	})
end
