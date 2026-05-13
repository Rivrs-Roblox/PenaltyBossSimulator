--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)

-- Controllers
local AutoController = Knit.GetController("AutoController")

function StopAutoWin(_, hooks)
	local autoReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.AutoReducer
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.775),
		LayoutOrder = 4,
		Visible = autoReducer.AutoWinning,
		Size = UDim2.fromScale(0.2, 0.2),
	}, {
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.5,
		}),
		StopAutoWin = Roact.createElement("ImageButton", {
			LayoutOrder = 2,
			ScaleType = 3,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.94, 0.35),
			ImageColor3 = Color3.fromHex("ff3300"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("fcfaff"),
			[Roact.Event.MouseButton1Click] = function()
				AutoController:StopAutoWin()
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromHex("8f0000"),
				Thickness = 3,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHex("ff0000")),
						ColorSequenceKeypoint.new(1, Color3.fromHex("000000")),
					}),
					Rotation = 90,
				}),
			}),
			Title = Text({
				text = "Stop Auto Win",
				position = UDim2.fromScale(0.508, 0.473),
				size = UDim2.fromScale(0.8, 0.5),
				color = Color3.fromHex("ffffff"),
				stroke = 1.5,
			}),

			UIGradient = Roact.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHex("ff362f")),
					ColorSequenceKeypoint.new(1, Color3.fromHex("8d1414")),
				}),
				Rotation = 90,
			}),
		}),
	})
end

StopAutoWin = RoactHooks.new(Roact)(StopAutoWin)
return StopAutoWin
