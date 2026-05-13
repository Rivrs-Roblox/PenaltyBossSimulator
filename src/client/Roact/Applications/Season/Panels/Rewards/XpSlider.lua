local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")

-- Panels
local Panels = script.Parent.Parent
local XpFill = require(Panels.Rewards.XpFill)

function XpSlider(_, hooks)
    local level = RoduxHooks.useSelector(hooks, function(state) return state.SeasonReducer.Level end)
    local currentExp = RoduxHooks.useSelector(hooks, function(state) return state.SeasonReducer.Exp end)

    if level > 0 and currentExp ~= 0 then
        for i = 1, level do
            currentExp -= Template.SeasonPass[i]
        end
    end

    local nextExp = Template.SeasonPass[level + 1]

    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),
        LayoutOrder=2,
        BackgroundColor3=Color3.fromHex('4a138c'),
        Size=UDim2.fromScale(1,0.1),
    }, {
        Xp = Roact.createElement("TextLabel", {
            TextWrapped=true,
            AutoLocalize=false,
            TextColor3=Color3.fromHex('ffffff'),
            BorderColor3=Color3.fromHex('000000'),
            Text= if level < 30 then `Lvl: {level} ({currentExp} / {nextExp}xp)` else `Lvl: {level} (Complete)`,
            Size=UDim2.fromScale(0.95,0.95),
            AnchorPoint=Vector2.new(0.5,0.5),
            Font=26,
            BackgroundTransparency=1,
            Position=UDim2.fromScale(0.5,0.5),
            TextScaled=true,
            TextSize=14,
            BorderSizePixel=0,
            BackgroundColor3=Color3.fromHex('ffffff'),
            ZIndex = 2
        }, {
            Stroke = Roact.createElement("UIStroke", {
                Color=Color3.fromHex('191919'),
                Thickness=2,
            }),
        }),
        Stroke = Roact.createElement("UIStroke", {
            Color=Color3.fromHex('191919'),
            Thickness=4,
        }),
        Corner = Roact.createElement("UICorner", {
            CornerRadius=UDim.new(0.2,0),
        }),
        Fill = Roact.createElement(XpFill),
    })
end

XpSlider = RoactHooks.new(Roact)(XpSlider)
return XpSlider