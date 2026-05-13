--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataService = nil

-- SettingsService
local SettingsService = Knit.CreateService({
    Name = "SettingsService",
    Client = {
        SettingsUpdated = Knit.CreateSignal()
    }
})

--|| Client Functions ||--
function SettingsService.Client:Toggle(player: Player, name: string)
    return self.Server:Toggle(player, name)
end

--|| Functions ||--
function SettingsService:Toggle(player: Player, name: string)
    local data = DataService:GetData(player)
    if not data then return warn("[SETTINGS SERVICE] Player has no data: " .. player.Name) end

    if data.Settings[name] == nil then return end

    data.Settings[name] = not data.Settings[name]
    self.Client.SettingsUpdated:Fire(player, data.Settings)

    return true
end

--|| Knit Lifecycle ||--
function SettingsService:KnitInit()
    DataService = Knit.GetService("DataService")

    print("[SETTINGS SERVICE] Service loaded successfully.")
end

return SettingsService