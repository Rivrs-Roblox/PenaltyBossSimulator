--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- Images
local UI = DataCacheController:GetFile("Images")

return function(params: {})
	setmetatable(params, {
		__index = {
			id = "" :: string,
			name = "" :: string,
			mapImage = "" :: string,
			icon = "" :: string,
			unlocked = false :: boolean,
			price = 0 :: number,
			order = 0 :: number,
			action = function() end,
			hooks = nil,
		},
	})

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		LayoutOrder = params.order,
		BackgroundColor3 = Color3.fromHex("2c3856"),
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		ZIndex = 2,
	}, {
		Ratio = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 4,
		}),
		UICorner = Roact.createElement("UICorner", {}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("6d88a8"),
			Thickness = 2,
		}),

		-- Map panel
		Map = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			ClipsDescendants = true,
			BackgroundColor3 = Color3.fromHex("2c3856"),
			Size = UDim2.fromScale(1, 1),
		}, {
			MaskLeft = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromHex("2c3856"),
				ClipsDescendants = true,
				Position = UDim2.fromScale(0, 0.5),
				ZIndex = 3,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.2, 1),
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Rotation = 180,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1, 0),
						NumberSequenceKeypoint.new(0.773, 0, 0),
						NumberSequenceKeypoint.new(1, 0, 0),
					}),
				}),
				UICorner = Roact.createElement("UICorner", {}),
			}),
			Image = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = params.mapImage,
				BackgroundTransparency = 0.5,
				Position = UDim2.fromScale(0.405, 0.491),
				ZIndex = 2,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				Size = UDim2.fromScale(0.791, 2.075),
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 2,
				}),
			}),
			MaskRight = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Color3.fromHex("2c3856"),
				ClipsDescendants = true,
				Position = UDim2.fromScale(0.83, 0.5),
				ZIndex = 3,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.252, 1),
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1, 0),
						NumberSequenceKeypoint.new(0.541, 0, 0),
						NumberSequenceKeypoint.new(1, 0, 0),
					}),
				}),
			}),
		}),

		-- Area icon (flag etc)
		Icon = Roact.createElement("ImageLabel", {
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Fit,
			ImageTransparency = 0.5,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://127153933329087",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.07, 0.5),
			ZIndex = 3,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Size = UDim2.fromScale(0.4, 0.4),
		}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),

		-- Area name
		NameText = Text({
			text = params.name,
			color = Color3.fromHex("eaeaea"),
			position = UDim2.fromScale(0.135, 0.5),
			size = UDim2.fromScale(0.5, 0.3),
			align = Enum.TextXAlignment.Left,
			index = 5,
			stroke = 2,
			strokeColor = Color3.fromHex("0d2c75"),
			anchorPoint = Vector2.new(0, 0.5),
		}),

		-- GO button (unlocked)
		Go = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.85, 0.5),
			ZIndex = 5,
			Size = UDim2.fromScale(0.25, 0.3),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Visible = params.unlocked,
			[Roact.Event.MouseButton1Click] = function()
				Sound:PlaySound("UI_Click")
				params.action()
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("2aeaff"),
				Thickness = 2,
			}),
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("21cede")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("166495")),
				}),
				Rotation = 90,
			}),
			PriceText = Text({
				text = "GO",
				color = Color3.fromHex("ffffff"),
				position = UDim2.fromScale(0.5, 0.5),
				size = UDim2.fromScale(0.588, 0.6),
				index = 5,
			}),
		}),

		-- BUY button (locked)
		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.85, 0.5),
			Size = UDim2.fromScale(0.25, 0.3),
			ZIndex = 5,
			Visible = not params.unlocked,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			[Roact.Event.MouseButton1Click] = function()
				Sound:PlaySound("UI_Click")
				params.action()
			end,
		}, {
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("3fd11e")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("0e7d01")),
				}),
				Rotation = 90,
			}),
			UICorner = Roact.createElement("UICorner", {}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("40ff40"),
				Thickness = 2,
			}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = UI.Wins,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				LayoutOrder = 1,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.85, 0.85),
				ZIndex = 5,
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
			PriceText = Text({
				text = FormatNumber(params.price),
				color = Color3.fromHex("ffffff"),
				position = UDim2.fromScale(0.5, 0.5),
				size = UDim2.fromScale(0.588, 0.6),
				order = 2,
				index = 5,
			}),
			List = Roact.createElement("UIListLayout", {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.02, 0),
				FillDirection = Enum.FillDirection.Horizontal,
			}),
		}),

		-- Lock overlay (when area locked)
		Lock = Roact.createElement("Frame", {
			Visible = not params.unlocked,
			BorderColor3 = Color3.fromHex("000000"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.25,
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("000000"),
			ZIndex = 2,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1), -- only covers map area, not the buy button
		}, {
			UICorner = Roact.createElement("UICorner", {}),
			Icon = Roact.createElement("ImageLabel", {
				LayoutOrder = 1,
				ScaleType = Enum.ScaleType.Fit,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://75544138657538",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.07, 0.5),
				ZIndex = 5,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				Size = UDim2.fromScale(0.4, 0.4),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		}),
	})
end
