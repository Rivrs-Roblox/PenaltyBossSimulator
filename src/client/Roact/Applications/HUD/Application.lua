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

-- Frames
local Frames = StarterPlayerScripts.Client.Roact.Applications.HUD.Frames
local TopFrame = require(Frames.TopFrame)
local LeftFrame = require(Frames.LeftFrame)
local RightFrame = require(Frames.RightFrame)
local BottomFrame = require(Frames.BottomFrame)
local ActiveEffects = require(Frames.ActiveEffects)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local UI = DataCacheController:GetFile("Images")

-- Hud
function Hud(_, hooks)
	return Roact.createFragment({
		HUD = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			TopFrame = Roact.createElement(TopFrame),
			LeftFrame = Roact.createElement(LeftFrame),
			RightFrame = Roact.createElement(RightFrame),
			BottomFrame = Roact.createElement(BottomFrame),
			ActiveEffects = Roact.createElement(ActiveEffects),
		}),
	})
end

Hud = RoactHooks.new(Roact)(Hud)
return Hud
