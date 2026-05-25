local DefaultBall = table.freeze({
	Lifetime = 0.5,
	CurveHeight = 12,
	StartForwardOffset = 2.0,
	StartRightOffset = 0.5,
	StartHeightOffset = 0.2,
})

return table.freeze({
	Default = table.freeze({
		Index = 1,
		Id = "rbxassetid://109006339253640",
		Speed = 1,
		MaxSpeedMultiplier = 3,
		MinimumShootCooldown = 1.15,
		CooldownPadding = 0.15,
		Ball = DefaultBall,
		Events = table.freeze({
			KickContact = table.freeze({
				Time = 0.3,
			}),
		}),
	}),

	Areas = table.freeze({
		[1] = table.freeze({
			Id = "rbxassetid://90962989306225",
			Speed = 1,
			MaxSpeedMultiplier = 3,
			Ball = DefaultBall,
			Events = table.freeze({
				KickContact = table.freeze({
					Time = 0.31,
				}),
			}),
		}),

		[2] = table.freeze({
			Id = "rbxassetid://106724109409632",
			Speed = 1,
			MaxSpeedMultiplier = 3,
			Ball = DefaultBall,
			Events = table.freeze({
				KickContact = table.freeze({
					Time = 2,
				}),
			}),
		}),

		[3] = table.freeze({
			Id = "rbxassetid://101967212345622",
			Speed = 1,
			MaxSpeedMultiplier = 3,
			Ball = DefaultBall,
			Events = table.freeze({
				KickContact = table.freeze({
					Time = 2.13,
				}),
			}),
		}),

		[4] = table.freeze({
			Id = "rbxassetid://104008465709867",
			Speed = 1,
			MaxSpeedMultiplier = 3,
			Ball = DefaultBall,
			Events = table.freeze({
				KickContact = table.freeze({
					Time = 2.69,
				}),
			}),
		}),

		[5] = table.freeze({
			Id = "rbxassetid://104008465709867",
			Speed = 1,
			MaxSpeedMultiplier = 3,
			Ball = DefaultBall,
			Events = table.freeze({
				KickContact = table.freeze({
					Time = 2.69,
				}),
			}),
		}),
	}),
})
