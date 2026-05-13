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
    setmetatable(params, { __index = { color = Color3.fromRGB(25, 25, 25), thick = 0, mode = Enum.ApplyStrokeMode.Contextual } })

    if params.thick == 0 then return end

    return Roact.createElement("UIStroke", {
        ApplyStrokeMode = params.mode,
        Color = params.color,
        Thickness = params.thick
    })
end