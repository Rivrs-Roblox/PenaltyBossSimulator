--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local ClicksActions = {
    setClicksUnlock = Rodux.makeActionCreator("setClicksUnlock", function(value)
        return { value = value }
    end),

    setCurrentClick = Rodux.makeActionCreator("setCurrentClick", function(value)
        return { value = value }
    end),

    setNewClickEquip = Rodux.makeActionCreator("setNewClickEquip", function(value)
        return { value = value }
    end),

    setGoldClick = Rodux.makeActionCreator("setGoldClick", function(value)
        return { value = value }
    end),

}

return ClicksActions