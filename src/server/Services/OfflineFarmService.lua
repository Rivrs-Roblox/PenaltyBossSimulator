-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataService

local OfflineFarmService = Knit.CreateService({
	Name = "OfflineFarmService",
	Client = {},
})

--|| Client Functions ||--

function OfflineFarmService.Client:GetPowerEarned(player: Player)
    self.Server:GetPowerEarned(player)
end

function OfflineFarmService.Client:CheckPowerEarned(player: Player)
    return self.Server:CheckPowerEarned(player)
end

--|| Functions ||--

function OfflineFarmService:GetPowerEarned(player: Player)
    local playerData = DataService:GetData(player)
	if not playerData or not playerData.LastConnection then
		warn("Data atau LastConnection tidak ditemukan untuk " .. player.Name)
		return
	end

	local lastConnection = playerData.LastConnection
	local now = os.time()
	local secondsPassed = now - lastConnection
	local hoursPassed = math.floor(secondsPassed / 3600) -- dibulatkan ke bawah

    -- Clamp hasil ke maksimum 24 jam
	hoursPassed = math.clamp(hoursPassed, 0, 24)

    local powerEarned = 0

    if hoursPassed > 1 then
        powerEarned = math.floor(hoursPassed * 0.04 * playerData.Money2)
    end

    DataService:ChangeValue(player, "Money2", powerEarned, true)
end

function OfflineFarmService:CheckPowerEarned(player: Player)
    local playerData = DataService:GetData(player)
	if not playerData or not playerData.LastConnection then
		warn("Data atau LastConnection tidak ditemukan untuk " .. player.Name)
		return
	end

	local lastConnection = playerData.LastConnection
	local now = os.time()
	local secondsPassed = now - lastConnection
	local hoursPassed = math.floor(secondsPassed / 3600) -- dibulatkan ke bawah

    -- Clamp hasil ke maksimum 24 jam
	hoursPassed = math.clamp(hoursPassed, 0, 24)

    local powerEarned = 0

    if hoursPassed >= 1 then
        powerEarned = math.floor(hoursPassed * 0.04 * playerData.Money2)
    end

    return powerEarned
end

-- KNIT START
function OfflineFarmService:KnitStart()
	DataService = Knit.GetService("DataService")
end

return OfflineFarmService