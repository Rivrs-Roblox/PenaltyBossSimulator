--[=[
 	Owner: rompionyoann
 	Version: 0.0.1
 	Contact owner if any question, concern or feedback
 ]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- Reducer
local BoostEventReducer = Rodux.createReducer({
	BoostEventCountdown = "00:00",
	CurrentBoostEvent = nil,
}, {
	setBoostEventCountdown = function(state, action)
		local newState = table.clone(state)
		newState.BoostEventCountdown = action.BoostEventCountdown
		return newState
	end,
	setCurrentBoostEvent = function(state, action)
		local newState = table.clone(state)
		newState.CurrentBoostEvent = action.CurrentBoostEvent
		return newState
	end,
})

return BoostEventReducer
