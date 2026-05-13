--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local White_Background = require(Components.Main.White_Background)
local AspectRatio = require(Components.AspectRatio)
local Text = require(Components.Text)
local List = require(Components.List)

-- Frames
local ExclusivePackFrame = require(script.Parent.Frames.ExclusivePack)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")

-- Store
function ExclusivePack(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.55, 0.55),
		BackgroundTransparency = 1,
	}, {
		Content = White_Background({
			title = "Brainrot Pack",
			size = UDim2.fromScale(1, 1),
			pos = UDim2.fromScale(0.5, 0.5),
			condition = UIReducer.CurrentUI == FramesConstants.ExclusivePack,
			ratio = 1.7,
			hooks = hooks,
		}, {
			Container = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.497, 0.515),
				Size = UDim2.fromScale(0.952, 0.869),
			}, {
				ExclusivePackFrame = ExclusivePackFrame(hooks),
			}),
		}),
	})
end

ExclusivePack = RoactHooks.new(Roact)(ExclusivePack)
return ExclusivePack
