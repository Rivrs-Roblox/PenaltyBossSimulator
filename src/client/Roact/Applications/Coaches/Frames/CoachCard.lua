--[=[
   Owner: JustStop__
   Version: 0.0.2
   Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)
local Size = require(Helpers.Size)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)
local AspectRatio = require(Components.AspectRatio)
local Corner = require(Components.Corner)
local Stroke = require(Components.Stroke)
local List = require(Components.List)
local Image = require(Components.Image)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local CoachesController = Knit.GetController("CoachesController")
local MonetizationController = Knit.GetController("MonetizationController")
local StoreController = Knit.GetController("StoreController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

local PREMIUM_COACH_PRODUCT_NAME = ""
local PREMIUM_COACH_TEMPLATE_NAME = ""
local CHRISTMAS_COACH_TEMPLATE_NAME = ""

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- CoachCard
return function(params: table, hooks)
	setmetatable(params, {
		__index = {
			id = "" :: string,
			name = "" :: string,
			price = 0 :: number,
			color = Color3.fromRGB(255, 255, 255) :: Color3,
			possessed = false :: boolean,
			equipped = false :: boolean,
			speed = 1 :: number,
			image = "" :: string,
			VIP = false :: boolean,
			Reward = false :: boolean,
			StarterPack = false :: boolean,
			Chest = false :: boolean,
			multiplier = 1 :: number,
			order = 0 :: number,
			flag = "Portugal" :: string,
		},
	})

	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	local ButtonText = ""
	if params.possessed and not params.equipped then
		ButtonText = "Equip"
	elseif params.possessed and params.equipped then
		ButtonText = "Unequip"
	end

	local ButtonColor
	if params.VIP then
		ButtonColor = Color3.fromHex("ffe13a")
	elseif params.Reward or params.StarterPack or params.Chest then
		ButtonColor = Color3.fromRGB(230, 156, 255)
	else
		ButtonColor = Color3.fromRGB(117, 207, 255)
	end

	if params.possessed and params.equipped then
		ButtonColor = Color3.fromRGB(180, 180, 180)
	end

	local PriceTextStr = if not params.possessed
		then (if params.VIP
			then `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice("Coach - " .. params.name)}`
			elseif params.Reward then "Daily Rewards Exclusive"
			elseif params.StarterPack then "Starter Pack Exclusive"
			elseif params.Chest then "Chest Rewards Exclusive"
			else FormatNumber(params.price))
		else ButtonText

	local gradientColors
	local strokeColor
	local strokeGradient
	local frameColor
	if params.VIP then
		gradientColors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("ffcc00")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("ff8239")),
		})
		strokeColor = Color3.fromRGB(125, 77, 21)
		strokeGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("ff5100")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("fdff6c")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("ff5100")),
		})
		frameColor = Color3.fromRGB(238, 177, 23)
	elseif params.Reward or params.StarterPack or params.Chest then
		gradientColors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("ad87ff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("501ac6")),
		})
		strokeColor = Color3.fromRGB(72, 15, 129)
		strokeGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("64328f")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("dfa7ff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("64328f")),
		})
		frameColor = Color3.fromRGB(123, 3, 144)
	else
		gradientColors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("82ff74")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("229300")),
		})
		strokeColor = Color3.fromRGB(25, 116, 0)
		frameColor = Color3.fromRGB(0, 0, 0)
	end

	return Roact.createElement("Frame", {
		LayoutOrder = params.order,
		BackgroundColor3 = frameColor,
		Position = UDim2.fromScale(0.02, 0.1),
		Size = UDim2.fromScale(0.96, 0.96),
		BackgroundTransparency = 0.7,
		ZIndex = 2,
	}, {
		Stroke = Roact.createElement("UIStroke", {
			Color = strokeGradient and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(88, 88, 88),
			Thickness = 2,
		}, {
			Gradient = strokeGradient and Roact.createElement("UIGradient", {
				Color = strokeGradient,
				Rotation = -32,
			}),
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),
		NameText = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			Text = params.displayName or params.name,
			AnchorPoint = Vector2.new(0.5, 0.5),
			FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.1),
			TextSize = 14,
			ZIndex = 3,
			TextScaled = true,
			Size = UDim2.fromScale(0.9, 0.15),
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromRGB(43, 43, 43),
				Thickness = 2,
			}),
		}),
		Pic = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Position = UDim2.fromScale(0, 0.55),
			Size = UDim2.fromScale(0.8, 0.8),
			ClipsDescendants = true,
			ZIndex = 2,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Gradient = Roact.createElement("UIGradient", {
				Color = gradientColors,
				Rotation = 90,
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = strokeColor,
				Thickness = 2,
			}),

			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = 3,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 2,
				Image = params.image,
				ImageColor3 = params.color or Color3.fromRGB(255, 255, 255),
				Size = UDim2.fromScale(1, 1),
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),

			Sparkle = Roact.createElement("ImageLabel", {
				Image = UI.Sparkle,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1.3, 1.3),
				ZIndex = 3,
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		}),

		Value = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.7, 0.6),
			BorderColor3 = Color3.fromHex("000000"),
			ZIndex = 10,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.53, 0.22),
		}, {
			ValueText = Text({
				size = UDim2.fromScale(0.5, 0.65),
				position = UDim2.fromScale(0.761, 0.383),
				text = "x" .. (params.multiplier or 1),
				color = Color3.fromHex("ffd500"),
				index = 10,
				align = Enum.TextXAlignment.Right,
				stroke = 2,
				strokeColor = Color3.fromHex("313131"),
			}),

			Icon = Roact.createElement("ImageLabel", {
				LayoutOrder = 1,
				ScaleType = 3,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = UI.Money2,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.849, 0.15),
				ZIndex = 10,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				Size = UDim2.fromScale(1, 1),
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),
			List = Roact.createElement("UIListLayout", {
				VerticalAlignment = 2,
				SortOrder = 2,
				HorizontalAlignment = 2,
				Padding = UDim.new(0.02, 0),
				ItemLineAlignment = 2,
				FillDirection = 0,
			}),
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.3,
		}),
		Flag = Roact.createElement("ImageLabel", {
			Image = UI[params.flag],
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.849, 0.35),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.3, 0.3),
			ZIndex = 3,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),

		PremiumBadge = params.VIP and Roact.createElement("ImageLabel", {
			Image = UI.Premium,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.2, 0.2),
			Position = UDim2.fromScale(0.85, 0.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 4,
		}, {
			AspectRatio = AspectRatio({ ratio = 1 }),
		}),
		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.7, 0.849),
			Size = Size(styles, { X = 0.53, Y = 0.2 }),
			ZIndex = 8,
			ClipsDescendants = true,
			BackgroundColor3 = ButtonColor,

			[Roact.Event.MouseButton1Click] = function()
				if not params.possessed then
					if params.VIP then
						StoreController:BuyItem({ name = `Coach - {params.name}` })
						UIController:HideFrame()
					elseif params.Reward then
						UIController:ShowFrame({ frame = FramesConstants.DailyRewards })
					elseif params.StarterPack then
						UIController:ShowFrame({ frame = FramesConstants.StarterPack })
					elseif not (params.VIP or params.Reward or params.StarterPack or params.Chest) then
						CoachesController:BuyCoach(params.id)
						UIController:HideFrame()
					end
				else
					if params.equipped then
						CoachesController:UnequipCoach(params.id)
						UIController:HideFrame()
					else
						CoachesController:EquipCoach(params.id)
						UIController:HideFrame()
					end
				end
				Sound:PlaySound("UI_Click")
			end,

			[Roact.Event.MouseEnter] = function()
				api.start({ sizeAlpha = 1.1 })
			end,

			[Roact.Event.MouseLeave] = function()
				api.start({ sizeAlpha = 1 })
			end,

			[Roact.Event.MouseButton1Down] = function()
				api.start({ sizeAlpha = 0.8 })
			end,

			[Roact.Event.MouseButton1Up] = function()
				api.start({ sizeAlpha = 1 })
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 2),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 2,
			}),
			List = List({
				fillDirection = Enum.FillDirection.Horizontal,
				horizontalAlignment = Enum.HorizontalAlignment.Center,
				verticalAlignment = Enum.VerticalAlignment.Center,
			}),
			BuyIcon = Image({
				index = 8,
				image = UI.Money2,
				backgroundTransparency = 1,
				size = UDim2.fromScale(0.282, 0.844),
				order = 1,
				visible = params.possessed == false
					and not (params.VIP or params.Reward or params.StarterPack or params.Chest),
				children = { AspectRatio = AspectRatio({ ratio = 1 }) },
			}),
			PriceText = Roact.createElement("TextLabel", {
				TextWrapped = true,
				TextColor3 = Color3.fromHex("ffffff"),
				Text = PriceTextStr,
				AnchorPoint = Vector2.new(0.5, 0.5),
				FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				TextSize = 18,
				ZIndex = 8,
				TextScaled = true,
				Size = UDim2.fromScale(0.70, 0.85),
				LayoutOrder = 2,
			}, {
				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("313131"),
					Thickness = 1.5,
				}),
			}),
		}),
	})
end
