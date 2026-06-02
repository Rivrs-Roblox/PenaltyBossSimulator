--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local UIButton = require(Components.UIButton)
local Text = require(Components.Text)
local Click = require(script.Parent.RightFrames.Click)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Services
local MonetizationService = Knit.GetService("MonetizationService")

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local NotificationController = Knit.GetController("NotificationController")
local UIController = Knit.GetController("UIController")

local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")

local function hasClaimableTimeReward(rewardsReducer)
	if typeof(rewardsReducer) ~= "table" or typeof(rewardsReducer.rewards) ~= "table" then
		return 0
	end

	local playerTime = rewardsReducer.time or 0

	for _, reward in pairs(rewardsReducer.rewards) do
		if typeof(reward) == "table" then
			local requiredTime = tonumber(reward.Time) or math.huge

			if reward.Claimed ~= true and playerTime >= requiredTime then
				return 1
			end
		end
	end

	return 0
end

local function promptGamepass(productName: string)
	MonetizationService:PromptPurchase(productName, "GamePasses"):andThen(function(result)
		if result ~= nil and result.type == "ERROR" then
			NotificationController:Notify(result)
		end
	end)
end

local function GamepassButton(props, hooks)
	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			scale = 1,
			rotation = 0,
		}
	end)

	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderColor3 = Color3.fromHex("000000"),
		BorderSizePixel = 0,
		LayoutOrder = props.order,
		Size = UDim2.fromScale(1, 1),

		[Roact.Event.MouseEnter] = function()
			api.start({
				scale = 1.1,
				rotation = props.hoverRotation or 35,
				config = { mass = 1, tension = 1000, friction = 50 },
			})
		end,

		[Roact.Event.MouseLeave] = function()
			api.start({
				scale = 1,
				rotation = 0,
				config = { mass = 1, tension = 1000, friction = 50 },
			})
		end,

		[Roact.Event.MouseButton1Down] = function()
			api.start({ scale = 0.8 })
		end,

		[Roact.Event.MouseButton1Up] = function()
			api.start({
				scale = 1,
				config = { mass = 1, tension = 1000, friction = 50 },
			})

			Sound:PlaySound("UI_Open")
		end,

		[Roact.Event.MouseButton1Click] = function()
			promptGamepass(props.productName)
		end,
	}, {
		Ratio = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),
		UIScale = Roact.createElement("UIScale", {
			Scale = styles.scale,
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("ffc800")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("8f0000")),
			}),
			Rotation = 90,
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("ffd900"),
			Thickness = 2,
		}),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Image = props.icon,
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = styles.rotation,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.85, 0.85),
			ZIndex = 2,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),

		ValueText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold),
			Position = UDim2.fromScale(0.95, 0.95),
			Size = UDim2.fromScale(0.45, 0.4),
			Text = props.valueText or "",
			TextColor3 = Color3.fromHex("ffea00"),
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			Visible = props.valueText ~= nil,
			ZIndex = 3,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Thickness = 2,
			}),
		}),
	})
end

GamepassButton = RoactHooks.new(Roact)(GamepassButton)

-- LeftFrame
function RightFrame(_, hooks)
	local NotificationReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.NotificationReducer
	end)

	local SpinsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.SpinsReducer
	end)

	local RewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.RewardsReducer
	end)

	local DailyRewardsNotif = 0
	if typeof(NotificationReducer) == "table" and typeof(NotificationReducer.Notifications) == "table" then
		DailyRewardsNotif = NotificationReducer.Notifications["DailyRewards"] or 0
	end

	local SpinsNotif = 0
	if typeof(SpinsReducer) == "table" and typeof(SpinsReducer.Spins) == "table" then
		SpinsNotif = (SpinsReducer.Spins.Free or 0) + (SpinsReducer.Spins.Premium or 0)
	end

	local RewardsNotif = hasClaimableTimeReward(RewardsReducer)

	local StarterPacks = Template.Shop.StarterPacks
	local StarterPacksReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.StarterPacksReducer
	end)

	local currentPack = StarterPacks[StarterPacksReducer.BoughtStarterPacks] or StarterPacks[0]

	local starterStyles, starterApi = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
			rotation = 0,
		}
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(0.99, 0.42),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.134, 0.2),
	}, {
		StarterPack = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.55, -0.5),
			Size = UDim2.fromScale(0.8, 0.8),

			[Roact.Event.MouseButton1Click] = function()
				UIController:ShowFrame({ frame = "StarterPack" })
			end,

			[Roact.Event.MouseEnter] = function()
				starterApi.start({
					sizeAlpha = 1.1,
					rotation = 35,
					config = { mass = 1, tension = 1000, friction = 50 },
				})
			end,

			[Roact.Event.MouseLeave] = function()
				starterApi.start({ sizeAlpha = 1, rotation = 0, config = { mass = 1, tension = 1000, friction = 50 } })
			end,

			[Roact.Event.MouseButton1Down] = function()
				starterApi.start({ sizeAlpha = 0.8 })
			end,

			[Roact.Event.MouseButton1Up] = function()
				starterApi.start({ sizeAlpha = 1 })

				Sound:PlaySound("UI_Open")
			end,
		}, {

			Ratio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.9,
			}),

			ButtonText = Text({
				text = `{currentPack.Name}!`,
				color = Color3.fromHex("fafafa"),
				anchorPoint = Vector2.new(0.5, 1),
				position = UDim2.fromScale(0.5, 0.98),
				index = 5,
				size = UDim2.fromScale(1.3, 0.35),
				stroke = 1.5,
			}),

			Effect = Roact.createElement("ImageLabel", {
				ImageColor3 = Color3.fromHex("ff5e00"),
				Image = "rbxassetid://106335669168445",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1.5, 1.5),
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),

			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 2,
				Image = currentPack.ShopIcon,
				Rotation = starterStyles.rotation,
				Size = UDim2.fromScale(1, 1),
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),

			LimitedText = Text({
				text = "LIMITED!",
				color = Color3.fromHex("fac800"),
				anchorPoint = Vector2.new(0.5, 1),
				position = UDim2.fromScale(0.65, 0.15),
				index = 5,
				size = UDim2.fromScale(1, 0.183),
				rotation = 20,
				stroke = 1.5,
				strokeColor = Color3.fromHex("ff1111"),
			}),
		}),

		Click = Roact.createElement(Click),

		Gamepasses = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.fromScale(0.877, 0.382),
			Position = UDim2.fromScale(1, 1.7),
		}, {
			Grid = Roact.createElement("UIGridLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				CellSize = UDim2.fromScale(0.3, 1),
				CellPadding = UDim2.fromScale(0.05, 0.1),
			}),

			Pass1 = Roact.createElement(GamepassButton, {
				order = 1,
				icon = UI.VIP,
				productName = "VIP",
				hoverRotation = 15,
				valueText = "VIP",
			}),

			Pass2 = Roact.createElement(GamepassButton, {
				order = 2,
				icon = UI.x2_Money2,
				productName = "x2 Power",
				hoverRotation = 15,
				valueText = "x2",
			}),

			Pass3 = Roact.createElement(GamepassButton, {
				order = 3,
				icon = UI.triple_Hatch,
				productName = "x3 Hatch",
				hoverRotation = 15,
				valueText = "x3",
			}),
		}),

		Buttons = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(1, 0),
		}, {
			UIGridLayout = Roact.createElement("UIGridLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				CellSize = UDim2.fromScale(0.45, 0.45),
				CellPadding = UDim2.fromScale(0, 0.1),
			}),

			Rewards = UIButton({
				icon = UI.Gift,
				text = "Rewards",
				order = 1,
				frame = FramesConstants.Rewards,
				hooks = hooks,
				notifs = RewardsNotif,
			}),

			Spins = UIButton({
				icon = UI.Spin_Wheel,
				text = "Spins",
				order = 2,
				frame = FramesConstants.Spins,
				hooks = hooks,
				notifs = SpinsNotif,
			}),

			DailyRewards = UIButton({
				icon = UI.Daily,
				text = "Daily",
				order = 3,
				frame = FramesConstants.DailyRewards,
				hooks = hooks,
				notifs = DailyRewardsNotif,
			}),

			Invite = UIButton({
				icon = UI.Invite,
				text = "Invite",
				order = 4,
				frame = FramesConstants.Friends,
				hooks = hooks,
			}),

			Trade = UIButton({
				icon = UI.Trading,
				text = "Trade",
				order = 5,
				frame = FramesConstants.TradeList,
				hooks = hooks,
			}),

			Settings = UIButton({
				icon = UI.Settings,
				text = "Settings",
				order = 6,
				frame = FramesConstants.Settings,
				hooks = hooks,
			}),
		}),
	})
end

RightFrame = RoactHooks.new(Roact)(RightFrame)
return RightFrame
