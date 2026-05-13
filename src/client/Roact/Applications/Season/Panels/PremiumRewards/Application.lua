--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Roact = require(ReplicatedStorage.Packages.roact)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Constants
local SeasonConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.SeasonConstants)

local Pass = require(script.Parent.Pass)
local PassPlus = require(script.Parent.PassPlus)
local Badge = require(script.Parent.Badge)

-- PremiumRewards
return function(hooks)
    local UIReducer = RoduxHooks.useSelector(hooks, function(state) return state.UIReducer end)

    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1,
        Position=UDim2.fromScale(0.5,0.5),
        BorderColor3=Color3.fromHex('000000'),
        BackgroundColor3=Color3.fromHex('ffffff'),
        BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),
        Visible = UIReducer.CurrentSeasonPassUI == SeasonConstants.PremiumRewards,
    }, {
        Badge = Roact.createElement(Badge),
        Pass = Roact.createElement(Pass),
        PassPlus = Roact.createElement(PassPlus),
    })
end