-- AuraModule.lua
local GroupEmitter = require(script.Parent.GroupEmitter)

local Aura = {}
Aura.__index = Aura

function Aura.new(auraFolder, character)
    local self = setmetatable({}, Aura)
    self.groupEmitters = {}
    self.character = character
    
    -- Create GroupEmitters for each body part
    local bodyParts = {
        character:WaitForChild("Head"),
        character:WaitForChild("HumanoidRootPart"),
        character:WaitForChild("UpperTorso"),
        character:WaitForChild("LowerTorso"),
        character:WaitForChild("LeftUpperArm"),
        character:WaitForChild("RightUpperArm"),
        character:WaitForChild("LeftLowerArm"),
        character:WaitForChild("RightLowerArm"),
        character:WaitForChild("LeftHand"),
        character:WaitForChild("RightHand"),
        character:WaitForChild("LeftUpperLeg"),
        character:WaitForChild("RightUpperLeg"),
        character:WaitForChild("LeftLowerLeg"),
        character:WaitForChild("RightLowerLeg"),
        character:WaitForChild("LeftFoot"),
        character:WaitForChild("RightFoot"),
    }
    
    -- For each body part, create a GroupEmitter if there's a corresponding folder
    for _, part in ipairs(bodyParts) do
        local partFolder = auraFolder:FindFirstChild(part.Name)
        if partFolder then
            self.groupEmitters[part] = GroupEmitter.new(partFolder, part)
        end
    end
    
    return self
end

function Aura:play()
    for _, groupEmitter in pairs(self.groupEmitters) do
        groupEmitter:play()
    end
end

function Aura:stop()
    for _, groupEmitter in pairs(self.groupEmitters) do
        groupEmitter:stop()
    end
end

function Aura:destroy()
    for _, groupEmitter in pairs(self.groupEmitters) do
        groupEmitter:destroy()
    end
    self.groupEmitters = {}
end

return Aura