--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Controllers
local UIController = Knit.GetController("UIController")
local FightController = Knit.GetController("FightController")
local TradeController = Knit.GetController("TradeController")

local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Components
local Text = require(script.Parent.Text)

local function TopLargeDisplay(props, hooks)
	setmetatable(props, {
		__index = {
			image = "",
			mainText = "",
			bottomText = "",
			order = 1,
			noButton = false,
			numScrollAdjust = 0,
			storeSection = "Featured",
			plusTouchTargetSize = UDim2.fromScale(1, 1),
			plusMobileTouchTargetSize = UDim2.fromScale(2.2, 2.2),
		},
	})

	if hooks then
		local plusTouchTargetSize = if UserInputService.TouchEnabled
			then props.plusMobileTouchTargetSize
			else props.plusTouchTargetSize

		local function onPlusActivated()
			if FightController.IsFighting or TradeController.IsTrading then
				return
			end

			if props.bottomText ~= "Rebirths" then
				Store:dispatch(UIActions.setStoreTargetSection(props.storeSection))
				Store:dispatch(UIActions.setCurrentUI("Store"))
				UIController:RemoveHUD({ ignoreTopFrame = true })
			else
				Store:dispatch(UIActions.setCurrentUI("Rebirth"))
				UIController:RemoveHUD({ ignoreTopFrame = true })
			end
		end

		return Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.2,
			BackgroundColor3 = Color3.fromHex("000000"),
			LayoutOrder = props.order,
			Size = UDim2.fromScale(0.8, 0.6),
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
			Ratio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 4,
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 2,
			}),

			Plus = if not props.noButton
				then Roact.createElement("Frame", {
					LayoutOrder = 3,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.9, 0.5),
					Size = UDim2.fromScale(0.5, 0.5),
				}, {
					Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
					Icon = Roact.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = "rbxassetid://98999428594161",
						ImageColor3 = Color3.fromHex("b0b0b0"),
						Position = UDim2.fromScale(0.5, 0.5),
						ScaleType = 3,
						Size = UDim2.fromScale(1, 1),
						ZIndex = 2,
					}),
					TouchTarget = Roact.createElement("ImageButton", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						ImageTransparency = 0.1,
						ImageColor3 = Color3.fromHex("b0b0b0"),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = plusTouchTargetSize,
						ZIndex = 3,
						[Roact.Event.Activated] = onPlusActivated,
					}),
				})
				else nil,

			BottomText = Text({
				text = props.bottomText,
				anchorPoint = Vector2.new(0.5, 0),
				position = UDim2.fromScale(0.5, 1.05),
				size = UDim2.fromScale(0.8, 0.4),
				color = Color3.fromHex("ffffff"),
				stroke = 1.5,
				index = 2,
			}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = 3,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.12, 0.5),
				ZIndex = 2,
				Image = props.image,
				Size = UDim2.fromScale(0.3, 0.7),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
			MainText = Text({
				text = FormatNumber(math.round(props.mainText)),
				anchorPoint = Vector2.new(0.5, 0.5),
				position = UDim2.fromScale(0.53, 0.5),
				size = UDim2.fromScale(0.62, 0.6),
				color = Color3.fromHex("ffffff"),
				index = 2,
			}),
		})
	end
end

TopLargeDisplay = RoactHooks.new(Roact)(TopLargeDisplay)
return TopLargeDisplay
