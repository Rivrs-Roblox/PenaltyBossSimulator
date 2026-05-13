local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local enablePowerClickEvent = ReplicatedStorage.RemoteEvents:WaitForChild("EnablePowerClickEvent")
local disablePowerClickEvent = ReplicatedStorage.RemoteEvents:WaitForChild("DisablePowerClickEvent")
local powerClickFarmEvent = ReplicatedStorage.RemoteEvents:WaitForChild("PowerClickFarmEvent")

local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui")
local powerClick = false
local cooldown = false

local COOLDOWN_TIME = 0.5

local function enablePowerClick()
    powerClick = true
end

local function disablePowerClick()
    powerClick = false
end

local function powerClickFarm()
    if powerClick and not cooldown then
        powerClickFarmEvent:FireServer()

        cooldown = true

        task.wait(COOLDOWN_TIME)

        cooldown = false
    end
end

-- Deteksi input tombol kiri mouse
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    -- Check if a UI element is focused (like a textbox)
    if UserInputService:GetFocusedTextBox() then return end 

    -- Ensure PlayerGui exists before checking UI elements
    if playerGui then
        local mousePosition = UserInputService:GetMouseLocation()
        local guiObjects = playerGui:GetGuiObjectsAtPosition(mousePosition.X, mousePosition.Y)

        -- Check if any of the detected GUI objects are active (blocking input)
        for _, gui in ipairs(guiObjects) do
            if gui:IsA("TextButton") or gui:IsA("ImageButton") or (gui:IsA("Frame") and gui.Active) then
                return -- Click was on an interactive UI element, so don't shoot
            end
        end
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        powerClickFarm()
    elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
        powerClickFarm()
    end
end)

UserInputService.TouchTap:Connect(function(touchPositions, gameProcessedEvent)
    if gameProcessedEvent then return end

    -- Check if a UI element is focused (like a textbox)
    if UserInputService:GetFocusedTextBox() then return end 

    -- Ensure PlayerGui exists before checking UI elements
    if playerGui then
        for _, touchPosition in ipairs(touchPositions) do
            local guiObjects = playerGui:GetGuiObjectsAtPosition(touchPosition.X, touchPosition.Y)

            -- Check if any of the detected GUI objects are active (blocking input)
            for _, gui in ipairs(guiObjects) do
                if gui:IsA("TextButton") or gui:IsA("ImageButton") or (gui:IsA("Frame") and gui.Active) then
                    return -- Touch was on an interactive UI element, so don't shoot
                end
            end
        end
    end

    powerClickFarm()  -- Call shoot function
end)

enablePowerClickEvent.OnClientEvent:Connect(enablePowerClick)
disablePowerClickEvent.OnClientEvent:Connect(disablePowerClick)