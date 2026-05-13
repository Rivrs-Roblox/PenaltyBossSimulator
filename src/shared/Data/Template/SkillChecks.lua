return table.freeze({
	Common = {
		delay = 3,
		value = 2,
		controllerInput = Enum.KeyCode.ButtonR1,
		promptText = "Press R1",
		image = "rbxassetid://125687653918208",
		name = "SkillCheck_Common",
		color = Color3.fromRGB(255, 255, 255), -- Putih
	},
	Uncommon = {
		delay = 2.5,
		value = 3,
		controllerInput = Enum.KeyCode.ButtonL1,
		promptText = "Press L1",
		image = "rbxassetid://116013068967631",
		name = "SkillCheck_Uncommon",
		color = Color3.fromRGB(0, 255, 0), -- Hijau
	},
	Rare = {
		delay = 2,
		value = 5,
		controllerInput = Enum.KeyCode.ButtonX,
		image = "rbxassetid://83388750524525",
		promptText = "Press X",
		name = "SkillCheck_Rare",
		color = Color3.fromRGB(0, 140, 255), -- Biru
	},
	Epic = {
		delay = 1.5,
		value = 8,
		controllerInput = Enum.KeyCode.ButtonB,
		image = "rbxassetid://89830416599360",
		promptText = "Press B",
		name = "SkillCheck_Epic",
		color = Color3.fromRGB(255, 0, 255), -- Ungu
	},
	Legendary = {
		delay = 1,
		value = 10,
		controllerInput = Enum.KeyCode.ButtonY,
		image = "rbxassetid://110656220405005",
		promptText = "Press Y",
		name = "SkillCheck_Legendary",
		color = Color3.fromRGB(255, 255, 0), -- Kuning
	},
})
