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
local Sound = require(ReplicatedStorage.Packages.Sound)
local NumberWithComma = require(ReplicatedStorage.Shared.Helpers.Numbers.NumberWithComma)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local AspectRatio = require(Components.AspectRatio)
local Text = require(Components.Text)
local Stroke = require(Components.Stroke)
local Corner = require(Components.Corner)
local ShopButton = require(Components.Shop.ShopButton)
local Image = require(Components.Image)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local MonetizationController = Knit.GetController("MonetizationController")
local ExclusivePackController = Knit.GetController("ExclusivePackController")
local UIController = Knit.GetController("UIController")
local TooltipController = Knit.GetController("TooltipController")
local NotificationController = Knit.GetController("NotificationController")

-- UI
local Template = DataCacheController:GetFile("Template")
local UI = DataCacheController:GetFile("Images")
local Pets = DataCacheController:GetFile("Pets")

-- ShopIcon
return function(frameParams: table, itemParams: table, nameBypass: string?)
	setmetatable(frameParams, {
		__index = {
			id = 0 :: number,
			position = UDim2.fromScale(0.5, 0.5) :: UDim2,
			size = UDim2.fromScale(1, 1) :: UDim2,
			hooks = nil,
			pet = false,
			order = 0,
			disabled = false,
			hover = nil :: string,
			roactRef = nil,
		},
	})

	setmetatable(itemParams, {
		__index = {
			DisplayName = "" :: string,
			Name = "" :: string,
			Icon = "" :: string,
			Price = 0 :: number,
			Text = "" :: string,
		},
	})

	-- if frameParams.pet then
	-- 	itemParams.Text = `x{NumberWithComma(Pets[itemParams.Name].Power)}`
	-- end

	local styles, api = RoactSpring.useSpring(frameParams.hooks, function()
		return {
			from = { Rotation = 0, sizeAlpha = 1 },
			to = { Rotation = 36000 },
			loop = true,
			reset = false,
			config = { mass = 1, tension = 1000, friction = 50, duration = 800 },
		}
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		LayoutOrder = frameParams.order,
		ZIndex = 2,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = UDim2.fromScale(0.3, 0.833),
	}, {
		Corner = Corner({ radius = 0.1 }),
		Stroke = Stroke({ thick = 3 }),

		NextArrow = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://81523979565214",
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1.05, 0.5),
			BorderColor3 = Color3.fromHex("000000"),
			ZIndex = 2,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.35, 0.35),
		}),

		Star = Image({
			visible = frameParams.pet,
			image = UI.Star,
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(1, 1),
			backgroundTransparency = 1,
			index = 2,
			rotation = styles.Rotation,
			children = {
				Gradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
						ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
					}),
				}),
			},
		}),

		Name = Text({
			text = nameBypass and nameBypass or itemParams.DisplayName,
			color = Color3.fromRGB(255, 234, 1),
			backgroundTransparency = 1,
			position = UDim2.fromScale(0.5, 0.1),
			size = UDim2.fromScale(0.9, 0.2),
			index = 4,
			stroke = 1.5,
		}),

		Multiplier = Text({
			text = itemParams.Text,
			color = Color3.fromRGB(85, 255, 127),
			backgroundTransparency = 1,
			position = UDim2.fromScale(0.5, 0.8),
			size = UDim2.fromScale(0.7, 0.2),
			index = 4,
			stroke = 1.5,
		}),

		Count = Text({
			text = (if itemParams.Quantity > 1 then `x{itemParams.Quantity}` else ""),
			color = Color3.fromRGB(255, 255, 255),
			backgroundTransparency = 1,
			position = UDim2.fromScale(0.7, 0.6),
			size = UDim2.fromScale(0.7, 0.25),
			index = 3,
			stroke = 1.5,
		}),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Image = UI[itemParams.Icon],
			Size = UDim2.fromScale(0.75, 0.75),
			ZIndex = 3,
			Rotation = 0,
			ScaleType = Enum.ScaleType.Fit,
			ImageTransparency = 0,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			[Roact.Event.MouseEnter] = function()
				if frameParams.hover ~= nil then
					TooltipController:SetSize(UDim2.fromScale(0.15, 0.18))
					TooltipController:SetText(`{frameParams.hover}`)
				end
			end,

			[Roact.Event.MouseLeave] = function()
				TooltipController:SetText(nil)
			end,
		}, {
			Ratio = AspectRatio({ ratio = 1 }),
		}),

		ShopButton = ShopButton({
			text = if itemParams.Price > 0 then `{Template.Messages.Robux_Icon} {itemParams.Price}` else "Free",
			position = UDim2.fromScale(0.5, 1.025),
			size = UDim2.fromScale(0.8, 0.25),
			color = if frameParams.disabled then Color3.fromRGB(58, 56, 56) else Color3.fromRGB(111, 255, 0),
			buy = itemParams.Name,
			hooks = frameParams.hooks,
			disabled = frameParams.disabled,
			action = function()
				Sound:PlaySound("UI_Click")
				ExclusivePackController:BuyItem(frameParams.id)
			end,
			roactRef = frameParams.roactRef,
		}),
	})
end
