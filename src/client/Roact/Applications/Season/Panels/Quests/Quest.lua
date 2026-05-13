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

-- Components
local Components = StarterPlayer.StarterPlayerScripts.Client.Roact.Components
local Text = require(Components.Text)
local ProgressBar = require(Components.ProgressBar)

-- Services
local SeasonService = Knit.GetService("SeasonService")

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")

-- Datas
local Template = DataCacheController:GetFile("Template")

-- Quests
return function(params: table)
    setmetatable(params, {
        __index = {
            id = "" :: string,
            title = "" :: string,
            description = "" :: string,
            amount = 0 :: number,
            current = 0 :: number,
            hooks = nil,
            daily = true,
            exp = 0
        }
    })

    local useState, useEffect = params.hooks.useState, params.hooks.useEffect
    local current, setCurrent = useState(params.current)

    useEffect(function()
        local connection = SeasonService.QuestProgressed:Connect(function(type: string, newCurrent: number)
            if type == params.title then
                setCurrent(newCurrent)
            end
        end)

        return function()
            connection:Disconnect()
        end
    end, {}) -- hanya setup sekali saat mount

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromScale(0.3, 0.8),
        BorderColor3 = Color3.fromHex('000000'),
        BackgroundColor3 = Color3.fromHex('600090'),
    }, {
        Description = Text({
            text = params.description:gsub("MONEY_2", Template.Economy.Money2),
            color = Color3.fromRGB(255, 255, 255),
            backgroundTransparency = 1,
            position = UDim2.fromScale(0.5, 0.2),
            size = UDim2.fromScale(0.95, 0.25),
            stroke = 2
        }),

        Progress = ProgressBar({
            current = current,
            total = params.amount,
            backgroundTransparency = 0,
            pos = UDim2.fromScale(0.5, 0.54),
            size = UDim2.fromScale(0.75, 0.25),
            gradientColor = "Blue"
        }),

        Exp = Text({
            text = `{params.exp} XP`,
            color = Color3.fromRGB(255, 255, 255),
            backgroundTransparency = 1,
            position = UDim2.fromScale(0.5, 0.825),
            size = UDim2.fromScale(0.75, 0.17),
            stroke = 2
        }),

        Corner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0.1, 0),
        }),

        Stroke = Roact.createElement("UIStroke", {
            Color = Color3.fromHex('191919'),
            Thickness = 3,
        }),
    })
end