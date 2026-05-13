--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local GetTableLength = require(Helpers.GetTableLength)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)
local AspectRatio = require(Components.AspectRatio)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Frames
local Frames = script.Parent.Frames
local Rewards = require(Frames.Rewards.Rewards)
local Friend = require(Frames.Friends.Friend)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local FriendsController = Knit.GetController("FriendsController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")

local function CloseButton()
	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.94, 0.08),
		Size = UDim2.fromScale(0.09, 0.09),
		ZIndex = 20,
		AutoButtonColor = true,

		[Roact.Event.MouseButton1Click] = function()
			Sound:PlaySound("UI_Close")
			UIController:HideFrame()
		end,
	}, {
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("ff362f")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("8d1414")),
			}),
			Rotation = 90,
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
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
			ZIndex = 21,
		}),
		Ratio = AspectRatio({ ratio = 1 }),
	})
end

local function Title()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.04, 0.08),
		Size = UDim2.fromScale(0.55, 0.09),
		ZIndex = 8,
	}, {
		List = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://102801816134630",
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1.2, 1.2),
			ZIndex = 9,
		}, {
			Ratio = AspectRatio({ ratio = 1 }),
		}),
		TitleText = Text({
			text = "Invite Friends",
			color = Color3.fromHex("fafafa"),
			size = UDim2.fromScale(0.8, 1),
			anchorPoint = Vector2.new(0, 0.5),
			align = Enum.TextXAlignment.Left,
			stroke = 1.5,
			strokeColor = Color3.fromHex("15284c"),
			index = 9,
			order = 2,
		}),
	})
end

local function StarsDisplay(stars)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0.8,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.752, 0.08),
		Size = UDim2.fromScale(0.262, 0.09),
		ZIndex = 8,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("939393"),
			Thickness = 2,
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = UI.Stars,
			Position = UDim2.fromScale(0.12, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.9, 0.9),
			ZIndex = 9,
		}, {
			Ratio = AspectRatio({ ratio = 1 }),
		}),
		NumberText = Text({
			text = tostring(stars),
			color = Color3.fromHex("fafafa"),
			position = UDim2.fromScale(0.614, 0.5),
			size = UDim2.fromScale(0.674, 0.8),
			stroke = 1.5,
			strokeColor = Color3.fromHex("15284c"),
			index = 9,
		}),
	})
end

-- Friends
function Friends(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)
	local FriendsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.FriendsReducer
	end)

	local friends = {}

	local function setOnlineStatus(friendTable, onlineFriendTable)
		for _, friend in friendTable do
			for _, onlineFriend in onlineFriendTable do
				if friend.Id == onlineFriend.VisitorId then
					friend.IsOnline = true
					break
				end
			end
		end
	end

	setOnlineStatus(FriendsReducer.Friends, FriendsReducer.OnlineFriends)

	local function NewTable(friendsTable)
		local newTable = {}
		for _, value in friendsTable do
			table.insert(newTable, value)
		end
		return newTable
	end

	local function SortOnlineFriend(friendsTable)
		local out = NewTable(friendsTable)
		table.sort(out, function(a, b)
			local aOnline = if a.IsOnline then 1 else 0
			local bOnline = if b.IsOnline then 1 else 0
			return aOnline < bOnline
		end)
		return out
	end

	local sortedFriend = SortOnlineFriend(FriendsReducer.Friends)

	for i, infos in pairs(sortedFriend) do
		if table.find(FriendsReducer.InvitedFriends, infos.Id) == nil then
			friends[i] = Friend({
				id = infos.Id,
				name = infos.Username,
				online = infos.IsOnline,
				hooks = hooks,
				icon = if infos.AvatarUrl == "" then UI.Player else infos.AvatarUrl,
				order = math.floor(1 / i * 100 + 2),
			})
		end
	end

	local friendsCount = GetTableLength(friends)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Visible = UIReducer.CurrentUI == FramesConstants.Friends,
		ZIndex = 1,
	}, {
		Content = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.7),
			ZIndex = 2,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1.6,
			}),
			UICorner = Roact.createElement("UICorner", {}),
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

			Close = CloseButton(),
			Title = Title(),
			Stars = StarsDisplay(FriendsReducer.Stars),
			Rewards = Rewards(hooks),

			ScrollingFrame = Roact.createElement("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromScale(0, 0),
				ClipsDescendants = true,
				ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
				Position = UDim2.fromScale(0.5, 0.763),
				ScrollBarImageColor3 = Color3.fromHex("386bff"),
				ScrollBarImageTransparency = 0.1,
				ScrollBarThickness = 8,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				Size = UDim2.fromScale(0.95, 0.428),
				ZIndex = 3,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0.05, 0),
					PaddingBottom = UDim.new(0.05, 0),
				}),
				Grid = Roact.createElement("UIGridLayout", {
					CellPadding = UDim2.fromScale(0.027, 0.1),
					CellSize = UDim2.fromScale(0.46, 0.4),
					FillDirectionMaxCells = 2,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Roact.createFragment(friends),

				NoFriends = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = UDim2.fromScale(1, 0.4),
					Visible = friendsCount == 0,
					ZIndex = 4,
				}, {
					Text = Text({
						text = "You've invited all your friends ! 🙁",
						color = Color3.fromHex("ffffff"),
						position = UDim2.fromScale(0.5, 0.5),
						size = UDim2.fromScale(0.9, 0.35),
						stroke = 1.5,
						strokeColor = Color3.fromHex("15284c"),
						index = 5,
					}),
				}),
			}),
		}),
	})
end

Friends = RoactHooks.new(Roact)(Friends)
return Friends
