--[=[
    Owner: JustStop__
	Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local White_Background = require(Components.Main.White_Background)
local Grid = require(Components.Grid)
local Text = require(Components.Text)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Frames
local NPCCard = require(script.Parent.NPCCard)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")

-- AutoFight
function AutoFight(_, hooks)
    local UIReducer = RoduxHooks.useSelector(hooks, function(state) return state.UIReducer end)
    local AreaReducer = RoduxHooks.useSelector(hooks, function(state) return state.AreaReducer end)
    local NPCs = {}
    if AreaReducer.Area ~= nil and AreaReducer.Area ~= "" then
        for name, NPC in pairs(Template.NPCs[AreaReducer.Area]) do
            if typeof(NPC) == "table" then
                NPCs[name] = NPCCard({
                    name = name,
                    image = name,
                    color = NPC.NameColor,
                    order = NPC.Order
                })
            end
        end
    end

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1
    }, {
        Content = White_Background({
            title = "Auto Fight",
            size = UDim2.fromScale(1, 1),
            pos = UDim2.fromScale(0.5, 0.5),
            ratio = 1.7,
            condition = UIReducer.CurrentUI == FramesConstants.AutoFight,
            align = Enum.TextXAlignment.Left,
            hooks = hooks
        }, {
            Title = Text({ text = AreaReducer.Area, color = Color3.fromRGB(255, 255, 255), position = UDim2.fromScale(0.5, 0.15), size = UDim2.fromScale(0.7, 0.1), backgroundTransparency = 1, stroke = 2.5 }),

            Cards = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.55),
                Size = UDim2.fromScale(0.9, 0.5),
                BackgroundTransparency = 1,
            }, {
                Grid = Grid({ cellPadding = UDim2.fromScale(0.02, 0.02), cellSize = UDim2.fromScale(0.23, 1) }),

                Roact.createFragment(NPCs)
            })
        })
    })
end

AutoFight = RoactHooks.new(Roact)(AutoFight)
return AutoFight