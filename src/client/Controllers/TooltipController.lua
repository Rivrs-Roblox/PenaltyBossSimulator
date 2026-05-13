--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Store
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Constants
local Mouse = Players.LocalPlayer:GetMouse()
local X_OFFSET = 0
local Y_OFFSET = 100

-- TooltipController
local TooltipController = Knit.CreateController({
    Name = "TooltipController",

    Frame = nil :: Frame,
    Position = UDim2.fromOffset(0, 0),
    Text = nil,
    Size = UDim2.fromScale(0.1, 0.03)
})

--|| Functions ||--
function TooltipController:InitFrame()
    self.Frame = ReplicatedStorage.Assets.Prompts.Tooltip:Clone()
    self.Frame.Parent = Players.LocalPlayer.PlayerGui:WaitForChild("GameScreenGui")
end

function TooltipController:MouseConnect()
    Mouse.Move:Connect(function()
        local Pos = Vector2.new(Mouse.X, Mouse.Y)
        local Bounds = workspace.CurrentCamera.ViewportSize
        local NewPosition = Vector2.new(Pos.X + X_OFFSET, Pos.Y + Y_OFFSET)

        self.Position = UDim2.fromOffset(NewPosition.X, NewPosition.Y)
    end)
end

function TooltipController:SetText(text: string)
    self.Text = text
end

function TooltipController:SetSize(size: UDim2)
    self.Size = size
end

--|| Knit Lifecycle ||--
function TooltipController:KnitInit()

    self:MouseConnect()

    task.spawn(function() self:InitFrame() end)

    task.spawn(function()
        RunService.RenderStepped:Connect(function()
            TooltipController.Frame.Position = TooltipController.Position
            if TooltipController.Text ~= nil and Store:getState()["UIReducer"].CurrentUI ~= nil then
                TooltipController.Frame.Visible = true
                
                TooltipController.Frame.Size = TooltipController.Size
                TooltipController.Frame.TextLabel.Text = TooltipController.Text
            else
                TooltipController.Frame.Visible = false
            end
        end)
    end)

    print("[TOOLTIP CONTROLLER] Controller loaded successfully.")
end

return TooltipController