--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local TweenService = game:GetService("TweenService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Gradient = require(Components.Gradient)
local Corner = require(Components.Corner)
local Stroke = require(Components.Stroke)
local Text = require(Components.Text)
local List = require(Components.List)
local ChainItemCard = require(Components.Shop.ChainItemCard)
local GreenButton = require(Components.Buttons.GreenButton)

--Frames
local Info = require(script.Parent.Info)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local ExclusivePackController = Knit.GetController("ExclusivePackController")

-- Services
local DataService = Knit.GetService("DataService")
local ExclusivePackService = Knit.GetService("ExclusivePackService")

-- UI
local Template = DataCacheController:GetFile("Template")
local Colors = DataCacheController:GetFile("Colors")

local ExclusivePack = Template.ExclusivePack
local UI = DataCacheController:GetFile("Images")

local function createHoverDescription(exclusiveChestTable)
	local hoverDescription = ""

	if exclusiveChestTable then
		for i, pet in ipairs(exclusiveChestTable.Pets) do
			hoverDescription = hoverDescription .. pet.Name .. " - " .. pet.Chance .. "%"
			if i < #exclusiveChestTable.Pets then
				hoverDescription = hoverDescription .. "\n"
			end
		end
	end

	return hoverDescription
end

local STEP = 0.236
local BASE_POS = 1

local itemsRef = {}
local chainItemFrameRef = Roact.createRef()
local soldOutRef = Roact.createRef()
local resetButtonRef = Roact.createRef()

ExclusivePackService.ItemClaimed:Connect(function(exclusivePack, id: number)
	task.defer(function()
		local chainFrame = chainItemFrameRef:getValue()
		if not chainFrame then
			return
		end

		local newPosition = UDim2.fromScale(BASE_POS - id * STEP, 0.29)
		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local tween = TweenService:Create(chainFrame, tweenInfo, { Position = newPosition })
		tween:Play()
	end)

	local itemButton = itemsRef[id]:getValue()
	if itemButton then
		itemButton.Interactable = false
		itemButton.ImageColor3 = Color3.fromRGB(58, 56, 56)
	end

	if id + 1 == 22 then
		local soldOut = soldOutRef:getValue()
		local resetButton = resetButtonRef:getValue()
		if soldOut then
			soldOut.Visible = true
		end
		if resetButton then
			resetButton.Visible = true
			resetButton.Interactable = true
		end
		return
	end
	itemButton = itemsRef[id + 1]:getValue()
	if itemButton then
		itemButton.Interactable = true
		itemButton.ImageColor3 = Color3.fromRGB(111, 255, 0)
	end
end)

ExclusivePackService.ExclusivePackReseted:Connect(function(exclusivePack)
	task.defer(function()
		local chainFrame = chainItemFrameRef:getValue()
		if not chainFrame then
			return
		end

		local newPosition = UDim2.fromScale(BASE_POS, 0.29)
		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local tween = TweenService:Create(chainFrame, tweenInfo, { Position = newPosition })
		tween:Play()
	end)

	local itemButton = itemsRef[1]:getValue()
	if itemButton then
		itemButton.Interactable = true
		itemButton.ImageColor3 = Color3.fromRGB(111, 255, 0)
	end

	local soldOut = soldOutRef:getValue()
	if soldOut then
		soldOut.Visible = false
	end
	local resetButton = resetButtonRef:getValue()
	if resetButton then
		resetButton.Visible = false
		resetButton.Interactable = false
	end
end)

return function(hooks)
	local ExclusivePackReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.ExclusivePackReducer
	end)

	local chainFramePos = 1

	local items = {}
	itemsRef = {}
	for index, item in ipairs(ExclusivePackReducer.exclusivePack) do
		if item.Claimed then
			chainFramePos = chainFramePos - STEP
		end
		itemsRef[index] = Roact.createRef()
		local itemDisplayData = ExclusivePack[item.Name]
		items["Item" .. index] = ChainItemCard({
			id = index,
			hooks = hooks,
			pet = (item.Type == "Pet"),
			order = index,
			disabled = (ExclusivePackReducer.exclusivePackCurrentIndex ~= index),
			hover = (if item.Type == "Chest" then createHoverDescription(Template.Shop.ExclusiveChest) else nil),
			roactRef = itemsRef[index],
		}, {
			DisplayName = itemDisplayData.DisplayName,
			Icon = itemDisplayData.Icon,
			Name = item.Name,
			Price = if item.Price == 50 then 49 else item.Price,
			Quantity = item.Quantity,
		})
	end

	return Roact.createElement("ImageLabel", {
		LayoutOrder = 1,
		Image = UI["UI_Bg_BrainRot"],
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ClipsDescendants = true,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = UDim2.fromScale(0.95, 0.95),
	}, {
		-- Gradient = Roact.createElement("UIGradient", {
		-- 	Color = ColorSequence.new({
		-- 		ColorSequenceKeypoint.new(0, Color3.fromHex("ff0772")),
		-- 		ColorSequenceKeypoint.new(1, Color3.fromHex("ff83ae")),
		-- 	}),
		-- 	Rotation = 270,
		-- }),
		Corner = Corner({ radius = 0.04 }),
		Stroke = Stroke({ thick = 3 }),

		Name = Text({
			text = "Unlock OP Rewards!",
			position = UDim2.fromScale(0.22, 0.077),
			size = UDim2.fromScale(0.411, 0.1),
			backgroundTransparency = 1,
			color = Color3.fromRGB(255, 255, 255),
			index = 3,
			stroke = 2,
		}),
		Duration = Text({
			text = "LIMITED!",
			position = UDim2.fromScale(0.85, 0.077),
			size = UDim2.fromScale(0.218, 0.094),
			backgroundTransparency = 1,
			color = Color3.fromRGB(255, 255, 255),
			index = 3,
			stroke = 2,
			align = Enum.TextXAlignment.Right,
		}),

		Content = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.55),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.934, 0.825),
		}, {
			InfoLabel = Roact.createElement("TextLabel", {
				TextWrapped = true,
				TextColor3 = Color3.fromHex("ffffff"),
				Text = "Chances for OP items, pets, & more!",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = 26,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.64),
				TextSize = 14,
				ZIndex = 3,
				TextScaled = true,
				Size = UDim2.fromScale(0.5, 0.1),
			}, {
				["1"] = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("191919"),
					Thickness = 2,
				}),
			}),
			SoldOutLabel = Roact.createElement("TextLabel", {
				TextWrapped = true,
				TextColor3 = Color3.fromHex("ff0000"),
				BorderColor3 = Color3.fromHex("000000"),
				Text = "SOLD OUT!",
				Size = UDim2.fromScale(0.92, 0.45),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = 26,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.2),
				TextScaled = true,
				TextSize = 14,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				Visible = (ExclusivePackReducer.exclusivePackCurrentIndex == 22),
				[Roact.Ref] = soldOutRef,
			}, {
				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("000000"),
					Thickness = 3,
				}),
			}),
			ResetButton = GreenButton({
				text = "Reset",
				action = function()
					ExclusivePackController:ResetExclusivePack()
				end,
				hooks = hooks,
				visible = (ExclusivePackReducer.exclusivePackCurrentIndex == 22),
				pos = UDim2.fromScale(0.5, 0.5),
				size = UDim2.fromScale(0.3, 0.14),
				roactRef = resetButtonRef,
				interactable = (ExclusivePackReducer.exclusivePackCurrentIndex == 22),
			}),
			ChainItemFrame = Roact.createElement("Frame", {
				BorderColor3 = Color3.fromHex("000000"),
				Size = UDim2.fromScale(2, 0.575),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(chainFramePos, 0.29),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				[Roact.Ref] = chainItemFrameRef,
			}, {
				UIGridLayout = Roact.createElement("UIGridLayout", {
					SortOrder = 2,
					CellSize = UDim2.fromScale(0.093, 0.9),
					FillDirectionMaxCells = 1,
					CellPadding = UDim2.fromScale(0.025, 0),
					FillDirection = 1,
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingBottom = UDim.new(0.05, 0),
					PaddingTop = UDim.new(0.05, 0),
					PaddingLeft = UDim.new(0, 0),
				}),
				items = Roact.createFragment(items),
			}),
			InfoFrame = Info(hooks),
		}),
	})
end
