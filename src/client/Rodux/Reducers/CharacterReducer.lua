--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- CharacterReducer
local CharacterReducer = Rodux.createReducer({
	Characters = {},
	CurrentCharacter = 0,
}, {
	setCharacters = function(state, action)
		local newState = table.clone(state)
		newState.Characters = action.value
		return newState
	end,

	setCharacter = function(state, action)
		local newState = table.clone(state)
		newState.CurrentCharacter = action.value
		return newState
	end,
})

return CharacterReducer
