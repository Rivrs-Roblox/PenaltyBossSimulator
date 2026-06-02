--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- UI
local UIController = Knit.GetController("UIController")
local DataCacheController = Knit.GetController("DataCacheController")
local MonetizationController = Knit.GetController("MonetizationController")
local UI = DataCacheController:GetFile("Images")

-- Services
local MonetizationService = Knit.GetService("MonetizationService")
local Template = DataCacheController:GetFile("Template")

local function strokeGradient(startColor, endColor, rotation)
	return Roact.createElement("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, startColor),
			ColorSequenceKeypoint.new(1, endColor),
		}),
		Rotation = rotation or 90,
	})
end

local function createTextStroke(thickness, color, children)
	return Roact.createElement("UIStroke", {
		Color = color or Color3.fromRGB(0, 0, 0),
		Thickness = thickness or 1.5,
	}, children)
end

local function createRewardItem(layoutOrder, icon, value)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(0.28, 1),
		ZIndex = 102,
	}, {
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = icon,
			Position = UDim2.fromScale(0.5, 0.48),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 102,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
		}),

		ValueText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.5, 0.9),
			Size = UDim2.fromScale(1, 0.4),
			Text = value,
			TextColor3 = Color3.fromHex("fafafa"),
			TextScaled = true,
			TextWrapped = true,
			ZIndex = 105,
		}, {
			UIStroke = createTextStroke(1.5),
		}),
	})
end

local function getPackReward(pack, index)
	local reward = pack.Rewards[index]
	return reward.Id, reward.Amount
end

-- StarterPack
function StarterPack(_, hooks)
	local StarterPacks = Template.Shop.StarterPacks
	local StarterPacksReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.StarterPacksReducer
	end)

	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	local currentPack = StarterPacks[StarterPacksReducer.BoughtStarterPacks] or StarterPacks[0]
	local robuxIcon = if Template.Messages and Template.Messages.Robux_Icon then Template.Messages.Robux_Icon else ""
	local price = MonetizationController:GetPrice(currentPack.Name) or "190"
	local priceNumber = tonumber(price)
	local oldPrice = if priceNumber then tostring(math.floor(priceNumber * 6.7)) else "1280"
	local hasCharacterReward = currentPack.CharacterIcon ~= nil and currentPack.CharacterIcon ~= ""
	local hasPetReward = currentPack.PetIcon ~= nil and currentPack.PetIcon ~= ""
	local hasDualMainReward = hasCharacterReward and hasPetReward
	local mainIcon = currentPack.PetIcon or currentPack.CharacterIcon or ""
	local moneyRewardId, moneyRewardAmount = getPackReward(currentPack, 1)
	local winsRewardId, winsRewardAmount = getPackReward(currentPack, 2)
	local rebirthRewardId, rebirthRewardAmount = getPackReward(currentPack, 3)
	local mainRewardsSize = if hasDualMainReward then UDim2.fromScale(0.58, 0.9) else UDim2.fromScale(0.46, 0.92)
	local singleRewardPosition = UDim2.fromScale(0.5, 0.5)
	local singleRewardSize = UDim2.fromScale(0.66, 0.92)
	local singleMultiplierPosition = UDim2.fromScale(0.5, 0.86)
	local opTextPosition = if hasDualMainReward then UDim2.fromScale(0.5, 0.2) else UDim2.fromScale(0.5, 0.14)
	local opTextSize = if hasDualMainReward then UDim2.fromScale(0.7, 0.22) else UDim2.fromScale(0.62, 0.18)

	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Visible = UIReducer.CurrentUI == FramesConstants.StarterPack,
		ZIndex = 100,
	}, {
		Main = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("fcfaff"),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.4, 0.4),
			ZIndex = 100,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 2,
			}),

			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 14),
			}),

			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("1b3a9e")),
					ColorSequenceKeypoint.new(0.487, Color3.fromHex("2e72de")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("1b3a9e")),
				}),
				Rotation = 45,
			}),

			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("ffffff"),
				Thickness = 5,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("1b3a9e")),
						ColorSequenceKeypoint.new(0.487, Color3.fromHex("4dabde")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("1b3a9e")),
					}),
					Rotation = -69,
				}),
			}),

			Center = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.85, 0.75),
				ZIndex = 100,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 10),
				}),

				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("ffffff"),
					Thickness = 4,
				}),

				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("b0f7ff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("72afff")),
					}),
					Rotation = 60,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.1, 0),
						NumberSequenceKeypoint.new(1, 0.1, 0),
					}),
				}),

			}),

			TitleText = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				FontFace = Font.fromName("LuckiestGuy", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				Position = UDim2.fromScale(0.017, 0.06),
				Size = UDim2.fromScale(0.6, 0.154),
				Text = `{currentPack.Name}!`,
				TextColor3 = Color3.fromHex("ffffff"),
				TextScaled = true,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 106,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
						ColorSequenceKeypoint.new(0.433, Color3.fromHex("57ffff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("2164ff")),
					}),
					Rotation = 90,
				}),

				UIStroke = createTextStroke(3, Color3.fromHex("ffffff"), {
					UIGradient = strokeGradient(Color3.fromHex("1c30b4"), Color3.fromHex("000000"), 90),
				}),
			}),

			Close = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutoButtonColor = true,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(1.08, 0.1),
				Size = UDim2.fromScale(0.2, 0.2),
				ZIndex = 107,

				[Roact.Event.MouseButton1Click] = function()
					UIController:HideFrame()
				end,
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),

				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),

				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ff362f")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("8d1414")),
					}),
					Rotation = 90,
				}),

				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("8f0000"),
					Thickness = 3,
				}),

				Icon = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://120045489184571",
					Position = UDim2.fromScale(0.5, 0.5),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.5, 0.5),
					ZIndex = 108,
				}),
			}),

			RewardsContent = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.46, 0.48),
				Size = UDim2.fromScale(0.82, 0.58),
				ZIndex = 102,
			}, {
				MainRewards = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.34, 0.48),
					Size = mainRewardsSize,
					ZIndex = 103,
				}, {
					Effect = Roact.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = "rbxassetid://106335669168445",
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1.15, 1.65),
						ZIndex = 101,
					}, {
						Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
					}),

					CharacterItem = hasCharacterReward and Roact.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = currentPack.CharacterIcon,
						Position = hasDualMainReward and UDim2.fromScale(0.34, 0.5) or singleRewardPosition,
						ScaleType = Enum.ScaleType.Fit,
						Size = hasDualMainReward and UDim2.fromScale(0.42, 0.9) or singleRewardSize,
						ZIndex = 103,
					}, {
						Ratio = Roact.createElement("UIAspectRatioConstraint", {}),

						MultiplierText = Roact.createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Font = Enum.Font.FredokaOne,
							Position = hasDualMainReward and UDim2.fromScale(0.5, 0.9) or singleMultiplierPosition,
							Size = UDim2.fromScale(0.65, 0.12),
							Text = currentPack.CharacterMultiplier or currentPack.Multiplier or "",
							TextColor3 = Color3.fromHex("ffffff"),
							TextScaled = true,
							TextWrapped = true,
							ZIndex = 105,
						}, {
							UIStroke = createTextStroke(1.5),
						}),
					}) or nil,

					PetItem = hasPetReward and Roact.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = currentPack.PetIcon,
						Position = hasDualMainReward and UDim2.fromScale(0.66, 0.5) or singleRewardPosition,
						ScaleType = Enum.ScaleType.Fit,
						Size = hasDualMainReward and UDim2.fromScale(0.42, 0.9) or singleRewardSize,
						ZIndex = 103,
					}, {
						Ratio = Roact.createElement("UIAspectRatioConstraint", {}),

						MultiplierText = Roact.createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Font = Enum.Font.FredokaOne,
							Position = hasDualMainReward and UDim2.fromScale(0.5, 0.9) or singleMultiplierPosition,
							Size = UDim2.fromScale(0.65, 0.12),
							Text = currentPack.PetMultiplier or currentPack.Multiplier or "",
							TextColor3 = Color3.fromHex("ffffff"),
							TextScaled = true,
							TextWrapped = true,
							ZIndex = 105,
						}, {
							UIStroke = createTextStroke(1.5),
						}),
					}) or nil,

					FallbackItem = (not hasCharacterReward and not hasPetReward) and Roact.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = mainIcon,
						Position = singleRewardPosition,
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromScale(0.74, 1),
						ZIndex = 103,
					}, {
						Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
					}) or nil,

					OPText = Roact.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						FontFace = Font.fromName("LuckiestGuy", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						Position = opTextPosition,
						Rotation = 20,
						Size = opTextSize,
						Text = if hasDualMainReward
							then "OP Pet + Character!"
							elseif hasPetReward then "OP Pet!"
							elseif hasCharacterReward then "OP Character!"
							else "OP",
						TextColor3 = Color3.fromHex("ffffff"),
						TextScaled = true,
						TextWrapped = true,
						ZIndex = 105,
					}, {
						Gradient = Roact.createElement("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromHex("ffe100")),
								ColorSequenceKeypoint.new(1, Color3.fromHex("ff3333")),
							}),
							Rotation = 90,
						}),

						UIStroke = createTextStroke(2, Color3.fromHex("ffffff"), {
							Gradient = strokeGradient(Color3.fromHex("ff5015"), Color3.fromHex("000000"), 107),
						}),
					}),
				}),

				Items = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					LayoutOrder = 6,
					Position = UDim2.fromScale(0.76, 0.52),
					Size = UDim2.fromScale(0.42, 0.38),
					ZIndex = 102,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						Padding = UDim.new(0.03, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					Reward1 = createRewardItem(1, UI[moneyRewardId], moneyRewardAmount),
					Reward2 = createRewardItem(2, UI[winsRewardId], winsRewardAmount),
					Reward3 = createRewardItem(3, UI[rebirthRewardId], rebirthRewardAmount),
				}),
			}),

			Buy = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutoButtonColor = true,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.75, 0.85),
				Size = styles.sizeAlpha:map(function(sizeAlpha)
					return UDim2.fromScale(sizeAlpha * 0.26, sizeAlpha * 0.26)
				end),
				ZIndex = 104,

				[Roact.Event.MouseButton1Click] = function()
					UIController:HideFrame()
					MonetizationService:PromptPurchase(currentPack.Name, "Packs")
				end,

				[Roact.Event.MouseEnter] = function()
					api.start({ sizeAlpha = 1.05, config = { duration = 0.2 } })
				end,

				[Roact.Event.MouseLeave] = function()
					api.start({ sizeAlpha = 1, config = { duration = 0.2 } })
				end,

				[Roact.Event.MouseButton1Down] = function()
					api.start({ sizeAlpha = 0.905, config = { duration = 0.2 } })
				end,

				[Roact.Event.MouseButton1Up] = function()
					api.start({ sizeAlpha = 1, config = { duration = 0.2 } })
				end,
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 3,
				}),

				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),

				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("28dc1e")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("176329")),
					}),
					Rotation = 90,
				}),

				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("ffffff"),
					Thickness = 2,
				}, {
					UIGradient = Roact.createElement("UIGradient", {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHex("177810")),
							ColorSequenceKeypoint.new(0.485, Color3.fromHex("27bf19")),
							ColorSequenceKeypoint.new(1, Color3.fromHex("177810")),
						}),
						Rotation = -70,
					}),
				}),

				DiscountText = Roact.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
					Position = UDim2.fromScale(0.5, -0.4),
					Size = UDim2.fromScale(0.85, 0.55),
					Text = `{robuxIcon} {oldPrice}`,
					TextColor3 = Color3.fromHex("ffffff"),
					TextScaled = true,
					TextTransparency = 0.4,
					TextWrapped = true,
					ZIndex = 106,
				}, {
					Slice = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromHex("ff0004"),
						BackgroundTransparency = 0.1,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.5, 0.5),
						Rotation = -6,
						Size = UDim2.fromScale(0.85, 0.15),
						ZIndex = 107,
					}),
				}),

				PriceText = Roact.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.85, 0.75),
					Text = `{robuxIcon} {price}`,
					TextColor3 = Color3.fromHex("ffffff"),
					TextScaled = true,
					TextWrapped = true,
					ZIndex = 106,
				}, {}),
			}),
		}),
	})
end

StarterPack = RoactHooks.new(Roact)(StarterPack)
return StarterPack
