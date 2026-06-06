--[=[
    Owner: JustStop__
    Version: 0.0.1
    Contact owner if any question, concern or feedback

    DailyRewards standalone application.
    Visual follows DailyRewardsVisual raw Roact.
    Functional flow still uses DailyRewardsReducer, DailyRewardsController,
    MonetizationController, and FramesConstants.DailyRewards.
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Frames
local Frames = script.Parent.Frames
local WeekFrame = require(Frames.WeekFrame)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local DailyRewardsController = Knit.GetController("DailyRewardsController")
local MonetizationController = Knit.GetController("MonetizationController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

local FONT_FACE = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

local function buildWeeks(rewards)
	local weeks = {}
	local weekIndex = 1

	for day = 1, #(rewards or {}) do
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

local function getRobuxPrice(productName, fallback)
	local price = MonetizationController:GetPrice(productName)

	if price == nil or price == "" then
		return fallback
	end

	return tostring(price)
end

local function RewardsTitle()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.04, 0.08),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.55, 0.09),
		ZIndex = 5,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Icon = Roact.createElement("ImageLabel", {
			LayoutOrder = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 5,
			Image = UI.Rewards or "rbxassetid://72857982925608",
			Size = UDim2.fromScale(0.2, 1.1),
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),

		TitleText = Roact.createElement("TextLabel", {
			LayoutOrder = 2,
			TextWrapped = true,
			TextColor3 = Color3.fromHex("fafafa"),
			Text = "Daily Rewards",
			TextScaled = true,
			FontFace = FONT_FACE,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5,
			TextSize = 14,
			Size = UDim2.fromScale(0.8, 1),
		}),
	})
end

local function RewardsActionButton(params)
	params = params or {}

	return Roact.createElement("ImageButton", {
		LayoutOrder = params.layoutOrder or 1,
		Size = UDim2.fromScale(0.32, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		BorderColor3 = Color3.fromHex("000000"),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BorderSizePixel = 0,
		BackgroundColor3 = params.color or Color3.fromHex("1b8d1b"),
		AutoButtonColor = true,
		ZIndex = 5,

		[Roact.Event.MouseButton1Click] = params.onClick,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		PriceText = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			Text = params.price or "",
			AnchorPoint = Vector2.new(1, 0.5),
			FontFace = FONT_FACE,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextScaled = true,
			Position = UDim2.fromScale(0.95, 0.5),
			TextSize = 14,
			Size = UDim2.fromScale(0.5, 0.5),
			ZIndex = 6,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = params.strokeColor or Color3.fromHex("052f03"),
				Thickness = 2,
			}),
		}),

		ButtonText = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("fafafa"),
			Text = params.text or "Button",
			TextScaled = true,
			AnchorPoint = Vector2.new(0, 0.5),
			FontFace = FONT_FACE,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromScale(0.05, 0.5),
			ZIndex = 6,
			TextSize = 14,
			Size = UDim2.fromScale(0.5, 0.5),
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = params.strokeColor or Color3.fromHex("052f03"),
				Thickness = 2,
			}),
		}),
	})
end

function DailyRewards(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	local DailyRewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.DailyRewardsReducer
	end)

	local weeks = buildWeeks(DailyRewardsReducer and DailyRewardsReducer.rewards or {})
	local renderedWeeks = {}

	for index, weekData in ipairs(weeks) do
		renderedWeeks["Week_" .. index] = WeekFrame(index, weekData, hooks)
	end

	local skipOnePrice = getRobuxPrice("Daily Rewards - Skip 1", "79")
	local skipAllPrice = getRobuxPrice("Daily Rewards - Skip All", "799")
	local robuxIcon = Template.Messages.Robux_Icon or ""

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = UIReducer.CurrentUI == FramesConstants.DailyRewards,
		ZIndex = 1,
	}, {
		Content = Blue_Background({
			title = "Daily Rewards",
			titleIcon = UI.Daily,
			size = UDim2.fromScale(0.7, 0.7),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.6,
			condition = UIReducer.CurrentUI == FramesConstants.DailyRewards,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {

			Container = Roact.createElement("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticCanvasSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromScale(0, 1),
				ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
				Position = UDim2.fromScale(0.5, 0.5),
				ScrollBarImageTransparency = 0.32,
				ScrollBarThickness = 6,
				ScrollingDirection = Enum.ScrollingDirection.X,
				Size = UDim2.fromScale(0.95, 0.9),
				ZIndex = 2,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 0),
					FillDirection = Enum.FillDirection.Horizontal,
				}),

				Roact.createFragment(renderedWeeks),
			}),

			Buttons = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.612, 0.92),
				BorderColor3 = Color3.fromHex("000000"),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.686, 0.1),
				ZIndex = 2,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0.01, 0),
					FillDirection = Enum.FillDirection.Horizontal,
				}),

				Skip1 = RewardsActionButton({
					layoutOrder = 2,
					text = "Skip 1",
					price = `{robuxIcon} {skipOnePrice}`,
					onClick = function()
						DailyRewardsController:Skip()
					end,
				}),

				SkipAll = RewardsActionButton({
					layoutOrder = 3,
					text = "Skip All",
					price = `{robuxIcon} {skipAllPrice}`,
					color = Color3.fromHex("ff6734"),
					strokeColor = Color3.fromHex("671311"),
					onClick = function()
						DailyRewardsController:BuyAll()
					end,
				}),
			}),
		}),
	})
end

DailyRewards = RoactHooks.new(Roact)(DailyRewards)
return DailyRewards
