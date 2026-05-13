local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)

local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local Components = StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

local DataCacheController = Knit.GetController("DataCacheController")
local Pets = DataCacheController:GetFile("Pets")
local UI = DataCacheController:GetFile("Images")

local function ShowcaseItem(props)
	setmetatable(props, {
		__index = {
			order = props.order or 1,
			chance = props.chance or 0,
			name = props.name or "Default",
			icon = props.icon or "rbxassetid://0",
		},
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BackgroundTransparency = 0.65,
		ClipsDescendants = true,
		BorderColor3 = Color3.fromHex("000000"),
		LayoutOrder = props.order,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.18, 0.9),
	}, {
		UICorner = Roact.createElement("UICorner", {}),
		PercentageText = Text({
			text = props.chance .. " %",
			color = Color3.fromHex("ffffff"),
			anchorPoint = Vector2.new(0.5, 1),
			position = UDim2.fromScale(0.5, 0.22),
			index = 3,
			size = UDim2.fromScale(0.95, 0.2),
			stroke = 1.5,
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 2,
			Image = props.icon,
			Size = UDim2.fromScale(1.5, 1.5),
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		NameText = Text({
			text = props.name,
			color = Color3.fromHex("ffffff"),
			anchorPoint = Vector2.new(0.5, 1),
			position = UDim2.fromScale(0.5, 0.95),
			index = 3,
			size = UDim2.fromScale(0.95, 0.15),
			stroke = 1.5,
			children = {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ffef10")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("ff9500")),
					}),
					Rotation = 90,
				}),
			},
		}),
	})
end

return function(props)
	setmetatable(props, {
		__index = {
			eggData = props.eggData,
			hooks = props.hooks,
		},
	})

	local elements = {}

	for index, item in props.eggData.Pets do
		local petData = Pets[index]

		if not petData then
			warn("Pet data not found: " .. index)
			continue
		end

		elements[index] = ShowcaseItem({
			order = -item.Chance,
			name = petData.Name,
			icon = UI[index],
			chance = item.Chance,
		})
	end

	elements["List"] = Roact.createElement("UIListLayout", {
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0.02, 0),
		FillDirection = Enum.FillDirection.Horizontal,
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.65, 0.47),
		BorderColor3 = Color3.fromHex("000000"),
		ZIndex = 3,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.65, 0.5),
	}, elements)
end
