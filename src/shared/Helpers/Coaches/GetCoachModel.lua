local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local CoachAssets = Assets:WaitForChild("Coaches")
local RegularCoach = CoachAssets:WaitForChild("Regulars")
local VIPCoach = CoachAssets:WaitForChild("Purchasables")
local RewardsCoach = CoachAssets:WaitForChild("Rewards")
return function(Data: table)
    -- Data di sini sekarang adalah template coach (misal: {Name = "Dog", DisplayName = "Dog", ...})
    local coachName = Data.Name or "Unknown"
    local coachModel = nil
    if (Data.VIP) then
        coachModel = VIPCoach:FindFirstChild(coachName, true)
    elseif (Data.Chest) then
        print("ChestCoach:", coachName)
        coachModel = RewardsCoach:FindFirstChild(coachName, true)
    else
        coachModel = RegularCoach:FindFirstChild(coachName, true)

    end
    if coachModel == nil then
        warn("Can't find coach model:", coachName)
        return nil
    end
    
    for _, v in coachModel:GetDescendants() do
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.CanQuery = false
        end
    end
    
    return coachModel
end