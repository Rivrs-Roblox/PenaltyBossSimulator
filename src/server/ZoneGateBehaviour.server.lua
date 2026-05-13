local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local Zone = require(ReplicatedStorage.Shared.ZonePlus)
local DataService = require(ServerScriptService.Server.Services.DataService)

local enableZoneUnlockEvent = ReplicatedStorage.RemoteEvents:WaitForChild("EnableZoneUnlockEvent")
local disableZoneUnlockEvent = ReplicatedStorage.RemoteEvents:WaitForChild("DisableZoneUnlockEvent")

local zoneGates = CollectionService:GetTagged("ZoneGate")

for _, zoneGate in pairs(zoneGates) do
    local zoneName = zoneGate:GetAttribute("ZoneName")
    local zone = Zone.new(zoneGate)
    zone:setDetection("Centre")

    -- Handle player entering the zone
    zone.playerEntered:Connect(function(player)
        local data = DataService:GetData(player)

        if data == nil then
          return
        end

        if table.find(data.Areas.Unlocked, zoneName) == nil then
          enableZoneUnlockEvent:FireClient(player, zoneName)
        end
    end)

    -- Handle player exiting the zone
    zone.playerExited:Connect(function(player)
        local data = DataService:GetData(player)

        if data == nil then
          return
        end

        if table.find(data.Areas.Unlocked, zoneName) == nil then
          disableZoneUnlockEvent:FireClient(player)
        end
    end)
end