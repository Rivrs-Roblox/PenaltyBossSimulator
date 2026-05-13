local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

local Components = script.Parent.Parent.Components
local ActionButton = require(Components.ActionButton)
local RewardCard = require(Components.RewardCard)
local Title = require(Components.Title)

-- Constants
local AllRewardsConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.AllRewardsConstants)

-- Controllers
local RewardsController = Knit.GetController("RewardsController")
local DataCacheController = Knit.GetController("DataCacheController")

local UI = DataCacheController:GetFile("Images")

local function getCurrentAreaName(areaReducer)
	local areas = areaReducer and areaReducer.Areas
	if typeof(areas) == "table" and table.maxn(areas) > 0 then
		return areas[table.maxn(areas)] or "Zone1"
	end

	return "Zone1"
end

local function getRewardAmount(reward, areaName)
	local areaData = reward.Areas and reward.Areas[areaName]
	if typeof(areaData) == "table" then
		return reward.Amount or areaData[2] or 1
	end

	return 1
end

return function(hooks)
	local AllRewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.AllRewardsReducer
	end)

	local RewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.RewardsReducer
	end)

	local AreaReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.AreaReducer
	end)

	local areaName = getCurrentAreaName(AreaReducer)
	local RewardsCards = {}

	for id, reward in pairs(RewardsReducer.rewards) do
		RewardsCards[id] = Roact.createElement(RewardCard, {
			id = id,
			amount = getRewardAmount(reward, areaName),
			claimed = reward.Claimed,
			currency = reward.Currency,
			image = reward.Image,
			rewardType = reward.Reward,
			name = "",
			time = reward.Time,
			playerTime = RewardsReducer.time,
			rarity = reward.Rarity,
			onClick = function()
				if not reward.Claimed then
					RewardsController:ClaimReward(id)
				end
			end,
		}, hooks)
	end

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Visible = AllRewardsReducer.AllRewards == AllRewardsConstants.TimeRewards,
		ZIndex = 3,
	}, {
		Title = Title({ text = "Time Rewards", icon = UI.Rewards }),

		Container = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.56),
			Size = UDim2.fromScale(1, 0.7),
		}, {
			UIGridLayout = Roact.createElement("UIGridLayout", {
				CellPadding = UDim2.fromScale(0.02, 0.02),
				CellSize = UDim2.fromScale(0.21, 0.26),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Roact.createFragment(RewardsCards),
		}),

		Buttons = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.612, 0.93),
			Size = UDim2.fromScale(0.686, 0.1),
			ZIndex = 5,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0.01, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Reset = ActionButton({
				layoutOrder = 1,
				text = "Reset Gifts",
				onClick = function()
					RewardsController:ResetGifts()
				end,
			}),

			Skip2 = ActionButton({
				layoutOrder = 2,
				text = "Skip 2",
				price = " 79",
				onClick = function()
					RewardsController:SkipTwo()
				end,
			}),

			BuyAll = ActionButton({
				layoutOrder = 3,
				text = "Buy All",
				price = " 799",
				color = Color3.fromHex("ff6734"),
				strokeColor = Color3.fromHex("671311"),
				onClick = function()
					RewardsController:BuyAll()
				end,
			}),
		}),
	})
end
