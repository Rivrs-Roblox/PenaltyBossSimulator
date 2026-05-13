local ReplicatedStorage = game:GetService("ReplicatedStorage")
	
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)

-- Panels
local Panels = script.Parent.Parent
local Free = require(Panels.Rewards.Free)
local Premium = require(Panels.Rewards.Premium)
local XpSlider = require(Panels.Rewards.XpSlider)

function Ticket(_, hooks)
    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1,
        Position=UDim2.fromScale(0.125,0.52),
        BorderColor3=Color3.fromHex('000000'),
        BackgroundColor3=Color3.fromHex('ffffff'),
        BorderSizePixel=0,
        Size=UDim2.fromScale(0.18,0.8),
    }, {
        UIListLayout = Roact.createElement("UIListLayout", {
            VerticalAlignment=0,
            SortOrder=2,
            HorizontalAlignment=0,
            Padding=UDim.new(0.06,0),
        }),
        XpSlider = Roact.createElement(XpSlider),
        Premium = Roact.createElement(Premium),
        Free = Roact.createElement(Free),
    })
end

Ticket = RoactHooks.new(Roact)(Ticket)
return Ticket