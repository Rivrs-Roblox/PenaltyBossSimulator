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
local ClicksReducer = Rodux.createReducer({
    ClicksUnlock = 0,
    CurrentClick = 0,
    NewClickEquip = {},
    GoldClick = false,
}, {
    setClicksUnlock = function(state, action)
        local newState = table.clone(state)
        newState.ClicksUnlock = action.value
        return newState
    end,

    setCurrentClick = function(state, action)
        local newState = table.clone(state)
        newState.CurrentClick = action.value
        return newState
    end,

    setNewClickEquip = function(state, action)
        local newState = table.clone(state)
        newState.NewClickEquip = action.value
        return newState
    end,

    setGoldClick = function(state, action)
        local newState = table.clone(state)
        newState.GoldClick = action.value
        return newState
    end,

})

return ClicksReducer