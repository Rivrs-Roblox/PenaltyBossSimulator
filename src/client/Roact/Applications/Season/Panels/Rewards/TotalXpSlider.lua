local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)

-- Panels
local Panels = script.Parent.Parent
local TotalXpFill = require(Panels.Rewards.TotalXpFill)

function TotalXpSlider(_, hooks)
    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.fromScale(0.017,0.385),
        BorderColor3=Color3.fromHex('000000'),
        BackgroundColor3=Color3.fromHex('ffffff'),
        BorderSizePixel=0,
        Size=UDim2.fromScale(0.965,0.08),
    }, {
        Fill = Roact.createElement(TotalXpFill),
        Stroke = Roact.createElement("UIStroke", {
            Color=Color3.fromHex('191919'),
            Thickness=3,
        }),
    })
end

TotalXpSlider = RoactHooks.new(Roact)(TotalXpSlider)
return TotalXpSlider