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
	local rarity = params.rarity

	local gradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("4aa9fc")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("3370fc")),
	})

	local strokeColor = Color3.fromHex("2ad1ff")

	local showOPText = false

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
		showOPText = true
	end

	local buttonText = FormatDuration(math.max(0, rewardTime - playerTime))
	if isClaimable then
		buttonText = "CLAIM"
	elseif isClaimed then
		buttonText = "CLAIMED"
	end

	local textColor = Color3.fromHex("ffffff")
	if isClaimable then
		textColor = Color3.fromHex("62ff00")
	elseif isClaimed then
		textColor = Color3.fromHex("000000")
	end

	local amountText = "x1"
	if typeof(params.amount) == "number" then
		amountText = "x" .. FormatNumber(params.amount)
	elseif params.amount ~= nil then
		amountText = "x" .. tostring(params.amount)
	end

	local iconImage = params.icon or UI[params.image] or "rbxassetid://96612943456507"
	local onClick = params.onClick
		or function()
			if not isClaimed then
				RewardsController:ClaimReward(params.id)
			end
		end

	return Roact.createElement("ImageButton", {
		LayoutOrder = params.layoutOrder or params.id or 1,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = Size(styles, { X = 1, Y = 1 }),
		ZIndex = 2,
		[Roact.Event.MouseButton1Click] = onClick,
		[Roact.Event.MouseEnter] = function()
			api.start({ sizeAlpha = 1.05, config = { mass = 1, tension = 1000, friction = 50 } })
		end,
		[Roact.Event.MouseLeave] = function()
			api.start({ sizeAlpha = 1, config = { mass = 1, tension = 1000, friction = 50 } })
		end,
	}, {
		UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Ratio = Roact.createElement("UIAspectRatioConstraint", { AspectRatio = params.ratio or 2 }),
		UIGradient = Roact.createElement("UIGradient", {
			Color = gradient,
			Rotation = 90,
		}),
		UIStroke = Roact.createElement("UIStroke", { Color = strokeColor, Thickness = 2 }),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = iconImage,
			Position = UDim2.fromScale(0.255, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.8, 0.8),
			ZIndex = 2,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint"),
		}),

		OPText = Roact.createElement(
			"TextLabel",
			{
				TextWrapped = true,
				TextColor3 = Color3.fromHex("ffffff"),
				Text = "OP!",
				TextSize = 14,
				Rotation = -15,
				Font = 100,
				FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.088, 0.193),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Visible = rarity == "OP",
				ZIndex = 10,
				TextScaled = true,
				Size = UDim2.fromScale(0.35, 0.35),
			},
			{
				Gradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ff5a5a")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("ffd500")),
					}),
					Rotation = -90,
				}),
				UIStroke = Roact.createElement(
					"UIStroke",
					{
						Color = Color3.fromHex("ffffff"),
						Thickness = 2,
					},
					{
						Gradient = Roact.createElement("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromHex("ff0000")),
								ColorSequenceKeypoint.new(1, Color3.fromHex("000000")),
							}),
							Rotation = 90,
						}),
					}
				),
			}
		),

		AmountText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.96, 0.513),
			Size = UDim2.fromScale(0.5, 0.26),
			Text = amountText,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 10,
		}, {}),

		TimeText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.96, 0.784),
			Size = UDim2.fromScale(0.53, 0.26),
			Text = buttonText,
			TextColor3 = textColor,
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 10,
		}, {}),

		Status = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = isClaimed and Color3.fromHex("00cc44") or Color3.fromHex("ff0000"),
			Position = UDim2.fromScale(0.9, 0.1),
			Size = UDim2.fromScale(0.3, 0.46),
			Visible = isClaimable or isClaimed,
			ZIndex = 15,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint"),
			Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = isClaimed and "rbxassetid://70882944948413" or "rbxassetid://113219014430159",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ScaleType = 3,
				Size = UDim2.fromScale(0.8, 0.8),
				ZIndex = 17,
			}),
			UIStroke = Roact.createElement(
				"UIStroke",
				{ Color = isClaimed and Color3.fromHex("0b5500") or Color3.fromHex("ffffff"), Thickness = 2.5 }
			),
		}),
	})
end

RewardCard = RoactHooks.new(Roact)(RewardCard)

return RewardCard
