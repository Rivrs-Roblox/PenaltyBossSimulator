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
local SettingsService = nil

-- SettingsController
local SettingsController = Knit.CreateController({
    Name = "SettingsController"
})

--|| Functions ||--
function SettingsController:Toggle(name: string)
    SettingsService:Toggle(name)
end

--|| Knit Lifecycle ||--
function SettingsController:KnitInit()
    SettingsService = Knit.GetService("SettingsService")

    print("[SETTINGS CONTROLLER] Controller loaded successfully.")
end

return SettingsController