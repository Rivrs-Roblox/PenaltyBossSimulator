--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataCacheService = nil
local DataService = nil

-- CodesService
local CodesService = Knit.CreateService({
    Name = "CodesService",

    Client = {
        PlayerVerified = Knit.CreateSignal()
    },

    Codes = {},
    Template = {}
})

--|| Client Functions ||--
function CodesService.Client:Redeem(player: Player, code: string)
    return self.Server:Redeem(player, code)
end

function CodesService.Client:Verify(player: Player, code: string)
    return self.Server:Verify(player, code)
end

--|| Functions ||--
function CodesService:Redeem(player: Player, code: string)
    if self.Codes[code] == nil then return { text = self.Template.Messages.Notifications.Code_Not_Exists, type = "ERROR" } end

    local data = DataService:GetData(player)
    if data == nil then return warn("[CODES SERVICE] Player has no data: " .. player.Name) end

    if table.find(data.Codes.Redeemed, code) then return { text = self.Template.Messages.Notifications.Code_Already_Redeemed, type = "ERROR" } end

    table.insert(data.Codes.Redeemed, code)

    self:GetReward(player, self.Codes[code])

    return { text = self.Template.Messages.Notifications.Code_Redeemed, type = "SUCCESS" }
end

function CodesService:GetReward(player: Player, codeData: {})
    if table.find({ "Money1", "Money2", "Wins", "Spins", "Rebirth" }, codeData.RewardType) then
        DataService:ChangeValue(player, codeData.RewardType, codeData.RewardValue, true)
    end
end

function CodesService:Verify(player: Player, code: string)
    if code == "" then return { text = self.Template.Messages.Notifications.No_Name_Provided, type = "ERROR" } end

    local data = DataService:GetData(player)
    if data == nil then return warn("[CODES SERVICE] Player has no data: " .. player.Name) end

    if data.Codes.Verified == true then return { text = self.Template.Messages.Notifications.Already_Verified, type = "ERROR" } end
    
    data.Codes.Verified = true
    self.Client.PlayerVerified:Fire(player, true)
    return { text = self.Template.Messages.Notifications.User_Verified, type = "SUCCESS" }
end

--|| Knit Lifecycle ||--
function CodesService:KnitInit()
    DataCacheService = Knit.GetService("DataCacheService")
    DataService = Knit.GetService("DataService")

    self.Codes = DataCacheService:GetFile("Codes")
    self.Template = DataCacheService:GetFile("Template")

    print("[CODES SERVICE] Service loaded successfully.")
end

return CodesService