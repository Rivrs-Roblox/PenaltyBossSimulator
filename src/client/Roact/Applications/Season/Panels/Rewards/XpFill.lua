local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")

function XpFill(_, hooks)
    local level = RoduxHooks.useSelector(hooks, function(state) return state.SeasonReducer.Level end)
    local currentExp = RoduxHooks.useSelector(hooks, function(state) return state.SeasonReducer.Exp end)

    if level > 0 and currentExp ~= 0 then
        for i = 1, level do
            currentExp -= Template.SeasonPass[i]
        end
    end

    local nextExp = Template.SeasonPass[level + 1]

    return Roact.createElement("Frame", {
        BackgroundColor3=Color3.fromHex('ffbf00'),
        Size= if level < 30 then UDim2.fromScale(currentExp / nextExp,1) else UDim2.fromScale(1,1),
    }, {
        Corner = Roact.createElement("UICorner", {
            CornerRadius=UDim.new(0.2,0),
        }),
        UIGradient = Roact.createElement("UIGradient", {
            Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('ffae00'))}),
            Rotation=90,
        }),
    })
end

XpFill = RoactHooks.new(Roact)(XpFill)
return XpFill