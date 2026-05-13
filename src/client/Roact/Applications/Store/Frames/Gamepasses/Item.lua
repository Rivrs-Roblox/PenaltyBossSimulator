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
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local MonetizationController = Knit.GetController("MonetizationController")
local StoreController = Knit.GetController("StoreController")

local Components = StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

-- UI
local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")

return function(params: table, order: number, has: boolean, hooks)
	setmetatable(params, {
		__index = {
			Name = "" :: string,
			Description = "" :: string,
			Icon = "" :: string,
			Price = 0 :: number,
			IsGold = false :: boolean,
			Gradient = "" :: string,
		},
	})
	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
			config = { mass = 1, tension = 1000, friction = 50 },
		}
	end)

	local gradientColor
	local strokeColor
	local buyColor
	local buyStrokeColor
	local buyTextColor

	if params.IsGold then
		gradientColor = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("ffd900")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("ff5500")),
		}
		strokeColor = Color3.fromHex("ffbf00")
		buyColor = Color3.fromHex("ffd500")
		buyStrokeColor = Color3.fromHex("fbff00")
		buyTextColor = Color3.fromHex("903c00")
	elseif params.Gradient == "Green" then
		gradientColor = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("0eb828")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("097419")),
		}
		strokeColor = Color3.fromHex("40d050")
		buyColor = Color3.fromHex("80ff5d")
		buyStrokeColor = Color3.fromHex("aaffb1")
		buyTextColor = Color3.fromHex("31791c")
	elseif params.Gradient == "Purple" then
		gradientColor = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("ff3eef")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("9614c2")),
		}
		strokeColor = Color3.fromHex("ff77e2")
		buyColor = Color3.fromHex("ff75e1")
		buyStrokeColor = Color3.fromHex("ffabeb")
		buyTextColor = Color3.fromHex("902d65")
	elseif params.Gradient == "Brown" then
		gradientColor = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("ff9326")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("c14b14")),
		}
		strokeColor = Color3.fromHex("ffbf00")
		buyColor = Color3.fromHex("ffd500")
		buyStrokeColor = Color3.fromHex("fbff00")
		buyTextColor = Color3.fromHex("903c00")
	else
		gradientColor = {
			ColorSequenceKeypoint.new(0, Color3.fromHex("4089ff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("394abe")),
		}
		strokeColor = Color3.fromHex("49aaff")
		buyColor = Color3.fromHex("22daff")
		buyStrokeColor = Color3.fromHex("00fbff")
		buyTextColor = Color3.fromHex("0950ac")
	end

	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromHex("ffffff"),
		ClipsDescendants = true,
		LayoutOrder = order,
		Size = styles.sizeAlpha:map(function(alpha)
			return UDim2.fromScale(1 * alpha, 0.45 * alpha)
		end),
		ZIndex = 2,
	}, {
		Ratio = Roact.createElement("UIAspectRatioConstraint", { AspectRatio = 2.1 }),
		Gradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new(gradientColor),
		}),
		Corner = Roact.createElement("UICorner", {}),
		Stroke = Roact.createElement("UIStroke", {
			Color = strokeColor,
			Thickness = 3,
		}),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = UI[params.Icon],
			Position = UDim2.fromScale(0.2, 0.5),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.8, 0.8),
			ZIndex = 3,
			ScaleType = Enum.ScaleType.Fit,
		}, { AspectRatio = Roact.createElement("UIAspectRatioConstraint", {}) }),

		Name = Text({
			text = params.Name,
			position = UDim2.fromScale(0.691, 0.156),
			color = Color3.fromHex("ffffff"),
			index = 3,
			size = UDim2.fromScale(0.528, 0.199),
		}),

		Description = Text({
			text = params.Description,
			position = UDim2.fromScale(0.697, 0.449),
			color = Color3.fromHex("ffffff"),
			index = 3,
			size = UDim2.fromScale(0.539, 0.313),
		}),

		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.697, 0.8),
			Size = UDim2.fromScale(0.539, 0.251),
			BackgroundColor3 = buyColor,
			ZIndex = 2,
			ClipsDescendants = true,
			[Roact.Event.MouseButton1Click] = function()
				if not has then
					StoreController:BuyItem({ name = params.Name })
				end
			end,
			[Roact.Event.MouseEnter] = function()
				if not has then
					api.start({ sizeAlpha = 1.05 })
				end
			end,
			[Roact.Event.MouseLeave] = function()
				api.start({ sizeAlpha = 1 })
			end,
			[Roact.Event.MouseButton1Down] = function()
				if not has then
					api.start({ sizeAlpha = 0.95 })
				end
			end,
			[Roact.Event.MouseButton1Up] = function()
				if not has then
					api.start({ sizeAlpha = 1.05 })
				end
			end,
		}, {
			Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 10) }),
			Stroke = Roact.createElement("UIStroke", { Color = buyStrokeColor, Thickness = 2 }),
			PriceText = Text({
				text = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(params.Name)}`,
				position = UDim2.fromScale(0.5, 0.5),
				color = buyTextColor,
				index = 3,
				size = UDim2.fromScale(0.85, 0.7),
			}),
		}),

		Bought = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0.2,
			BackgroundColor3 = Color3.fromHex("000000"),
			Visible = has,
			ZIndex = 10,
		}, {
			Corner = Roact.createElement("UICorner", {}),
			BoughtText = Text({
				text = "Bought!",
				color = Color3.fromHex("ffffff"),
				index = 11,
				size = UDim2.fromScale(0.7, 0.3),
				position = UDim2.fromScale(0.5, 0.5),
				stroke = 3,
				strokeColor = Color3.fromHex("000000"),
			}),
		}),
	})
end
