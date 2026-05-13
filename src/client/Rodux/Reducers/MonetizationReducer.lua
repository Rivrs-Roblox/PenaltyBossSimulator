--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- PetsReducer
local MonetizationReducer = Rodux.createReducer({
	Gamepasses = {},
}, {
	setGamepasses = function(state, action)
		local newState = table.clone(state)
		newState.Gamepasses = action.value
		return newState
	end,
})

return MonetizationReducer
