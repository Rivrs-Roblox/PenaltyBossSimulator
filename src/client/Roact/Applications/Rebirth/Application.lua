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
local Blue_Background = require(Components.Main.Blue_Background)

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

-- UI
local Template = DataCacheController:GetFile("Template")
local RebirthTable = DataCacheController:GetFile("RebirthTable")

local REBIRTH_ICON = "rbxassetid://113418726949889"
local PROGRESS_ICON = "rbxassetid://87965046776914"

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
			CornerRadius = UDim.new(0, 2),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("334695"),
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
			CornerRadius = UDim.new(0, 2),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("334695"),
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
		BackgroundTransparency = 0.75,
		BackgroundColor3 = Color3.fromHex("000000"),
		Size = UDim2.fromScale(0.793, 1),
		LayoutOrder = params.layoutOrder,
		ZIndex = 3,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),
		Stroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("7c7c7c"),
			Thickness = 2,
		}),

		TitleText = Text({
			text = "Rebirthing cost wins",
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.623, 0.25),
			size = UDim2.fromScale(0.705, 0.3),
			anchorPoint = Vector2.new(0.5, 0.5),
			align = Enum.TextXAlignment.Left,
			stroke = 2,
			strokeColor = Color3.fromHex("535353"),
			index = 4,
		}),

		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = PROGRESS_ICON,
			Position = UDim2.fromScale(0.122, 0.4),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.204, 1.26),
			ZIndex = 4,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),

		ProgressBar = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("340908"),
			BackgroundTransparency = 0.5,
			Position = UDim2.fromScale(0.623, 0.7),
			Size = UDim2.fromScale(0.705, 0.4),
			ZIndex = 4,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 2),
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("934141"),
				Thickness = 2,
			}),
			Bar = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(percentage, 1),
				ZIndex = 4,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 2),
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
				color = Color3.fromHex("ffd900"),
				position = UDim2.fromScale(0.5, 0.5),
				size = UDim2.fromScale(0.8, 0.7),
				stroke = 2,
				strokeColor = Color3.fromHex("934141"),
				index = 5,
			}),
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
		Content = Blue_Background({
			title = "Rebirth",
			titleIcon = REBIRTH_ICON,
			size = UDim2.fromScale(0.7, 0.7),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.3,
			condition = UIReducer.CurrentUI == FramesConstants.Rebirth,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {

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
				stroke = 2,
				strokeColor = Color3.fromHex("143758"),
				index = 5,
			}),

			Center = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.52),
				Size = UDim2.fromScale(0.9, 0.52),
				ZIndex = 3,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.04, 0),
				}),
				Panel = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					LayoutOrder = 0,
					Size = UDim2.fromScale(1, 0.15),
					ZIndex = 3,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						Padding = UDim.new(0.2, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					Current = Roact.createElement("Frame", {
						BackgroundColor3 = Color3.fromHex("6087c5"),
						BorderSizePixel = 0,
						LayoutOrder = 1,
						Size = UDim2.fromScale(0.25, 1),
						ZIndex = 4,
					}, {
						UICorner = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 2),
						}),
						TitleText = Text({
							text = "Current",
							color = Color3.fromHex("ffffff"),
							size = UDim2.fromScale(0.8, 0.6),
							index = 5,
						}),
					}),
					Next = Roact.createElement("Frame", {
						BackgroundColor3 = Color3.fromHex("2e933a"),
						BorderSizePixel = 0,
						LayoutOrder = 2,
						Size = UDim2.fromScale(0.4, 1),
						ZIndex = 4,
					}, {
						UICorner = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 2),
						}),
						TitleText = Text({
							text = "Next (After Rebirth)",
							color = Color3.fromHex("ffffff"),
							size = UDim2.fromScale(0.8, 0.6),
							index = 5,
						}),
					}),
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
				Position = UDim2.fromScale(0.5, 0.88),
				Size = UDim2.fromScale(0.9, 0.15),
				ZIndex = 3,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Top,
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
