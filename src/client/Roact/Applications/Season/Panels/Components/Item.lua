--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local SeasonController = Knit.GetController("SeasonController")
local StoreController = Knit.GetController("StoreController")
local NotificationController = Knit.GetController("NotificationController")
local TooltipController = Knit.GetController("TooltipController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

-- Store
local Store = require(StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Constants
local SeasonConstants = require(StarterPlayerScripts.Client.Roact.Constants.SeasonConstants)

-- Item
return function(params: table)
	setmetatable(params, {
		__index = {
			id = "" :: string,
			title = "" :: string,
			image = "" :: string,
			locked = true :: boolean,
			level = 0 :: number,
			hover = nil :: string,
			hooks = nil,
		},
	})

	local level = RoduxHooks.useSelector(params.hooks, function(state)
		return state.SeasonReducer.Level
	end)
	local premium = RoduxHooks.useSelector(params.hooks, function(state)
		return state.SeasonReducer.Premium
	end)
	local claimedRewards = RoduxHooks.useSelector(params.hooks, function(state)
		return state.SeasonReducer.Claimed_Rewards
	end)
	local claimedPremiumRewards = RoduxHooks.useSelector(params.hooks, function(state)
		return state.SeasonReducer.Claimed_Premium_Rewards
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 0.5),
		BorderColor3 = Color3.fromHex("000000"),
		LayoutOrder = params.level,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.03, 1),
	}, {
		Corner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0.04, 0),
		}),

		Free = Roact.createElement("Frame", {
			LayoutOrder = 1,
			BackgroundColor3 = Color3.fromHex("ff85d0"),
			BorderColor3 = Color3.fromHex("000000"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.9, 0.37),
		}, {
			Number = Roact.createElement("TextLabel", {
				TextWrapped = true,
				AutoLocalize = false,
				TextColor3 = Color3.fromHex("ffffff"),
				BorderColor3 = Color3.fromHex("000000"),
				Text = `x{Template.Season["Rewards"][params.level].Amount}`,
				Size = UDim2.fromScale(0.85, 0.3),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = 26,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.83),
				TextScaled = true,
				TextSize = 14,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 2,
			}, {
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("7a0464"),
					Thickness = 3,
				}),
			}),
			Checkmark = Roact.createElement("ImageLabel", {
				Visible = if table.find(claimedRewards, params.level) ~= nil then true else false,
				ScaleType = 3,
				BorderColor3 = Color3.fromHex("000000"),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://93421256237423",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.85),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.6, 0.5),
				ZIndex = 2,
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("191919"),
				Thickness = 3,
			}),
			Skip = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.85, 0.3),
				Position = UDim2.fromScale(0.5, 0.5),
				BorderColor3 = Color3.fromHex("000000"),
				ZIndex = 4,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("e5ff00"),
				Visible = params.locked and level + 1 == params.level,
				[Roact.Event.MouseButton1Click] = function()
					Sound:PlaySound("UI_Click")
					StoreController:BuyItem({ name = "Season Pass - Skip 1" })
				end,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("27d400")),
					}),
					Rotation = 90,
				}),
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("245d00"),
					Thickness = 5,
				}),
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.3, 0),
				}),
				Label = Roact.createElement("TextLabel", {
					TextWrapped = true,
					TextColor3 = Color3.fromHex("ffffff"),
					BorderColor3 = Color3.fromHex("000000"),
					Text = "Skip",
					Size = UDim2.fromScale(0.95, 0.95),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Font = 26,
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					TextScaled = true,
					TextSize = 14,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromHex("ffffff"),
					ZIndex = 5,
				}, {
					Stroke = Roact.createElement("UIStroke", {
						Color = Color3.fromHex("245d00"),
						Thickness = 3,
					}),
				}),
			}),
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0.2, 0),
			}),
			Claim = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.85, 0.3),
				Position = UDim2.fromScale(0.5, 0.5),
				BorderColor3 = Color3.fromHex("000000"),
				Visible = if not params.locked and table.find(claimedRewards, params.level) == nil then true else false,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("e5ff00"),
				ZIndex = 4,
				[Roact.Event.MouseButton1Click] = function()
					Sound:PlaySound("UI_Click")
					SeasonController:ClaimReward(params.level)
				end,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("27d400")),
					}),
					Rotation = 90,
				}),
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("245d00"),
					Thickness = 5,
				}),
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.3, 0),
				}),
				Label = Roact.createElement("TextLabel", {
					TextWrapped = true,
					TextColor3 = Color3.fromHex("ffffff"),
					BorderColor3 = Color3.fromHex("000000"),
					Text = "Claim",
					Size = UDim2.fromScale(0.95, 0.95),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Font = 26,
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					TextScaled = true,
					TextSize = 14,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromHex("ffffff"),
					ZIndex = 5,
				}, {
					Stroke = Roact.createElement("UIStroke", {
						Color = Color3.fromHex("245d00"),
						Thickness = 3,
					}),
				}),
			}),
			Locked = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("000000"),
				BackgroundTransparency = 0.5,
				Position = UDim2.fromScale(0.5, 0.5),
				BorderColor3 = Color3.fromHex("000000"),
				ZIndex = 3,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				Visible = params.locked,
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.2, 0),
				}),
				Lock = Roact.createElement("ImageLabel", {
					ScaleType = 3,
					BorderColor3 = Color3.fromHex("000000"),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = "rbxassetid://126950907883178",
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.9, 0.85),
					BackgroundColor3 = Color3.fromHex("ffffff"),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(0.5, 0.5),
					ZIndex = 4,
				}),
			}),
			Name = Roact.createElement("TextLabel", {
				TextWrapped = true,
				AutoLocalize = false,
				TextColor3 = Color3.fromHex("ffffff"),
				BorderColor3 = Color3.fromHex("000000"),
				Text = Template.Season["Rewards"][params.level].Title,
				Size = UDim2.fromScale(0.85, 0.3),
				TextScaled = true,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = 26,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.2),
				TextSize = 14,
				TextYAlignment = 0,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 2,
			}, {
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("7a0464"),
					Thickness = 3,
				}),
			}),
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("d29eff")),
				}),
				Rotation = 90,
			}),
			Reward = Roact.createElement("ImageLabel", {
				ScaleType = 3,
				BorderColor3 = Color3.fromHex("000000"),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = if UI[params.image] then UI[params.image] else "rbxassetid://102462674525255",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.7, 0.7),
				[Roact.Event.MouseEnter] = function()
					if params.hover ~= nil then
						TooltipController:SetSize(UDim2.fromScale(0.15, 0.18))
						TooltipController:SetText(`{params.hover}`)
					end
				end,

				[Roact.Event.MouseLeave] = function()
					TooltipController:SetText(nil)
				end,
			}),
		}),

		Premium = Roact.createElement("Frame", {
			LayoutOrder = 3,
			BackgroundColor3 = Color3.fromHex("ffcc00"),
			BorderColor3 = Color3.fromHex("000000"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.9, 0.37),
		}, {
			Number = Roact.createElement("TextLabel", {
				TextWrapped = true,
				AutoLocalize = false,
				TextColor3 = Color3.fromHex("ffffff"),
				BorderColor3 = Color3.fromHex("000000"),
				Text = `x{Template.Season["Premium Rewards"][params.level].Amount}`,
				Size = UDim2.fromScale(0.85, 0.3),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = 26,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.83),
				TextScaled = true,
				TextSize = 14,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 2,
			}, {
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("ad4800"),
					Thickness = 3,
				}),
			}),
			Checkmark = Roact.createElement("ImageLabel", {
				Visible = if table.find(claimedPremiumRewards, params.level) ~= nil then true else false,
				ScaleType = 3,
				BorderColor3 = Color3.fromHex("000000"),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://93421256237423",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.85),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.6, 0.5),
				ZIndex = 2,
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("191919"),
				Thickness = 3,
			}),
			Skip = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.85, 0.3),
				Position = UDim2.fromScale(0.5, 0.5),
				BorderColor3 = Color3.fromHex("000000"),
				ZIndex = 4,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("e5ff00"),
				Visible = params.locked and level + 1 == params.level,
				[Roact.Event.MouseButton1Click] = function()
					Sound:PlaySound("UI_Click")
					StoreController:BuyItem({ name = "Season Pass - Skip 1" })
				end,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("27d400")),
					}),
					Rotation = 90,
				}),
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("245d00"),
					Thickness = 5,
				}),
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.3, 0),
				}),
				Label = Roact.createElement("TextLabel", {
					TextWrapped = true,
					TextColor3 = Color3.fromHex("ffffff"),
					BorderColor3 = Color3.fromHex("000000"),
					Text = "Skip",
					Size = UDim2.fromScale(0.95, 0.95),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Font = 26,
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					TextScaled = true,
					TextSize = 14,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromHex("ffffff"),
					ZIndex = 5,
				}, {
					Stroke = Roact.createElement("UIStroke", {
						Color = Color3.fromHex("245d00"),
						Thickness = 3,
					}),
				}),
			}),
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("ff7700")),
				}),
				Rotation = 90,
			}),
			Claim = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.85, 0.3),
				Position = UDim2.fromScale(0.5, 0.5),
				BorderColor3 = Color3.fromHex("000000"),
				Visible = if not params.locked and table.find(claimedPremiumRewards, params.level) == nil
					then true
					else false,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("e5ff00"),
				ZIndex = 4,
				[Roact.Event.MouseButton1Click] = function()
					Sound:PlaySound("UI_Click")

					if premium then
						SeasonController:PremiumClaimReward(params.level)
					else
						Store:dispatch(UIActions.setCurrentSeasonPassUI(SeasonConstants.PremiumRewards))
						NotificationController:Notify({
							tag = "SeasonPass",
							text = Template.Messages.Notifications.Dont_Have_Season_Pass,
							type = "ERROR",
						})
					end
				end,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("27d400")),
					}),
					Rotation = 90,
				}),
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("245d00"),
					Thickness = 5,
				}),
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.3, 0),
				}),
				Label = Roact.createElement("TextLabel", {
					TextWrapped = true,
					TextColor3 = Color3.fromHex("ffffff"),
					BorderColor3 = Color3.fromHex("000000"),
					Text = "Claim",
					Size = UDim2.fromScale(0.95, 0.95),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Font = 26,
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					TextScaled = true,
					TextSize = 14,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromHex("ffffff"),
					ZIndex = 5,
				}, {
					Stroke = Roact.createElement("UIStroke", {
						Color = Color3.fromHex("245d00"),
						Thickness = 3,
					}),
				}),
			}),
			Locked = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("000000"),
				BackgroundTransparency = 0.5,
				Position = UDim2.fromScale(0.5, 0.5),
				BorderColor3 = Color3.fromHex("000000"),
				ZIndex = 3,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				Visible = params.locked,
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.2, 0),
				}),
				Lock = Roact.createElement("ImageLabel", {
					ScaleType = 3,
					BorderColor3 = Color3.fromHex("000000"),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = "rbxassetid://126950907883178",
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.9, 0.85),
					BackgroundColor3 = Color3.fromHex("ffffff"),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(0.5, 0.5),
					ZIndex = 4,
				}),
			}),
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0.2, 0),
			}),
			Name = Roact.createElement("TextLabel", {
				TextWrapped = true,
				AutoLocalize = false,
				TextColor3 = Color3.fromHex("ffffff"),
				BorderColor3 = Color3.fromHex("000000"),
				Text = Template.Season["Premium Rewards"][params.level].Title,
				Size = UDim2.fromScale(0.85, 0.3),
				TextScaled = true,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = 26,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.2),
				TextSize = 14,
				TextYAlignment = 0,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 2,
			}, {
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("ad4800"),
					Thickness = 3,
				}),
			}),
			Reward = Roact.createElement("ImageLabel", {
				ScaleType = 3,
				BorderColor3 = Color3.fromHex("000000"),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = if UI[Template.Season["Premium Rewards"][params.level].Image]
					then UI[Template.Season["Premium Rewards"][params.level].Image]
					else "rbxassetid://102462674525255",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.7, 0.7),
				[Roact.Event.MouseEnter] = function()
					if params.hover ~= nil then
						TooltipController:SetSize(UDim2.fromScale(0.15, 0.18))
						TooltipController:SetText(`{params.hover}`)
					end
				end,

				[Roact.Event.MouseLeave] = function()
					TooltipController:SetText(nil)
				end,
			}),
		}),

		Level = Roact.createElement("Frame", {
			LayoutOrder = 2,
			BackgroundColor3 = Color3.fromHex("61346a"),
			BorderColor3 = Color3.fromHex("000000"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.35, 0.15),
		}, {
			Number = Roact.createElement("TextLabel", {
				TextWrapped = true,
				AutoLocalize = false,
				TextColor3 = Color3.fromHex("ffffff"),
				BorderColor3 = Color3.fromHex("000000"),
				Text = params.level,
				Size = UDim2.fromScale(0.95, 0.95),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Font = 26,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				TextScaled = true,
				TextSize = 14,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHex("ffffff"),
			}, {
				Stroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("191919"),
					Thickness = 3,
				}),
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("191919"),
				Thickness = 3,
			}),
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0.2, 0),
			}),
			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("5d5ab0")),
				}),
				Rotation = 90,
			}),
		}),

		UIListLayout = Roact.createElement("UIListLayout", {
			VerticalAlignment = 0,
			SortOrder = 2,
			HorizontalAlignment = 0,
			Padding = UDim.new(0.04, 0),
		}),
	})
end
