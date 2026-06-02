--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatDuration = require(Helpers.FormatDuration)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local InventoryActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.InventoryActions)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local TooltipController = Knit.GetController("TooltipController")
local NotificationController = Knit.GetController("NotificationController")

-- Services
local FruitService = Knit.GetService("FruitService")
local BoostService = Knit.GetService("BoostService")
local PetsService = Knit.GetService("PetsService")

-- UI
local UI = DataCacheController:GetFile("Images")
local Colors = DataCacheController:GetFile("Colors")

local PET_THEMES = {
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
		gradientTop = Color3.fromHex("ff6347"),
		gradientBottom = Color3.fromHex("8f1d1d"),
		stroke = Color3.fromHex("ff5b2f"),
	},
	Secret = {
		gradientTop = Color3.fromHex("76e8ff"),
		gradientBottom = Color3.fromHex("2c7aa4"),
		stroke = Color3.fromHex("8befff"),
	},
	Exclusive = {
		gradientTop = Color3.fromHex("7015d8"),
		gradientBottom = Color3.fromHex("4d065b"),
		stroke = Color3.fromHex("7645e1"),
	},
}

local function showResult(result)
	if result and result.text then
		NotificationController:Notify({
			tag = "Pet",
			text = result.text,
			type = result.type or "INFO",
		})
	end
end

local function callPetPromise(promise)
	if promise and promise.andThen then
		promise:andThen(showResult):catch(function(err)
			warn("[PET ITEM] Pet action failed:", err)
			NotificationController:Notify({
				tag = "Pet",
				text = "Pet action failed.",
				type = "ERROR",
			})
		end)
	end
end

local function getPetTheme(params)
	local theme = PET_THEMES[params.rarity]
	if theme ~= nil then
		return theme
	end

	local topColor = params.bg_color or Colors[params.rarity] or Color3.fromRGB(215, 216, 205)
	return {
		gradientTop = topColor,
		gradientBottom = Color3.fromHex("2f3444"),
		stroke = topColor,
	}
end

local function getPowerTextSize(text: string)
	local length = string.len(text or "")

	if length <= 4 then
		return 22
	elseif length <= 6 then
		return 16
	elseif length <= 8 then
		return 14
	elseif length <= 10 then
		return 9
	end

	return 8
end

local function createTextLabel(params: table)
	setmetatable(params, {
		__index = {
			text = "",
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.85, 0.2),
			color = Color3.fromHex("ffffff"),
			zIndex = 10,
			stroke = 1.5,
			anchorPoint = Vector2.new(0.5, 0.5),
		},
	})

	return Roact.createElement("TextLabel", {
		TextWrapped = true,
		TextColor3 = params.color,
		Text = params.text,
		AnchorPoint = params.anchorPoint,
		FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		BackgroundTransparency = 1,
		Position = params.position,
		TextSize = 14,
		ZIndex = params.zIndex,
		TextScaled = true,
		Size = params.size,
		TextXAlignment = params.align or Enum.TextXAlignment.Center,
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Thickness = params.stroke,
		}),
	})
end

local function createPetItem(InventoryReducer, params: table)
	local theme = getPetTheme(params)
	local function handlePetAction()
		Sound:PlaySound("UI_Click")

		local petId = tostring(params.id)
		if InventoryReducer.DeletingPets == true then
			if params.deleting == true then
				Store:dispatch(InventoryActions.removeDeletedPet(petId))
			else
				Store:dispatch(InventoryActions.addDeletedPet(petId))
			end

			return
		end

		if params.equipped == true then
			callPetPromise(PetsService:UnequipPet({ id = petId, name = params.name }))
		else
			callPetPromise(PetsService:EquipPet({ id = petId, name = params.name }))
		end
	end

	return Roact.createElement("Frame", {
		LayoutOrder = params.order,
		BackgroundColor3 = Color3.fromHex("fcfaff"),
		BorderSizePixel = 0,
		ZIndex = 2,
	}, {
		TouchTarget = Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ImageTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 50,
			[Roact.Event.MouseButton1Click] = handlePetAction,
		}),
		Deleting = Roact.createElement("ImageLabel", {
			Visible = params.deleting,
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://76931062937616",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 12,
			ImageColor3 = Color3.fromHex("ff0000"),
			Size = UDim2.fromScale(0.65, 0.65),
		}),
		NameText = createTextLabel({
			text = params.name,
			position = UDim2.fromScale(0.5, 0.12),
			size = UDim2.fromScale(0.85, 0.2),
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.gradientTop),
				ColorSequenceKeypoint.new(1, theme.gradientBottom),
			}),
			Rotation = 90,
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = params.icon,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.9, 0.75),
			ZIndex = 2,
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 2,
		}),
		Equipped = Roact.createElement("ImageLabel", {
			Visible = params.equipped,
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://93840956317609",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 11,
			ImageColor3 = Color3.fromHex("00fa00"),
			Size = UDim2.fromScale(0.65, 0.65),
		}),
		Stats = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.9),
			BorderColor3 = Color3.fromHex("000000"),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.9, 0.2),
		}, {
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = UI.Money2,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.14, 0.5),
				ZIndex = 13,
				LayoutOrder = 1,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.42, 2.025),
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),
			PowerText = Roact.createElement("TextLabel", {
				LayoutOrder = 2,
				TextWrapped = false,
				TextColor3 = Color3.fromHex("ffffff"),
				Text = params.power,
				TextScaled = true,
				AnchorPoint = Vector2.new(0, 0.5),
				FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromScale(0.34, 0.5),
				ZIndex = 14,
				Size = UDim2.fromScale(0.62, 1.25),
			}, {
				UIStroke = Roact.createElement("UIStroke", {
					Thickness = 1.5,
				}),
				UITextSizeConstraint = Roact.createElement("UITextSizeConstraint", {
					MaxTextSize = getPowerTextSize(params.power),
					MinTextSize = 1,
				}),
			}),
		}),
	})
end

return function(InventoryReducer, params: table)
	setmetatable(params, {
		__index = {
			equipped = false :: boolean,
			deleting = false :: boolean,
			icon = "" :: string,
			name = "" :: string,
			effect = "" :: string,
			id = 0 :: number,
			order = 0 :: number,
			duration = 0 :: number,
			power = "" :: string,
			rarity = "Common" :: string,
			type = "" :: string,
			hover = nil :: string,
			bg_color = Color3.fromRGB(255, 255, 255),
		},
	})

	if params.type == "Pet" then
		return createPetItem(InventoryReducer, params)
	end

	local function handleItemAction()
		Sound:PlaySound("UI_Click")

		TooltipController:SetText(nil)

		if params.type == "Fruit" then
			FruitService:Consume(params.id)
		elseif params.type == "Boost" then
			BoostService:Consume(params.id)
		end
	end

	return Roact.createElement("Frame", {
		LayoutOrder = params.order,
		BackgroundColor3 = Color3.fromHex("fcfaff"),
		BorderSizePixel = 0,
		ZIndex = 2,
	}, {
		TouchTarget = Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ImageTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 50,
			[Roact.Event.MouseButton1Click] = handleItemAction,
			[Roact.Event.MouseEnter] = function()
				if params.hover ~= nil then
					TooltipController:SetSize(UDim2.fromScale(0.15, 0.06))
					TooltipController:SetText(`{params.hover}`)
				end
			end,
			[Roact.Event.MouseLeave] = function()
				TooltipController:SetText(nil)
			end,
		}),
		EffectText = Text({
			text = params.effect,
			size = UDim2.fromScale(0.88, 0.25),
			color = Color3.fromHex("ffd500"),
			position = UDim2.fromScale(0.5, 0.88),
			index = 10,
			stroke = 1.5,
		}),
		NameText = Text({
			text = params.name,
			size = UDim2.fromScale(0.88, 0.3),
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.5, 0.5),
			index = 10,
			stroke = 1.5,
		}),
		ValueText = Text({
			text = params.power,
			size = UDim2.fromScale(0.9, 0.25),
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.5, 0.15),
			index = 10,
			stroke = 1.5,
			align = Enum.TextXAlignment.Right,
		}),
		DurationText = Text({
			text = math.floor(params.duration / 60) .. " Min",
			size = UDim2.fromScale(0.4, 0.2),
			color = Color3.fromHex("60ff88"),
			position = UDim2.fromScale(0.25, 0.1),
			index = 10,
			stroke = 1.5,
			align = Enum.TextXAlignment.Right,
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = params.type == "Fruit" and ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("4d86d6")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("27436b")),
			}) or ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("d5d5d5")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("8c8c8c")),
			}),
			Rotation = 90,
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 2,
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = params.icon,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.9, 0.75),
			ZIndex = 2,
		}),
	})
end
