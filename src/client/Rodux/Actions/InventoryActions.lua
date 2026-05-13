--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local InventoryActions = {
    setInventory = Rodux.makeActionCreator("setInventory", function(value)
        return { value = value }
    end),

    setDeletingPets = Rodux.makeActionCreator("setDeletingPets", function(value)
        return { value = value }
    end),

    addDeletedPet = Rodux.makeActionCreator("addDeletedPet", function(value)
        return { value = value }
    end),

    removeDeletedPet = Rodux.makeActionCreator("removeDeletedPet", function(value)
        return { value = value }
    end),

    setMaxEquipped = Rodux.makeActionCreator("setMaxEquipped", function(value)
        return { value = value }
    end),

    setMaxStored = Rodux.makeActionCreator("setMaxStored", function(value)
        return { value = value }
    end),
}

return InventoryActions