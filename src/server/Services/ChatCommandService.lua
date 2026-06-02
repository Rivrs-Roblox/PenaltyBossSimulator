--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local DataService = nil
local TeleportService = nil

local AuthorizedUsers = {
	7823060855,
	7660212220,
	7660239356,
	7516240581,
	7823986403,
	1621760624,
	3814769116,
	8277811848,
	456241570,
	8541573881,
	10757582468,
	7475265620,
	10590365299,
	10757463055,
	9243225098,
	10142393036,
}

-- ChatCommandService
local ChatCommandService = Knit.CreateService({
	Name = "ChatCommandService",
})

--|| Local Functions ||--

local function isAuthorized(id)
	for _, authorizedId in ipairs(AuthorizedUsers) do
		if authorizedId == id then
			return true
		end
	end
	return false
end

--|| Client Functions ||--
function ChatCommandService.Client:ResetPlayer(player: Player)
	return self.Server:ResetPlayer(player)
end
function ChatCommandService.Client:Data(player: Player)
	return self.Server:Data(player)
end

function ChatCommandService.Client:Give(player: Player, text: string)
	return self.Server:Give(player, text)
end
function ChatCommandService.Client:UnlockZone(player: Player, name: string)
	return self.Server:UnlockZone(player, name)
end
function ChatCommandService.Client:Beat(player: Player, name: string)
	return self.Server:Beat(player, name)
end
function ChatCommandService.Client:Teleport(player: Player, text: string)
	return self.Server:Teleport(player, text)
end

--|| Functions ||-
function ChatCommandService:ResetPlayer(player: Player)
	local userId = Players:GetUserIdFromNameAsync(player.Name)
	if not isAuthorized(userId) then
		DataService:_deletePlayerProfile(player)

		pcall(function()
			Players:BanAsync({
				UserIds = { player.UserId },
				Duration = -1,
				DisplayReason = "Cheating attempt",
				PrivateReason = "Unauthorized user tried to use /Reset command",
				ExcludeAltAccounts = false,
				ApplyToUniverse = true,
			})
		end)

		player:Kick("You have been banned for cheating.")

		return
	end

	DataService:_deletePlayerProfile(player)

	player:Kick("Your data has been reset, please log in again!")
end
function ChatCommandService:Data(player: Player)
	local userId = Players:GetUserIdFromNameAsync(player.Name)
	if not isAuthorized(userId) then
		DataService:_deletePlayerProfile(player)

		pcall(function()
			Players:BanAsync({
				UserIds = { player.UserId },
				Duration = -1,
				DisplayReason = "Cheating attempt",
				PrivateReason = "Unauthorized user tried to use /Data command",
				ExcludeAltAccounts = false,
				ApplyToUniverse = true,
			})
		end)

		player:Kick("You have been banned for cheating.")

		return
	end

	local _, playerdata = DataService:GetData(player):await()
	print(playerdata)

	player:Kick("Your data has been reset, please log in again!")
end

function ChatCommandService:Give(player: Player, text: string)
	local userId = Players:GetUserIdFromNameAsync(player.Name)
	if not isAuthorized(userId) then
		DataService:_deletePlayerProfile(player)

		pcall(function()
			Players:BanAsync({
				UserIds = { player.UserId },
				Duration = -1,
				DisplayReason = "Cheating attempt",
				PrivateReason = "Unauthorized user tried to use /Give command",
				ExcludeAltAccounts = false,
				ApplyToUniverse = true,
			})
		end)

		player:Kick("You have been banned for cheating.")

		return
	end

	DataService:ChangeValue(player, string.split(text, " ")[2], tonumber(string.split(text, " ")[3]), true)
end

function ChatCommandService.Client:UnlockZone(player: Player, name: string)
	local userId = Players:GetUserIdFromNameAsync(player.Name)
	if not isAuthorized(userId) then
		DataService:_deletePlayerProfile(player)

		pcall(function()
			Players:BanAsync({
				UserIds = { player.UserId },
				Duration = -1,
				DisplayReason = "Cheating attempt",
				PrivateReason = "Unauthorized user tried to use /UnlockZone command",
				ExcludeAltAccounts = false,
				ApplyToUniverse = true,
			})
		end)

		player:Kick("You have been banned for cheating.")
		return
	end

	return DataService:AddArea(player, string.split(name, " ")[2], true)
end
function ChatCommandService.Client:Beat(player: Player, name: string)
	--return FightService:Beat(player,string.split(name, " ")[2])
end

function ChatCommandService:Teleport(player: Player, text: string)
	return TeleportService:TeleportRequest(player, string.split(text, " ")[2])
end

--|| Knit Lifecycle ||--
function ChatCommandService:KnitInit()
	DataService = Knit.GetService("DataService")
	--FightService = Knit.GetService("FightService")
	TeleportService = Knit.GetService("TeleportService")
end

return ChatCommandService
