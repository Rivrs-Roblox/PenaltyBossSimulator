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

-- Components
local Stroke = require(script.Parent.Stroke)

return function(params: table)
	setmetatable(params, {
		__index = {
			image = "",
			transparency = 0,
			color = Color3.fromRGB(0, 0, 0),
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(1, 1),
			stroke = 0,
			backgroundTransparency = 0,
			backgroundColor = Color3.fromRGB(255, 255, 255),
			visible = true,
			index = 1,
			action = function() end,
			children = {},
			hooks = nil,
			order = 0,
		},
	})

	local styles, api = RoactSpring.useSpring(params.hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = params.backgroundTransparency,
		BackgroundColor3 = params.backgroundColor,
		Position = params.position,
		Image = params.image,
		Size = Size(styles, { X = params.size.X.Scale, Y = params.size.Y.Scale }),
		ZIndex = params.index,
		Visible = params.visible,
		ScaleType = Enum.ScaleType.Fit,
		ImageTransparency = params.transparency,
		LayoutOrder = params.order,

		[Roact.Event.MouseButton1Click] = function()
			Sound:PlaySound("UI_Click")
			--SoundController:CreateSound(Players.LocalPlayer.Character, "UI_Click")
			params.action()
		end,

		[Roact.Event.MouseEnter] = function()
			api.start({ sizeAlpha = 1.1 })
		end,

		[Roact.Event.MouseLeave] = function()
			api.start({ sizeAlpha = 1 })
		end,

		[Roact.Event.MouseButton1Down] = function()
			api.start({ sizeAlpha = 0.8 })
		end,

		[Roact.Event.MouseButton1Up] = function()
			api.start({ sizeAlpha = 1 })
		end,
	}, {
		UIStroke = Stroke({ thick = params.stroke }),

		Roact.createFragment(params.children),
	})
end
