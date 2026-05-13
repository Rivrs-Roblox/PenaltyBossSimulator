--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local Stroke = require(Components.Stroke)

local SHADOW = {
    Position = {
        [true] = UDim2.fromScale(0.23, -0.006),
        [false] = UDim2.fromScale(0.23, -0.011)
    },

    TextColor3 = {
        [true] = Color3.fromRGB(25, 25, 25),
        [false] = Color3.fromRGB(255, 255, 255)
    },

    ZIndex = {
        [true] = 100,
        [false] = 101
    }
}

return function(params: table)
    setmetatable(params, { __index = { title = "" :: string, shadow = false :: boolean, align = Enum.TextXAlignment.Center, size = UDim2.fromScale(0.5, 0.13) } })

    return Roact.createElement("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = SHADOW.Position[params.shadow],
        Size = params.size,
        Rotation = -3,
        FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
        TextScaled = true,
        TextSize = 14,
        TextColor3 = SHADOW.TextColor3[params.shadow],
        Text = params.title,
        TextXAlignment = params.align,
        ZIndex = SHADOW.ZIndex[params.shadow]
    }, {
        UIStroke = Stroke({ thick = 2.487 })
    })
end