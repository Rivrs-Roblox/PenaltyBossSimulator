--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback

    Visual updated to follow AllRewards SpinWheels style.
    Structure and logic stay on Applications/Spins.
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Frames
local Frames = script.Parent.Frames
local Wheel = require(Frames.Wheel)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")

local function Title()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.04, 0.08),
		Size = UDim2.fromScale(0.55, 0.09),
		ZIndex = 5,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Icon = Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = UI.Rewards or UI.Spin_Wheel or "",
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 5,
		}, {
			Ratio = Roact.createElement("UIAspectRatioConstraint"),
		}),

		Text = Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.82, 1),
			Text = "Spin Wheels",
			TextColor3 = Color3.fromHex("fafafa"),
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5,
		}, {}),
	})
end

local function CloseButton()
	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.94, 0.08),
		BorderColor3 = Color3.fromHex("000000"),
		Size = UDim2.fromScale(0.09, 0.09),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		ZIndex = 10,

		[Roact.Event.MouseButton1Click] = function()
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
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 11,
			Image = "rbxassetid://120045489184571",
			Size = UDim2.fromScale(0.5, 0.5),
		}),

		Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
	})
end

-- Spins
function Spins(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
	}, {
		Content = Blue_Background({
			title = "Spin Wheels",
			titleIcon = UI.Rewards or UI.Spin_Wheel or "",
			size = UDim2.fromScale(0.7, 0.7),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.6,
			condition = UIReducer.CurrentUI == FramesConstants.Spins,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {

			Container = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.96),
				Size = UDim2.fromScale(0.95, 0.8),
				ZIndex = 4,
			}, {
				List = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.02, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				Free = Wheel({
					order = 1,
					type = "Free",
					hooks = hooks,
				}),

				Premium = Wheel({
					order = 2,
					type = "Premium",
					hooks = hooks,
				}),
			}),
		}),
	})
end

Spins = RoactHooks.new(Roact)(Spins)
return Spins
