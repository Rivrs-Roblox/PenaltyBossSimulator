--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback

    Visual updated to follow TimeRewardsVisual raw Roact.
    Structure and reward logic stay on Applications/Rewards.
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
local RewardCard = require(Frames.RewardCard)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local RewardsController = Knit.GetController("RewardsController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

local function getCurrentAreaName(areaReducer)
	local areas = areaReducer and areaReducer.Areas
	if typeof(areas) == "table" and table.maxn(areas) > 0 then
		return areas[table.maxn(areas)] or "Zone1"
	end

	return "Zone1"
end

local function getRewardAmount(reward, areaName)
	local areaData = reward.Areas and reward.Areas[areaName]
	-- if reward.Reward == "Fruit" then
	-- 	return tostring(reward.Amount)
	-- end
	if reward.Reward == "Fruit" or reward.Reward == "Pets" or reward.Reward == "Egg" then
		return reward.Amount or 1
	end
	if typeof(areaData) == "table" and reward.Reward ~= "Pets"  and reward.Reward ~= "Egg" then
		return areaData[2] or 1
	end

	

	return 1
end

local function ActionButton(params)
	params = params or {}

	local color = params.color or Color3.fromHex("1b8d1b")
	local strokeColor = params.strokeColor or Color3.fromHex("052f03")
	local hasPrice = params.price ~= nil

	return Roact.createElement("ImageButton", {
		LayoutOrder = params.layoutOrder or 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.32, 1),
		ZIndex = 5,
		[Roact.Event.MouseButton1Click] = params.onClick,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		ButtonText = Roact.createElement("TextLabel", {
			AnchorPoint = hasPrice and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = hasPrice and UDim2.fromScale(0.05, 0.5) or UDim2.fromScale(0.5, 0.5),
			Size = hasPrice and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0.9, 0.5),
			Text = params.text or "Button",
			TextColor3 = Color3.fromHex("fafafa"),
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = hasPrice and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
			ZIndex = 6,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = strokeColor,
				Thickness = 2,
			}),
		}),

		PriceText = hasPrice and Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.95, 0.5),
			Size = UDim2.fromScale(0.5, 0.5),
			Text = params.price,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 6,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = strokeColor,
				Thickness = 2,
			}),
		}) or nil,
	})
end

local function Title()
	local iconImage = UI.Rewards or "rbxassetid://72857982925608"

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.04, 0.08),
		Size = UDim2.fromScale(0.55, 0.09),
		ZIndex = 5,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Icon = Roact.createElement("ImageLabel", {
			LayoutOrder = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = iconImage,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1.2, 1.2),
			ZIndex = 6,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint"),
		}),

		TitleText = Roact.createElement("TextLabel", {
			LayoutOrder = 2,
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Size = UDim2.fromScale(0.8, 1),
			Text = "Time Rewards",
			TextColor3 = Color3.fromHex("fafafa"),
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 6,
		}),
	})
end

local function CloseButton()
	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.94, 0.08),
		Size = UDim2.fromScale(0.09, 0.09),
		ZIndex = 10,
		[Roact.Event.MouseButton1Click] = function()
			UIController:HideFrame()
		end,
	}, {
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("ff362f")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("8d1414")),
			}),
			Rotation = 90,
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("8f0000"),
			Thickness = 3,
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://120045489184571",
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.5, 0.5),
			ZIndex = 11,
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint"),
	})
end

-- Rewards
function Rewards(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
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
		}, hooks)
	end

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
	}, {
		Content = Blue_Background({
			title = "Time Rewards",
			titleIcon = UI.Rewards or "",
			size = UDim2.fromScale(0.7, 0.7),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.6,
			condition = UIReducer.CurrentUI == FramesConstants.Rewards,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {

			Container = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.95, 0.682),
				ZIndex = 3,
			}, {
				Grid = Roact.createElement("UIGridLayout", {
					CellPadding = UDim2.fromScale(0.018, 0.04),
					CellSize = UDim2.fromScale(0.23, 0.3),
					FillDirection = Enum.FillDirection.Horizontal,
					FillDirectionMaxCells = 4,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),

				Roact.createFragment(RewardsCards),
			}),

			Buttons = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.612, 0.92),
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
					price = `{Template.Messages.Robux_Icon} 79`,
					onClick = function()
						RewardsController:SkipTwo()
					end,
				}),

				BuyAll = ActionButton({
					layoutOrder = 3,
					text = "Buy All",
					price = `{Template.Messages.Robux_Icon} 799`,
					color = Color3.fromHex("ff6734"),
					strokeColor = Color3.fromHex("671311"),
					onClick = function()
						RewardsController:BuyAll()
					end,
				}),
			}),
		}),
	})
end

Rewards = RoactHooks.new(Roact)(Rewards)
return Rewards
