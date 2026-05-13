--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- BoostsReducer
local GroupReducer = Rodux.createReducer({
	Group = {},
	SelectedInstrument = "Bass",
}, {
	setGroup = function(state, action)
		local newState = table.clone(state)
		newState.Group = action.value
		return newState
	end,
	setSelectedInstrument = function(state, action)
		local newState = table.clone(state)
		newState.SelectedInstrument = action.value
		return newState
	end,
})

return GroupReducer
