-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataService = nil

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

-- Controllers
local DataCacheController = nil
local UIController = nil

-- Datas
local Template = nil

local enableZoneUnlockEvent = ReplicatedStorage.RemoteEvents:WaitForChild("EnableZoneUnlockEvent")
local disableZoneUnlockEvent = ReplicatedStorage.RemoteEvents:WaitForChild("DisableZoneUnlockEvent")

-- local zoneUnlockGuis = ReplicatedStorage.UnlockAreas:GetChildren()
local zoneGuiTemplate = ReplicatedStorage.ZoneGui

local inputConnection -- Simpan koneksi di variabel global

local zoneGates

-- ZoneUnlockController
local ZoneUnlockController = Knit.CreateController({
	Name = "ZoneUnlockController",
	UnlockedAreas = {},
})

function ZoneUnlockController:CheckGate(unlockAreas)
	local newZoneGates = {}

	if #zoneGates < 1 then
		return
	end

	for _, zoneGate in zoneGates do
		local zoneName = zoneGate:GetAttribute("ZoneName")
		local shouldDestroy = false

		for _, unlockArea in unlockAreas do
			if zoneName == unlockArea then
				zoneGate.Parent:Destroy()
				shouldDestroy = true
				break
			end
		end

		-- Jika tidak dihapus, tambahkan ke table baru
		if not shouldDestroy then
			table.insert(newZoneGates, zoneGate)
		end
	end

	-- Perbarui zoneGates dengan table baru
	zoneGates = newZoneGates
end

function ZoneUnlockController:UpdateGate()
	for _, zoneGate in zoneGates do
		if zoneGate:GetAttribute("IsSetup") then
			continue
		end

		local zoneName = zoneGate:GetAttribute("ZoneName")
		local zoneGui = zoneGuiTemplate:Clone()
		zoneGui.Adornee = zoneGate.Parent.Lock.Area
		zoneGui.Parent = Players.LocalPlayer.PlayerGui

		for _, teleporter in Template.Areas do
			if teleporter.Id == zoneName then
				local priceText = zoneGui.Requirement.ScoreText
				priceText.Text = FormatNumber(teleporter.Price)

				local unlockButton = zoneGui.EnterButton
				unlockButton.Activated:Connect(function()
					UIController:BuyArea(teleporter)
				end)

				break
			end
		end

		zoneGate:SetAttribute("IsSetup", true)
	end
end

local function unlockZone(zoneId)
	-- Pastikan tidak ada koneksi ganda
	if inputConnection then
		inputConnection:Disconnect()
	end

	-- Simpan koneksi event
	inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end -- Hindari mendeteksi input yang sudah digunakan game

		if input.KeyCode == Enum.KeyCode.E then
			for _, teleporter in Template.Areas do
				if teleporter.Id == zoneId then
					UIController:BuyArea(teleporter)

					break
				end
			end
		end
	end)
end

local function disableUnlockZone()
	-- Periksa apakah ada koneksi event, lalu putuskan
	if inputConnection then
		inputConnection:Disconnect()
		inputConnection = nil -- Kosongkan variabel untuk mencegah pemutusan ulang
	end
end

--|| Knit Lifecycle ||--
function ZoneUnlockController:KnitStart()
	DataService = Knit.GetService("DataService")

	DataService.AreasUpdated:Connect(function(areasUnlocked)
		self.UnlockedAreas = areasUnlocked
		self:CheckGate(areasUnlocked)
		disableUnlockZone()
	end)

	DataCacheController = Knit.GetController("DataCacheController")

	UIController = Knit.GetController("UIController")

	Template = DataCacheController:GetFile("Template")

	enableZoneUnlockEvent.OnClientEvent:Connect(unlockZone)
	disableZoneUnlockEvent.OnClientEvent:Connect(disableUnlockZone)

	zoneGates = CollectionService:GetTagged("ZoneGate")

	self:UpdateGate()

	DataService:GetData(Players.LocalPlayer):andThen(function(data)
		self.UnlockedAreas = data.Areas.Unlocked
		self:CheckGate(data.Areas.Unlocked)
		disableUnlockZone()
	end)

	CollectionService:GetInstanceAddedSignal("ZoneGate"):Connect(function(zoneGate)
		table.insert(zoneGates, zoneGate)

		if #self.UnlockedAreas > 0 then
			self:CheckGate(self.UnlockedAreas)
		end

		self:UpdateGate()
	end)

	print("[ZONE NOTIFICATION CONTROLLER] Controller loaded successfully!")
end

return ZoneUnlockController
