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

function PassPrize(_, hooks)
    return Roact.createElement("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1,
        Position=UDim2.fromScale(0.5,0.393),
        BorderColor3=Color3.fromHex('000000'),
        BackgroundColor3=Color3.fromHex('ffffff'),
        BorderSizePixel=0,
        Size=UDim2.fromScale(1,0.787),
    }, {
        UIPadding = Roact.createElement("UIPadding", {
            PaddingTop=UDim.new(0.04,0),
        }),
        UIListLayout = Roact.createElement("UIListLayout", {
            SortOrder=2,
            HorizontalAlignment=0,
            Padding=UDim.new(0.07,0),
        }),
        Reward1 = Roact.createElement("Frame", {
            AnchorPoint=Vector2.new(0.5,0.5),
            BackgroundColor3=Color3.fromHex('ff0101'),
            Position=UDim2.fromScale(0.5,0.185),
            BorderColor3=Color3.fromHex('000000'),
            LayoutOrder=1,
            BorderSizePixel=0,
            Size=UDim2.fromScale(0.9,0.26),
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius=UDim.new(0.15,0),
            }),
            Info = Roact.createElement("TextLabel", {
                Size=UDim2.fromScale(0.73,0.9),
                TextWrapped=true,
                AutoLocalize=false,
                TextColor3=Color3.fromHex('ffffff'),
                BorderColor3=Color3.fromHex('000000'),
                Text="Premium Rewards!",
                TextScaled=true,
                Position=UDim2.fromScale(0.591,0.5),
                AnchorPoint=Vector2.new(0.5,0.5),
                Font=26,
                BackgroundTransparency=1,
                TextXAlignment=0,
                TextSize=14,
                TextYAlignment=0,
                BorderSizePixel=0,
                BackgroundColor3=Color3.fromHex('ffffff'),
            }, {
                Stroke = Roact.createElement("UIStroke", {
                    Thickness=3,
                }),
            }),
            Stroke = Roact.createElement("UIStroke", {
                Color=Color3.fromHex('191919'),
                Thickness=3,
            }),
            UIGradient = Roact.createElement("UIGradient", {
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('841212'))}),
                Rotation=90,
            }),
            Reward = Roact.createElement("ImageLabel", {
                ScaleType=3,
                BorderColor3=Color3.fromHex('000000'),
                AnchorPoint=Vector2.new(0.5,0.5),
                Image="rbxassetid://81846085332138",
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0,0.5),
                BackgroundColor3=Color3.fromHex('ffffff'),
                BorderSizePixel=0,
                Size=UDim2.fromScale(0.4,1.3),
            }),
        }),
        Reward2 = Roact.createElement("Frame", {
            AnchorPoint=Vector2.new(0.5,0.5),
            BackgroundColor3=Color3.fromHex('ffcc00'),
            Position=UDim2.fromScale(0.5,0.185),
            BorderColor3=Color3.fromHex('000000'),
            LayoutOrder=2,
            BorderSizePixel=0,
            Size=UDim2.fromScale(0.9,0.26),
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius=UDim.new(0.15,0),
            }),
            Info = Roact.createElement("TextLabel", {
                Size=UDim2.fromScale(0.73,0.5),
                TextWrapped=true,
                AutoLocalize=false,
                TextColor3=Color3.fromHex('ffffff'),
                BorderColor3=Color3.fromHex('000000'),
                Text="+8 Brainrot Egg",
                TextScaled=true,
                Position=UDim2.fromScale(0.591,0.5),
                AnchorPoint=Vector2.new(0.5,0.5),
                Font=26,
                BackgroundTransparency=1,
                TextXAlignment=0,
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
                Thickness=3,
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
                Position=UDim2.fromScale(0,0.5),
                BackgroundColor3=Color3.fromHex('ffffff'),
                BorderSizePixel=0,
                Size=UDim2.fromScale(0.4,1.3),
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
            Size=UDim2.fromScale(0.9,0.26),
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius=UDim.new(0.15,0),
            }),
            Info = Roact.createElement("TextLabel", {
                Size=UDim2.fromScale(0.73,0.5),
                TextWrapped=true,
                AutoLocalize=false,
                TextColor3=Color3.fromHex('ffffff'),
                BorderColor3=Color3.fromHex('000000'),
                Text="Chill Guy",
                TextScaled=true,
                Position=UDim2.fromScale(0.591,0.5),
                AnchorPoint=Vector2.new(0.5,0.5),
                Font=26,
                BackgroundTransparency=1,
                TextXAlignment=0,
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
                Thickness=3,
            }),
            UIGradient = Roact.createElement("UIGradient", {
                Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('ffffff')),ColorSequenceKeypoint.new(1,Color3.fromHex('ff7700'))}),
                Rotation=90,
            }),
            Reward = Roact.createElement("ImageLabel", {
                ScaleType=3,
                BorderColor3=Color3.fromHex('000000'),
                AnchorPoint=Vector2.new(0.5,0.5),
                Image=UI["Chill Guy"],
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0,0.5),
                BackgroundColor3=Color3.fromHex('ffffff'),
                BorderSizePixel=0,
                Size=UDim2.fromScale(0.4,1.3),
                [Roact.Event.MouseEnter] = function()
                    TooltipController:SetSize(UDim2.fromScale(0.07, 0.05))
                    TooltipController:SetText(`x{FormatNumber(3360)} 💪`)
                end,

                [Roact.Event.MouseLeave] = function()
                    TooltipController:SetText(nil)
                end,
            }),
        }),
    })
end

PassPrize = RoactHooks.new(Roact)(PassPrize)
return PassPrize