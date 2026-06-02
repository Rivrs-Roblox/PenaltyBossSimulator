local DefaultBall = table.freeze({
	Lifetime = 0.5,
	CurveHeight = 12,
	HorizontalCurve = -5,
	StartForwardOffset = 2.0,
	StartRightOffset = 0.5,
	StartHeightOffset = 0.2,
})

return table.freeze({
	Default = table.freeze({
		Index = 1,
		Id = "rbxassetid://90962989306225",
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
			Id = "rbxassetid://91569620861250",
			Speed = 1,
			MaxSpeedMultiplier = 3,
			Ball = table.freeze({
				Lifetime = 0.5,
				CurveHeight = 12,
				HorizontalCurve = 5,
				StartForwardOffset = 2.0,
				StartRightOffset = -0.5,
				StartHeightOffset = 0.2,
			}),
			Events = table.freeze({
				KickContact = table.freeze({
					Time = 0.31,
				}),
			}),
		}),

		[3] = table.freeze({
			Id = "rbxassetid://112265244283937",
			Speed = 1,
			MaxSpeedMultiplier = 3,
			Ball = table.freeze({
				Lifetime = 0.45,
				CurveHeight = 5,
				HorizontalCurve = -1,
				StartForwardOffset = 2.0,
				StartRightOffset = 0,
				StartHeightOffset = 4.8,
			}),
			Events = table.freeze({
				KickContact = table.freeze({
					Time = 1.81,
				}),
			}),
		}),

		[4] = table.freeze({
			Id = "rbxassetid://87868997887253",
			Speed = 1.2,
			MaxSpeedMultiplier = 3,
			Ball = table.freeze({
				Lifetime = 0.45,
				CurveHeight = 1,
				HorizontalCurve = 2,
				StartForwardOffset = 2.0,
				StartRightOffset = 0.5,
				StartHeightOffset = 0.2,
			}),
			Events = table.freeze({
				KickContact = table.freeze({
					Time = 0.6,
				}),
			}),
		}),

		[5] = table.freeze({
			Id = "rbxassetid://111382836756018",
			Speed = 1,
			MaxSpeedMultiplier = 3,
			Ball = table.freeze({
				Lifetime = 0.6,
				CurveHeight = 12,
				HorizontalCurve = -14,
				StartForwardOffset = 2.0,
				StartRightOffset = 0.5,
				StartHeightOffset = 0.2,
			}),
			Events = table.freeze({
				KickContact = table.freeze({
					Time = 2.7,
				}),
			}),
		}),

		[6] = table.freeze({
			Id = "rbxassetid://125948637948668",
			Speed = 1,
			MaxSpeedMultiplier = 3,
			Ball = table.freeze({
				Lifetime = 0.4,
				CurveHeight = 2,
				HorizontalCurve = 8,
				StartForwardOffset = 2.0,
				StartRightOffset = 0.5,
				StartHeightOffset = 0.2,
			}),
			Events = table.freeze({
				KickContact = table.freeze({
					Time = 3.65,
				}),
			}),
		}),
	}),
})
