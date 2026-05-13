local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

local Helpers = ReplicatedStorage.Shared.Helpers
local FormatDuration = require(Helpers.FormatDuration)

local Components = script.Parent.Parent.Components
local ActionButton = require(Components.ActionButton)
local Title = require(Components.Title)

local Frames = script.Parent.Frames
local WeekFrame = require(Frames.WeekFrame)

local AllRewardsConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.AllRewardsConstants)

local DailyRewardsController = Knit.GetController("DailyRewardsController")
local MonetizationController = Knit.GetController("MonetizationController")
local DataCacheController = Knit.GetController("DataCacheController")

local UI = DataCacheController:GetFile("Images")

local function buildWeeks(rewards)
	local weeks = {}
	local weekIndex = 1

	for day = 1, #rewards do
		weeks[weekIndex] = weeks[weekIndex] or {}
		table.insert(weeks[weekIndex], {
			day = day,
			reward = rewards[day],
		})

		if day % 7 == 0 then
			weekIndex += 1
		end
	end

	return weeks
end

return function(hooks)
	local AllRewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.AllRewardsReducer
	end)

	local DailyRewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.DailyRewardsReducer
	end)

	local weeks = buildWeeks(DailyRewardsReducer.rewards)

	local nextRewardId = DailyRewardsReducer.lastRedeemedId + 1
	local allClaimed = nextRewardId > #DailyRewardsReducer.rewards and #DailyRewardsReducer.rewards > 0
	local cooldownRemaining = math.max(0, 86400 - (os.time() - DailyRewardsReducer.lastRedeemedTimestamp))
	local canClaimNow = (not allClaimed) and cooldownRemaining <= 0
	--local claimButtonText = allClaimed and "Claimed All" or (canClaimNow and "Claim" or FormatDuration(cooldownRemaining))

	local renderedWeeks = {}
	for index, weekData in ipairs(weeks) do
		renderedWeeks["Week_" .. index] = WeekFrame(index, weekData, hooks)
	end

	local skipOnePrice = MonetizationController:GetPrice("Daily Rewards - Skip 1") or "79"
	local skipAllPrice = MonetizationController:GetPrice("Daily Rewards - Skip All") or "799"

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Visible = AllRewardsReducer.AllRewards == AllRewardsConstants.DailyRewards,
		ZIndex = 3,
	}, {
		Title = Title({ text = "Daily Rewards", icon = UI.Rewards }),

		Container = Roact.createElement("ScrollingFrame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticCanvasSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.fromScale(0, 1),
			ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
			Position = UDim2.fromScale(0.51, 0.56),
			ScrollBarImageTransparency = 0.32,
			ScrollBarThickness = 6,
			ScrollingDirection = Enum.ScrollingDirection.X,
			Size = UDim2.fromScale(0.94, 0.66),
			ZIndex = 4,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 0.05),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Roact.createFragment(renderedWeeks),
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

			--Claim = ActionButton({
			--    layoutOrder = 1,
			--    text = claimButtonText,
			--    onClick = function()
			--        if nextRewardId > #DailyRewardsReducer.rewards then
			--          NotificationController:Notify({
			--             text = "All daily rewards have already been claimed!",
			--             type = "ERROR",
			--          })
			--          return
			--      end

			--       if cooldownRemaining > 0 then
			--            NotificationController:Notify({
			--                text = "Next daily reward in " .. FormatDuration(cooldownRemaining),
			--              type = "ERROR",
			--           })
			--          return
			--       end
			--
			--        DailyRewardsController:ClaimReward(nextRewardId)
			--    end,
			--}),

			Skip = ActionButton({
				layoutOrder = 2,
				text = "Skip 1",
				price = "" .. tostring(skipOnePrice),
				onClick = function()
					DailyRewardsController:Skip()
				end,
			}),

			SkipAll = ActionButton({
				layoutOrder = 3,
				text = "Skip All",
				price = "" .. tostring(skipAllPrice),
				color = Color3.fromHex("ff6734"),
				strokeColor = Color3.fromHex("671311"),
				onClick = function()
					DailyRewardsController:BuyAll()
				end,
			}),
		}),
	})
end
