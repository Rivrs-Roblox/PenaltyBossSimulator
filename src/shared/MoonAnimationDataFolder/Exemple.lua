return {
    AnimationType = "Moon",
    Behaviors = {
        [2] = {
            CFrame = {
                [0] = {
                    Easing = {
                        Direction = Enum.EasingDirection.In,
                        Style = Enum.EasingStyle.Linear,
                    },
                    Values = CFrame.new(-1.498436, 0.310769, -2.799988, -0.000323, -0.000559, 1.000000, 0.499998, 0.866027, 0.000646, -0.866027, 0.499998, -0.000000),
                },
            },
        },
        [3] = {
            CFrame = {
                [0] = {
                    Easing = {
                        Direction = Enum.EasingDirection.In,
                        Style = Enum.EasingStyle.Linear,
                    },
                    Values = CFrame.new(-0.297215, -1.054902, -5.735641, 0.000559, -0.000323, 1.000001, -0.866027, 0.499999, 0.000646, -0.499998, -0.866027, -0.000000),
                },
            },
        },
        [4] = {
            CFrame = {
                [0] = {
                    Easing = {
                        Direction = Enum.EasingDirection.In,
                        Style = Enum.EasingStyle.Linear,
                    },
                    Values = CFrame.new(1.301960, 0.224578, -3.149994, -0.000323, -0.000559, 1.000000, 0.499998, 0.866027, 0.000646, -0.866027, 0.499998, -0.000000),
                },
            },
        },
        [5] = {
            Emit = {
                [14] = {
                    Values = 1,
                },
                [50] = {
                    Values = 1,
                },
                [59] = {
                    Values = 1,
                },
                [76] = {
                    Values = 1,
                },
            },
        },
        [6] = {
            Emit = {
                [15] = {
                    Values = 1,
                },
                [41] = {
                    Values = 1,
                },
                [67] = {
                    Values = 1,
                },
                [92] = {
                    Values = 1,
                },
                [119] = {
                    Values = 1,
                },
                [144] = {
                    Values = 1,
                },
            },
        },
        [7] = {
            Emit = {
                [26] = {
                    Values = 1,
                },
                [33] = {
                    Values = 1,
                },
            },
        },
    },
    Id = "rbxassetid://138168813449876",
    Items = {
        [2] = {
            Mode = "Relative",
            Name = "ImpactDrumLeft",
            Place = "",
            Type = "BasePart",
        },
        [3] = {
            Mode = "Relative",
            Name = "ImpactDrumKick",
            Place = "",
            Type = "BasePart",
        },
        [4] = {
            Mode = "Relative",
            Name = "ImpactDrumRight",
            Place = "",
            Type = "BasePart",
        },
        [5] = {
            Name = "ImpactRight",
            Place = "ImpactDrumRight",
            Type = "ParticleEmitter",
        },
        [6] = {
            Name = "ImpactKick",
            Place = "ImpactDrumKick",
            Type = "ParticleEmitter",
        },
        [7] = {
            Name = "ImpactLeft",
            Place = "ImpactDrumLeft",
            Type = "ParticleEmitter",
        },
    },
    Loop = true,
    Name = "Exemple",
    Priority = "Action",
    Speed = 1,
    Weight = 1,
    isExclusive = false,
}