--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- Reducer
local RewardsReducer = Rodux.createReducer(
    {
        rewards = {},
        time = 0
    },
    {
        setRewards = function(state, action)
            local newState = table.clone(state)
            newState.rewards = action.rewards
            return newState
        end,

        updateReward = function(state, action)
            local newState = table.clone(state)
            newState.rewards[action.index] = action.reward
            return newState
        end,

        addTime = function(state, action)
            local newState = table.clone(state)
            newState.time += action.value
            return newState
        end
    }
)

return RewardsReducer