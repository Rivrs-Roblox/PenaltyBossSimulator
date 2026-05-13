--[=[
    Owner: JustStop__
    Version: 0.0.1
    Contact owner if any question, concern or feedback

    Update:
    - Background pet trade disamakan dengan Inventory/Frames/Components/Item.lua
      memakai gradient rarity, bukan gradient abu hardcoded.
    - Stroke juga mengikuti theme rarity agar konsisten dengan inventory pet.
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local TradeController = Knit.GetController("TradeController")

-- UI
local Colors = DataCacheController:GetFile("Colors")

local SELECTED_ICON = "rbxassetid://93840956317609"

local PET_THEMES = {
    Common = {
        gradientTop = Color3.fromHex("d7d8cd"),
        gradientBottom = Color3.fromHex("797979"),
        stroke = Color3.fromHex("e1e1e1"),
    },
    Uncommon = {
        gradientTop = Color3.fromHex("50ff20"),
        gradientBottom = Color3.fromHex("1a8a18"),
        stroke = Color3.fromHex("64ff39"),
    },
    Rare = {
        gradientTop = Color3.fromHex("6085ff"),
        gradientBottom = Color3.fromHex("3a559e"),
        stroke = Color3.fromHex("46a9ff"),
    },
    Epic = {
        gradientTop = Color3.fromHex("c041ff"),
        gradientBottom = Color3.fromHex("5b1579"),
        stroke = Color3.fromHex("c743ff"),
    },
    Legendary = {
        gradientTop = Color3.fromHex("fff240"),
        gradientBottom = Color3.fromHex("ff8c27"),
        stroke = Color3.fromHex("ff9501"),
    },
    Mythical = {
        gradientTop = Color3.fromHex("ff6347"),
        gradientBottom = Color3.fromHex("8f1d1d"),
        stroke = Color3.fromHex("ff5b2f"),
    },
    Secret = {
        gradientTop = Color3.fromHex("76e8ff"),
        gradientBottom = Color3.fromHex("2c7aa4"),
        stroke = Color3.fromHex("8befff"),
    },
    Exclusive = {
        gradientTop = Color3.fromHex("7015d8"),
        gradientBottom = Color3.fromHex("4d065b"),
        stroke = Color3.fromHex("7645e1"),
    },
}

local function getPetTheme(params: table)
    local theme = PET_THEMES[params.rarity]
    if theme ~= nil then
        return theme
    end

    local topColor = params.bg_color or Colors[params.rarity] or Color3.fromRGB(215, 216, 205)
    return {
        gradientTop = topColor,
        gradientBottom = Color3.fromHex("2f3444"),
        stroke = topColor,
    }
end

return function(params: table)
    setmetatable(params, {
        __index = {
            trading = false :: boolean,
            icon = "" :: string,
            name = "" :: string,
            id = 0 :: number,
            order = 0 :: number,
            power = "" :: string,
            bg_color = Color3.fromRGB(225, 225, 225),
            rarity = "Common" :: string,
            my_side = true :: boolean,
        },
    })

    local theme = getPetTheme(params)

    local NameColor = Color3.fromRGB(255, 255, 255)
    if string.find(params.name, "Gold ") then
        NameColor = Colors["Gold"] or Color3.fromHex("ffd447")
    elseif string.find(params.name, "Rainbow") then
        NameColor = Colors["Rainbow"] or Color3.fromHex("ff5df7")
    end

    return Roact.createElement("ImageButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        ScaleType = Enum.ScaleType.Fit,
        LayoutOrder = params.order,
        BackgroundColor3 = Color3.fromHex("fcfaff"),
        BorderSizePixel = 0,
        AutoButtonColor = params.my_side,
        ZIndex = 5,

        [Roact.Event.MouseButton1Click] = function()
            if params.my_side then
                if params.trading then
                    TradeController:RemovePet({ id = params.id, name = params.name })
                else
                    TradeController:AddPet({ id = params.id, name = params.name })
                end
            end
        end,
    }, {
        Ratio = Roact.createElement("UIAspectRatioConstraint", {}),

        UIGradient = Roact.createElement("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.gradientTop),
                ColorSequenceKeypoint.new(1, theme.gradientBottom),
            }),
            Rotation = 90,
        }),

        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),

        UIStroke = Roact.createElement("UIStroke", {
            Color = theme.stroke,
            Thickness = 3,
        }),

        Icon = Roact.createElement("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = params.icon or "",
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            ScaleType = Enum.ScaleType.Fit,
            Size = UDim2.fromScale(0.9, 0.75),
            ZIndex = 6,
        }),

        NameText = Roact.createElement("TextLabel", {
            TextWrapped = true,
            TextColor3 = NameColor,
            Text = params.name,
            AnchorPoint = Vector2.new(0.5, 0.5),
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.12),
            ZIndex = 10,
            TextScaled = true,
            Size = UDim2.fromScale(0.85, 0.2),
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromHex("000000"),
        }),

        PowerText = Roact.createElement("TextLabel", {
            TextWrapped = true,
            TextColor3 = Color3.fromHex("ffffff"),
            Text = params.power,
            AnchorPoint = Vector2.new(0.5, 0.5),
            FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.88),
            ZIndex = 10,
            TextScaled = true,
            Size = UDim2.fromScale(0.85, 0.2),
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromHex("000000"),
        }),

        Equipped = Roact.createElement("ImageLabel", {
            Visible = params.trading,
            ScaleType = Enum.ScaleType.Fit,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = SELECTED_ICON,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            ZIndex = 11,
            ImageColor3 = Color3.fromHex("00fa00"),
            Size = UDim2.fromScale(0.7, 0.7),
        }),
    })
end
