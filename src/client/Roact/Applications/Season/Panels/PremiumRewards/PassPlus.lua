local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local TooltipController = Knit.GetController("TooltipController")
local StoreController = Knit.GetController("StoreController")
local MonetizationController = Knit.GetController("MonetizationController")

-- UI
local UI = DataCacheController:GetFile("Images")

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

local PassPlusPrize = require(script.Parent.PassPlusPrize)

function PassPlus(_, hooks)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0.6,
		Position = UDim2.fromScale(0.68, 0.586),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("3e1162"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.501, 0.65),
	}, {
		TextTitle = Roact.createElement("TextLabel", {
			TextWrapped = true,
			AutoLocalize = false,
			TextColor3 = Color3.fromHex("ffff00"),
			Text = "Brainrot Pass Plus!",
			TextScaled = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Font = 26,
			BackgroundTransparency = 1,
			TextXAlignment = 0,
			Position = UDim2.fromScale(0.5, -0.1),
			ZIndex = 101,
			TextSize = 14,
			Size = UDim2.fromScale(1, 0.15),
		}, {
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("ff6a00")),
				}),
				Rotation = 90,
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ba0000"),
				Thickness = 2.487,
			}),
		}),
		Corner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0.05, 0),
		}),
		Reward4 = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffcc00"),
			Position = UDim2.fromScale(0.5, 0.682),
			BorderColor3 = Color3.fromHex("000000"),
			LayoutOrder = 3,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.94, 0.206),
		}, {
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0.15, 0),
			}),
			Info = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(0.75, 0.723),
				TextWrapped = true,
				AutoLocalize = false,
				TextColor3 = Color3.fromHex("ffffff"),
				BorderColor3 = Color3.fromHex("000000"),
				Text = "Gold Chill Guy",
				TextScaled = true,
				Position = UDim2.fromScale(0.575, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = 26,
				BackgroundTransparency = 1,
				TextXAlignment = 0,
				TextSize = 14,
				TextYAlignment = 0,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("ffffff"),
			}, {
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("ad4800"),
					Thickness = 3,
				}),
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("191919"),
				Thickness = 3,
			}),
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("ff7700")),
				}),
				Rotation = 90,
			}),
			Reward = Roact.createElement("ImageLabel", {
				ScaleType = 3,
				BorderColor3 = Color3.fromHex("000000"),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = UI["Gold Chill Guy"],
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.04, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.25, 1.3),
				[Roact.Event.MouseEnter] = function()
					TooltipController:SetSize(UDim2.fromScale(0.07, 0.05))
					TooltipController:SetText(`x{FormatNumber(6720)} ⚽`)
				end,

				[Roact.Event.MouseLeave] = function()
					TooltipController:SetText(nil)
				end,
			}),
		}),
		Prize = Roact.createElement(PassPlusPrize),
		Stroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("191919"),
			Thickness = 4,
		}),
		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.95),
			BorderColor3 = Color3.fromHex("000000"),
			Size = UDim2.fromScale(0.6, 0.2),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("e5ff00"),
			[Roact.Event.MouseButton1Click] = function()
				Sound:PlaySound("UI_Click")
				StoreController:BuyItem({ name = "Brainrot Pass - Plus" })
			end,
		}, {
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("27d400")),
				}),
				Rotation = 90,
			}),
			Robux = Roact.createElement("ImageLabel", {
				ScaleType = 3,
				BorderColor3 = Color3.fromHex("000000"),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://96573043483506",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.15, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.3, 0.9),
			}),
			Price = Roact.createElement("TextLabel", {
				TextWrapped = true,
				AutoLocalize = false,
				TextColor3 = Color3.fromHex("ffffff"),
				BorderColor3 = Color3.fromHex("000000"),
				Text = `{MonetizationController:GetPrice("Brainrot Pass - Plus")}`,
				Size = UDim2.fromScale(0.65, 0.9),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = 26,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.625, 0.5),
				TextScaled = true,
				TextSize = 14,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("ffffff"),
			}, {
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("245d00"),
					Thickness = 3,
				}),
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("153400"),
				Thickness = 5,
			}),
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0.2, 0),
			}),
		}),
		TitleShadow = Roact.createElement("TextLabel", {
			TextWrapped = true,
			AutoLocalize = false,
			TextColor3 = Color3.fromHex("a51515"),
			Text = "Brainrot Pass Plus!",
			TextScaled = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Font = 26,
			BackgroundTransparency = 1,
			TextXAlignment = 0,
			Position = UDim2.fromScale(0.51, -0.085),
			ZIndex = 100,
			TextSize = 14,
			Size = UDim2.fromScale(1, 0.15),
		}),
	})
end

PassPlus = RoactHooks.new(Roact)(PassPlus)
return PassPlus
