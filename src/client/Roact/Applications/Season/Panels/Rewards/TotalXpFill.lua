local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")

function TotalXpFill(_, hooks)
    local level = RoduxHooks.useSelector(hooks, function(state) return state.SeasonReducer.Level end)

    local size = 0.035 * (level - 1)
    size = math.clamp(size, 0, 1)

    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.fromScale(0,0.5),
        BorderColor3=Color3.fromHex('000000'),
        BackgroundColor3=Color3.fromHex('ffb300'),
        BorderSizePixel=0,
        Size=UDim2.fromScale(size, 1),
    }, {
        Stroke = Roact.createElement("UIStroke", {
            Color=Color3.fromHex('191919'),
            Thickness=3,
        }),
        UIGradient = Roact.createElement("UIGradient", {
            Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('ff8800'))}),
            Rotation=90,
        }),
        Corner = Roact.createElement("UICorner", {
            CornerRadius=UDim.new(0.4,0),
        }),
    })
end

TotalXpFill = RoactHooks.new(Roact)(TotalXpFill)
return TotalXpFill