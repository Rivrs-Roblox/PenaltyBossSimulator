--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local Size = require(Helpers.Size)

-- Controllers
local UIController = Knit.GetController("UIController")

-- Components
local Corner = require(script.Parent.Corner)
local Stroke = require(script.Parent.Stroke)

return function(action, hooks, params)
	setmetatable(params, {
		pos = UDim2.fromScale(0.931, -0.041),
	})

	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = params.pos,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		Size = Size(styles, { X = 0.09, Y = 0.09 }),
		ZIndex = 100,
		[Roact.Event.MouseButton1Click] = function()
			Sound:PlaySound("UI_Close")
			action()
		end,

		[Roact.Event.MouseEnter] = function()
			api.start({ sizeAlpha = 1.1, config = { duration = 0.2 } })
		end,

		[Roact.Event.MouseLeave] = function()
			api.start({ sizeAlpha = 1, config = { duration = 0.2 } })
		end,

		[Roact.Event.MouseButton1Down] = function()
			api.start({ sizeAlpha = 0.8, config = { duration = 0.2 } })
		end,

		[Roact.Event.MouseButton1Up] = function()
			api.start({ sizeAlpha = 1, config = { duration = 0.2 } })
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
			CornerRadius = UDim.new(0, 2),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("8f0000"),
			Thickness = 2,
		}),
		Icon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			ScaleType = 3,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ZIndex = 101,
			Image = "rbxassetid://120045489184571",
			Size = UDim2.fromScale(0.5, 0.5),
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
	})
end
