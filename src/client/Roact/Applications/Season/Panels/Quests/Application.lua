--[=[
    Owner: JustStop__
    Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Constants
local SeasonConstants = require(StarterPlayer.StarterPlayerScripts.Client.Roact.Constants.SeasonConstants)

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Grid = require(Components.Grid)
local Text = require(Components.Text)

-- Frames
local Quest = require(script.Parent.Quest)

-- Quest Definitions
local QuestDefinitions = require(ReplicatedStorage.Shared.Data.QuestDefinitions)

return function(hooks)
    local dailyQuests = RoduxHooks.useSelector(hooks, function(state) return state.SeasonReducer.DailyQuests end)
    local weeklyQuests = RoduxHooks.useSelector(hooks, function(state) return state.SeasonReducer.WeeklyQuests end)
    local remainingDayTime = RoduxHooks.useSelector(hooks, function(state) return state.SeasonReducer.RemainingDayTime end)
    local remainingWeekTime = RoduxHooks.useSelector(hooks, function(state) return state.SeasonReducer.RemainingWeekTime end)
    local UIReducer = RoduxHooks.useSelector(hooks, function(state) return state.UIReducer end)

    local function createQuestElements(playerQuests, definitions)
        local quests = {}

        for _, entry in pairs(playerQuests) do
            local title = entry.Title
            local def = definitions[title]
            if def then
                table.insert(quests, Roact.createElement(Quest, {
                    key = title,
                    id = title,
                    title = title,
                    description = def.Description,
                    amount = def.Amount,
                    current = entry.Current or 0,
                    exp = def.Exp,
                    hooks = hooks,
                }))
            else
                warn(`[Quest UI] Definition not found for quest:`, title)
            end
        end

        return quests
    end

    local dailyQuestsCount = 0
    for _ in pairs(dailyQuests) do
        dailyQuestsCount += 1
    end

    local DailyQuests = {}

    if dailyQuestsCount == 6 then
        DailyQuests = createQuestElements(dailyQuests, QuestDefinitions.DailyQuests)
    end

    local weeklyQuestsCount = 0
    for _ in pairs(weeklyQuests) do
        weeklyQuestsCount += 1
    end

    local WeeklyQuests

    if weeklyQuestsCount == 6 then
        WeeklyQuests = createQuestElements(weeklyQuests, QuestDefinitions.WeeklyQuests)
    end

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.28, 0.52),
        Size = UDim2.fromScale(0.5, 0.9),
        BackgroundTransparency = 1,
        Visible = UIReducer.CurrentSeasonPassUI == SeasonConstants.Quests,
    }, {
        DailyText = Text({
            text = "Daily",
            color = Color3.fromRGB(255, 255, 255),
            backgroundTransparency = 1,
            position = UDim2.fromScale(0.45, 0.11),
            size = UDim2.fromScale(0.75, 0.1),
            stroke = 2,
            align = Enum.TextXAlignment.Left
        }),

        DailyTimerText = Text({
            text = string.format("%dh %dmins", math.floor(remainingDayTime / 3600), math.floor((remainingDayTime % 3600) / 60)),
            color = Color3.fromRGB(255, 255, 255),
            backgroundTransparency = 1,
            position = UDim2.fromScale(0.55, 0.11),
            size = UDim2.fromScale(0.75, 0.1),
            stroke = 2,
            align = Enum.TextXAlignment.Right
        }),

        Roact.createElement("ScrollingFrame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.48, 0.57),
            Size = UDim2.fromScale(0.95, 0.75),
            BackgroundTransparency = 1,
            ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarImageTransparency = 1,
            ClipsDescendants = true,
            CanvasSize = UDim2.new(0, 0, 2.1, 0)
        }, {
            Grid = Grid({
                cellPadding = UDim2.fromScale(0, 0.06),
                cellSize = UDim2.fromScale(0.87, 0.4),
                fillDirection = Enum.FillDirection.Horizontal,
                horizontalAlignment = Enum.HorizontalAlignment.Center,
                verticalAlignment = Enum.VerticalAlignment.Top,
                fillDirectionMaxCells = 1
            }),
            Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0.01, 0),
                PaddingTop = UDim.new(0.01, 0)
            }),
            Roact.createFragment(DailyQuests)
        }),

        WeeklyText = Text({
            text = "Weekly",
            color = Color3.fromRGB(255, 255, 255),
            backgroundTransparency = 1,
            position = UDim2.fromScale(1.37, 0.11),
            size = UDim2.fromScale(0.75, 0.1),
            stroke = 2,
            align = Enum.TextXAlignment.Left
        }),

        WeeklyTimerText = Text({
            text = string.format("%dd %dh", math.floor(remainingWeekTime / 86400), math.floor((remainingWeekTime % 86400) / 3600)),
            color = Color3.fromRGB(255, 255, 255),
            backgroundTransparency = 1,
            position = UDim2.fromScale(1.47, 0.11),
            size = UDim2.fromScale(0.75, 0.1),
            stroke = 2,
            align = Enum.TextXAlignment.Right
        }),

        Roact.createElement("ScrollingFrame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(1.42, 0.57),
            Size = UDim2.fromScale(0.95, 0.75),
            BackgroundTransparency = 1,
            ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarImageTransparency = 1,
            ClipsDescendants = true,
            CanvasSize = UDim2.new(0, 0, 2.1, 0)
        }, {
            Grid = Grid({
                cellPadding = UDim2.fromScale(0, 0.06),
                cellSize = UDim2.fromScale(0.87, 0.4),
                fillDirection = Enum.FillDirection.Horizontal,
                horizontalAlignment = Enum.HorizontalAlignment.Center,
                verticalAlignment = Enum.VerticalAlignment.Top,
                fillDirectionMaxCells = 1
            }),
            Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0.01, 0),
                PaddingTop = UDim.new(0.01, 0)
            }),
            Roact.createFragment(WeeklyQuests)
        })
    })
end
