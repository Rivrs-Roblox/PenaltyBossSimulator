-- Balance pass v2: lower base Power, requirement tetap bertahap, multiplier coach dibuat lebih bernilai.
-- Catatan: PowerPerSecond dipakai TrainingService sebagai base per tick training, lalu dikalikan DataService multiplier.
-- Saat ini loop training server memakai task.wait(1.5), jadi secara aktual ini bukan murni per 1 detik.

return table.freeze({
	["Zone1"] = {
		[1] = {
			PowerPerSecond = 2,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 3,
			PowerRequirement = 250,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 5,
			PowerRequirement = 900,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 6,
			PowerRequirement = 3_600,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 9,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone2"] = {
		[1] = {
			PowerPerSecond = 25,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 39,
			PowerRequirement = 5_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 60,
			PowerRequirement = 22_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 100,
			PowerRequirement = 88_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 112,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone3"] = {
		[1] = {
			PowerPerSecond = 90,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 140,
			PowerRequirement = 45_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 216,
			PowerRequirement = 180_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 300,
			PowerRequirement = 720_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 405,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone4"] = {
		[1] = {
			PowerPerSecond = 300,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 465,
			PowerRequirement = 300_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 720,
			PowerRequirement = 1_200_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 1_000,
			PowerRequirement = 4_800_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 1_350,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone5"] = {
		[1] = {
			PowerPerSecond = 1_100,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 1_705,
			PowerRequirement = 2_500_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 2_640,
			PowerRequirement = 10_000_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 3_610,
			PowerRequirement = 40_000_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 4_950,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone6"] = {
		[1] = {
			PowerPerSecond = 3_700,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 5_735,
			PowerRequirement = 20_000_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 8_880,
			PowerRequirement = 85_000_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 12_200,
			PowerRequirement = 340_000_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 16_650,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone7"] = {
		[1] = {
			PowerPerSecond = 13_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 20_150,
			PowerRequirement = 180_000_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 31_200,
			PowerRequirement = 700_000_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 42_700,
			PowerRequirement = 2_800_000_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 58_500,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone8"] = {
		[1] = {
			PowerPerSecond = 45_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 69_750,
			PowerRequirement = 1_500_000_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 108_000,
			PowerRequirement = 6_000_000_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 148_000,
			PowerRequirement = 24_000_000_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 202_500,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone9"] = {
		[1] = {
			PowerPerSecond = 155_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 240_250,
			PowerRequirement = 13_000_000_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 372_000,
			PowerRequirement = 50_000_000_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 509_000,
			PowerRequirement = 200_000_000_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 697_500,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone10"] = {
		[1] = {
			PowerPerSecond = 530_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 821_500,
			PowerRequirement = 100_000_000_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 1_272_000,
			PowerRequirement = 400_000_000_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 1_740_000,
			PowerRequirement = 1_600_000_000_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 2_385_000,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone11"] = {
		[1] = {
			PowerPerSecond = 1_800_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 2_790_000,
			PowerRequirement = 850_000_000_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 4_320_000,
			PowerRequirement = 3_500_000_000_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 5_920_000,
			PowerRequirement = 14_000_000_000_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 8_100_000,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone12"] = {
		[1] = {
			PowerPerSecond = 6_200_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 9_610_000,
			PowerRequirement = 7_000_000_000_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 14_880_000,
			PowerRequirement = 28_000_000_000_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 20_400_000,
			PowerRequirement = 112_000_000_000_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 27_900_000,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone13"] = {
		[1] = {
			PowerPerSecond = 21_000_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 32_550_000,
			PowerRequirement = 60_000_000_000_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 50_400_000,
			PowerRequirement = 240_000_000_000_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 69_000_000,
			PowerRequirement = 960_000_000_000_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 94_500_000,
			PowerRequirement = 0,
			VIP = true,
		},
	},
	["Zone14"] = {
		[1] = {
			PowerPerSecond = 72_000_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 111_600_000,
			PowerRequirement = 500_000_000_000_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 172_800_000,
			PowerRequirement = 2_000_000_000_000_000,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 237_000_000,
			PowerRequirement = 8_000_000_000_000_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 324_000_000,
			PowerRequirement = 0,
			VIP = true,
		},
	},
})
