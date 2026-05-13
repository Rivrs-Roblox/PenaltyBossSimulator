--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local List = require(Components.List)

-- Frames
local StarterPack = require(script.Parent.StartPack)
local Egg = require(script.Parent.Egg)
local EvolutiveEgg = require(script.Parent.EvolutiveEgg)
local ChristmasBundle = require(script.Parent.ChristmasBundle)

-- Featured
return function(hooks)
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.78, 1),
		LayoutOrder = 1,
	}, {
		List = List({
			padding = UDim.new(0.05, 0),
			fillDirection = Enum.FillDirection.Vertical,
			horizontalAlignment = Enum.HorizontalAlignment.Left,
			verticalAlignment = Enum.VerticalAlignment.Top,
		}),
		Egg = Egg(hooks),
		EvolutiveEgg = EvolutiveEgg(hooks),
		-- ChristmasBundle = ChristmasBundle(hooks),
	})
end
