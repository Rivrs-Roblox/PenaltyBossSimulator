-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Helpers
local Helpers = ReplicatedStorage.Shared.Helpers
local FormatNumber = require(Helpers.Numbers.FormatNumber)

return {
	[1] = {
		Time = 60,

		Image = "Money2",

		Reward = "Currency",
		Currency = "Money2",

		Areas = {
			Zone1 = { `x{FormatNumber(500)} MONEY2`, 500 },
			Zone2 = { `x{FormatNumber(50)} MONEY2`, 50 },
			Zone3 = { `x{FormatNumber(225)} MONEY2`, 225 },
			Zone4 = { `x{FormatNumber(11250)} MONEY2`, 11250 },
			Zone5 = { `x{FormatNumber(82500)} MONEY2`, 82500 },
			Zone6 = { `x{FormatNumber(1425000)} MONEY2`, 1425000 },
			Zone7 = { `x{FormatNumber(3575000)} MONEY2`, 3575000 },
			Zone8 = { `x{FormatNumber(162500000)} MONEY2`, 162500000 },
			Zone9 = { `x{FormatNumber(1075000000)} MONEY2`, 1075000000 },
			Zone10 = { `x{FormatNumber(3575000000)} MONEY2`, 3575000000 },
			Zone11 = { `x{FormatNumber(21250000000)} MONEY2`, 21250000000 },
			Zone12 = { `x{FormatNumber(142500000000)} MONEY2`, 142500000000 },
			Zone13 = { `x{FormatNumber(700000000000)} MONEY2`, 700000000000 },
			Zone14 = { `x{FormatNumber(17850000000000)} MONEY2`, 17850000000000 },
			Zone15 = { `x{FormatNumber(107500000000000)} MONEY2`, 107500000000000 },
			Zone16 = { `x{FormatNumber(357500000000000)} MONEY2`, 357500000000000 },
			Zone17 = { `x{FormatNumber(175000000000000)} MONEY2`, 175000000000000 },
			Zone18 = { `x{FormatNumber(712500000000000)} MONEY2`, 712500000000000 },
		},

		Claimed = false,
	},

	[2] = {
		Time = 60 * 3,

		Image = "Wins",

		Reward = "Currency",
		Currency = "Wins",

		Areas = {
			Zone1 = { `x{FormatNumber(20)} Wins`, 20 },
			Zone2 = { `x{FormatNumber(10)} Wins`, 10 },
			Zone3 = { `x{FormatNumber(25)} Wins`, 25 },
			Zone4 = { `x{FormatNumber(50)} Wins`, 50 },
			Zone5 = { `x{FormatNumber(225)} Wins`, 225 },
			Zone6 = { `x{FormatNumber(3500)} Wins`, 3500 },
			Zone7 = { `x{FormatNumber(22500)} Wins`, 22500 },
			Zone8 = { `x{FormatNumber(100000)} Wins`, 100000 },
			Zone9 = { `x{FormatNumber(500000)} Wins`, 500000 },
			Zone10 = { `x{FormatNumber(2500000)} Wins`, 2500000 },
			Zone11 = { `x{FormatNumber(12500000)} Wins`, 12500000 },
			Zone12 = { `x{FormatNumber(50000000)} Wins`, 50000000 },
			Zone13 = { `x{FormatNumber(250000000)} Wins`, 250000000 },
			Zone14 = { `x{FormatNumber(1250000000)} Wins`, 1250000000 },
			Zone15 = { `x{FormatNumber(6250000000)} Wins`, 6250000000 },
			Zone16 = { `x{FormatNumber(25000000000)} Wins`, 25000000000 },
			Zone17 = { `x{FormatNumber(115000000000)} Wins`, 115000000000 }, -- 2.5Q
			Zone18 = { `x{FormatNumber(500000000000)} Wins`, 500000000000 }, -- 45Q
		},

		Claimed = false,
	},

	[3] = {
		Time = 60 * 5,

		Image = "Money2",

		Reward = "Currency",
		Currency = "Money2",

		Areas = {
			Zone1 = { `x{FormatNumber(5_000)} MONEY2`, 5_000 },
			Zone2 = { `x{FormatNumber(500)} MONEY2`, 500 },
			Zone3 = { `x{FormatNumber(2250)} MONEY2`, 2250 },
			Zone4 = { `x{FormatNumber(112500)} MONEY2`, 112500 },
			Zone5 = { `x{FormatNumber(825000)} MONEY2`, 825000 },
			Zone6 = { `x{FormatNumber(14250000)} MONEY2`, 14250000 },
			Zone7 = { `x{FormatNumber(35750000000)} MONEY2`, 35750000000 },
			Zone8 = { `x{FormatNumber(1625000000)} MONEY2`, 1625000000 },
			Zone9 = { `x{FormatNumber(10750000000)} MONEY2`, 10750000000 },
			Zone10 = { `x{FormatNumber(35750000000)} MONEY2`, 35750000000 },
			Zone11 = { `x{FormatNumber(212500000000)} MONEY2`, 212500000000 },
			Zone12 = { `x{FormatNumber(1425000000000)} MONEY2`, 1425000000000 },
			Zone13 = { `x{FormatNumber(7000000000000)} MONEY2`, 7000000000000 },
			Zone14 = { `x{FormatNumber(178500000000000)} MONEY2`, 178500000000000 },
			Zone15 = { `x{FormatNumber(1075000000000000)} MONEY2`, 1075000000000000 },
			Zone16 = { `x{FormatNumber(3575000000000000)} MONEY2`, 3575000000000000 },
			Zone17 = { `x{FormatNumber(1750000000000000)} MONEY2`, 1750000000000000 }, -- 640T
			Zone18 = { `x{FormatNumber(7125000000000000)} MONEY2`, 7125000000000000 }, -- 12.8Q
		},

		Claimed = false,
	},

	[4] = {
	Time = 60 * 8,

	Image = "RandomEgg",

	Reward = "Egg",
	Amount = 1,

	Areas = {
		Zone1 = { "x1 Random Egg", { "DefaultEgg", "SpottedEgg" } },
		Zone2 = { "x1 Random Egg", { "SilverEgg", "JuvenileEgg" } },
		Zone3 = { "x1 Random Egg", { "SakuraEgg", "SushiEgg" } },
		Zone4 = { "x1 Random Egg", { "EagleEgg", "CowboyEgg" } },
		Zone5 = { "x1 Random Egg", { "BombEgg", "DamierEgg" } },
		Zone6 = { "x1 Random Egg", { "SombreroEgg" } },
		Zone7 = { "x1 Random Egg", { "SkaterEgg" } },
		Zone8 = { "x1 Random Egg", { "MafiaEgg" } },
		Zone9 = { "x1 Random Egg", { "CoconutEgg" } },
		Zone10 = { "x1 Random Egg", { "HooliganEgg" } },
		Zone11 = { "x1 Random Egg", { "LabEgg" } },
		Zone12 = { "x1 Random Egg", { "DiscoEgg" } },
		Zone13 = { "x1 Random Egg", { "ArcadeEgg" } },
		Zone14 = { "x1 Random Egg", { "SunkenEgg" } },
		Zone15 = { "x1 Random Egg", { "SunkenEgg" } },
		Zone16 = { "x1 Random Egg", { "SunkenEgg" } },
		Zone17 = { "x1 Random Egg", { "SunkenEgg" } },
		Zone18 = { "x1 Random Egg", { "SunkenEgg" } },
	},

	Claimed = false,
},

	[5] = {
		Time = 60 * 10,

		Image = "Wins",

		Reward = "Currency",
		Currency = "Wins",

		Areas = {
			Zone1 = { `x{FormatNumber(200)} Wins`, 200 },
			Zone2 = { `x{FormatNumber(20)} Wins`, 20 },
			Zone3 = { `x{FormatNumber(50)} Wins`, 50 },
			Zone4 = { `x{FormatNumber(100)} Wins`, 100 },
			Zone5 = { `x{FormatNumber(450)} Wins`, 450 },
			Zone6 = { `x{FormatNumber(7000)} Wins`, 7000 },
			Zone7 = { `x{FormatNumber(45000)} Wins`, 45000 },
			Zone8 = { `x{FormatNumber(200000)} Wins`, 200000 },
			Zone9 = { `x{FormatNumber(1000000)} Wins`, 1000000 },
			Zone10 = { `x{FormatNumber(5000000)} Wins`, 5000000 },
			Zone11 = { `x{FormatNumber(25000000)} Wins`, 25000000 },
			Zone12 = { `x{FormatNumber(100000000)} Wins`, 100000000 },
			Zone13 = { `x{FormatNumber(500000000)} Wins`, 500000000 },
			Zone14 = { `x{FormatNumber(2500000000)} Wins`, 2500000000 },
			Zone15 = { `x{FormatNumber(12500000000)} Wins`, 12500000000 },
			Zone16 = { `x{FormatNumber(50000000000)} Wins`, 50000000000 },
			Zone17 = { `x{FormatNumber(230000000000)} Wins`, 230000000000 },
			Zone18 = { `x{FormatNumber(1000000000000)} Wins`, 1000000000000 },
		},

		Claimed = false,
	},

	[6] = {
		Time = 60 * 15,

		Image = "Gasuo",

		Reward = "Pets",
		Amount = 1,

		Areas = {
			Zone1 = { "x1 Gasuo", "Gasuo" },
			Zone2 = { "x1 Gasuo", "Gasuo" },
			Zone3 = { "x1 Gasuo", "Gasuo" },
			Zone4 = { "x1 Gasuo", "Gasuo" },
			Zone5 = { "x1 Gasuo", "Gasuo" },
			Zone6 = { "x1 Gasuo", "Gasuo" },
			Zone7 = { "x1 Gasuo", "Gasuo" },
			Zone8 = { "x1 Gasuo", "Gasuo" },
			Zone9 = { "x1 Gasuo", "Gasuo" },
			Zone10 = { "x1 Gasuo", "Gasuo" },
			Zone11 = { "x1 Gasuo", "Gasuo" },
			Zone12 = { "x1 Gasuo", "Gasuo" },
			Zone13 = { "x1 Gasuo", "Gasuo" },
			Zone14 = { "x1 Gasuo", "Gasuo" },
			Zone15 = { "x1 Gasuo", "Gasuo" },
			Zone16 = { "x1 Gasuo", "Gasuo" },
			Zone17 = { "x1 Gasuo", "Gasuo" },
			Zone18 = { "x1 Gasuo", "Gasuo" },
		},

		Claimed = false,
	},

	[7] = {
		Time = 60 * 20,

		Image = "Peach",

		Reward = "Fruit",
		Amount = 1,

		Areas = {
			Zone1 = { "x1 Peach", "3" },
			Zone2 = { "x1 Peach", "3" },
			Zone3 = { "x1 Peach", "3" },
			Zone4 = { "x1 Peach", "3" },
			Zone5 = { "x1 Peach", "3" },
			Zone6 = { "x1 Peach", "3" },
			Zone7 = { "x1 Peach", "3" },
			Zone8 = { "x1 Peach", "3" },
			Zone9 = { "x1 Peach", "3" },
			Zone10 = { "x1 Peach", "3" },
			Zone11 = { "x1 Peach", "3" },
			Zone12 = { "x1 Peach", "3" },
			Zone13 = { "x1 Peach", "3" },
			Zone14 = { "x1 Peach", "3" },
			Zone15 = { "x1 Peach", "3" },
			Zone16 = { "x1 Peach", "3" },
			Zone17 = { "x1 Peach", "3" },
			Zone18 = { "x1 Peach", "3" },
		},

		Rarity = "Rare",

		Claimed = false,
	},

	[8] = {
		Time = 60 * 25,

		Image = "Money2",

		Reward = "Currency",
		Currency = "Money2",

		Areas = {
			Zone1 = { `x{FormatNumber(50_000)} MONEY2`, 50_000 },
			Zone2 = { `x{FormatNumber(100_000)} MONEY2`, 2500 },
			Zone3 = { `x{FormatNumber(2_000_000)} MONEY2`, 11250 },
			Zone4 = { `x{FormatNumber(40_000_000)} MONEY2`, 562500 },
			Zone5 = { `x{FormatNumber(800_000_000)} MONEY2`, 4125000 },
			Zone6 = { `x{FormatNumber(16_000_000_000)} MONEY2`, 71250000 },
			Zone7 = { `x{FormatNumber(320_000_000_000)} MONEY2`, 178750000 },
			Zone8 = { `x{FormatNumber(6_400_000_000_000)} MONEY2`, 8125000000 },
			Zone9 = { `x{FormatNumber(128_000_000_000_000)} MONEY2`, 53750000000 },
			Zone10 = { `x{FormatNumber(2_560_000_000_000_000)} MONEY2`, 178750000000 },
			Zone11 = { `x{FormatNumber(50_000_000_000_000_000)} MONEY2`, 1062500000000 },
			Zone12 = { `x{FormatNumber(1_000_000_000_000_000_000)} MONEY2`, 7125000000000 },
			Zone13 = { `x{FormatNumber(20_000_000_000_000_000_000)} MONEY2`, 35000000000000 },
			Zone14 = { `x{FormatNumber(400_000_000_000_000_000_000)} MONEY2`, 892500000000000 },
			Zone15 = { `x{FormatNumber(8_000_000_000_000_000_000_000)} MONEY2`, 5375000000000000 },
			Zone16 = { `x{FormatNumber(160_000_000_000_000_000_000_000)} MONEY2`, 17875000000000000 },
			Zone17 = { `x{FormatNumber(3_200_000_000_000_000_000_000_000)} MONEY2`, 8750000000000000 },
			Zone18 = { `x{FormatNumber(64_000_000_000_000_000_000_000_000)} MONEY2`, 35625000000000000 },
		},

		Claimed = false,
	},

	[9] = {
		Time = 60 * 30,

		Image = "Money2",

		Reward = "Currency",
		Currency = "Money2",

		Areas = {
			Zone1 = { `x{FormatNumber(5_000_000)} MONEY2`, 5_000_000 },
			Zone2 = { `x{FormatNumber(5000)} MONEY2`, 5000 },
			Zone3 = { `x{FormatNumber(22500)} MONEY2`, 22500 },
			Zone4 = { `x{FormatNumber(1125000)} MONEY2`, 1125000 },
			Zone5 = { `x{FormatNumber(8250000)} MONEY2`, 8250000 },
			Zone6 = { `x{FormatNumber(142500000)} MONEY2`, 142500000 },
			Zone7 = { `x{FormatNumber(357500000)} MONEY2`, 357500000 },
			Zone8 = { `x{FormatNumber(16250000000)} MONEY2`, 16250000000 },
			Zone9 = { `x{FormatNumber(107500000000)} MONEY2`, 107500000000 },
			Zone10 = { `x{FormatNumber(357500000000)} MONEY2`, 357500000000 },
			Zone11 = { `x{FormatNumber(2125000000000)} MONEY2`, 2125000000000 },
			Zone12 = { `x{FormatNumber(14250000000000)} MONEY2`, 14250000000000 },
			Zone13 = { `x{FormatNumber(70000000000000)} MONEY2`, 70000000000000 },
			Zone14 = { `x{FormatNumber(1785000000000000)} MONEY2`, 1785000000000000 },
			Zone15 = { `x{FormatNumber(10750000000000000)} MONEY2`, 10750000000000000 },
			Zone16 = { `x{FormatNumber(35750000000000000)} MONEY2`, 35750000000000000 },
			Zone17 = { `x{FormatNumber(17500000000000000)} MONEY2`, 17500000000000000 },
			Zone18 = { `x{FormatNumber(71250000000000000)} MONEY2`, 71250000000000000 },
		},

		Claimed = false,
	},

	[10] = {
		Time = 60 * 45,

		Image = "Blue Dragon",

		Reward = "Pets",
		Amount = 1,

		Areas = {
			Zone1 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone2 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone3 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone4 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone5 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone6 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone7 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone8 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone9 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone10 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone11 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone12 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone13 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone14 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone15 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone16 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone17 = { "x1 Blue Dragon", "Blue Dragon" },
			Zone18 = { "x1 Blue Dragon", "Blue Dragon" },
		},

		Claimed = false,
	},

	[11] = {
		Time = 60 * 60 * 1.5,

		Image = "Wins",

		Reward = "Currency",
		Currency = "Wins",

		Areas = {
			Zone1 = { `x{FormatNumber(100)} Wins`, 100 },
			Zone2 = { `x{FormatNumber(200)} Wins`, 200 },
			Zone3 = { `x{FormatNumber(500)} Wins`, 500 },
			Zone4 = { `x{FormatNumber(1000)} Wins`, 1000 },
			Zone5 = { `x{FormatNumber(4500)} Wins`, 4500 },
			Zone6 = { `x{FormatNumber(70000)} Wins`, 70000 },
			Zone7 = { `x{FormatNumber(450000)} Wins`, 450000 },
			Zone8 = { `x{FormatNumber(2000000)} Wins`, 2000000 },
			Zone9 = { `x{FormatNumber(10000000)} Wins`, 10000000 },
			Zone10 = { `x{FormatNumber(50000000)} Wins`, 50000000 },
			Zone11 = { `x{FormatNumber(250000000)} Wins`, 250000000 },
			Zone12 = { `x{FormatNumber(1000000000)} Wins`, 1000000000 },
			Zone13 = { `x{FormatNumber(5000000000)} Wins`, 5000000000 },
			Zone14 = { `x{FormatNumber(25000000000)} Wins`, 25000000000 },
			Zone15 = { `x{FormatNumber(125000000000)} Wins`, 125000000000 },
			Zone16 = { `x{FormatNumber(500000000000)} Wins`, 500000000000 },
			Zone17 = { `x{FormatNumber(2300000000000)} Wins`, 2300000000000 },
			Zone18 = { `x{FormatNumber(10000000000000)} Wins`, 10000000000000 },
		},

		Claimed = false,
	},

	[12] = {
		Time = 60 * 60 * 2,

		Image = "Norauto",

		Reward = "Pets",
		Amount = 1,

		Areas = {
			Zone1 = { "x1 Norauto", "Norauto" },
			Zone2 = { "x1 Norauto", "Norauto" },
			Zone3 = { "x1 Norauto", "Norauto" },
			Zone4 = { "x1 Norauto", "Norauto" },
			Zone5 = { "x1 Norauto", "Norauto" },
			Zone6 = { "x1 Norauto", "Norauto" },
			Zone7 = { "x1 Norauto", "Norauto" },
			Zone8 = { "x1 Norauto", "Norauto" },
			Zone9 = { "x1 Norauto", "Norauto" },
			Zone10 = { "x1 Norauto", "Norauto" },
			Zone11 = { "x1 Norauto", "Norauto" },
			Zone12 = { "x1 Norauto", "Norauto" },
			Zone13 = { "x1 Norauto", "Norauto" },
			Zone14 = { "x1 Norauto", "Norauto" },
			Zone15 = { "x1 Norauto", "Norauto" },
			Zone16 = { "x1 Norauto", "Norauto" },
			Zone17 = { "x1 Norauto", "Norauto" },
			Zone18 = { "x1 Norauto", "Norauto" },
		},

		Claimed = false,
	},
}
