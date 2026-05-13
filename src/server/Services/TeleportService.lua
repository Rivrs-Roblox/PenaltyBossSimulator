--[=[
	Owner: JustStop__
	Version: v0.0.2
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataService = nil
local DataCacheService = nil
local CharactersService = nil

local AuthorizedUsers = {
	7823060855,
	7660212220,
	7660239356,
	7516240581,
	7823986403,
	1621760624,
	3814769116,
}

local function buildCoachPayload(template: table, data: table)
	local payload = {}

	if data and data.Coaches and data.Coaches.Current and data.Coaches.Current ~= 0 then
		local coachTemplate = template.Coaches and template.Coaches[data.Coaches.Current]
		if coachTemplate then
			payload["ActiveCoach"] = coachTemplate
		end
	end

	return payload
end

-- TeleportService
local TeleportService = Knit.CreateService({
	Name = "TeleportService",

	Client = {
		AreaUpdated = Knit.CreateSignal(),
		PlayerTeleported = Knit.CreateSignal(),
	},

	Template = {},
})

--|| Client Functions ||--
function TeleportService.Client:TeleportRequest(player: Player, name: string, params: string)
	return self.Server:TeleportRequest(player, name, params)
end

function TeleportService.Client:BuyTeleporter(player: Player, name: string)
	return self.Server:BuyTeleporter(player, name)
end

--|| Functions ||--
-- Returns teleporter from area name
function TeleportService:GetTeleporter(player: Player, name: string, bypass: boolean?, callback)
	local function try()
		local teleporter = workspace.Teleporters.Teleporters:FindFirstChild(name)
		if not teleporter then
			return
		end

		if name == "Boss" then
			callback(teleporter)
			return
		end

		if not bypass then
			local data = DataService:GetData(player)
			if not data then
				task.delay(0.1, try)
				return
			end

			if table.find(data.Areas.Unlocked, name) == nil then
				callback(false)
				return
			end
		end

		callback(teleporter)
	end

	try()
end

-- Handle player teleport request
function TeleportService:TeleportRequest(player: Player, name: string)
	local userId = Players:GetUserIdFromNameAsync(player.Name)

	local function isAuthorized(id)
		for _, authorizedId in ipairs(AuthorizedUsers) do
			if authorizedId == id then
				return true
			end
		end
		return false
	end

	self:GetTeleporter(player, name, isAuthorized(userId), function(teleporter)
		if teleporter == nil or teleporter == false then
			return
		end
		if not teleporter:IsA("Part") then
			return
		end

		local data = DataService:GetData(player)
		if not data then
			return
		end

		if name ~= "Boss" then
			data.Areas.Current = teleporter.Name
		end

		self.Client.PlayerTeleported:FireAll(player, buildCoachPayload(self.Template, data), data.Inventory.EquippedPets)
		self.Client.AreaUpdated:Fire(player, data.Areas.Current)

		player:RequestStreamAroundAsync(teleporter.Position)

		if player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				player.Character:MoveTo(teleporter.Position)
			end
		end
	end)
end

-- Buy teleporter for player
function TeleportService:BuyTeleporter(player: Player, name: string)
	local data = DataService:GetData(player)
	if table.find(data.Areas.Unlocked, name) then
		return { text = self.Template.Messages.Notifications.Teleporter_Already_Bought, type = "ERROR" }, false
	end

	if data.Wins >= self.Template.Areas[name].Price then
		print("Passe le verif du prix")
		if not table.find(data.BeatenNPCs, self.Template.Areas[name].PreviousBossID) then
			print("Passe pas celui là")
			local BossNotBeaten = self.Template.Areas[name].PreviousBossName
			return { text = self.Template.Messages.Notifications.PreviousBoss_Not_Beaten(BossNotBeaten), type = "ERROR" }
		end
		DataService:AddArea(player, name)
		DataService:ChangeValue(player, "Wins", -self.Template.Areas[name].Price, true)

		return {
			text = self.Template.Messages.Notifications.Teleporter_Bought(name),
			type = "SUCCESS",
		}
	end

	return { text = self.Template.Messages.Notifications.Not_Enough_Money("Wins"), type = "ERROR" }, false
end

--|| Knit Lifecycle ||--
function TeleportService:KnitInit()
	DataService = Knit.GetService("DataService")
	DataCacheService = Knit.GetService("DataCacheService")
	CharactersService = Knit.GetService("CharactersService")

	self.Template = DataCacheService:GetFile("Template")

	Players.PlayerAdded:Connect(function(player: Player)
		player.CharacterAdded:Connect(function()
			if CharactersService.IsChanging[player] then
				return
			end

			print("[TELEPORT SERVICE] Teleporting player to area: " .. self.Template.Config.First_Area_Name)
			self:TeleportRequest(player, self.Template.Config.First_Area_Name)
		end)
	end)

	print("[TELEPORT SERVICE] Service loaded successfully.")
end

return TeleportService
