--[=[
    Owner: JustStop__
	Version: 0.0.2
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local TooltipController = Knit.GetController("TooltipController")

-- UI
local UI = DataCacheController:GetFile("Images")

-- ShopIcon
return function(frameParams: table, itemParams: table, nameBypass: string?)
	setmetatable(frameParams, {
		__index = {
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(1, 1),
			hooks = nil,
			pet = false,
			order = 0,
			hover = nil,
		},
	})

	setmetatable(itemParams, {
		__index = {
			Name = "",
			Icon = "",
			Price = 0,
			Text = "",
		},
	})

	local starRef = Roact.createRef()

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.6),
		LayoutOrder = frameParams.order,
		ZIndex = 2,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = UDim2.fromScale(0.15, 0.75),

		[Roact.Event.AncestryChanged] = function(rbx)
			if rbx:IsDescendantOf(game) then
				local star = starRef:getValue()
				if star then
					local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
					local tween = TweenService:Create(star, tweenInfo, { Rotation = 360 })
					tween:Play()
				end
			end
		end,
	}, {
		OP = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = if itemParams.Secret then Color3.fromRGB(125, 218, 255) else Color3.fromHex("fff70a"),
			Text = if itemParams.Secret then "???" else "OP!",
			TextSize = 14,
			Rotation = 10,
			Font = 26,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.9, 0.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 5,
			TextScaled = true,
			Size = UDim2.fromScale(0.6, 0.4),
		}, {
			["1"] = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("191919"),
				Thickness = 1.5,
			}),
		}),

		Corner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),

		Stroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("191919"),
			Thickness = 3,
		}),

		Star = Roact.createElement("ImageLabel", {
			ScaleType = Enum.ScaleType.Stretch,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://17668879621",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 3,
			Rotation = 0,
			[Roact.Ref] = starRef,
			Size = UDim2.fromScale(1.2, 1.2),
		}, {
			Gradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ff0000")),
					ColorSequenceKeypoint.new(0.2, Color3.fromHex("ffff00")),
					ColorSequenceKeypoint.new(0.4, Color3.fromHex("00ff00")),
					ColorSequenceKeypoint.new(0.6, Color3.fromHex("00ffff")),
					ColorSequenceKeypoint.new(0.8, Color3.fromHex("0000ff")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("ff00ff")),
				}),
			}),
		}),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = Enum.ScaleType.Stretch,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.456),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 4,
			Image = UI[itemParams.Icon],
			Size = UDim2.fromScale(1, 1),

			[Roact.Event.MouseEnter] = function()
				if frameParams.hover then
					TooltipController:SetText(frameParams.hover)
					if itemParams.Secret then
						TooltipController:SetSize(UDim2.fromScale(0.2, 0.06))
					else
						TooltipController:SetSize(UDim2.fromScale(0.1, 0.03))
					end
				end
			end,

			[Roact.Event.MouseLeave] = function()
				TooltipController:SetText(nil)
				TooltipController:SetSize(UDim2.fromScale(0.1, 0.03))
			end,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),

		Name = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			Text = itemParams.Name,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Font = 26,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.9),
			TextSize = 14,
			ZIndex = 5,
			TextScaled = true,
			Size = UDim2.fromScale(1.25, 0.3),
		}, {
			["1"] = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("191919"),
				Thickness = 1.5,
			}),
		}),
	})
end
