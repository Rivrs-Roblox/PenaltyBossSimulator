-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Actions = StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)
local AutoActions = require(Actions.AutoActions)

-- Controllers
local NotificationController
local FightController
local TrainingController

-- Signals
local AutoTrainingSignals = require(ReplicatedStorage.Shared.Signals.AutoTrainingSignals)

-- TemplateController
local AutoController = Knit.CreateController({
	Name = "AutoController",
	IsAutoTraining = false,
	BlockAutoTrain = false,
	IsAutoWinning = false,
	BlockAutoWin = false,
})

--|| Functions ||--

function AutoController:AutoTrain()
	if self.IsAutoTraining == true then
		Store:dispatch(AutoActions.setAutoTraining(false))
		self.IsAutoTraining = false
		self.BlockAutoWin = false

		AutoTrainingSignals.AutoTrainingStopped:Fire()
	else
		if self.BlockAutoTrain or FightController.IsFighting then
			NotificationController:Notify({
				tag = "Auto",
				text = "You can't auto train while winning." :: string,
				type = "ERROR",
			})

			return
		end

		Store:dispatch(AutoActions.setAutoTraining(true))
		self.IsAutoTraining = true
		self.BlockAutoWin = true
	end
end

function AutoController:AutoWin()
	if self.IsAutoWinning == true then
		Store:dispatch(AutoActions.setAutoWinning(false))
		self.IsAutoWinning = false
		self.BlockAutoTrain = false
	else
		if self.BlockAutoWin or TrainingController.IsTraining then
			NotificationController:Notify({
				tag = "Auto",
				text = "You can't auto win while training." :: string,
				type = "ERROR",
			})

			return
		end

		Store:dispatch(AutoActions.setAutoWinning(true))
		self.IsAutoWinning = true
		self.BlockAutoTrain = true
	end
end

--|| Knit Lifecycle ||--

function AutoController:KnitStart()
	NotificationController = Knit.GetController("NotificationController")
	FightController = Knit.GetController("FightController")
	TrainingController = Knit.GetController("TrainingController")
end

return AutoController
