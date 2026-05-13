--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Controllers
local GoldMachineController = Knit.GetController("GoldMachineController")

local CHECK_ICON = "rbxassetid://93840956317609"

local RarityThemes = {
	Common = {
		gradientTop = Color3.fromHex("d7d8cd"),
		gradientBottom = Color3.fromHex("797979"),
		stroke = Color3.fromHex("e1e1e1"),
	},
	Uncommon = {
		gradientTop = Color3.fromHex("50ff20"),
		gradientBottom = Color3.fromHex("1a8a18"),
		stroke = Color3.fromHex("64ff39"),
	},
	Rare = {
		gradientTop = Color3.fromHex("6085ff"),
		gradientBottom = Color3.fromHex("3a559e"),
		stroke = Color3.fromHex("46a9ff"),
	},
	Epic = {
		gradientTop = Color3.fromHex("c041ff"),
		gradientBottom = Color3.fromHex("5b1579"),
		stroke = Color3.fromHex("c743ff"),
	},
	Legendary = {
		gradientTop = Color3.fromHex("fff240"),
		gradientBottom = Color3.fromHex("ff8c27"),
		stroke = Color3.fromHex("ff9501"),
	},
	Mythical = {
		gradientTop = Color3.fromHex("ff494c"),
		gradientBottom = Color3.fromHex("8d0909"),
		stroke = Color3.fromHex("e13b3e"),
	},
	Exclusive = {
		gradientTop = Color3.fromHex("7015d8"),
		gradientBottom = Color3.fromHex("4d065b"),
		stroke = Color3.fromHex("7645e1"),
	},
}

local function getTheme(rarity: string?)
	return RarityThemes[rarity or ""] or RarityThemes.Rare
end

return function(params: table)
	setmetatable(params, {
		__index = {
			equipped = false :: boolean,
			icon = "" :: string,
			name = "" :: string,
			id = 0 :: number,
			order = 0 :: number,
			power = "" :: string,
			rarity = "Rare" :: string,
		},
	})

	local theme = getTheme(params.rarity)

	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = true,
		BackgroundColor3 = Color3.fromHex("fcfaff"),
		BorderSizePixel = 0,
		LayoutOrder = params.order,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 5,

		[Roact.Event.MouseButton1Click] = function()
			GoldMachineController:AddOrRemovePet(params)
		end,
	}, {
		Ratio = Roact.createElement("UIAspectRatioConstraint"),

		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.gradientTop),
				ColorSequenceKeypoint.new(1, theme.gradientBottom),
			}),
			Rotation = 90,
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = theme.stroke,
			Thickness = 3,
		}),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = params.icon,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.9, 0.75),
			ZIndex = 6,
		}),

		Equipped = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = CHECK_ICON,
			ImageColor3 = Color3.fromHex("00fa00"),
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.7, 0.7),
			Visible = params.equipped,
			ZIndex = 11,
		}),

		NameText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 0.12),
			Size = UDim2.fromScale(0.85, 0.2),
			Text = params.name,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 10,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Thickness = 1.5,
			}),
		}),

		PowerText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 0.88),
			Size = UDim2.fromScale(0.85, 0.2),
			Text = params.power,
			TextColor3 = Color3.fromHex("ffffff"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 10,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Thickness = 1.5,
			}),
		}),
	})
end
