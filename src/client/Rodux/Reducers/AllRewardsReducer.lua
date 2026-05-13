--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- InventoryReducer
local AllRewardsReducer = Rodux.createReducer({
    AllRewards = "TimeRewards",
}, {
    setAllRewards = function(state, action)
        local newState = table.clone(state)
        newState.AllRewards = action.value
        return newState
    end,
})

return AllRewardsReducer