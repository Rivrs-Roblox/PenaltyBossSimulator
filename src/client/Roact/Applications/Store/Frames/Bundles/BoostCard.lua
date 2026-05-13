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
local UI = DataCacheController:GetFile("Images")

local BOOST_COLORS = {
	-- ["Money_2"] = {
	-- 	gradient = ColorSequence.new({
	-- 		ColorSequenceKeypoint.new(0, Color3.fromHex("47ff26")),
	-- 		ColorSequenceKeypoint.new(1, Color3.fromHex("34a62c")),
	-- 	}),
	-- 	stroke = Color3.fromHex("37ff00"),
	-- 	btnBg = Color3.fromHex("80ff5d"),
	-- 	btnStroke = Color3.fromHex("aaffb1"),
	-- 	txtColor = Color3.fromHex("31791c"),
	-- },
	["Money_2"] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("2fb6ff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("4740a6")),
		}),
		stroke = Color3.fromHex("25edff"),
		btnBg = Color3.fromHex("22daff"),
		btnStroke = Color3.fromHex("00fbff"),
		txtColor = Color3.fromHex("0e69bb"),
	},
	["Wins"] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("2fb6ff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("4740a6")),
		}),
		stroke = Color3.fromHex("25edff"),
		btnBg = Color3.fromHex("22daff"),
		btnStroke = Color3.fromHex("00fbff"),
		txtColor = Color3.fromHex("0e69bb"),
	},
	["All"] = {
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("ffe30b")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("e74a2b")),
		}),
		stroke = Color3.fromHex("ffea4c"),
		btnBg = Color3.fromHex("ffd500"),
		btnStroke = Color3.fromHex("fbff00"),
		txtColor = Color3.fromHex("903c00"),
	},
}

local function BoostCardComp(props, hooks)
	local styles, api = RoactSpring.useSpring(hooks, function()
		return { sizeAlpha = 1 }
	end)

	local colorConfig = BOOST_COLORS[props.colorKey] or BOOST_COLORS["Money_2"]

	return Roact.createElement("Frame", {
		LayoutOrder = props.order,
		ClipsDescendants = true,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = UDim2.fromScale(1, 0.45),
		ZIndex = 2,
	}, {
		UICorner = Roact.createElement("UICorner", {}),
		ScaleEffect = Roact.createElement("UIScale", {
			Scale = styles.sizeAlpha,
		}),
		ValueText = Text({
			text = props.timeText,
			position = UDim2.fromScale(0.5, 0.737),
			color = Color3.fromHex("ffffff"),
			index = 3,
			size = UDim2.fromScale(0.9, 0.09),
		}),

		Center = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.5,
			Position = UDim2.fromScale(0.5, 0.3),
			ZIndex = 2,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Size = UDim2.fromScale(0.7, 0.5),
		}, {
			UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 10) }),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 3,
				Image = props.icon,
				Size = UDim2.fromScale(0.9, 0.9),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
			Sparkle = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 3,
				Image = UI.Sparkle,
				Size = UDim2.fromScale(1.2, 1.2),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.9,
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = colorConfig.gradient,
			Rotation = 90,
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = colorConfig.stroke,
			Thickness = 3,
		}),
		NameText = Text({
			text = props.name,
			position = UDim2.fromScale(0.5, 0.632),
			color = Color3.fromHex("ffffff"),
			index = 3,
			size = UDim2.fromScale(0.9, 0.11),
		}),
		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.89),
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

return RoactHooks.new(Roact)(BoostCardComp)
