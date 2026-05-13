--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

return function(params: table)
    setmetatable(params, {
        __index = {
            startColor = Color3.fromRGB(255, 255, 255),
            endColor = Color3.fromRGB(255, 255, 255),
            rotation = 0
        }
    })

    return Roact.createElement("UIGradient", {
        Color = ColorSequence.new(params.startColor, params.endColor),
        Rotation = params.rotation
    })
end