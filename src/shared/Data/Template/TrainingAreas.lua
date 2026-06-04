-- Balance v4: Req = Boss_n.Power × k (gates next spot)
-- S1=free, S2..S5 require beating Boss 1..4
-- S6=VIP (no power req)
local VIP_POWER_MULTIPLIER = 1.2

local function getVipPower(freePower: number): number
	return math.floor((freePower * VIP_POWER_MULTIPLIER) + 0.5)
end

return table.freeze({
	["Zone1"] = {  -- k=0.8
		[1] = {
			PowerPerSecond = 2,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 3,
			PowerRequirement = 24,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 5,
			PowerRequirement = 72,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 6,
			PowerRequirement = 240,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 9,
			PowerRequirement = 1_224,
			VIP = false,
		},
		[6] = {
			PowerPerSecond = getVipPower(6),
			PowerRequirement = 0,
			VIP = true,
		},
	},

	["Zone2"] = {  -- k=0.8
		[1] = {
			PowerPerSecond = 25,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 39,
			PowerRequirement = 120,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 60,
			PowerRequirement = 374,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 100,
			PowerRequirement = 2_016,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 112,
			PowerRequirement = 15_456,
			VIP = false,
		},
		[6] = {
			PowerPerSecond = getVipPower(100),
			PowerRequirement = 0,
			VIP = true,
		},
	},

	["Zone3"] = {  -- k=0.85
		[1] = {
			PowerPerSecond = 90,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 140,
			PowerRequirement = 1_071,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 216,
			PowerRequirement = 4_189,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 300,
			PowerRequirement = 39_327,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 405,
			PowerRequirement = 284_580,
			VIP = false,
		},
		[6] = {
			PowerPerSecond = getVipPower(300),
			PowerRequirement = 0,
			VIP = true,
		},
	},

	["Zone4"] = {  -- k=0.9
		[1] = {
			PowerPerSecond = 300,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 465,
			PowerRequirement = 11_286,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 720,
			PowerRequirement = 63_277,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 1_000,
			PowerRequirement = 576_202,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 1_350,
			PowerRequirement = 3_931_200,
			VIP = false,
		},
		[6] = {
			PowerPerSecond = getVipPower(1_000),
			PowerRequirement = 0,
			VIP = true,
		},
	},

	["Zone5"] = {  -- k=0.9
		[1] = {
			PowerPerSecond = 1_100,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 1_705,
			PowerRequirement = 198_990,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 2_640,
			PowerRequirement = 1_031_184,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 3_610,
			PowerRequirement = 7_997_616,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 4_950,
			PowerRequirement = 50_598_626,
			VIP = false,
		},
		[6] = {
			PowerPerSecond = getVipPower(3_610),
			PowerRequirement = 0,
			VIP = true,
		},
	},

	["Zone6"] = {  -- k=0.9
		[1] = {
			PowerPerSecond = 3_700,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 5_735,
			PowerRequirement = 1_670_328,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 8_880,
			PowerRequirement = 8_909_781,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 12_200,
			PowerRequirement = 65_371_363,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 16_650,
			PowerRequirement = 393_356_304,
			VIP = false,
		},
		[6] = {
			PowerPerSecond = getVipPower(12_200),
			PowerRequirement = 0,
			VIP = true,
		},
	},

	["Zone7"] = {  -- k=0.95
		[1] = {
			PowerPerSecond = 13_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 20_150,
			PowerRequirement = 13_091_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 31_200,
			PowerRequirement = 66_891_552,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 42_700,
			PowerRequirement = 622_771_968,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 58_500,
			PowerRequirement = 3_848_190_612,
			VIP = false,
		},
		[6] = {
			PowerPerSecond = getVipPower(42_700),
			PowerRequirement = 0,
			VIP = true,
		},
	},

	["Zone8"] = {  -- k=0.95
		[1] = {
			PowerPerSecond = 45_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 69_750,
			PowerRequirement = 82_627_200,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 108_000,
			PowerRequirement = 462_300_210,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 148_000,
			PowerRequirement = 4_620_693_600,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 202_500,
			PowerRequirement = 29_282_818_240,
			VIP = false,
		},
		[6] = {
			PowerPerSecond = getVipPower(148_000),
			PowerRequirement = 0,
			VIP = true,
		},
	},

	["Zone9"] = {  -- k=1.1
		[1] = {
			PowerPerSecond = 155_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 240_250,
			PowerRequirement = 643_808_000,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 372_000,
			PowerRequirement = 3_576_275_010,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 509_000,
			PowerRequirement = 35_321_816_640,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 697_500,
			PowerRequirement = 229_310_628_360,
			VIP = false,
		},
		[6] = {
			PowerPerSecond = getVipPower(509_000),
			PowerRequirement = 0,
			VIP = true,
		},
	},

	["Zone10"] = {  -- k=1.1
		[1] = {
			PowerPerSecond = 530_000,
			PowerRequirement = 0,
			VIP = false,
		},
		[2] = {
			PowerPerSecond = 821_500,
			PowerRequirement = 4_067_940_800,
			VIP = false,
		},
		[3] = {
			PowerPerSecond = 1_272_000,
			PowerRequirement = 36_039_369_300,
			VIP = false,
		},
		[4] = {
			PowerPerSecond = 1_740_000,
			PowerRequirement = 328_888_956_000,
			VIP = false,
		},
		[5] = {
			PowerPerSecond = 2_385_000,
			PowerRequirement = 2_056_281_018_000,
			VIP = false,
		},
		[6] = {
			PowerPerSecond = getVipPower(1_740_000),
			PowerRequirement = 0,
			VIP = true,
		},
	},

})