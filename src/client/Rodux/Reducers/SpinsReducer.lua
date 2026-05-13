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
local SpinsReducer = Rodux.createReducer({
	Spins = {
		Free = 0,
		Premium = 0,
		Last_Free_Spin = 0,
	},
}, {
	setSpins = function(state, action)
		local newState = table.clone(state)
		newState.Spins[action.valueType] = action.value
		return newState
	end,

	setLastFreeSpin = function(state, action)
		local newState = table.clone(state)
		newState.Spins.Last_Free_Spin = action.value
		return newState
	end,
})

return SpinsReducer
