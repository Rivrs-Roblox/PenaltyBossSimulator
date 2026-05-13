--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local NumberWithComma = require(Helpers.Numbers.NumberWithComma)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)
local Text = require(Components.Text)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local CodesController = Knit.GetController("CodesController")
local RejoinController = Knit.GetController("RejoinController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

local player = Players.LocalPlayer

-- Helper: quest progress bar row matching converted Rejoin.lua style
local function QuestBar(progressScale: number, labelText: string, order: number)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0.8,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = UDim2.fromScale(1, 0.25),
		BorderSizePixel = 0,
		LayoutOrder = order,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Stroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("939393"),
			Thickness = 2,
		}),
		ProgressText = Text({
			text = labelText,
			color = Color3.fromHex("ffffff"),
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.9, 0.55),
			index = 2,
			stroke = 1.5,
			strokeColor = Color3.fromHex("951a1a"),
		}),
		Bar = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(math.clamp(progressScale, 0, 1), 1),
			BorderSizePixel = 0,
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
	})
end

-- Rejoin
function Rejoin(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)
	local PlayerReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.PlayerReducer
	end)
	local RejoinReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.RejoinReducer
	end)

	local requiredTime = Template.RejoinReward.RequiredTime

	hooks.useEffect(function()
		if
			RejoinReducer.FirstConnection
			and (os.time() - RejoinReducer.FirstConnection > requiredTime)
			and PlayerReducer.Verified == false
		then
			task.spawn(function()
				CodesController:Verify("Verify")
			end)
		end
	end, { RejoinReducer.FirstConnection, PlayerReducer.Verified, requiredTime })

	local firstConnection = RejoinReducer.FirstConnection or os.time()
	local timeSinceJoin = os.time() - firstConnection
	local rejoinProgress = math.clamp(timeSinceJoin / requiredTime, 0, 1)
	local followProgress = if player:IsInGroup(Template.Config.Group) then 1 else 0
	local claimCount = if timeSinceJoin > requiredTime
			and PlayerReducer.Verified
			and not RejoinReducer.ClaimedRejoinReward
		then 1
		else 0

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Content = Blue_Background({
			title = "Rejoin Reward!",
			titleIcon = "rbxassetid://104309648308024",
			size = UDim2.fromScale(0.7, 0.7),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.3,
			condition = UIReducer.CurrentUI == FramesConstants.Rejoin,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {
			-- "EXCLUSIVE CHARACTER!" heading with blue gradient
			TitleText = Roact.createElement("TextLabel", {
				TextWrapped = true,
				TextColor3 = Color3.fromHex("ffffff"),
				Text = "EXCLUSIVE CHARACTER!",
				TextScaled = true,
				AnchorPoint = Vector2.new(0, 1),
				Font = Enum.Font.FredokaOne,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromScale(0.06, 0.423),
				ZIndex = 101,
				TextSize = 14,
				Size = UDim2.fromScale(0.509, 0.23),
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
						ColorSequenceKeypoint.new(0.433, Color3.fromHex("57ffff")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("2164ff")),
					}),
					Rotation = 90,
				}),
				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.fromHex("ffffff"),
					Thickness = 3,
				}, {
					UIGradient = Roact.createElement("UIGradient", {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHex("1c30b4")),
							ColorSequenceKeypoint.new(1, Color3.fromHex("000000")),
						}),
						Rotation = 90,
					}),
				}),
			}),

			-- Reward item name (golden)
			NameText = Text({
				text = `{Template.RejoinReward and Template.RejoinReward.Name or "Character"}`,
				color = Color3.fromHex("fab81f"),
				position = UDim2.fromScale(0.06, 0.5),
				size = UDim2.fromScale(0.478, 0.075),
				anchorPoint = Vector2.new(0, 0.5),
				align = Enum.TextXAlignment.Left,
				index = 5,
			}),

			-- Glow effect behind pet
			Effect = Roact.createElement("ImageLabel", {
				ImageColor3 = Color3.fromHex("ffd943"),
				Image = "rbxassetid://106335669168445",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.767, 0.362),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.416, 0.546),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),

			-- Pet / item image (right side)
			Item = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.758, 0.324),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				ZIndex = 2,
				Image = Template.RejoinReward.Image,
				Size = UDim2.fromScale(0.33, 0.463),
			}, {
				Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
				-- MultiplierText = Text({
				-- 	text = `x{NumberWithComma(5000)}`,
				-- 	color = Color3.fromHex("ffffff"),
				-- 	position = UDim2.fromScale(0.5, 0.986),
				-- 	size = UDim2.fromScale(0.5, 0.15),
				-- 	index = 100,
				-- 	stroke = 1.5,
				-- }),
				OPText = Roact.createElement("TextLabel", {
					TextWrapped = true,
					TextColor3 = Color3.fromHex("ffffff"),
					Text = "OP!",
					Rotation = -20,
					Font = Enum.Font.FredokaOne,
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.877, 0.499),
					TextSize = 14,
					AnchorPoint = Vector2.new(0.5, 0.5),
					TextScaled = true,
					Size = UDim2.fromScale(0.463, 0.382),
					ZIndex = 2,
				}, {
					UIStroke = Roact.createElement("UIStroke", {
						Color = Color3.fromHex("ffffff"),
						Thickness = 2,
					}, {
						Gradient = Roact.createElement("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromHex("ff5015")),
								ColorSequenceKeypoint.new(1, Color3.fromHex("000000")),
							}),
							Rotation = 134,
						}),
					}),
					Gradient = Roact.createElement("UIGradient", {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHex("ffe100")),
							ColorSequenceKeypoint.new(1, Color3.fromHex("ff3333")),
						}),
						Rotation = 113,
					}),
				}),
			}),

			-- Quest section (bottom half)
			Quest = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.95),
				ZIndex = 5,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.9, 0.4),
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0.05, 0),
				}),

				TitleText = Text({
					text = "Quests:",
					color = Color3.fromHex("fafafa"),
					position = UDim2.fromScale(0.5, 0.21),
					size = UDim2.fromScale(1, 0.15),
					align = Enum.TextXAlignment.Left,
					index = 5,
					order = 1,
				}),

				Rejoin = QuestBar(rejoinProgress, `Rejoin 1 day in a row ({math.floor(rejoinProgress * 100)}%)`, 2),

				Follow = QuestBar(
					followProgress,
					`Follow {Template.RejoinReward and Template.RejoinReward.Follow or "@RivrsGames"} (Roblox) ({followProgress * 100}%)`,
					3
				),

				-- Claim row
				ClaimRow = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 4,
					Size = UDim2.fromScale(1, 0.25),
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					InfoText = Text({
						text = "WILL BE GONE FOREVER SOON!",
						color = Color3.fromHex("fafafa"),
						size = UDim2.fromScale(0.75, 0.6),
						align = Enum.TextXAlignment.Left,
						index = 5,
						order = 1,
					}),
					ClaimButton = Roact.createElement("ImageButton", {
						LayoutOrder = 2,
						Size = UDim2.fromScale(0.25, 1),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromHex("ffffff"),
						[Roact.Event.MouseButton1Click] = function()
							UIController:HideFrame()
							RejoinController:Claim()
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
							text = `Claim ({claimCount})`,
							color = Color3.fromHex("fafafa"),
							position = UDim2.fromScale(0.5, 0.5),
							size = UDim2.fromScale(0.9, 0.5),
							index = 5,
						}),
					}),
				}),
			}),
		}),
	})
end

Rejoin = RoactHooks.new(Roact)(Rejoin)
return Rejoin
