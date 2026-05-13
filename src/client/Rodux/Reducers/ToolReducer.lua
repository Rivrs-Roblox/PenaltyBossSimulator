--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- ToolReducer
local ToolReducer = Rodux.createReducer({
    Tools = {},
    CurrentTool = 0
}, {
    setTools = function(state, action)
        local newState = table.clone(state)
        newState.Tools = action.value
        return newState
    end,

    setTool = function(state, action)
        local newState = table.clone(state)
        newState.CurrentTool = action.value
        return newState
    end
})

return ToolReducer