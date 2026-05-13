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
    setmetatable(params, { __index = { ratio = 1 :: number, type = Enum.AspectType.FitWithinMaxSize, axis = Enum.DominantAxis.Width } })

    return Roact.createElement("UIAspectRatioConstraint", {
        AspectRatio = params.ratio,
        AspectType = params.type,
        DominantAxis = params.axis
    })
end