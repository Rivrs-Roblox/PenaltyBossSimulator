return {
	Row = nil,
	Column = nil,

	TotalColumns = 0,
	TotalRows = 0,
	Index = 0,
	TimeElapsed = 0,

	Model = "",
	CoachData = "None",

	LastInformation = {
		Position = nil,
		Raycast = nil,
		RaycastHeight = 0,
		NextRaycast = nil,
		Distance = 0,
		AnimationPosition = CFrame.new(0, 0, 0),
		AnimationRotation = CFrame.fromOrientation(0, 0, 0),
		AnimationHeight = 0,
		Orientation = CFrame.fromOrientation(0, 0, 0),
	},

	Information = {
		AnimationLeft = false,
		Arrived = false,
		Farming = false,
		Target = nil,
	},
}