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
			Zone1  = { `x{FormatNumber(10000)} MONEY2`,                   10000                   },
			Zone2  = { `x{FormatNumber(14000000)} MONEY2`,                14000000                },
			Zone3  = { `x{FormatNumber(1050000000)} MONEY2`,              1050000000              },
			Zone4  = { `x{FormatNumber(318000000000)} MONEY2`,            318000000000            },
			Zone5  = { `x{FormatNumber(72000000000000)} MONEY2`,          72000000000000          },
			Zone6  = { `x{FormatNumber(3850000000000000)} MONEY2`,        3850000000000000        },
			Zone7  = { `x{FormatNumber(232000000000000000)} MONEY2`,      232000000000000000      },
			Zone8  = { `x{FormatNumber(14000000000000000000)} MONEY2`,    14000000000000000000    },
			Zone9  = { `x{FormatNumber(704000000000000000000)} MONEY2`,   704000000000000000000   },
			Zone10 = { `x{FormatNumber(26800000000000000000000)} MONEY2`, 26800000000000000000000 },
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
			Zone1  = { `x{FormatNumber(50)} Wins`,                       50                       },
			Zone2  = { `x{FormatNumber(56250)} Wins`,                    56250                    },
			Zone3  = { `x{FormatNumber(12500000)} Wins`,                 12500000                 },
			Zone4  = { `x{FormatNumber(9750000000)} Wins`,               9750000000               },
			Zone5  = { `x{FormatNumber(9000000000000)} Wins`,            9000000000000            },
			Zone6  = { `x{FormatNumber(2835000000000000)} Wins`,         2835000000000000         },
			Zone7  = { `x{FormatNumber(1050000000000000000)} Wins`,      1050000000000000000      },
			Zone8  = { `x{FormatNumber(432000000000000000000)} Wins`,    432000000000000000000    },
			Zone9  = { `x{FormatNumber(148500000000000000000000)} Wins`, 148500000000000000000000 },
			Zone10 = { `x{FormatNumber(148500000000000000000000)} Wins`, 148500000000000000000000 },
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
			Zone1  = { `x{FormatNumber(20000)} MONEY2`,                   20000                   },
			Zone2  = { `x{FormatNumber(28000000)} MONEY2`,                28000000                },
			Zone3  = { `x{FormatNumber(2100000000)} MONEY2`,              2100000000              },
			Zone4  = { `x{FormatNumber(635000000000)} MONEY2`,            635000000000            },
			Zone5  = { `x{FormatNumber(144000000000000)} MONEY2`,         144000000000000         },
			Zone6  = { `x{FormatNumber(7700000000000000)} MONEY2`,        7700000000000000        },
			Zone7  = { `x{FormatNumber(465000000000000000)} MONEY2`,      465000000000000000      },
			Zone8  = { `x{FormatNumber(28000000000000000000)} MONEY2`,    28000000000000000000    },
			Zone9  = { `x{FormatNumber(1408000000000000000000)} MONEY2`,  1408000000000000000000  },
			Zone10 = { `x{FormatNumber(53600000000000000000000)} MONEY2`, 53600000000000000000000 },
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
			Zone1  = { `x{FormatNumber(100)} Wins`,                      100                      },
			Zone2  = { `x{FormatNumber(112500)} Wins`,                   112500                   },
			Zone3  = { `x{FormatNumber(25000000)} Wins`,                 25000000                 },
			Zone4  = { `x{FormatNumber(19500000000)} Wins`,              19500000000              },
			Zone5  = { `x{FormatNumber(18000000000000)} Wins`,           18000000000000           },
			Zone6  = { `x{FormatNumber(5670000000000000)} Wins`,         5670000000000000         },
			Zone7  = { `x{FormatNumber(2100000000000000000)} Wins`,      2100000000000000000      },
			Zone8  = { `x{FormatNumber(864000000000000000000)} Wins`,    864000000000000000000    },
			Zone9  = { `x{FormatNumber(297000000000000000000000)} Wins`, 297000000000000000000000 },
			Zone10 = { `x{FormatNumber(297000000000000000000000)} Wins`, 297000000000000000000000 },
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
			Zone1  = { `x{FormatNumber(40_000)} MONEY2`,                          40_000                          },
			Zone2  = { `x{FormatNumber(57_000_000)} MONEY2`,                      57_000_000                      },
			Zone3  = { `x{FormatNumber(4_200_000_000)} MONEY2`,                   4_200_000_000                   },
			Zone4  = { `x{FormatNumber(1_270_000_000_000)} MONEY2`,               1_270_000_000_000               },
			Zone5  = { `x{FormatNumber(289_000_000_000_000)} MONEY2`,             289_000_000_000_000             },
			Zone6  = { `x{FormatNumber(15_400_000_000_000_000)} MONEY2`,          15_400_000_000_000_000          },
			Zone7  = { `x{FormatNumber(929_000_000_000_000_000)} MONEY2`,         929_000_000_000_000_000         },
			Zone8  = { `x{FormatNumber(56_000_000_000_000_000_000)} MONEY2`,      56_000_000_000_000_000_000      },
			Zone9  = { `x{FormatNumber(2_817_000_000_000_000_000_000)} MONEY2`,   2_817_000_000_000_000_000_000   },
			Zone10 = { `x{FormatNumber(107_200_000_000_000_000_000_000)} MONEY2`, 107_200_000_000_000_000_000_000 },
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
			Zone1  = { `x{FormatNumber(80000)} MONEY2`,                    80000                    },
			Zone2  = { `x{FormatNumber(113000000)} MONEY2`,                113000000                },
			Zone3  = { `x{FormatNumber(8400000000)} MONEY2`,               8400000000               },
			Zone4  = { `x{FormatNumber(2540000000000)} MONEY2`,            2540000000000            },
			Zone5  = { `x{FormatNumber(577000000000000)} MONEY2`,          577000000000000          },
			Zone6  = { `x{FormatNumber(30800000000000000)} MONEY2`,        30800000000000000        },
			Zone7  = { `x{FormatNumber(1859000000000000000)} MONEY2`,      1859000000000000000      },
			Zone8  = { `x{FormatNumber(112000000000000000000)} MONEY2`,    112000000000000000000    },
			Zone9  = { `x{FormatNumber(5634000000000000000000)} MONEY2`,   5634000000000000000000   },
			Zone10 = { `x{FormatNumber(214400000000000000000000)} MONEY2`, 214400000000000000000000 },
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
			Zone1  = { `x{FormatNumber(350)} Wins`,                        350                        },
			Zone2  = { `x{FormatNumber(393750)} Wins`,                     393750                     },
			Zone3  = { `x{FormatNumber(87500000)} Wins`,                   87500000                   },
			Zone4  = { `x{FormatNumber(68250000000)} Wins`,                68250000000                },
			Zone5  = { `x{FormatNumber(63000000000000)} Wins`,             63000000000000             },
			Zone6  = { `x{FormatNumber(19845000000000000)} Wins`,          19845000000000000          },
			Zone7  = { `x{FormatNumber(7350000000000000000)} Wins`,        7350000000000000000        },
			Zone8  = { `x{FormatNumber(3024000000000000000000)} Wins`,     3024000000000000000000     },
			Zone9  = { `x{FormatNumber(1039500000000000000000000)} Wins`,  1039500000000000000000000  },
			Zone10 = { `x{FormatNumber(1039500000000000000000000)} Wins`,  1039500000000000000000000  },
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
