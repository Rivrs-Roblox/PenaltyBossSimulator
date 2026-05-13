--[=[
   Owner: JustStop__
   Version: 0.0.1
   Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)
local Size = require(Helpers.Size)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)
local AspectRatio = require(Components.AspectRatio)
local Corner = require(Components.Corner)
local Stroke = require(Components.Stroke)
local List = require(Components.List)
local Image = require(Components.Image)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local CharactersController = Knit.GetController("CharactersController")
local MonetizationController = Knit.GetController("MonetizationController")
local StoreController = Knit.GetController("StoreController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- BowlingCard
return function(params: table, hooks)
	setmetatable(params, {
		__index = {
			id = "" :: string,
			name = "" :: string,
			price = 0 :: number,
			color = Color3.fromRGB(255, 255, 255) :: Color3,
			possessed = false :: boolean,
			equipped = false :: boolean,
			power = 1 :: number,
			image = "rbxassetid://121233306488265" :: string,
			VIP = false :: boolean,
			Reward = false :: boolean,
			StarterPack = false :: boolean,

			multiplier = 1 :: number,
			order = 0 :: number,
		},
	})
	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	local ButtonText = ""
	if params.possessed and not params.equipped then
		ButtonText = "Equip"
	elseif params.possessed and params.equipped then
		ButtonText = "Equipped"
	end

	local ButtonColor
	if params.VIP then
		ButtonColor = Color3.fromHex("ffe13a")
	elseif params.Reward or params.StarterPack or params.RejoinReward then
		ButtonColor = Color3.fromRGB(230, 156, 255)
	else
		ButtonColor = Color3.fromRGB(117, 207, 255)
	end

	if params.possessed and params.equipped then
		ButtonColor = Color3.fromRGB(180, 180, 180)
	end

	local PriceTextStr = if not params.possessed
		then (if params.VIP
			then `{Template.Messages.Robux_Icon} {MonetizationController:GetPrice(`Character - {params.displayName}`)}`
			elseif params.Reward then "Daily Rewards Exclusive"
			elseif params.StarterPack then "Starter Pack Exclusive"
			elseif params.RejoinReward then "Rejoin Reward Exclusive"
			else FormatNumber(params.price))
		else ButtonText

	local gradientColors
	local effectColor
	if params.VIP then
		gradientColors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("ffe66b")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("ff491c")),
		})
		effectColor = Color3.fromHex("ffe66b")
	elseif params.Reward or params.StarterPack or params.RejoinReward then
		gradientColors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("b9a1ff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("8e3dff")),
		})
		effectColor = Color3.fromRGB(202, 148, 243)
	else
		gradientColors = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("3aa0ff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("2d63df")),
		})
		effectColor = Color3.fromHex("3aa0ff")
	end

	return Roact.createElement("Frame", {
		LayoutOrder = params.order,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Position = UDim2.fromScale(0.02, 0.1),
		Size = UDim2.fromScale(0.96, 0.96),
		ZIndex = 2,
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("ffffff"),
			Thickness = 3,
		}, {
			UIGradient = Roact.createElement("UIGradient", {
				Color = gradientColors,
				Rotation = -90,
			}),
		}),
		UIGradient = Roact.createElement("UIGradient", {
			Color = gradientColors,
			Rotation = 90,
		}),

		Effect = Roact.createElement("ImageLabel", {
			ImageColor3 = effectColor,
			Image = "rbxassetid://106335669168445",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.4),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = 3,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),
		UICorner = Roact.createElement("UICorner", {}),
		NameText = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			Text = params.displayName,
			AnchorPoint = Vector2.new(0.5, 0.5),
			FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.7),
			TextSize = 14,
			ZIndex = 3,
			TextScaled = true,
			Size = UDim2.fromScale(0.9, 0.12),
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("833f20"),
				Thickness = 2,
			}),
		}),
		Value = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1, -0.053),
			BorderColor3 = Color3.fromHex("000000"),
			ZIndex = 10,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.9, 0.213),
		}, {
			ValueText = Text({
				size = UDim2.fromScale(0.5, 0.65),
				position = UDim2.fromScale(0.761, 0.383),
				text = "x" .. (params.multiplier or 1),
				color = Color3.fromHex("ffd500"),
				index = 3,
				align = Enum.TextXAlignment.Right,
				stroke = 2,
				strokeColor = Color3.fromHex("313131"),
			}),

			Icon = Roact.createElement("ImageLabel", {
				LayoutOrder = 1,
				ScaleType = 3,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = UI.Wins,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.849, 0.15),
				ZIndex = 10,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				Size = UDim2.fromScale(1, 1),
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
			}),
			List = Roact.createElement("UIListLayout", {
				VerticalAlignment = 2,
				SortOrder = 2,
				HorizontalAlignment = 2,
				Padding = UDim.new(0.02, 0),
				ItemLineAlignment = 2,
				FillDirection = 0,
			}),
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.85,
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = 3,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.4),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 2,
			Image = params.image,
			ImageColor3 = params.color or Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromScale(0.9, 0.9),
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),
		PremiumBadge = params.VIP and Roact.createElement("ImageLabel", {
			Image = UI.Premium,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.2, 0.2),
			Position = UDim2.fromScale(0.85, 0.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 4,
		}, {
			AspectRatio = AspectRatio({ ratio = 1 }),
		}),
		Buy = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.88),
			Size = Size(styles, { X = 0.8, Y = 0.18 }),
			ZIndex = 8,
			ClipsDescendants = true,
			BackgroundColor3 = ButtonColor,

			[Roact.Event.MouseButton1Click] = function()
				if not params.possessed then
					if params.VIP then
						StoreController:BuyItem({ name = `Character - {params.displayName}` })
						UIController:HideFrame()
					elseif params.Reward then
						UIController:ShowFrame({ frame = FramesConstants.DailyRewards })
					elseif params.StarterPack then
						UIController:ShowFrame({ frame = FramesConstants.StarterPack })
					elseif params.RejoinReward then
						UIController:ShowFrame({ frame = FramesConstants.Rejoin })
					elseif not (params.VIP or params.Reward or params.StarterPack or params.RejoinReward) then
						CharactersController:Buy(params.id)
						UIController:HideFrame()
					end
				else
					if not params.equipped then
						CharactersController:Equip(params.id)
						UIController:HideFrame()
					end
				end
				Sound:PlaySound("UI_Click")
			end,

			[Roact.Event.MouseEnter] = function()
				api.start({ sizeAlpha = 1.1 })
			end,

			[Roact.Event.MouseLeave] = function()
				api.start({ sizeAlpha = 1 })
			end,

			[Roact.Event.MouseButton1Down] = function()
				api.start({ sizeAlpha = 0.8 })
			end,

			[Roact.Event.MouseButton1Up] = function()
				api.start({ sizeAlpha = 1 })
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 2,
			}),
			List = List({
				fillDirection = Enum.FillDirection.Horizontal,
				horizontalAlignment = Enum.HorizontalAlignment.Center,
				verticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Icon = Image({
				index = 8,
				image = UI.Wins,
				backgroundTransparency = 1,
				size = UDim2.fromScale(0.282, 0.844),
				order = 1,
				visible = params.possessed == false
					and not (params.VIP or params.Reward or params.StarterPack or params.RejoinReward),
				children = { AspectRatio = AspectRatio({ ratio = 1 }) },
			}),
			PriceText = Roact.createElement("TextLabel", {
				TextWrapped = true,
				TextColor3 = Color3.fromHex("ffffff"),
				Text = PriceTextStr,
				AnchorPoint = Vector2.new(0.5, 0.5),
				FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				TextSize = 18,
				ZIndex = 8,
				TextScaled = true,
				Size = UDim2.fromScale(0.70, 0.85),
				LayoutOrder = 2,
			}, {
				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("313131"),
					Thickness = 1.5,
				}),
			}),
		}),
	})
end
