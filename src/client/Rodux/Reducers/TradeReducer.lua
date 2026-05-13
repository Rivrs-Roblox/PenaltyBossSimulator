--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- TradeReducer
local TradeReducer = Rodux.createReducer({
    IncomingRequest = nil,
    OutgoingRequest = nil,

    MyPets = {},
    HisPets = {},

    Ready = false,
    OtherReady = false,
    Timer = 0,

    Trading = false
}, {
    setIncomingRequest = function(state, action)
        local newState = table.clone(state)
        newState.IncomingRequest = action.value
        return newState
    end,

    setOutgoingRequest = function(state, action)
        local newState = table.clone(state)
        newState.OutgoingRequest = action.value
        return newState
    end,

    setMyPets = function(state, action)
        local newState = table.clone(state)
        newState.MyPets = action.value
        return newState
    end,

    setHisPets = function(state, action)
        local newState = table.clone(state)
        newState.HisPets = action.value
        return newState
    end,

    setReady = function(state, action)
        local newState = table.clone(state)
        newState.Ready = action.value
        return newState
    end,

    setOtherReady = function(state, action)
        local newState = table.clone(state)
        newState.OtherReady = action.value
        return newState
    end,

    setTrading = function(state, action)
        local newState = table.clone(state)
        newState.Trading = action.value
        return newState
    end,

    setTimer = function(state, action)
        local newState = table.clone(state)
        newState.Timer = action.value
        return newState
    end
})

return TradeReducer