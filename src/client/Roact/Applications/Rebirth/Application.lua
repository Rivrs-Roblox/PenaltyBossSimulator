--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)
local AspectRatio = require(Components.AspectRatio)
local CloseButton = require(Components.CloseButton)

-- Frames
local Frames = script.Parent.Frames
local Row = require(Frames.Row)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local MonetizationController = Knit.GetController("MonetizationController")
local StoreController = Knit.GetController("StoreController")
local RebirthController = Knit.GetController("RebirthController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")
local RebirthTable = DataCacheController:GetFile("RebirthTable")

local function getRebirthRequirement(rebirth: number)
	if rebirth < #RebirthTable then
		return RebirthTable[rebirth]
	end

	return RebirthTable[#RebirthTable] * math.pow(1.3, rebirth - #RebirthTable)
end

local function getProgressPercent(current: number, total: number)
	if total <= 0 then
		return 0
	end

	return math.min(current / total, 1)
end

local function getProgressText(current: number, total: number)
	local Helpers = ReplicatedStorage.Shared.Helpers
	local FormatNumber = require(Helpers.Numbers.FormatNumber)

	local percentage = 0
	if total > 0 then
		percentage = math.min(math.floor((current / total) * 100), 100)
	end

	return `{FormatNumber(current)}/{FormatNumber(total)} ({percentage}%)`
end

local function BlueButton(params: {})
	setmetatable(params, {
		__index = {
			text = "Button",
			price = "",
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.45, 1),
			layoutOrder = 1,
			action = function() end,
		},
	})

	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Position = params.position,
		Size = params.size,
		LayoutOrder = params.layoutOrder,
		AutoButtonColor = true,
		ZIndex = 5,
		[Roact.Event.MouseButton1Click] = function()
			Sound:PlaySound("UI_Click")
			params.action()
		end,
	}, {
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("377df4")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("1f44b6")),
			}),
			Rotation = 90,
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("5776ff"),
			Thickness = 2,
		}),
		ButtonText = Text({
			text = params.text,
			color = Color3.fromHex("fafafa"),
			position = UDim2.fromScale(0.05, 0.5),
			size = UDim2.fromScale(0.5, 0.45),
			anchorPoint = Vector2.new(0, 0.5),
			align = Enum.TextXAlignment.Left,
			stroke = 1.5,
			strokeColor = Color3.fromHex("15284c"),
			index = 6,
		}),
		PriceText = Text({
			text = params.price,
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.95, 0.5),
			size = UDim2.fromScale(0.5, 0.45),
			anchorPoint = Vector2.new(1, 0.5),
			align = Enum.TextXAlignment.Right,
			stroke = 1.5,
			strokeColor = Color3.fromHex("15284c"),
			index = 6,
		}),
	})
end

local function RebirthButton(params: {})
	setmetatable(params, {
		__index = {
			text = "Rebirth",
			action = function() end,
			layoutOrder = 3,
		},
	})

	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.19, 1),
		LayoutOrder = params.layoutOrder,
		AutoButtonColor = true,
		ZIndex = 5,
		[Roact.Event.MouseButton1Click] = function()
			Sound:PlaySound("UI_Click")
			params.action()
		end,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("4782da"),
			Thickness = 2,
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("3699ef")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("103db0")),
			}),
			Rotation = 90,
		}),
		ButtonText = Text({
			text = params.text,
			color = Color3.fromHex("fafafa"),
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.9, 0.55),
			stroke = 0,
			strokeColor = Color3.fromHex("15284c"),
			index = 6,
		}),
	})
end

local function CustomProgressBar(params: {})
	setmetatable(params, {
		__index = {
			current = 0,
			total = 100,
			layoutOrder = 1,
		},
	})

	local percentage = getProgressPercent(params.current, params.total)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0.8,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = UDim2.fromScale(0.793, 1),
		LayoutOrder = params.layoutOrder,
		ZIndex = 3,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Stroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("939393"),
			Thickness = 2,
		}),
		Bar = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(percentage, 1),
			ZIndex = 3,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
			Gradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("e98533")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("e94343")),
				}),
				Rotation = 90,
			}),
		}),
		ProgressText = Text({
			text = getProgressText(params.current, params.total),
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.8, 0.5),
			stroke = 0,
			strokeColor = Color3.fromHex("15284c"),
			index = 5,
		}),
	})
end

-- Rebirth
function Rebirth(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)
	local PlayerReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.PlayerReducer
	end)

	local currentRebirth = PlayerReducer.Rebirth or 0
	local nextRebirth = currentRebirth + 1
	local currentWins = PlayerReducer.Wins or 0
	local rebirthRequirement = getRebirthRequirement(nextRebirth)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = UIReducer.CurrentUI == FramesConstants.Rebirth,
	}, {
		Popup = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.7),
			ZIndex = 2,
		}, {
			UICorner = Roact.createElement("UICorner", {}),
			Ratio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1.3,
			}),
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("1e314b")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("0a0e27")),
				}),
				Rotation = 90,
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 5,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("3369e6")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("1e388d")),
					}),
					Rotation = 90,
				}),
			}),

			Close = CloseButton(function()
				UIController:HideFrame()
			end, hooks, {
				pos = UDim2.fromScale(0.94, 0.08),
			}),

			Title = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.04, 0.08),
				Size = UDim2.fromScale(0.55, 0.09),
				ZIndex = 4,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0.02, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Icon = Roact.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = UI.Rebirth,
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.16, 1.2),
					LayoutOrder = 1,
					ZIndex = 5,
				}, {
					Ratio = AspectRatio({ ratio = 1 }),
				}),
				TitleText = Text({
					text = "Rebirth",
					color = Color3.fromHex("fafafa"),
					position = UDim2.fromScale(0, 0.5),
					size = UDim2.fromScale(0.8, 1),
					anchorPoint = Vector2.new(0, 0.5),
					align = Enum.TextXAlignment.Left,
					stroke = 1.5,
					strokeColor = Color3.fromHex("15284c"),
					index = 5,
					order = 2,
				}),
			}),

			Top = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.638, 0.08),
				Size = UDim2.fromScale(0.49, 0.09),
				ZIndex = 4,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0.03, 0),
					FillDirection = Enum.FillDirection.Horizontal,
				}),
				Skip1 = BlueButton({
					text = "Skip 1",
					price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice("Rebirth - Skip 1")}`,
					layoutOrder = 2,
					action = function()
						StoreController:BuyItem({ name = "Rebirth - Skip 1" })
					end,
				}),
				Skip5 = BlueButton({
					text = "Skip 5",
					price = `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice("Rebirth - Skip 5")}`,
					layoutOrder = 3,
					action = function()
						StoreController:BuyItem({ name = "Rebirth - Skip 5" })
					end,
				}),
			}),

			InfoText = Text({
				text = "Rebirthing will reset your currency & in exchange give you a multiplier increase!",
				color = Color3.fromHex("fafafa"),
				position = UDim2.fromScale(0.5, 0.21),
				size = UDim2.fromScale(0.9, 0.08),
				stroke = 0,
				index = 5,
			}),

			Center = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.63),
				Size = UDim2.fromScale(0.9, 0.547),
				ZIndex = 3,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.04, 0),
				}),
				RebirthRow = Row({
					name = "Rebirth",
					currentValue = currentRebirth,
					nextValue = nextRebirth,
					layoutOrder = 1,
					size = UDim2.fromScale(1, 0.2),
				}),
				Money2Row = Row({
					name = "Money2",
					currentValue = PlayerReducer.Money2,
					nextValue = 0,
					layoutOrder = 2,
					size = UDim2.fromScale(1, 0.2),
				}),
				MultiplierRow = Row({
					name = "Multiplier",
					currentValue = "+" .. tostring(currentRebirth * 20) .. "%",
					nextValue = "+" .. tostring(nextRebirth * 20) .. "%",
					layoutOrder = 3,
					size = UDim2.fromScale(1, 0.2),
				}),
			}),

			Bottom = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.91),
				Size = UDim2.fromScale(0.9, 0.1),
				ZIndex = 3,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.02, 0),
					FillDirection = Enum.FillDirection.Horizontal,
				}),
				ProgressBar = CustomProgressBar({
					current = currentWins,
					total = rebirthRequirement,
					layoutOrder = 1,
				}),
				RebirthButton = RebirthButton({
					text = "Rebirth",
					layoutOrder = 3,
					action = function()
						RebirthController:Rebirth()
					end,
				}),
			}),
		}),
	})
end

Rebirth = RoactHooks.new(Roact)(Rebirth)
return Rebirth
