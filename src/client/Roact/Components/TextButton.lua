--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)

-- Components
local Stroke = require(script.Parent.Stroke)

return function(params: table)
    setmetatable(params, {
        __index = {
            pos = UDim2.fromScale(0.5, 0.5),
            size = UDim2.fromScale(1, 1),
            text = "",
            scaled = true,
            txtSize = 14,
            color = Color3.fromRGB(255, 255, 255),
            index = 1,
            backgroundTransparency = 1,
            strokeMode = Enum.ApplyStrokeMode.Contextual,
            stroke = 1.5,
            action = function() end,
            children = {},
        }
    })

    return Roact.createElement("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = params.pos,
        Size = params.size,
        Text = params.text,
        TextScaled = params.scaled,
        TextSize = params.txtSize,
        TextColor3 = params.color,
        ZIndex = params.index,
        BackgroundTransparency = params.backgroundTransparency,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),

        [Roact.Event.MouseButton1Click] = function()
            params.action()
        end
    }, {
        Stroke = Stroke({ thick = params.stroke, mode = params.strokeMode }),
        Roact.createFragment(params.children)
    })
end