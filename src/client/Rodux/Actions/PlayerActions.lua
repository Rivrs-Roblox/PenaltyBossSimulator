--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local PlayerActions = {
    addMoney1 = Rodux.makeActionCreator("addMoney1", function(value)
        return { value = value }
    end),

    addMoney2 = Rodux.makeActionCreator("addMoney2", function(value)
        return { value = value }
    end),
    
    addRebirth = Rodux.makeActionCreator("addRebirth", function(value)
        return { value = value }
    end),
    
    addWins = Rodux.makeActionCreator("addWins", function(value)
        return { value = value }
    end),

    setVerified = Rodux.makeActionCreator("setVerified", function(value)
        return { value = value }
    end),
}

return PlayerActions