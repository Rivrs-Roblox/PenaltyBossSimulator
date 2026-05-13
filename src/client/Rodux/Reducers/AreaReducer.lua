--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- AreaReducer
local AreaReducer = Rodux.createReducer({
    Areas = { "Zone1" },
    Area = "Zone1"
}, {
    setAreas = function(state, action)
        local newState = table.clone(state)
        newState.Areas = action.value
        return newState
    end,

    setArea = function(state, action)
        local newState = table.clone(state)
        newState.Area = action.value
        return newState
    end
})

return AreaReducer