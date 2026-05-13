--[=[
    Owner: JustStop__
    Version: 0.0.1
    Contact owner if any question, concern or feedback
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

local GradColors = {
    Legendary = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("fff70a")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("ff5776")),
    }),
    Epic = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("e0ccff")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("a45eff")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("6a00ff")),
    }),
    Rare = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("cceeff")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("3399ff")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("0066cc")),
    }),
    Uncommon = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("ccffcc")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("66cc66")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("228b22")),
    }),
    Common = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("eeeeee")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("cccccc")),
    }),
}

local Frames = script.Parent
local RewardCard = require(Frames.RewardCard)
local Day1to6Frame = require(Frames.Day1to6Frame)

local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("Template")

return function(order, props, hooks)
    props = props or {}

    local rewardsCards1to6 = {}
    local rewardCard7 = nil

    for _, item in ipairs(props) do
        local weekDay = ((item.day - 1) % 7) + 1
        local card = RewardCard({
            id = item.day,
            weekDay = weekDay,
            amount = item.reward.Amount,
            claimed = item.reward.Claimed,
            currency = item.reward.Currency,
            image = item.reward.Image,
            name = item.reward.Name,
            reward = item.reward.Reward,
            size = weekDay == 7 and UDim2.fromScale(0.28, 1) or UDim2.fromScale(0.28, 0.9),
            exclusive = weekDay == 7,
            gradColor = GradColors[Template.DailyRewards[item.day].Rarity] or GradColors.Common,
        }, hooks)

        if weekDay == 7 then
            rewardCard7 = card
        else
            table.insert(rewardsCards1to6, card)
        end
    end

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Size = UDim2.fromScale(0.98, 0.975),
    }, {
        UIListLayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Padding = UDim.new(0.0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
        Day1to6Frame = Day1to6Frame(rewardsCards1to6, hooks),
        Day7 = rewardCard7,
    })
end
