local EggPlacements = {
	[1] = {
		Vector3.new(0, 0, 0),
	},
	[3] = {
		Vector3.new(0, 0, 0),
		Vector3.new(2, 0, -1),
		Vector3.new(-2, 0, -1),
	},
	[8] = {
		Vector3.new(-3, 1.7, -1),
		Vector3.new(-1, 1.7, 0),
		Vector3.new(1, 1.7, 0),
		Vector3.new(3, 1.7, -1),
		Vector3.new(-3, -1.3, -1),
		Vector3.new(-1, -1.3, 0),
		Vector3.new(1, -1.3, 0),
		Vector3.new(3, -1.3, -1),
	},
}

local EggSizes = {
	[1] = {
		Vector3.new(2.254, 2.663, 2.254),
	},
	[3] = {
		Vector3.new(2.254, 2.663, 2.254),
		Vector3.new(2.423, 2.863, 2.423),
		Vector3.new(2.846, 3.363, 2.846),
	},
	[8] = {
		Vector3.new(2.254, 2.663, 2.254),
		Vector3.new(2.423, 2.863, 2.423),
		Vector3.new(2.423, 2.863, 2.423),
		Vector3.new(2.846, 3.363, 2.846),
		Vector3.new(2.254, 2.663, 2.254),
		Vector3.new(2.423, 2.863, 2.423),
		Vector3.new(2.423, 2.863, 2.423),
		Vector3.new(2.846, 3.363, 2.846),
	},
}

local PetPlacements = {
	[1] = {
		Vector3.new(0, 0, 0),
	},
	[3] = {
		Vector3.new(0, 0, 0),
		Vector3.new(3, 0, -1),
		Vector3.new(-3, 0, -1),
	},
	[8] = {
		Vector3.new(-3.5, 1.4, -1),
		Vector3.new(-0.8, 1.4, 0),
		Vector3.new(1.8, 1.4, 0),
		Vector3.new(4.5, 1.4, -1),
		Vector3.new(-3.5, -1.6, -1),
		Vector3.new(-0.8, -1.6, 0),
		Vector3.new(1.8, -1.6, 0),
		Vector3.new(4.5, -1.6, -1),
	},
}

return {
	EggPlacements = EggPlacements,
	EggSizes = EggSizes,
	PetPlacements = PetPlacements,
	EggSpeed = 2,
}