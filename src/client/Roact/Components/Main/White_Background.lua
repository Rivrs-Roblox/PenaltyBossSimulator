--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local CloseButton = require(Components.CloseButton)
local AspectRatio = require(Components.AspectRatio)
local Title = require(Components.Main.Title)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")
local UI = DataCacheController:GetFile("Images")

return function(params: table, children)
	setmetatable(params, {
		__index = {
			title = "" :: string,
			condition = false :: boolean,
			size = UDim2.fromScale(0.5, 0.5),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.2,
			image = UI.White_Background,
			align = Enum.TextXAlignment.Center,
			color = Color3.fromRGB(255, 255, 255),
			action = function()
				UIController:HideFrame()
			end,
		},
	})

	return Roact.createElement("ImageLabel", {
		Image = params.image,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = params.pos,
		Size = params.size,
		Visible = params.condition,
		ImageColor3 = params.color,
		BackgroundTransparency = 1,
	}, {
		Ratio = AspectRatio({ ratio = params.ratio }),
		Close = CloseButton(params.action, params.hooks, { pos = UDim2.fromScale(0.931, -0.041) }),

		TitleShadow = Title({ title = params.title, shadow = true, align = params.align }),
		TextTitle = Title({ title = params.title, align = params.align }),

		Children = Roact.createFragment(children),
	})
end
