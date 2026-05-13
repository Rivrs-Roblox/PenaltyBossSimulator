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
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local GetTableLength = require(ReplicatedStorage.Shared.Helpers.GetTableLength)
local FormatNumber = require(ReplicatedStorage.Shared.Helpers.Numbers.FormatNumber)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local InventoryActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.InventoryActions)
local UIActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

-- Inventory Components
local InventoryComponents = script.Parent.Parent.Components
local Item = require(InventoryComponents.Item)
local ScrollFrame = require(InventoryComponents.ScrollFrame)

-- Services
local PetsService = Knit.GetService("PetsService")

-- Constants
local InventoryConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.InventoryConstants)

-- UI / Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local NotificationController = Knit.GetController("NotificationController")
local UIController = Knit.GetController("UIController")
local UI = DataCacheController:GetFile("Images")
local Colors = DataCacheController:GetFile("Colors")
local PetsData = DataCacheController:GetFile("Pets")

local SEARCH_ICON = "rbxassetid://108045196460145"
local COUNTER_ICON = "rbxassetid://103901141281428"
local PLUS_ICON = "rbxassetid://98999428594161"

local function getPetIcon(images, petName: string)
	return images[petName]
		or images[petName:gsub("Gold ", ""):gsub("Rainbow ", "")]
		or images.Pets
		or ""
end

local function getPetPower(petsData, petsReducer, petName: string)
	local templatePet = petsData[petName]
	if templatePet == nil then
		return 0
	end

	local powerData = templatePet.Power
	if powerData == nil and templatePet.Type == "Scaling" then
		powerData = petsReducer.ScaledPetsPower[petName] or 0
	end

	return tonumber(powerData) or 0
end

local function notifyPetResult(result)
	if result and result.text then
		NotificationController:Notify({
			tag = "Pet",
			text = result.text,
			type = result.type or "INFO",
		})
	end
end

local function safePetPromise(promise, warnPrefix: string)
	if promise and promise.andThen then
		promise:andThen(notifyPetResult):catch(function(err)
			warn(warnPrefix, err)
		end)
	end
end

local function openStore()
	Store:dispatch(UIActions.setCurrentUI("Store"))
	UIController:RemoveHUD({ ignoreTopFrame = true })
end

local function createActionButton(params: table)
	setmetatable(params, {
		__index = {
			text = "Button",
			order = 1,
			size = UDim2.fromScale(0.19, 1),
			strokeColor = Color3.fromHex("e1e1e1"),
			gradientTop = Color3.fromHex("d7d8cd"),
			gradientBottom = Color3.fromHex("797979"),
			action = function() end,
		},
	})

	return Roact.createElement("ImageButton", {
		LayoutOrder = params.order,
		Size = params.size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		AutoButtonColor = true,
		[Roact.Event.MouseButton1Click] = function()
			Sound:PlaySound("UI_Click")
			params.action()
		end,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		
		UIStroke = Roact.createElement("UIStroke", {
			Color = params.strokeColor,
			Thickness = 2,
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, params.gradientTop),
				ColorSequenceKeypoint.new(1, params.gradientBottom),
			}),
			Rotation = 90,
		}),
		ButtonText = Text({
			text = params.text,
			color = Color3.fromHex("fafafa"),
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.9, 0.55),
			index = 5,
			stroke = 0,
		}),
	})
end

local function createCounter(params: table)
	setmetatable(params, {
		__index = {
			order = 1,
			count = 0,
			max = 0,
			position = UDim2.fromScale(0.97, 0.5),
			textSize = UDim2.fromScale(0.52, 0.5),
		},
	})

	return Roact.createElement("Frame", {
		LayoutOrder = params.order,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = params.position,
		BackgroundTransparency = 1,
		ZIndex = 15,
		Size = UDim2.fromScale(0.2, 0.8),
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.02, 0),
			FillDirection = Enum.FillDirection.Horizontal,
		}),
		Icon = Roact.createElement("ImageLabel", {
			LayoutOrder = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = COUNTER_ICON,
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.6, 0.6),
			ZIndex = 15,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),
		AmountText = Text({
			order = 2,
			text = `{params.count}/{params.max}`,
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.5, 0.5),
			size = params.textSize,
			index = 15,
			stroke = 0,
		}),
		Plus = Roact.createElement("ImageButton", {
			LayoutOrder = 3,
			ScaleType = Enum.ScaleType.Fit,
			Image = PLUS_ICON,
			ImageColor3 = Color3.fromHex("c4d6ff"),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Size = UDim2.fromScale(0.5, 0.5),
			ZIndex = 15,
			[Roact.Event.MouseButton1Click] = function()
				Sound:PlaySound("UI_Click")
				openStore()
			end,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),
	})
end

local function createBottomBar(params: table)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.925),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.9, 0.1),
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.02, 0),
			FillDirection = Enum.FillDirection.Horizontal,
		}),

		DeleteButton = createActionButton({
			order = 2,
			text = params.isDeleting and "Confirm" or "Delete",
			strokeColor = Color3.fromHex("da5b5d"),
			gradientTop = Color3.fromHex("ff3134"),
			gradientBottom = Color3.fromHex("822b2d"),
			action = params.onDelete,
		}),

		SearchBar = Roact.createElement("Frame", {
			LayoutOrder = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 10,
			BackgroundColor3 = Color3.fromHex("3b65a3"),
			Size = UDim2.fromScale(0.57, 1),
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("6f88e1"),
				Thickness = 2,
			}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = SEARCH_ICON,
				BackgroundTransparency = 1,
				ImageTransparency = 0.5,
				Position = UDim2.fromScale(0.06, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.6, 0.6),
				ZIndex = 12,
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),
			TextBox = Roact.createElement("TextBox", {
				TextWrapped = true,
				TextColor3 = Color3.fromHex("ffffff"),
				TextTransparency = 0.5,
				Text = "",
				PlaceholderColor3 = Color3.fromHex("ffffff"),
				AnchorPoint = Vector2.new(0, 0.5),
				FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromScale(0.12, 0.5),
				PlaceholderText = "Search pets...",
				TextScaled = true,
				Size = UDim2.fromScale(0.424, 0.5),
				ZIndex = 11,
				[Roact.Ref] = params.textBoxRef,
			}),
			Equipped = createCounter({
				order = 3,
				position = UDim2.fromScale(0.7, 0.5),
				count = params.equippedCount,
				max = params.maxEquipped,
				textSize = UDim2.fromScale(0.45, 0.5),
			}),
			Storage = createCounter({
				order = 4,
				position = UDim2.fromScale(0.97, 0.5),
				count = params.storageCount,
				max = params.maxStored,
				textSize = UDim2.fromScale(0.7, 0.5),
			}),
		}),

		RightButton = createActionButton({
			order = 3,
			text = params.isDeleting and "Cancel" or "Equip Best",
			strokeColor = Color3.fromHex("04da01"),
			gradientTop = Color3.fromHex("00d921"),
			gradientBottom = Color3.fromHex("0e820e"),
			action = params.onRight,
		}),
	})
end

return function(hooks)
	local InventoryReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.InventoryReducer
	end)
	local PetsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.PetsReducer
	end)

	local TextBoxRef = hooks.useValue(Roact.createRef())
	local SearchText, SetSearchText = hooks.useState("")

	hooks.useEffect(function()
		local TextBox = TextBoxRef.value:getValue()
		if TextBox == nil then
			return
		end

		local connection = TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			SetSearchText(string.lower(TextBox.Text or ""))
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	local EquippedPets = {}
	local Pets = {}
	local AllPets = {}

	for id, Pet in pairs(PetsReducer.EquippedPets) do
		local Icon = getPetIcon(UI, Pet.Name)
		local powerData = getPetPower(PetsData, PetsReducer, Pet.Name)
		local petId = tostring(id)

		local PetItem = Item(InventoryReducer, {
			equipped = true,
			deleting = InventoryReducer.DeletedPets[petId] == true and InventoryReducer.DeletingPets == true,
			icon = Icon,
			name = Pet.Name,
			id = petId,
			order = -(powerData * 10000),
			power = `x{FormatNumber(powerData)}`,
			rarity = Pet.Rarity,
			bg_color = Colors[Pet.Rarity] or Color3.fromRGB(255, 255, 255),
			type = "Pet",
		})

		if SearchText == "" or string.find(string.lower(Pet.Name), SearchText, 1, true) then
			EquippedPets[petId] = PetItem
		end

		AllPets[petId] = PetItem
	end

	for id, Pet in pairs(PetsReducer.Pets) do
		local petId = tostring(id)
		if PetsReducer.EquippedPets[petId] == nil then
			local Icon = getPetIcon(UI, Pet.Name)
			local powerData = getPetPower(PetsData, PetsReducer, Pet.Name)

			local PetItem = Item(InventoryReducer, {
				equipped = false,
				deleting = InventoryReducer.DeletedPets[petId] == true and InventoryReducer.DeletingPets == true,
				icon = Icon,
				name = Pet.Name,
				id = petId,
				order = -powerData,
				power = `x{FormatNumber(powerData)}`,
				rarity = Pet.Rarity,
				type = "Pet",
				bg_color = Colors[Pet.Rarity] or Color3.fromRGB(255, 255, 255),
			})

			if SearchText == "" or string.find(string.lower(Pet.Name), SearchText, 1, true) then
				Pets[petId] = PetItem
			end

			AllPets[petId] = PetItem
		end
	end

	local function confirmDeleteSelectedPets()
		Store:dispatch(InventoryActions.setDeletingPets(false))
		for id, deleting in pairs(InventoryReducer.DeletedPets) do
			if deleting == true then
				safePetPromise(PetsService:DeletePet(id), "[PETS UI] Delete pet failed:")
				Store:dispatch(InventoryActions.removeDeletedPet(id))
			end
		end
	end

	local function cancelDeletingPets()
		Store:dispatch(InventoryActions.setDeletingPets(false))
		for id, deleting in pairs(InventoryReducer.DeletedPets) do
			if deleting == true then
				Store:dispatch(InventoryActions.removeDeletedPet(id))
			end
		end
	end

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Visible = InventoryReducer.Inventory == InventoryConstants.Pets,
	}, {
		ScrollFrame = ScrollFrame({
			equippedPets = EquippedPets,
			pets = Pets,
		}),

		Bottom = createBottomBar({
			isDeleting = InventoryReducer.DeletingPets,
			textBoxRef = TextBoxRef.value,
			equippedCount = GetTableLength(PetsReducer.EquippedPets),
			storageCount = GetTableLength(AllPets),
			maxEquipped = InventoryReducer.MaxEquipped,
			maxStored = InventoryReducer.MaxStored,
			onDelete = function()
				if InventoryReducer.DeletingPets == true then
					confirmDeleteSelectedPets()
				else
					Store:dispatch(InventoryActions.setDeletingPets(true))
				end
			end,
			onRight = function()
				if InventoryReducer.DeletingPets == true then
					cancelDeletingPets()
				else
					safePetPromise(PetsService:EquipBest(), "[PETS UI] Equip best failed:")
				end
			end,
		}),
	})
end
