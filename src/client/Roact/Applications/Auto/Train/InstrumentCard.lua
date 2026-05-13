local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local UIActions = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions.UIActions)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Image = require(Components.Image)
local Text = require(Components.Text)
local TutorialOutline = require(Components.TutorialOutline)

-- UI
local UI = DataCacheController:GetFile("Images")

return function(params: table)
	setmetatable(params, {
		__index = {
			name = "Drums",
			zone = "Forest",
			image = "Drums",
			LayoutOrder = 0,
			IsAutoTrain = false,
			tutorialVisible = false,
			hooks = nil
		},
	})

	
	return Roact.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = UI.Vertical_Background,
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		LayoutOrder = params.LayoutOrder
	}, {
		Outline = params.IsAutoTrain
				and Roact.createElement("UIStroke", {
					Color = Color3.fromRGB(111, 255, 0),
					Thickness = 3,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					[Roact.Children] = {
						Corner = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0.3, 0.3), -- Adjust this value to match your frame's corner radius
						}),
					},
				})
			or nil,

		InstrumentIcon = Image({
			image = UI[params.image],
			color = Color3.fromRGB(255, 255, 255),
			position = UDim2.fromScale(0.5, 0.25),
			size = UDim2.fromScale(0.7, 0.43),
			backgroundTransparency = 1,
		}),

		InstrumentName = Text({
			text = params.name,
			color = Color3.fromRGB(255, 255, 255),
			position = UDim2.fromScale(0.5, 0.6),
			size = UDim2.fromScale(0.7, 0.15),
			backgroundTransparency = 1,
			stroke = 2,
		}),

		AutoTrainButton = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.8),
			Size = UDim2.fromScale(0.8, 0.2),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			Image = params.IsAutoTrain and UI.Red_Button or UI.Button, 
			ZIndex = 2,

			[Roact.Event.MouseButton1Click] = function()
				--UIController:HideFrame()
			end,
		}, {
			TutorialOutline = TutorialOutline({
				visible = params.tutorialVisible, -- or bind to your tutorial state
				color = Color3.fromRGB(215, 56, 56), -- Optional: customize color
				strokeThickness = 3, -- Optional: customize thickness
				pulseSpeed = 1.2, -- Optional: customize animation speed
				pulseSize = 1.3, -- Optional: customize maximum scale
				hooks = params.hooks
			}),
			ButtonText = Text({
				text = params.IsAutoTrain and "Stop Training" or "Auto Train",
				position = UDim2.fromScale(0.5, 0.45),
				size = UDim2.fromScale(0.7, 0.7),
				color = Color3.fromRGB(255, 255, 255),
				backgroundTransparency = 1,
				stroke = 1.5,
				index = 3,
			}),
		}),
	})
end
