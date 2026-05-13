local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Roact = require(ReplicatedStorage.Packages.roact)

local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local AllRewardsActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.AllRewardsActions)

local DAILY_REWARD_COOLDOWN = 86400

local CONFIG = {
	TimeRewards = { text = "Time Rewards", icon = "rbxassetid://72857982925608" },
	DailyRewards = { text = "Daily Rewards", icon = "rbxassetid://72857982925608" },
	SpinWheels = { text = "Spin Wheels", icon = "rbxassetid://72857982925608" },
}

local function hasClaimableTimeReward(rewardsReducer)
	if typeof(rewardsReducer) ~= "table" or typeof(rewardsReducer.rewards) ~= "table" then
		return false
	end

	local playerTime = rewardsReducer.time or 0

	for _, reward in pairs(rewardsReducer.rewards) do
		if typeof(reward) == "table" then
			local requiredTime = tonumber(reward.Time) or math.huge

			if reward.Claimed ~= true and playerTime >= requiredTime then
				return true
			end
		end
	end

	return false
end

local function hasClaimableDailyReward(dailyRewardsReducer, now)
	if typeof(dailyRewardsReducer) ~= "table" or typeof(dailyRewardsReducer.rewards) ~= "table" then
		return false
	end

	local rewards = dailyRewardsReducer.rewards
	local rewardsCount = #rewards

	if rewardsCount <= 0 then
		return false
	end

	local lastRedeemedId = dailyRewardsReducer.lastRedeemedId or 0
	local nextRewardId = lastRedeemedId + 1

	if nextRewardId > rewardsCount then
		return false
	end

	local nextReward = rewards[nextRewardId]
	if typeof(nextReward) == "table" and nextReward.Claimed == true then
		return false
	end

	local lastRedeemedTimestamp = dailyRewardsReducer.lastRedeemedTimestamp or 0
	local cooldownRemaining = math.max(0, DAILY_REWARD_COOLDOWN - (now - lastRedeemedTimestamp))

	return cooldownRemaining <= 0
end

local function hasAvailableSpin(spinsReducer)
	if typeof(spinsReducer) ~= "table" or typeof(spinsReducer.Spins) ~= "table" then
		return false
	end

	local spins = spinsReducer.Spins
	return (spins.Free or 0) > 0 or (spins.Premium or 0) > 0
end

local function shouldShowNotification(name, rewardsReducer, dailyRewardsReducer, spinsReducer, now)
	if name == "TimeRewards" then
		return hasClaimableTimeReward(rewardsReducer)
	elseif name == "DailyRewards" then
		return hasClaimableDailyReward(dailyRewardsReducer, now)
	elseif name == "SpinWheels" then
		return hasAvailableSpin(spinsReducer)
	end

	return false
end

return function(params)
	local hooks = params.hooks

	local AllRewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.AllRewardsReducer
	end)

	local RewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.RewardsReducer
	end)

	local DailyRewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.DailyRewardsReducer
	end)

	local SpinsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.SpinsReducer
	end)

	local now, setNow = hooks.useState(os.time())

	hooks.useEffect(function()
		local running = true

		task.spawn(function()
			while running do
				setNow(os.time())
				task.wait(1)
			end
		end)

		return function()
			running = false
		end
	end, {})

	local name = params.name or "TimeRewards"
	local config = CONFIG[name] or CONFIG.TimeRewards
	local active = AllRewardsReducer.AllRewards == name
	local showNotification = shouldShowNotification(name, RewardsReducer, DailyRewardsReducer, SpinsReducer, now)

	return Roact.createElement("ImageButton", {
		LayoutOrder = params.layoutOrder or 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = active and Color3.fromHex("ff6734") or Color3.fromHex("3b65a3"),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.325, 1),
		BackgroundTransparency = 0,
		ZIndex = 2,

		[Roact.Event.MouseButton1Click] = function()
			Store:dispatch(AllRewardsActions.setAllRewards(params.name))
		end,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = config.icon,
			Position = UDim2.fromScale(0.19, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.22, 0.72),
			ZIndex = 3,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint"),
		}),

		ButtonText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.6, 0.5),
			Size = UDim2.fromScale(0.72, 0.58),
			Text = config.text,
			TextColor3 = Color3.fromHex("fafafa"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 4,
		}),

		Notification = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.97, 0.1),
			ZIndex = 4,
			BackgroundColor3 = Color3.fromHex("ff0000"),
			Size = UDim2.fromScale(0.5, 0.5),
			Visible = showNotification,
		}, {
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = 3,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 5,
				Image = "rbxassetid://125311831710765",
				Size = UDim2.fromScale(0.8, 0.8),
			}),

			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),

			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),

			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 2,
			}),
		}),
	})
end