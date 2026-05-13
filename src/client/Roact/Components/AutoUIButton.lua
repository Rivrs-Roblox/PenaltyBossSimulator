--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Controllers
local AutoController = Knit.GetController("AutoController")

-- Components
local Gradient = require(script.Parent.Gradient)
local Text = require(script.Parent.Text)

return function(params: table)
	setmetatable(params, {
		__index = {
			icon = "",
			text = "Training",
			order = 1,
			visible = true,
			hooks = nil,
			autoType = "AutoTraining",
		},
	})

	local AutoReducer = RoduxHooks.useSelector(params.hooks, function(state)
		return state.AutoReducer
	end)

	local styles, api = RoactSpring.useSpring(params.hooks, function()
		return {
			sizeAlpha = 1,
			rotation = 0,
		}
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		LayoutOrder = params.order,
		Size = UDim2.fromScale(0.8, 0.8),
		Visible = params.visible,
	}, {
		Button = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			[Roact.Event.MouseButton1Click] = function()
				if params.autoType == "AutoTraining" then
					AutoController:AutoTrain()
				elseif params.autoType == "AutoWinning" then
					AutoController:AutoWin()
				end
			end,

			[Roact.Event.MouseEnter] = function()
				api.start({ sizeAlpha = 1.05, rotation = 35, config = { mass = 1, tension = 1000, friction = 50 } })
			end,

			[Roact.Event.MouseLeave] = function()
				api.start({ sizeAlpha = 1, rotation = 0, config = { mass = 1, tension = 1000, friction = 50 } })
			end,

			[Roact.Event.MouseButton1Down] = function()
				api.start({ sizeAlpha = 0.95 })
			end,

			[Roact.Event.MouseButton1Up] = function()
				api.start({ sizeAlpha = 1 })
				Sound:PlaySound("UI_Open")
			end,
		}, {

			ButtonText = Text({
				text = params.text,
				color = Color3.fromHex("fafafa"),
				anchorPoint = Vector2.new(0.5, 1),
				position = UDim2.fromScale(0.5, 0.96),
				size = UDim2.fromScale(0.91, 0.25),
				index = 5,
			}),

			UIGradient = Gradient({
				startColor = AutoReducer[params.autoType] and Color3.fromRGB(111, 255, 0)
					or Color3.fromRGB(255, 62, 62),
				endColor = AutoReducer[params.autoType] and Color3.fromRGB(50, 120, 0) or Color3.fromRGB(136, 45, 29),
				rotation = 90,
			}),
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = AutoReducer[params.autoType] and Color3.fromRGB(40, 100, 0) or Color3.fromRGB(138, 22, 22),
				Thickness = 2,
			}),
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScaleType = 3,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.4),
				ZIndex = 2,
				Image = params.icon,
				Rotation = styles.rotation,
				Size = UDim2.fromScale(0.65, 0.65),
			}, { Ratio = Roact.createElement("UIAspectRatioConstraint", {}) }),
		}),
		Shadow = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("000000"),
			BackgroundTransparency = 0.7,
			Position = UDim2.fromScale(0.5, 0.6),
			ZIndex = 0,
			Size = UDim2.fromScale(1.05, 1.05),
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
		}),
		Ratio = Roact.createElement("UIAspectRatioConstraint", {}),
	})
end
