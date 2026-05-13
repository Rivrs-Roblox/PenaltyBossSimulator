-- Knit Packages
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- Services
local DataService
local PetsService
local BoostService
local DataCacheService

local ExitGiftService = Knit.CreateService({
	Name = "ExitGiftService",
	Client = {
		ExitGiftClaimed = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--
function ExitGiftService.Client:ClaimExitGift(player: Player)
	return self.Server:ClaimExitGift(player)
end

-- || Functions || --
function ExitGiftService:ClaimExitGift(player: Player)
	local data = DataService:GetData(player)
	if not data then
		return
	end

	if data.ExitGiftClaimed then
		return { tag = "ExitGift", text = "You have already claimed this gift!", type = "ERROR" }
	end

	for _, reward in ipairs(self.Template.ExitGifts) do
		if reward.Type == "Pet" then
			PetsService:AddPet(player, reward.Name)
		elseif reward.Type == "Boost" then
			BoostService:AddBoost(player, reward.Name, reward.Amount)
		elseif reward.Type == "Currency" then
			DataService:ChangeValue(player, reward.Name, reward.Amount, true)
		end
	end

	data.ExitGiftClaimed = true

	self.Client.ExitGiftClaimed:Fire(player)
	return { tag = "ExitGift", text = "You have successfully claimed your free gift!", type = "SUCCESS" }
end

function ExitGiftService:KnitInit()
	DataService = Knit.GetService("DataService")
	BoostService = Knit.GetService("BoostService")
	PetsService = Knit.GetService("PetsService")
	DataCacheService = Knit.GetService("DataCacheService")

	self.Template = DataCacheService:GetFile("Template")
end

-- KNIT START
function ExitGiftService:KnitStart() end

return ExitGiftService
