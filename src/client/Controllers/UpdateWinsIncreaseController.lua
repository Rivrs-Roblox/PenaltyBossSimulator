-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Helpers
local FormatNumber = require(ReplicatedStorage.Shared.Helpers.Numbers.FormatNumber)

-- Services
local DataService = nil
local MonetizationService = nil
local FruitsService = nil
local BoostService = nil

local updateWinsIncreaseEvent = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateWinsIncreaseEvent")

-- Store winsIncrease data
local winsIncreaseData = {}

-- UpdateWinsIncreaseController
local UpdateWinsIncreaseController = Knit.CreateController({
	Name = "UpdateWinsIncreaseController",
})

local function reupdateWinsIncrease()
	for _, data in ipairs(winsIncreaseData) do
		-- Hitung nilai akhir dan perbarui UI
		DataService:GetValue("Wins", data.wins, false):andThen(function(value)
			data.textObject.Text = FormatNumber(value)
		end)
	end
end

-- Fungsi untuk mengecek apakah winsIncreaseText sudah ada dalam tabel
local function isWinsIncreaseExists(winsIncreaseText)
	for _, data in ipairs(winsIncreaseData) do
		if data.textObject == winsIncreaseText then
			return true -- Sudah ada, jangan tambahkan lagi
		end
	end
	return false -- Belum ada, bisa ditambahkan
end

local function updateWinsIncrease(winsIncrease, winsIncreaseText)
	-- Cek apakah powerPerSecondText sudah ada sebelum memasukkan data
	if not isWinsIncreaseExists(winsIncreaseText) then
		table.insert(winsIncreaseData, {
			wins = winsIncrease,
			textObject = winsIncreaseText,
		})
	end

	-- Hitung nilai akhir dan perbarui UI
	DataService:GetValue("Wins", winsIncrease, false):andThen(function(value)
		winsIncreaseText.Text = FormatNumber(value)
	end)
end

--|| Knit Lifecycle ||--
function UpdateWinsIncreaseController:KnitInit()
	DataService = Knit.GetService("DataService")
	DataService.RebirthsUpdated:Connect(reupdateWinsIncrease)

	 FruitsService = Knit.GetService("FruitService")
	 FruitsService.FruitsUpdated:Connect(reupdateWinsIncrease)

	 BoostService = Knit.GetService("BoostService")
	 BoostService.BoostsUpdated:Connect(reupdateWinsIncrease)

	MonetizationService = Knit.GetService("MonetizationService")
	MonetizationService.GamepassesUpdate:Connect(reupdateWinsIncrease)

	updateWinsIncreaseEvent.OnClientEvent:Connect(updateWinsIncrease)

	print("[UPDATE POWER PER SECOND CONTROLLER] Controller loaded successfully!")
end

return UpdateWinsIncreaseController
