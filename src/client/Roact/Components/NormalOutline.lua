local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local Size = require(Helpers.Size)

return function(params: table)
    setmetatable(params, {
        __index = {
            visible = false,
            color = Color3.fromRGB(255, 255, 255),
            strokeThickness = 2,
            order = 0,
            hooks = nil,
            pulseSpeed = 1, -- Speed of the pulse animation
            pulseSize = 1.2, -- Maximum scale of the pulse
        },
    })

    local styles = RoactSpring.useSpring(params.hooks, function()
        return {
            from = { sizeAlpha = 1 },
            to = { sizeAlpha = params.pulseSize },
            loop = {
                reset = true -- This will make it instantly return to original size
            },
            config = { 
                mass = 1,
                tension = 300 * params.pulseSpeed,
                friction = 20,
                duration = 1000 / params.pulseSpeed -- 1 second divided by pulse speed
            }
        }
    end)

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = Size(styles, { X = 1, Y = 1 }),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Visible = params.visible,
        LayoutOrder = params.order,
    }, {
        UIStroke = Roact.createElement("UIStroke", {
            Color = params.color,
            Thickness = params.strokeThickness,
            Transparency = 0,
        }),

        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })
end