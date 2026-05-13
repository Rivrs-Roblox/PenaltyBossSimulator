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
    setmetatable(params, { __index = { radius = 1 } })

    return Roact.createElement("UICorner", {
        CornerRadius = UDim.new(params.radius, 0)
    })
end