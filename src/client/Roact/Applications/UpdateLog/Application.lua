--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Blue_Background = require(Components.Main.Blue_Background)
local Text = require(Components.Text)
local Log = require(script.Parent.Log)

local FramesConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local UIController = Knit.GetController("UIController")
local UpdateLogController = Knit.GetController("UpdateLogController")

local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

-- Constants

function UpdateLog(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	local updateLogs = {}

	for index, logText in ipairs(Template.Config.UpdateLogs) do
		updateLogs[index] = Log({
			Text = logText,
			Index = index,
		}, hooks)
	end

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {

		Content = Blue_Background({
			title = "Update Log",
			titleIcon = UI.UpdateLog,
			size = UDim2.fromScale(0.6, 0.6),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.3,
			condition = UIReducer.CurrentUI == FramesConstants.UpdateLog,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
			action = function()
				UIController:HideFrame()
				UpdateLogController:SetAlreadyRead()
			end,
		}, {
			UpdateVerText = Text({
				text = Template.Config.Version,
				color = Color3.fromHex("ffffff"),
				position = UDim2.fromScale(0.024, 0.982),
				index = 101,
				size = UDim2.fromScale(0.5, 0.05),
				align = Enum.TextXAlignment.Left,
				anchorPoint = Vector2.new(0, 1),
			}),

			DateText = Text({
				text = Template.Config.Date,
				color = Color3.fromHex("ffffff"),
				position = UDim2.fromScale(0.5, 0.175),
				index = 101,
				size = UDim2.fromScale(0.25, 0.05),
			}),

			ScrollingFrame = Roact.createElement("ScrollingFrame", {
				ScrollBarImageColor3 = Color3.fromHex("000000"),
				ScrollBarImageTransparency = 0.32,
				ScrollBarThickness = 4,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.525),
				AutomaticCanvasSize = 3,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.9, 0.6),
				ZIndex = 2,
			}, {

				UIPadding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0.01, 0),
					PaddingLeft = UDim.new(0.005, 0),
					PaddingRight = UDim.new(0.005, 0),
				}),
				List = Roact.createElement("UIListLayout", {
					SortOrder = 2,
					HorizontalAlignment = 0,
					Padding = UDim.new(0.04, 0),
				}),

				Roact.createFragment(updateLogs),
			}),
		}),
	})
end

UpdateLog = RoactHooks.new(Roact)(UpdateLog)
return UpdateLog
