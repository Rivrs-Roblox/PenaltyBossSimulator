--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- InventoryService
local InventoryService = Knit.CreateService({
    Name = "InventoryService",
})

--|| Client Functions ||--

--|| Functions ||--

--|| Knit Lifecycle ||--
function InventoryService:KnitInit()
    print("[INVENTORY SERVICE] Service loaded successfully.")
end

return InventoryService