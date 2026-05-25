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

local Themes = {
	Blue = {
		cardGradient = { "3b65a3", "254066" },
		strokeGradient = { "1e40b9", "000000" },
	},
	Red = {
		cardGradient = { "ff7777", "ee0000" },
		strokeGradient = { "ff0000", "000000" },
	},
	Green = {
		cardGradient = { "3ce86a", "2aa34c" },
		strokeGradient = { "19ac2a", "000000" },
	},
	Pink = {
		cardGradient = { "ff7ee3", "ee3095" },
		strokeGradient = { "d833c2", "000000" },
	},
	Purple = {
		cardGradient = { "d460e8", "a924b3" },
		strokeGradient = { "9930ac", "000000" },
	},
	Yellow = {
		cardGradient = { "fff58a", "eed200" },
		strokeGradient = { "ff9500", "000000" },
	},
	Brown = {
		cardGradient = { "ffbb77", "ee6b00" },
		strokeGradient = { "ff7700", "000000" },
	},
	Gold = {
		cardGradient = { "ffb700", "ee6b00" },
		strokeGradient = { "ff7700", "000000" },
	},
}

local ProductThemes = {
	["VIP"] = "Gold",
	["x2 Power"] = "Red",
	["x2 Wins"] = "Yellow",
	["x2 Rebirths"] = "Pink",
	["+2 Pet Equip"] = "Blue",
	["+4 Pet Equip"] = "Blue",
	["+7 Pet Equip"] = "Blue",
	["+25 Pet Storage"] = "Blue",
	["+50 Pet Storage"] = "Blue",
	["x3 Hatch"] = "Blue",
	["x8 Hatch"] = "Blue",
	["Lucky"] = "Green",
	["Super Lucky"] = "Purple",
	["Ultra Lucky"] = "Gold",
}

local function makeGradient(colors)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex(colors[1])),
		ColorSequenceKeypoint.new(1, Color3.fromHex(colors[2])),
	})
end

local function getValueBadge(name: string): string?
	return string.match(name, "^x%d+") or string.match(name, "^%+%d+")
end

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

	local themeName = ProductThemes[params.Name] or (params.IsGold and "Gold" or params.Gradient)
	local theme = Themes[themeName] or Themes.Blue
	local valueBadge = getValueBadge(params.Name)

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
			Color = makeGradient(theme.cardGradient),
			Rotation = 90,
		}),
		Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 2) }),
		Stroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("ffffff"),
			Thickness = 2,
		}, {
			Gradient = Roact.createElement("UIGradient", {
				Color = makeGradient(theme.strokeGradient),
				Rotation = 90,
			}),
		}),

		Item = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BackgroundTransparency = 0.5,
			Position = UDim2.fromScale(0.21, 0.5),
			Size = UDim2.fromScale(0.75, 0.75),
			ZIndex = 3,
		}, {
			Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 10) }),
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = UI[params.Icon],
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.9, 0.9),
				ZIndex = 4,
			}, { AspectRatio = Roact.createElement("UIAspectRatioConstraint", {}) }),
			ValueText = Text({
				anchorPoint = Vector2.new(1, 1),
				color = Color3.fromHex("ffea00"),
				index = 5,
				position = UDim2.fromScale(0.98, 0.98),
				size = UDim2.fromScale(0.4, 0.35),
				stroke = 2,
				strokeColor = Color3.fromHex("313131"),
				text = valueBadge or "",
				visible = valueBadge ~= nil,
			}),
		}),

		Name = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.FredokaOne,
			Position = UDim2.fromScale(0.691, 0.156),
			Size = UDim2.fromScale(0.528, 0.199),
			Text = params.Name,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 3,
		}, {
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 2,
			}, {
				Gradient = Roact.createElement("UIGradient", {
					Color = makeGradient(theme.strokeGradient),
					Rotation = 90,
				}),
			}),
		}),

		Description = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.FredokaOne,
			Position = UDim2.fromScale(0.697, 0.449),
			Size = UDim2.fromScale(0.539, 0.313),
			Text = params.Description,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 3,
		}, {
			Stroke = Roact.createElement("UIStroke", {
				Thickness = 1,
			}),
		}),

		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.697, 0.8),
			Size = UDim2.fromScale(0.539, 0.251),
			BackgroundColor3 = Color3.fromHex("ffffff"),
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
			Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 2) }),
			Stroke = Roact.createElement("UIStroke", { Color = Color3.fromHex("ffffff"), Thickness = 2 }),
			Gradient = Roact.createElement("UIGradient", {
				Color = makeGradient({ "3dff27", "23a617" }),
				Rotation = 90,
			}),
			PriceText = Text({
				text = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(params.Name)}`,
				position = UDim2.fromScale(0.5, 0.5),
				color = Color3.fromHex("ffffff"),
				index = 3,
				size = UDim2.fromScale(0.85, 0.7),
				stroke = 1.5,
				strokeColor = Color3.fromHex("313131"),
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
			Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 2) }),
			BoughtText = Text({
				text = "Bought!",
				color = Color3.fromHex("ffffff"),
				index = 11,
				size = UDim2.fromScale(0.7, 0.3),
				position = UDim2.fromScale(0.5, 0.5),
			}),
		}),
	})
end
