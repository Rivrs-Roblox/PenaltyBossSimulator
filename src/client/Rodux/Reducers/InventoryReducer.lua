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
local InventoryReducer = Rodux.createReducer({
    Inventory = "Pets",

    DeletingPets = false,
    DeletedPets = {},

    MaxEquipped = 4,
    MaxStored = 75
}, {
    setInventory = function(state, action)
        local newState = table.clone(state)
        newState.Inventory = action.value
        return newState
    end,

    setDeletingPets = function(state, action)
        local newState = table.clone(state)
        newState.DeletingPets = action.value
        return newState
    end,

    addDeletedPet = function(state, action)
        local newState = table.clone(state)
        newState.DeletedPets[action.value] = true
        return newState
    end,

    removeDeletedPet = function(state, action)
        local newState = table.clone(state)
        newState.DeletedPets[action.value] = nil
        return newState
    end,

    setMaxEquipped = function(state, action)
        local newState = table.clone(state)
        newState.MaxEquipped = action.value
        return newState
    end,

    setMaxStored = function(state, action)
        local newState = table.clone(state)
        newState.MaxStored = action.value
        return newState
    end
})

return InventoryReducer