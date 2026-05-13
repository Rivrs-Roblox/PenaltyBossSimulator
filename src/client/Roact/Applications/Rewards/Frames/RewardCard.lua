--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback

    Visual updated to follow TimeRewardsVisual raw Roact.
    Claiming logic stays connected to RewardsController.
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatDuration = require(Helpers.FormatDuration)
local FormatNumber = require(Helpers.Numbers.FormatNumber)
local Size = require(Helpers.Size)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local RewardsController = Knit.GetController("RewardsController")

-- UI
local UI = DataCacheController:GetFile("Images")

local function getVisualStyle(params)
	local rarity = params.rarity

	if rarity == nil then
		if params.rewardType == "Pets" or params.rewardType == "Boost" then
			rarity = "OP"
		elseif params.rewardType == "Egg" or params.rewardType == "Fruit" then
			rarity = "Rare"
		end
	end

	local gradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("4aa9fc")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("3370fc")),
	})
	local strokeColor = Color3.fromHex("2ad1ff")

	if rarity == "Rare" then
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("ad5ffc")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("af0092")),
		})
		strokeColor = Color3.fromHex("ff77ff")
	elseif rarity == "OP" then
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("fcb539")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("d52c16")),
		})
		strokeColor = Color3.fromHex("ffa425")
	end

	return gradient, strokeColor, rarity
end

local function getAmountText(amount)
	if typeof(amount) == "number" then
		return "x" .. FormatNumber(amount)
	end

	if amount ~= nil then
		return "x1 " .. tostring(amount)
	end

	return "x1"
end

-- RewardsCard
local function RewardCard(params: table, hooks)
	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	local playerTime = params.playerTime or 0
	local rewardTime = params.time or 0
	local isClaimed = params.claimed == true
	local isClaimable = (not isClaimed) and playerTime >= rewardTime

	local buttonText = FormatDuration(math.max(0, rewardTime - playerTime))
	if isClaimable then
		buttonText = "CLAIM"
	elseif isClaimed then
		buttonText = "CLAIMED"
	end

	local buttonColor = Color3.fromHex("ffffff")
	if isClaimable then
		buttonColor = Color3.fromHex("62ff00")
	elseif isClaimed then
		buttonColor = Color3.fromHex("000000")
	end

	local gradient, strokeColor, rarity = getVisualStyle(params)
	local iconImage = UI[params.image] or "rbxassetid://96612943456507"
	local amountText = getAmountText(params.amount)

	return Roact.createElement("ImageButton", {
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		LayoutOrder = params.id,
		Size = Size(styles, { X = 1, Y = 1 }),
		ZIndex = 8,
		[Roact.Event.MouseButton1Click] = function()
			if not isClaimed then
				RewardsController:ClaimReward(params.id)
			end
		end,
		[Roact.Event.MouseEnter] = function()
			api.start({ sizeAlpha = 1.05, config = { mass = 1, tension = 1000, friction = 50 } })
		end,
		[Roact.Event.MouseLeave] = function()
			api.start({ sizeAlpha = 1, config = { mass = 1, tension = 1000, friction = 50 } })
		end,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.8,
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = gradient,
			Rotation = 90,
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = strokeColor,
			Thickness = 2,
		}),

		Sparkle = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "rbxassetid://106466414055348",
			Position = UDim2.fromScale(0.255, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1.2, 1.2),
			Visible = rarity == "OP" and not isClaimed,
			ZIndex = 9,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint"),
		}),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = iconImage,
			Position = UDim2.fromScale(0.255, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.8, 0.8),
			ZIndex = 10,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint"),
		}),

		OPText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.088, 0.193),
			Rotation = -15,
			Size = UDim2.fromScale(0.35, 0.35),
			Text = "OP!",
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			Visible = rarity == "OP",
			ZIndex = 15,
		}, {
			Gradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ff5a5a")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("ffd500")),
				}),
				Rotation = -90,
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 2,
			}, {
				Gradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ff0000")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("000000")),
					}),
					Rotation = 90,
				}),
			}),
		}),

		AmountText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.96, 0.513),
			Size = UDim2.fromScale(0.5, 0.26),
			Text = amountText,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 15,
		}),

		TimeText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.96, 0.784),
			Size = UDim2.fromScale(0.53, 0.26),
			Text = buttonText,
			TextColor3 = buttonColor,
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 15,
		}),

		Claimable = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ff1d1d"),
			Position = UDim2.fromScale(0.91, 0.17),
			Size = UDim2.fromScale(0.45, 0.45),
			Visible = isClaimable,
			ZIndex = 17,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 2,
			}),
			AspectRatio = Roact.createElement("UIAspectRatioConstraint"),
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://113219014430159",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.8, 0.8),
				ZIndex = 18,
			}),
		}),

		Claimed = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("47af2a"),
			Position = UDim2.fromScale(0.91, 0.17),
			Size = UDim2.fromScale(0.45, 0.45),
			Visible = isClaimed,
			ZIndex = 19,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("0b5500"),
				Thickness = 2,
			}),
			AspectRatio = Roact.createElement("UIAspectRatioConstraint"),
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://70882944948413",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.8, 0.8),
				ZIndex = 20,
			}),
		}),
	})
end

RewardCard = RoactHooks.new(Roact)(RewardCard)

return RewardCard
