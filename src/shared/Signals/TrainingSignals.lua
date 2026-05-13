local Signal = require(game:GetService("ReplicatedStorage").Packages.Signal)

return {
	TrainingStarted = Signal.new(),
	TrainingStopped = Signal.new(),
}
