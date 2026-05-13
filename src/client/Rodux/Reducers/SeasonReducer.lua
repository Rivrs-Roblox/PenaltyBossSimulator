--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- SeasonReducer
local SeasonReducer = Rodux.createReducer({
    Season = 0 :: number,
    Level = 0 :: number,
    Exp = 0 :: number,
    Premium = false :: boolean,

    Rewards = {},
    Premium_Rewards = {},

    Claimed_Rewards = {},
    Claimed_Premium_Rewards = {},

    DailyQuests = {},
    WeeklyQuests = {},

    RemainingDayTime = 0 :: number,
    RemainingWeekTime = 0 :: number
}, {
    setSeason = function(state, action)
        local newState = table.clone(state)
        newState.Season = action.value
        return newState
    end,

    setLevel = function(state, action)
        local newState = table.clone(state)
        newState.Level = action.value
        return newState
    end,

    setExp = function(state, action)
        local newState = table.clone(state)
        newState.Exp = action.value
        return newState
    end,

    setFreeRewards = function(state, action)
        local newState = table.clone(state)
        newState.Rewards = action.value
        return newState
    end,

    setPremiumRewards = function(state, action)
        local newState = table.clone(state)
        newState.Premium_Rewards = action.value
        return newState
    end,

    setClaimedRewards = function(state, action)
        local newState = table.clone(state)
        newState.Claimed_Rewards = action.value
        return newState
    end,

    setClaimedPremiumRewards = function(state, action)
        local newState = table.clone(state)
        newState.Claimed_Premium_Rewards = action.value
        return newState
    end,

    setSeasonQuests = function(state, action)
        local newState = table.clone(state)
        newState.DailyQuests = action.value1
        newState.WeeklyQuests = action.value2
        return newState
    end,

    setRemainingDayTime = function(state, action)
        local newState = table.clone(state)
        newState.RemainingDayTime = action.value
        return newState
    end,

    setRemainingWeekTime = function(state, action)
        local newState = table.clone(state)
        newState.RemainingWeekTime = action.value
        return newState
    end,

    setPremium = function(state, action)
        local newState = table.clone(state)
        newState.Premium = action.value
        return newState
    end,
})

return SeasonReducer