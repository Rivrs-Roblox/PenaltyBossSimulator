--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local ChatCommandService = nil
local DataService = nil

-- Controllers
local DataCacheController = nil
local UIController = nil

-- Commands
local Commands = {
	["/Reset"] = {
		Name = "ResetCommand",
		Function = function(self, ...)
			self:ResetPlayer(...)
		end,
		Admin = true,
	},

	["/Give"] = {
		Name = "GiveCommand",
		Function = function(self, _: Player, text: string)
			self:Give(text)
		end,
		Admin = true,
	},

	["/Teleport"] = {
		Name = "TeleportCommand",
		Function = function(self, _: Player, text: string)
			self:Teleport(text)
		end,
		Admin = true,
	},
	-- ["/UnlockZone"] = {
	-- 	Name = "UnlockZoneCommand",
	-- 	Function = function(self, _: Player, name: string)
	-- 		self:UnlockZone(name)
	-- 	end,
	-- 	Admin = true,
	-- },
	-- ["/Beat"] = {
	-- 	Name = "BeatCommand",
	-- 	Function = function(self, _: Player, name: string)
	-- 		self:Beat(name)
	-- 	end,
	-- 	Admin = true,
	-- },
	-- ["/Data"] = {
	-- 	Name = "DataCommand",
	-- 	Function = function(self, _: Player, name: string)
	-- 		self:Data()
	-- 	end,
	-- 	Admin = true,
	-- },
	["/BuyRifle"] = {
		Name = "BuyRifleCommand",
		Function = function(self, _: Player, text: string)
			self:BuyRifle(text)
		end,
		Admin = true,
	},
	["/EquipRifle"] = {
		Name = "EquipRifleCommand",
		Function = function(self, _: Player, text: string)
			self:EquipRifle(text)
		end,
		Admin = true,
	},
}

-- ChatCommandController
local ChatCommandController = Knit.CreateController({
	Name = "ChatCommandController",

	Template = {},
})

--|| Commands ||-
function ChatCommandController:ResetPlayer()
	ChatCommandService:ResetPlayer()
end
function ChatCommandController:Data()
	ChatCommandService:Data()
end

function ChatCommandController:UnlockZone(name: string)
	ChatCommandService:UnlockZone(name)
end
function ChatCommandController:Give(text: string)
	ChatCommandService:Give(text)
end
function ChatCommandController:Beat(name: string)
	ChatCommandService:Beat(name)
end

function ChatCommandController:BuyRifle(text: string)
	ChatCommandService:BuyRifle(text)
end

function ChatCommandController:EquipRifle(text: string)
	ChatCommandService:EquipRifle(text)
end

function ChatCommandController:Teleport(text: string)
	ChatCommandService:Teleport(text)
end

--|| Knit Lifecycle ||--
function ChatCommandController:KnitInit()
	ChatCommandService = Knit.GetService("ChatCommandService")

	DataCacheController = Knit.GetController("DataCacheController")
	UIController = Knit.GetController("UIController")
	DataService = Knit.GetService("DataService")
	self.Template = DataCacheController:GetFile("Template")
	for cmd, command in Commands do
		if self.Template.Config.Commands == true or command.Admin == false then
			local Command = Instance.new("TextChatCommand")
			Command.Parent = TextChatService
			Command.PrimaryAlias = cmd
			Command.Name = command.Name

			Command.Triggered:Connect(function(originTextSource, unfilteredText)
				command.Function(self, originTextSource, unfilteredText)
			end)
		end
	end
end

return ChatCommandController
