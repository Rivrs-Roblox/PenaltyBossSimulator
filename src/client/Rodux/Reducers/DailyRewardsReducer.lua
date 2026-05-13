--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- DailyRewardsReducer
local DailyRewardsReducer = Rodux.createReducer({
    lastRedeemedTimestamp = 0,
    lastRedeemedId = 0,
    rewards = {}
}, {
    setLastRedeemedTimestamp = function(state, action)
        local newState = table.clone(state)
        newState.lastRedeemedTimestamp = action.value
        return newState
    end,

    setLastRedeemedId = function(state, action)
        local newState = table.clone(state)
        newState.lastRedeemedId = action.value
        return newState
    end,

    setDailyRewards = function(state, action)
        local newState = table.clone(state)
        newState.rewards = action.value
        return newState
    end
})

return DailyRewardsReducer