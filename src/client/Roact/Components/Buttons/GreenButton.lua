--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local StarterPLayerScript = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)
local Sound = require(ReplicatedStorage.Packages.Sound)

-- Components
local Components = StarterPLayerScript.Client.Roact.Components
local AspectRatio = require(Components.AspectRatio)
local Text = require(Components.Text)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local Size = require(Helpers.Size)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")

return function(params: table)
	setmetatable(params, {
		__index = {
			text = "No text." :: string,
			pos = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.5, 0.5),
			action = function() end,
			visible = true,
			hooks = nil,
			roactRef = nil,
			interactable = true,
		},
	})

	local styles, api = RoactSpring.useSpring(params.hooks, function()
		return {
			sizeAlpha = 1,
		}
	end)

	return Roact.createElement("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = params.pos,
		Size = Size(styles, { X = params.size.X.Scale, Y = params.size.Y.Scale }),
		Image = UI.Button,
		ScaleType = Enum.ScaleType.Fit,
		Visible = params.visible,
		ZIndex = 3,
		Interactable = params.interactable,
		[Roact.Ref] = params.roactRef,

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
		AspectRatio = AspectRatio({ ratio = 3 }),
		Text = Text({
			text = params.text,
			color = Color3.fromRGB(255, 255, 255),
			backgroundTransparency = 1,
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.fromScale(0.9, 0.5),
			stroke = 2,
			index = 4,
		}),
	})
end
