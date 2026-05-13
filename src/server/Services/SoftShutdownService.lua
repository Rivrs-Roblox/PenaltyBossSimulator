--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicateStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- Packages
local Knit = require(ReplicateStorage.Packages.Knit)

-- SoftShutdownService
local SoftShutdownService = Knit.CreateService({
    Name = "SoftShutdownService",

    Client = {
        Update = Knit.CreateSignal()
    }
})

--|| Functions ||--
function SoftShutdownService:CFrameToArray(CoordinateFrame: CFrame)
    return { CoordinateFrame:GetComponents() }
end

function SoftShutdownService:ArrayToCFrame(a: { number })
    return CFrame.new(table.unpack(a))
end

function SoftShutdownService:PlayerAdded(player: Player)
    local TeleportData = player:GetJoinData().TeleportData

    if TeleportData and TeleportData.isSoftShutdown == true then
        local CoordinateFrame = TeleportData.CharacterCFrames[tostring(player.UserId)]

        if CoordinateFrame then
            local Character = player.Character or player.CharacterAdded:Wait()
            local HumanoitRootPart = Character:WaitForChild("HumanoidRootPart") :: BasePart

            if not player:HasAppearanceLoaded() then
                player.CharacterAppearanceLoaded:Wait()
            end

            task.wait(0.01)
            HumanoitRootPart:PivotTo(self:ArrayToCFrame(CoordinateFrame))
        end
    end
end

--|| Knit Lifecycle ||--
function SoftShutdownService:KnitInit()
   -- Players.PlayerAdded:Connect(function(player: Player) self:PlayerAdded(player) end)

    game:BindToClose(function()
        if RunService:IsStudio() then return end

        --workspace:SetAttribute("SS2_ShuttingDown", true)
        for i = 10, 0, -1 do
            self.Client.Update:FireAll(true, i)
            task.wait(1)
        end

        local CurrentPlayers = Players:GetPlayers()
        if not CurrentPlayers[1] then return end

        local CharacterCFrames = {}
        for _, Player in CurrentPlayers do
            local Character = Player.Character
            local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

            if HumanoidRootPart then
                CharacterCFrames[tostring(Player.UserId)] = self:CFrameToArray(HumanoidRootPart.CFrame)
            end
        end

        local TeleportOptions = Instance.new("TeleportOptions")
        TeleportOptions:SetTeleportData({
            isSoftShutdown = true,
            CharacterCFrames = CharacterCFrames
        })

        local TeleportResult = TeleportService:TeleportAsync(game.PlaceId, CurrentPlayers, TeleportOptions)

        while Players:GetPlayers()[1] do
            task.wait(1)
        end
    end)

    print("[SOFT SHUTDOWN SERVICE] Service loaded successfully.")
end

return SoftShutdownService