--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local TradeActions = {
    setIncomingRequest = Rodux.makeActionCreator("setIncomingRequest", function(value)
        return { value = value }
    end),

    setOutgoingRequest = Rodux.makeActionCreator("setOutgoingRequest", function(value)
        return { value = value }
    end),

    setMyPets = Rodux.makeActionCreator("setMyPets", function(value)
        return { value = value }
    end),

    setHisPets = Rodux.makeActionCreator("setHisPets", function(value)
        return { value = value }
    end),

    setReady = Rodux.makeActionCreator("setReady", function(value)
        return { value = value}
    end),

    setOtherReady = Rodux.makeActionCreator("setOtherReady", function(value)
        return { value = value}
    end),

    setTrading = Rodux.makeActionCreator("setTrading", function(value)
        return { value = value}
    end),

    setTimer = Rodux.makeActionCreator("setTimer", function(value)
        return { value = value }
    end)
}

return TradeActions