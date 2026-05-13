local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local RoactHooks = require(ReplicatedStorage.Packages.hooks)
local RoduxHooks = require(ReplicatedStorage.Packages.roduxhooks)

-- Components
local Components = StarterPlayerScripts.Client.Roact.Components
local White_Background = require(Components.Main.White_Background)
local Grid = require(Components.Grid)
local Text = require(Components.Text)
local RedButton = require(Components.Buttons.RedButton)

-- Constants
local FramesConstants = require(StarterPlayerScripts.Client.Roact.Constants.FramesConstants)

-- Frames
local InstrumentCard = require(script.Parent.InstrumentCard)

-- UI
local DataCacheController = Knit.GetController("DataCacheController")
local Template = DataCacheController:GetFile("ZonesMusic")

function AutoTrain(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)
	local AreaReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.AreaReducer
	end)
	local AutoReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.AutoReducer
	end)
	local TutorialReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.TutorialReducer
	end)

	local Instruments = {}
	if AreaReducer.Area ~= nil and AreaReducer.Area ~= "" then
		local instrumentOrder = Template[AreaReducer.Area] and Template[AreaReducer.Area].Order
			or { "Drums", "Bass", "Guitar", "Voice" }

		-- Calculate total number of instruments for reverse ordering

		for index, instrumentName in ipairs(instrumentOrder) do
			if
				instrumentName == "Drums"
				or instrumentName == "Bass"
				or instrumentName == "Guitar"
				or instrumentName == "Voice"
			then
				-- Use (totalInstruments - index + 1) to reverse the layout order
				Instruments[instrumentName .. "Order" .. index] = InstrumentCard({
					name = instrumentName,
					image = instrumentName,
					zone = AreaReducer.Area,
					LayoutOrder = index,
					IsAutoTrain = table.find(AutoReducer.AutoTrainingCurrent or {}, instrumentName) ~= nil,
					tutorialVisible = instrumentName == "Drums" and TutorialReducer.Step4Visible,
					hooks = hooks
				})
			end
		end
	end

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		Content = White_Background({
			title = "Band Train",
			size = UDim2.fromScale(1, 1),
			pos = UDim2.fromScale(0.5, 0.5),
			ratio = 1.7,
			condition = UIReducer.CurrentUI == FramesConstants.AutoTrain,
			align = Enum.TextXAlignment.Left,
			hooks = hooks,
		}, {
			CancelAllButton = RedButton({
				text = "Cancel All Training",
				pos = UDim2.fromScale(0.5, 0.15),
				size = UDim2.fromScale(0.4, 0.1),
				action = function()
				end,
				hooks = hooks,
			}),

			Cards = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.9, 0.5),
				BackgroundTransparency = 1,
			}, {
				Grid = Grid({
					cellPadding = UDim2.fromScale(0.02, 0.02),
					cellSize = UDim2.fromScale(0.23, 1),
					sortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Roact.createFragment(Instruments),
			}),
		}),
	})
end

AutoTrain = RoactHooks.new(Roact)(AutoTrain)
return AutoTrain
