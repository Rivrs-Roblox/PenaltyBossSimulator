--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- TrailReducer
local TrailsReducer = Rodux.createReducer({
	Trails = {},
	CurrentTrail = 0,
}, {
	setTrails = function(state, action)
		local newState = table.clone(state)
		newState.Trails = action.value
		return newState
	end,

	setTrail = function(state, action)
		local newState = table.clone(state)
		newState.CurrentTrail = action.value
		return newState
	end,
})

return TrailsReducer
