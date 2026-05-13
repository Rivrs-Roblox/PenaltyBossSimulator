local areasID = {
	[1] = 6,
	[2] = 11,
	[3] = 16,
	[4] = 21,
	[5] = 26,
	[6] = 31,
}

return table.freeze({
	ONBOARDING = {

		PLAYER_JOINED = {
			step = 1,
			name = "Player Joined",
			updateData = function(data)
				if data.FunnelsData.FirstConnection == true then
					data.FunnelsData.FirstConnection = false
					return true
				end
				return false
			end,
		},

		CLICK_COUNTER = {
			step = 2,
			name = "Clicked to get 3K Fame",
			updateData = function(data)
				if not data.FunnelsData.ClickTuto then
					data.FunnelsData.ClickTuto = true
					return true
				end
				return false
			end,
			funnelStep = "CLICK_COUNTER",
		},

		START_FIRST_FIGHT = {
			step = 3,
			name = "Started first fight vs Avril",
			updateData = function(data)
				if not data.FunnelsData.StartFirstFight then
					data.FunnelsData.StartFirstFight = true
					return true
				end
				return false
			end,
			funnelStep = "START_FIRST_FIGHT",
		},

		WIN_FIRST_FIGHT = {
			step = 4,
			name = "Won first fight vs Avril",
			updateData = function(data)
				if not data.FunnelsData.WinFirstFight then
					data.FunnelsData.WinFirstFight = true
					return true
				end
				return false
			end,
			funnelStep = "WIN_FIRST_FIGHT",
		},

		TUTORIAL_FINISHED = {
			step = 5,
			name = "Tutorial Completed",
			updateData = function(data)
				if not data.FunnelsData.TutorialFinished then
					data.FunnelsData.TutorialFinished = true
					data.TutorialComplete = true
					return true
				end
				return false
			end,
			funnelStep = "TUTORIAL_FINISHED",
		},
	},

	PROGRESSION = {
		getFightStep = function(fightNumber, areaNumber)
			if fightNumber == 0 then
				return areasID[areaNumber]
			else
				local previousZonesSteps = 1 + (4 * (areaNumber - 1)) + (areaNumber - 1)
				if fightNumber == 0 then
					return previousZonesSteps
				end
				return previousZonesSteps + fightNumber
			end
		end,
		ACTIONS = {
			COMPLETE_FIGHT = {
				updateData = function(data, npcInfo)
					local key = "Completed_Fight_" .. npcInfo.id
					if not data.FunnelsData[key] then
						data.FunnelsData[key] = true
						return true
					end
					return false
				end,
				funnelStep = function(npcInfo, self)
					local npcId = tonumber(npcInfo.id)
					local areaOrder = tonumber(npcInfo.areaOrder)

					if not npcId or not areaOrder then
						warn("Invalid npcId or areaOrder:", npcId, areaOrder)
						return 1
					end

					local fightNumber = ((npcId - 1) % 4) + 1
					return tonumber(self.PROGRESSION.getFightStep(fightNumber, areaOrder))
				end,
			},
			ENTER_AREA = {
				updateData = function(data, areaInfo)
					local key = "Entered_Area_" .. areaInfo.name
					if not data.FunnelsData[key] then
						data.FunnelsData[key] = true
						return true
					end
					return false
				end,
				funnelStep = function(areaInfo, self)
					local areaOrder = tonumber(areaInfo.areaOrder)
					if not areaOrder then
						warn("Invalid areaOrder:", areaOrder)
						return 1
					end
					return tonumber(self.PROGRESSION.getFightStep(0, areaOrder))
				end,
			},
		},
	},

	STORE = {
		OPEN_STORE = {
			step = 1,
			name = "Opened Store",
			funnelStep = "OPEN_STORE",
		},

		CLICK_ITEM = {
			step = 2,
			name = "Clicked Item",
			funnelStep = "CLICK_ITEM",
		},

		PURCHASE_ITEM = {
			step = 3,
			name = "Purchased Item",
			funnelStep = "PURCHASE_ITEM",
		},
	},
})
