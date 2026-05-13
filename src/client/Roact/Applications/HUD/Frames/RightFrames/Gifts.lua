--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local Size = require(Helpers.Size)
local FormatDuration = require(Helpers.FormatDuration)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Image = require(Components.Image)
local Text = require(Components.Text)
local Gradient = require(Components.Gradient)
local AspectRatio = require(Components.AspectRatio)
local Stroke = require(Components.Stroke)
local Corner = require(Components.Corner)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")

-- Gifts
function Gifts(_, hooks)
	local RewardsReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.RewardsReducer
	end)

	local timeleft = math.huge
	local claimable = {}
	for _, reward in pairs(RewardsReducer.rewards) do
		if not reward.Claimed and reward.Time <= RewardsReducer.time then
			table.insert(claimable, reward)
		end
		if
			not reward.Claimed
			and reward.Time > RewardsReducer.time
			and reward.Time - RewardsReducer.time < timeleft
		then
			timeleft = reward.Time - RewardsReducer.time
		end
	end

	-- Tentukan teks yang akan ditampilkan di Title
	local labelText
	if #claimable > 0 then
		-- labelText = `{#claimable} Gift{if #claimable > 1 then "s" else ""} Ready`
		labelText = `Gift{if #claimable > 1 then "s" else ""} Ready`
	elseif timeleft < math.huge then
		labelText = FormatDuration(timeleft)
	else
		labelText = "No More Rewards"
	end

	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.06, 0.35),
		Size = UDim2.fromScale(0.94, 0.249),
		ZIndex = 1,
		LayoutOrder = 3,
	}, {
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 3.5,
		}),

		UIListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0.03, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Gifts = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = UI.Background,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.51, 0.518),
			Size = Size(styles, { X = 1, Y = 1 }),
			ScaleType = Enum.ScaleType.Fit,
			LayoutOrder = 1,

			[Roact.Event.MouseEnter] = function()
				api.start({ sizeAlpha = 1.1, config = { mass = 1, tension = 1000, friction = 50 } })
			end,

			[Roact.Event.MouseLeave] = function()
				api.start({ sizeAlpha = 1 })
			end,

			[Roact.Event.MouseButton1Down] = function()
				api.start({ sizeAlpha = 0.8 })
				UIController:ShowFrame({ frame = FramesConstants.Rewards })
				Sound:PlaySound("UI_Open")
			end,

			[Roact.Event.MouseButton1Up] = function()
				api.start({ sizeAlpha = 1 })
			end,
		}, {
			Icon = Image({
				image = UI.Gift,
				position = UDim2.fromScale(0.067, 0.482),
				size = UDim2.fromScale(0.259, 0.992),
				backgroundTransparency = 1,
				children = {
					UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
						AspectRatio = 1,
					}),
				},
			}),

			Title = Text({
				text = labelText,
				position = UDim2.fromScale(0.582, 0.473),
				size = UDim2.fromScale(0.641, 0.441),
				stroke = 1.75,
				color = Color3.fromRGB(255, 255, 255),
				children = {
					UIGradient = Gradient({
						startColor = Color3.fromRGB(255, 200, 0),
						endColor = Color3.fromRGB(255, 255, 0),
						rotation = 90,
					}),
				},
			}),

			Notification = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.96, 0.15),
				Size = UDim2.fromScale(0.3, 0.3),
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),

				Visible = #claimable > 0,
				ZIndex = 10000,
			}, {
				AspectRatio = AspectRatio({ radio = 1 }),
				Corner = Corner({ radius = 1 }),
				Stroke = Stroke({ thick = 1.5 })
			}),
		}),
	})
end

Gifts = RoactHooks.new(Roact)(Gifts)
return Gifts
