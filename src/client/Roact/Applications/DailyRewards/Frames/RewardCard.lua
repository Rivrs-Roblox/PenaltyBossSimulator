local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

local Helpers = ReplicatedStorage.Shared.Helpers
local FormatDuration = require(Helpers.FormatDuration)

local DailyRewardsController = Knit.GetController("DailyRewardsController")
local NotificationController = Knit.GetController("NotificationController")
local DataCacheController = Knit.GetController("DataCacheController")

local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")

local HOVER_SCALE = 1.05
local CLICK_SCALE = 0.95
local TWEEN_DURATION = 0.15
local TWEEN_INFO = TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local DAY_THEME = {
	[1] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("4aa9fc")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("3370fc")),
		}),
		stroke = Color3.fromHex("2ad1ff"),
		text = Color3.fromHex("00e5ff"),
		textStroke = Color3.fromHex("0a2f6b"),
		aspect = 0.95,
		showEffect = false,
	},

	[2] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("52fc6e")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("299f37")),
		}),
		stroke = Color3.fromHex("7bff23"),
		text = Color3.fromHex("72ff52"),
		textStroke = Color3.fromHex("0c4b1c"),
		aspect = 0.95,
		showEffect = true,
		effectColor = Color3.fromHex("a8ff8a"),
	},

	[3] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("4aa9fc")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("3370fc")),
		}),
		stroke = Color3.fromHex("2ad1ff"),
		text = Color3.fromHex("00e5ff"),
		textStroke = Color3.fromHex("0a2f6b"),
		aspect = 0.95,
		showEffect = false,
	},

	[4] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("4aa9fc")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("3370fc")),
		}),
		stroke = Color3.fromHex("2ad1ff"),
		text = Color3.fromHex("00e5ff"),
		textStroke = Color3.fromHex("0a2f6b"),
		aspect = 0.95,
		showEffect = false,
	},

	[5] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("4aa9fc")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("3370fc")),
		}),
		stroke = Color3.fromHex("2ad1ff"),
		text = Color3.fromHex("00e5ff"),
		textStroke = Color3.fromHex("0a2f6b"),
		aspect = 0.95,
		showEffect = false,
	},

	[6] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("cc53fc")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("5923ab")),
		}),
		stroke = Color3.fromHex("ff69aa"),
		text = Color3.fromHex("e28aff"),
		textStroke = Color3.fromHex("430c4a"),
		aspect = 0.95,
		showEffect = true,
		effectColor = Color3.fromHex("f3a0ff"),
	},

	[7] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("fcd706")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("ff2f13")),
		}),
		stroke = Color3.fromHex("ffffff"),
		text = Color3.fromHex("fcd706"),
		textStroke = Color3.fromHex("752100"),
		aspect = 0.63,
		showEffect = true,
		effectColor = Color3.fromHex("fff07a"),
	},
}

local function scaleUDim2(udim2, scale)
	return UDim2.new(udim2.X.Scale * scale, udim2.X.Offset * scale, udim2.Y.Scale * scale, udim2.Y.Offset * scale)
end

local function formatRewardName(name)
	name = tostring(name or "Reward")

	local economy = Template and Template.Economy or {}
	local money1 = economy.Money1 or "Money1"
	local money2 = economy.Money2 or "Money2"

	return name:gsub("MONEY_1", money1):gsub("MONEY_2", money2)
end

return function(params, hooks)
	params = params or {}

	local weekDay = params.weekDay or (((params.id or 1) - 1) % 7) + 1
	local theme = DAY_THEME[weekDay] or DAY_THEME[1]
	local size = params.size or (weekDay == 7 and UDim2.fromScale(0.28, 1.2) or UDim2.fromScale(0.3, 0.65))

	local DailyRewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.DailyRewardsReducer
	end) or {}

	local _ = RoduxHooks.useSelector(hooks, function(state)
		return state.RewardsReducer
	end)

	local buttonRef = Roact.createRef()

	local lastRedeemedId = DailyRewardsReducer.lastRedeemedId or 0
	local lastRedeemedTimestamp = DailyRewardsReducer.lastRedeemedTimestamp or 0

	local nextRewardId = lastRedeemedId + 1
	local cooldownRemaining = math.max(0, 86400 - (os.time() - lastRedeemedTimestamp))

	local isNextReward = not params.claimed and params.id == nextRewardId
	local canBeClaimed = isNextReward and cooldownRemaining <= 0
	local showCountdown = isNextReward and cooldownRemaining > 0

	local iconImage = (UI and params.image and UI[params.image]) or "rbxassetid://96612943456507"

	local function animateTo(targetSize, tweenInfo)
		local button = buttonRef:getValue()

		if button then
			TweenService:Create(button, tweenInfo or TWEEN_INFO, {
				Size = targetSize,
			}):Play()
		end
	end

	local function animateHover()
		animateTo(scaleUDim2(size, HOVER_SCALE))
	end

	local function animateNormal()
		animateTo(size)
	end

	local function animateClick()
		animateTo(
			scaleUDim2(size, CLICK_SCALE),
			TweenInfo.new(TWEEN_DURATION / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		)
	end

	return Roact.createElement("ImageButton", {
		LayoutOrder = params.id,
		BackgroundColor3 = Color3.fromHex("fcfaff"),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ImageTransparency = 1,
		Interactable = not params.claimed,
		Size = size,
		ZIndex = 2,

		[Roact.Ref] = buttonRef,

		[Roact.Event.MouseEnter] = animateHover,
		[Roact.Event.MouseLeave] = animateNormal,
		[Roact.Event.MouseButton1Down] = animateClick,
		[Roact.Event.MouseButton1Up] = animateHover,

		[Roact.Event.MouseButton1Click] = function()
			if params.claimed then
				return
			end

			if params.id == nextRewardId and cooldownRemaining <= 0 then
				DailyRewardsController:ClaimReward(params.id)
			elseif params.id ~= nextRewardId then
				NotificationController:Notify({
					text = "You need to claim the previous rewards first!",
					type = "ERROR",
				})
			else
				NotificationController:Notify({
					text = "Next daily reward in " .. FormatDuration(cooldownRemaining),
					type = "ERROR",
				})
			end

			animateHover()
		end,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		Ratio = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = theme.aspect,
		}),

		UIGradient = Roact.createElement("UIGradient", {
			Color = theme.gradient,
			Rotation = 90,
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = theme.stroke,
			Thickness = weekDay == 7 and 3 or 2,
		}, {
			Gradient = weekDay == 7 and Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ff2f13")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("fcd706")),
				}),
				Rotation = 90,
			}) or nil,
		}),

		DayText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 0.02),
			Size = UDim2.fromScale(0.85, 0.18),
			Text = "Day " .. tostring(params.id or weekDay),
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 12,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = theme.textStroke,
				Thickness = weekDay == 7 and 2.5 or 2,
			}),
		}),

		Effect = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://106335669168445",
			BackgroundTransparency = 1,
			ImageTransparency = 0.1,
			ImageColor3 = theme.effectColor or Color3.fromHex("ffffff"),
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 2,
			Visible = theme.showEffect == true,
			Size = weekDay == 7 and UDim2.fromScale(1.2, 1.3) or UDim2.fromScale(1.2, 1.2),
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),

		Sparkle = Roact.createElement("ImageLabel", {
			Visible = theme.showEffect == true,
			ScaleType = 3,
			BorderColor3 = Color3.fromHex("000000"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://106466414055348",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 3,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1.1, 1.1),
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),

		IconMask = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Position = UDim2.fromScale(0.5, 0.50),
			Size = UDim2.fromScale(0.78, 0.95),
			ZIndex = 3,
		}, {
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = iconImage,
				Position = UDim2.fromScale(0.5, weekDay == 7 and 0.46 or 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = params.reward == "Pets" and UDim2.fromScale(0.95, 0.95)
					or (weekDay == 7 and UDim2.fromScale(1, 1) or UDim2.fromScale(0.82, 0.82)),
				ZIndex = 3,
			}),
		}),

		AmountText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 0.97),
			Size = UDim2.fromScale(0.85, weekDay == 7 and 0.20 or 0.18),
			Text = formatRewardName(params.name),
			TextColor3 = theme.text,
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 4,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = theme.textStroke,
				Thickness = weekDay == 7 and 2.5 or 2,
			}),
		}),

		Status = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ff0000"),
			Position = UDim2.fromScale(0.95, 0.05),
			Size = UDim2.fromScale(0.22, weekDay == 7 and 0.18 or 0.20),
			Visible = canBeClaimed,
			ZIndex = 15,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 2,
			}),

			AspectRatio = Roact.createElement("UIAspectRatioConstraint", {}),

			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),

			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://113219014430159",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ScaleType = 3,
				ZIndex = 16,
				Size = UDim2.fromScale(0.8, 0.8),
			}),
		}),

		Countdown = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.80, 0.18),
			Text = FormatDuration(cooldownRemaining),
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			Visible = showCountdown,
			ZIndex = 9,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = theme.textStroke,
				Thickness = 2,
			}),
		}),

		CanBeClaimed = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.35),
			Text = "Claim",
			TextColor3 = Color3.fromHex("68ff68"),
			TextScaled = true,
			TextWrapped = true,
			Visible = canBeClaimed,
			ZIndex = 9,
		}, {}),

		ClaimedOverlay = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.335,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Visible = params.claimed,
			ZIndex = 10,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(weekDay == 7 and 0.042 or 0.06, 0),
			}),

			Text = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.875, 0.375),
				Text = "Claimed!",
				TextColor3 = Color3.fromHex("ffffff"),
				TextScaled = true,
				TextWrapped = true,
				ZIndex = 11,
			}, {}),
		}),
	})
end
