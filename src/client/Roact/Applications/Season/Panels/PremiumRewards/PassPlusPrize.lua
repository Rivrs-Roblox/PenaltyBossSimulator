local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)

-- Controllers
local DataCacheController = Knit.GetController("DataCacheController")
local TooltipController = Knit.GetController("TooltipController")

-- UI
local UI = DataCacheController:GetFile("Images")
local Template = DataCacheController:GetFile("Template")

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

local function createHoverDescription(exclusiveEgg)
	local hoverDescription = ""

	if exclusiveEgg then
		for i, pet in ipairs(exclusiveEgg.Pets) do
			hoverDescription = hoverDescription .. pet.Name .. " - " .. pet.Chance .. "%"
			if i < #exclusiveEgg.Pets then
				hoverDescription = hoverDescription .. "\n"
			end
		end
	end

	return hoverDescription
end

function PassPlusPrize(_, hooks)
    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1,
        Position=UDim2.fromScale(0.5,0.28),
        BorderColor3=Color3.fromHex('000000'),
        BackgroundColor3=Color3.fromHex('ffffff'),
        BorderSizePixel=0,
        Size=UDim2.fromScale(1,0.5),
    }, {
        UIListLayout = Roact.createElement("UIListLayout", {
            Padding=UDim.new(0.05,0),
            FillDirection=0,
            HorizontalAlignment=0,
            SortOrder=2,
        }),
        Reward1 = Roact.createElement("Frame", {
            AnchorPoint=Vector2.new(0.5,0.5),
            BackgroundColor3=Color3.fromHex('ffcc00'),
            Position=UDim2.fromScale(0.5,0.185),
            BorderColor3=Color3.fromHex('000000'),
            LayoutOrder=1,
            BorderSizePixel=0,
            Size=UDim2.fromScale(0.28,1),
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius=UDim.new(0.15,0),
            }),
            UIGradient = Roact.createElement("UIGradient", {
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('ff7700'))}),
                Rotation=90,
            }),
            Info = Roact.createElement("TextLabel", {
                Size=UDim2.fromScale(0.9,0.3),
                TextWrapped=true,
                AutoLocalize=false,
                TextColor3=Color3.fromHex('ffffff'),
                BorderColor3=Color3.fromHex('000000'),
                Text="Get All Gift Instant!",
                TextScaled=true,
                ZIndex=2,
                AnchorPoint=Vector2.new(0.5,0.5),
                Font=26,
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.5,0.85),
                TextSize=14,
                TextYAlignment=0,
                BorderSizePixel=0,
                BackgroundColor3=Color3.fromHex('ffffff'),
            }, {
                Stroke = Roact.createElement("UIStroke", {
                    Color=Color3.fromHex('ad4800'),
                    Thickness=3,
                }),
            }),
            Stroke = Roact.createElement("UIStroke", {
                Color=Color3.fromHex('191919'),
                Thickness=4,
            }),
            Gift = Roact.createElement("ImageLabel", {
                ScaleType=3,
                BorderColor3=Color3.fromHex('000000'),
                AnchorPoint=Vector2.new(0.5,0.5),
                Image="rbxassetid://128197558541858",
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.685,0.49),
                BackgroundColor3=Color3.fromHex('ffffff'),
                BorderSizePixel=0,
                Size=UDim2.fromScale(0.586,0.393),
                ZIndex = 2
            }),
            Reward = Roact.createElement("ImageLabel", {
                ScaleType=3,
                BorderColor3=Color3.fromHex('000000'),
                AnchorPoint=Vector2.new(0.5,0.5),
                Image="rbxassetid://81846085332138",
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.427,0.388),
                BackgroundColor3=Color3.fromHex('ffffff'),
                Rotation=-2,
                BorderSizePixel=0,
                Size=UDim2.fromScale(1,0.9),
            }),
        }),
        Reward2 = Roact.createElement("Frame", {
            AnchorPoint=Vector2.new(0.5,0.5),
            BackgroundColor3=Color3.fromHex('ffcc00'),
            Position=UDim2.fromScale(0.5,0.185),
            BorderColor3=Color3.fromHex('000000'),
            LayoutOrder=2,
            BorderSizePixel=0,
            Size=UDim2.fromScale(0.28,1),
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius=UDim.new(0.15,0),
            }),
            Info = Roact.createElement("TextLabel", {
                Size=UDim2.fromScale(0.9,0.3),
                TextWrapped=true,
                AutoLocalize=false,
                TextColor3=Color3.fromHex('ffffff'),
                BorderColor3=Color3.fromHex('000000'),
                Text="+30 Brainrot Egg",
                TextScaled=true,
                ZIndex=2,
                AnchorPoint=Vector2.new(0.5,0.5),
                Font=26,
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.5,0.85),
                TextSize=14,
                TextYAlignment=0,
                BorderSizePixel=0,
                BackgroundColor3=Color3.fromHex('ffffff'),
            }, {
                Stroke = Roact.createElement("UIStroke", {
                    Color=Color3.fromHex('ad4800'),
                    Thickness=3,
                }),
            }),
            Stroke = Roact.createElement("UIStroke", {
                Color=Color3.fromHex('191919'),
                Thickness=4,
            }),
            UIGradient = Roact.createElement("UIGradient", {
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('ff7700'))}),
                Rotation=90,
            }),
            Reward = Roact.createElement("ImageLabel", {
                ScaleType=3,
                BorderColor3=Color3.fromHex('000000'),
                AnchorPoint=Vector2.new(0.5,0.5),
                Image=UI["Brainrot_Egg"],
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.5,0.4),
                BackgroundColor3=Color3.fromHex('ffffff'),
                BorderSizePixel=0,
                Size=UDim2.fromScale(0.9,0.9),
                [Roact.Event.MouseEnter] = function()
                    TooltipController:SetSize(UDim2.fromScale(0.15, 0.18))
                    TooltipController:SetText(createHoverDescription(Template.Shop.BrainrotEgg))
                end,

                [Roact.Event.MouseLeave] = function()
                    TooltipController:SetText(nil)
                end,
            }),
        }),
        Reward3 = Roact.createElement("Frame", {
            AnchorPoint=Vector2.new(0.5,0.5),
            BackgroundColor3=Color3.fromHex('ffcc00'),
            Position=UDim2.fromScale(0.5,0.185),
            BorderColor3=Color3.fromHex('000000'),
            LayoutOrder=3,
            BorderSizePixel=0,
            Size=UDim2.fromScale(0.28,1),
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius=UDim.new(0.15,0),
            }),
            Info = Roact.createElement("TextLabel", {
                Size=UDim2.fromScale(0.9,0.3),
                TextWrapped=true,
                AutoLocalize=false,
                TextColor3=Color3.fromHex('ffffff'),
                BorderColor3=Color3.fromHex('000000'),
                Text="OP Exclusive Skin",
                TextScaled=true,
                ZIndex=2,
                AnchorPoint=Vector2.new(0.5,0.5),
                Font=26,
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.5,0.85),
                TextSize=14,
                TextYAlignment=0,
                BorderSizePixel=0,
                BackgroundColor3=Color3.fromHex('ffffff'),
            }, {
                Stroke = Roact.createElement("UIStroke", {
                    Color=Color3.fromHex('ad4800'),
                    Thickness=3,
                }),
            }),
            Stroke = Roact.createElement("UIStroke", {
                Color=Color3.fromHex('191919'),
                Thickness=4,
            }),
            UIGradient = Roact.createElement("UIGradient", {
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('ff7700'))}),
                Rotation=90,
            }),
            Reward = Roact.createElement("ImageLabel", {
                ScaleType=3,
                BorderColor3=Color3.fromHex('000000'),
                AnchorPoint=Vector2.new(0.5,0.5),
                Image=UI["Skin_Salmon"],
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.5,0.4),
                BackgroundColor3=Color3.fromHex('ffffff'),
                BorderSizePixel=0,
                Size=UDim2.fromScale(0.9,0.9),
                [Roact.Event.MouseEnter] = function()
                    TooltipController:SetSize(UDim2.fromScale(0.05, 0.05))
                    TooltipController:SetText(`x{FormatNumber(8)} 🏆`)
                end,

                [Roact.Event.MouseLeave] = function()
                    TooltipController:SetText(nil)
                end,
            }),
        }),
    })
end

PassPlusPrize = RoactHooks.new(Roact)(PassPlusPrize)
return PassPlusPrize