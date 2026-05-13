--[=[
    Owner: JustStop__
    Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
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

    local springs, api = RoactSpring.useSprings(params.hooks, 1, function()
        return {
            sizeAlpha = 1,
            config = {
                tension = 300 * params.pulseSpeed,
                friction = 20,
            }
        }
    end)

    params.hooks.useEffect(function()
        if params.visible then
            -- Create a recurring animation using task.spawn
            local function pulsate()
                while params.visible do
                    api.start(function()
                        return {
                            sizeAlpha = params.pulseSize,
                            config = {
                                tension = 300 * params.pulseSpeed,
                                friction = 20,
                            }
                        }
                    end)
                    task.wait(0.5 / params.pulseSpeed)
                    
                    api.start(function()
                        return {
                            sizeAlpha = 1,
                            config = {
                                tension = 300 * params.pulseSpeed,
                                friction = 20,
                            }
                        }
                    end)
                    task.wait(0.5 / params.pulseSpeed)
                end
            end
            
            task.spawn(pulsate)
        else
            api.start(function()
                return {
                    sizeAlpha = 1,
                    config = {
                        tension = 300,
                        friction = 20,
                    }
                }
            end)
        end
    end, {params.visible})

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = Size(springs[1], { X = 1, Y = 1 }),
        BackgroundTransparency = 1,
        ZIndex = 100, -- Ensure it's above other UI elements
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