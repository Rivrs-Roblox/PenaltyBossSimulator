--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local Components = StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

-- Controllers
local StoreController = Knit.GetController("StoreController")
local DataCacheController = Knit.GetController("DataCacheController")

-- Data
local UI = DataCacheController:GetFile("Images")

local WINS_COLORS = {
	[1] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("497fca")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("203758")),
		}),
		stroke = Color3.fromRGB(76, 157, 255),
		btnBg = Color3.fromRGB(103, 202, 255),
		btnStroke = Color3.fromRGB(183, 227, 255),
		txtColor = Color3.fromRGB(33, 73, 149),
		iconSize = UDim2.fromScale(0.6, 0.6),
	},
	[2] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("57bcff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("316c90")),
		}),
		stroke = Color3.fromRGB(82, 226, 255),
		btnBg = Color3.fromRGB(126, 238, 255),
		btnStroke = Color3.fromRGB(231, 255, 253),
		txtColor = Color3.fromRGB(33, 73, 149),
		iconSize = UDim2.fromScale(0.8, 0.8),
	},
	[3] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("c98bff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("5437c6")),
		}),
		stroke = Color3.fromRGB(168, 105, 255),
		btnBg = Color3.fromRGB(212, 183, 255),
		btnStroke = Color3.fromRGB(233, 211, 255),
		txtColor = Color3.fromRGB(95, 52, 144),
		iconSize = UDim2.fromScale(1, 1),
	},
	[4] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("ffcc33")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("b83c0c")),
		}),
		stroke = Color3.fromHex("ffbf00"),
		btnBg = Color3.fromHex("ffd500"),
		btnStroke = Color3.fromHex("fbff00"),
		txtColor = Color3.fromHex("903c00"),
		iconSize = UDim2.fromScale(1, 1),
	},
}

local function WinsCardComp(props, hooks)
	local styles, api = RoactSpring.useSpring(hooks, function()
		return { sizeAlpha = 1 }
	end)

	local colorConfig = WINS_COLORS[props.tier] or WINS_COLORS[1]

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		LayoutOrder = props.order,
		ZIndex = 2,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = styles.sizeAlpha:map(function(alpha)
			return UDim2.new(0.223 * alpha, 0, 1 * alpha, 0)
		end),
	}, {
		Ratio = Roact.createElement("UIAspectRatioConstraint", { AspectRatio = 0.65 }),
		ValueText = Text({
			text = props.amountText,
			position = UDim2.fromScale(0.5, 0.71),
			color = Color3.fromHex("ffffff"),
			index = 3,
			size = UDim2.fromScale(0.9, 0.1),
			font = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular),
		}),
		Center = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.5,
			Position = UDim2.fromScale(0.5, 0.28),
			ZIndex = 2,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Size = UDim2.fromScale(0.8, 0.45),
		}, {
			UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 10) }),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 3,
				Image = props.icon,
				Size = colorConfig.iconSize,
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
			Sparkle = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 3,
				Image = UI.Sparkle,
				Size = UDim2.fromScale(1.2, 1.2),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = colorConfig.gradient,
			Rotation = 90,
		}),
		UICorner = Roact.createElement("UICorner", {}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = colorConfig.stroke,
			Thickness = 3,
		}),
		NameText = Text({
			text = props.name,
			position = UDim2.fromScale(0.5, 0.6),
			color = Color3.fromHex("ffffff"),
			index = 3,
			size = UDim2.fromScale(0.9, 0.11),
		}),
		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.87),
			Size = UDim2.fromScale(0.75, 0.15),
			ZIndex = 2,
			ClipsDescendants = true,
			BackgroundColor3 = colorConfig.btnBg,
			[Roact.Event.MouseButton1Click] = function()
				StoreController:BuyItem({ name = props.productName })
			end,
			[Roact.Event.MouseEnter] = function()
				api.start({ sizeAlpha = 1.05 })
			end,
			[Roact.Event.MouseLeave] = function()
				api.start({ sizeAlpha = 1 })
			end,
			[Roact.Event.MouseButton1Down] = function()
				api.start({ sizeAlpha = 0.95 })
			end,
			[Roact.Event.MouseButton1Up] = function()
				api.start({ sizeAlpha = 1.05 })
			end,
		}, {
			UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 5) }),
			UIStroke = Roact.createElement("UIStroke", {
				Color = colorConfig.btnStroke,
				Thickness = 2,
			}),
			PriceText = Text({
				text = props.price,
				position = UDim2.fromScale(0.5, 0.5),
				color = colorConfig.txtColor,
				index = 3,
				size = UDim2.fromScale(0.85, 0.7),
			}),
		}),
	})
end

return RoactHooks.new(Roact)(WinsCardComp)
