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
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Constants
local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local Size = require(Helpers.Size)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Image = require(Components.Image)
local Text = require(Components.Text)
local Gradient = require(Components.Gradient)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")

-- UI
local UI = DataCacheController:GetFile("Images")

-- FreePet
function CTAbutton(props: table, hooks)
	local styles = RoactSpring.useSpring(hooks, function()
		return {
			from = { sizeAlpha = 1, Rotation = 0 },
			to = { Rotation = 36000 },
			loop = true,
			reset = false,
			config = { mass = 1, tension = 1000, friction = 50, duration = 800 },
			default = true,
		}
	end)
	local size, api = RoactSpring.useSpring(hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)
	setmetatable(props, {
		__index = {
			Visible = true,
		},
	})
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(props.position.X, props.position.Y),
		Size = UDim2.fromScale(0.871, 0.8),
		ZIndex = 1,
		LayoutOrder = 1,
		Visible = props.Visible,
	}, {
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),
		Star = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = UI.Star,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.6),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 0.1,
			Rotation = styles.Rotation,
			ZIndex = 0,
		}, {
			UIGradient = Gradient({
				startColor = Color3.fromRGB(255, 255, 0),
				endColor = Color3.fromRGB(255, 200, 0),
				roatation = 90,
			}),
		}),

		CTAbutton = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = props.image,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.6),
			Size = Size(size, { X = props.size.X, Y = props.size.Y }),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ScaleType = Enum.ScaleType.Fit,
			LayoutOrder = 3,

			[Roact.Event.MouseEnter] = function()
				api.start({ sizeAlpha = 1.1, config = { mass = 1, tension = 1000, friction = 50 } })
			end,

			[Roact.Event.MouseLeave] = function()
				api.start({ sizeAlpha = 1 })
			end,

			[Roact.Event.MouseButton1Down] = function()
				api.start({ sizeAlpha = 0.8 })
				if props.frame then
					Sound:PlaySound("UI_Open")
					--SoundController:CreateSound(Players.LocalPlayer.Character, "UI_Open")
					UIController:ShowFrame({ frame = props.frame })
				end
				if props.link then
					props.link()
				end
			end,

			[Roact.Event.MouseButton1Up] = function()
				api.start({ sizeAlpha = 1 })
			end,
		}),
		UpperText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.7, 0.482),
			Text = props.upperText,
			Size = UDim2.fromScale(1, 0.15),
			TextColor3 = Color3.fromRGB(255, 255, 0),
			TextSize = 17.5,
			FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
			TextScaled = true,
			ZIndex = 6,
			Rotation = 20,
		}, {
			Stroke = Roact.createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
				Color = Color3.fromRGB(255, 0, 0),
				Thickness = 1.75,
			}),
		}),
		BottomText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.527, 0.782),
			Text = props.bottomText,
			Size = UDim2.fromScale(1, 0.15),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 17.5,
			FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
			TextScaled = true,
			ZIndex = 6,
		}, {
			Stroke = Roact.createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
				Color = Color3.fromRGB(25, 25, 25),
				Thickness = 1.75,
			}),
		}),
	})
end
CTAbutton = RoactHooks.new(Roact)(CTAbutton)
return CTAbutton
