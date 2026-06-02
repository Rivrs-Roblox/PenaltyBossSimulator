--[=[--------------------------------------------------------

        This file is used for messages arround
        the project that will be sent to the user.

        There can be two types of messages:
        - Normal messages represented as strings
        - Function messages, which is a function take arguments to modify the string.

--------------------------------------------------------]=]
--

return table.freeze({
	Robux_Icon = "",

	Notifications = {
		Vip_Needed = function(type: string)
			return `You need VIP to use this {type} !`
		end,
		Not_Enough_Money = function(type: string)
			return `You don't have enough {type} !`
		end,

		Teleporter_Not_Exists = function(name: string)
			return `This teleporter ({name}) is not available.`
		end,
		Teleporter_Not_Unlocked = "You haven't unlocked this teleporter yet.",
		Teleporter_Already_Bought = "You have already bought this teleporter.",
		Teleporter_Bought = function(name: string)
			return `You bought the teleporter for {name}.`
		end,

		Boss_Fight_Win = function(name: string, win: number)
			return `You won {win} Wins by stopping the {name} !`
		end,

		Npc_Already_Fighting = "You are already fighting against another NPC.",
		Npc_Not_Found = function(name: string)
			return `There is no data for this NPC ({name}).`
		end,
		Npc_Not_Fighting = function(name: string)
			return `You are not fighting this NPC ({name}).`
		end,
		Npc_Fight_Start = function(name: string)
			return `You are now fighting against {name} !`
		end,
		Npc_Fight_Ended = function(win: number, name: string)
			return `You won {win} trophees by winning against {name} !`
		end,
		Previous_Npc_Not_Beaten = function(name: string)
			return `You need to beat {name} before trying to fight this NPC.`
		end,
		PreviousBoss_Not_Beaten = "You need to beat previous area's boss before doing that.",

		Purchase_Success = "Your purchase has been completed. Thanks for supporting us!",
		Purchase_Error = "Your purchase has been canceled.",

		Rebirth_Successfull = function(rebirth: number)
			return `You successfully rebirthed! You've rebirthed {rebirth} time{if rebirth > 1 then "s" else ""}!`
		end,

		Trail_Not_Exists = "This trail does not exists.",
		Trail_Allready_Bought = "You have already bought this trail.",
		Trail_Not_Bought = "You need to buy this trail before using it.",
		Trail_Bought = function(name: string)
			return `You bought the {name} Trail.`
		end,
		Trail_Equipped = function(name: string)
			return `You've equipped the {name} Trail.`
		end,
		Trail_Desequipped = function(name: string)
			return `You've desquipped the {name} Trail.`
		end,
		Buy_Trail_First = function(name: string)
			return `You need to buy the {name} Trail before this one.`
		end,

		Click_Not_Exists = "This click does not exists.",
		Click_Allready_Bought = "You have already bought this click.",
		Click_Not_Bought = "You need to unlock this click before using it.",
		Click_Bought = function(number: number)
			return `You've unlocked Click x{number}.`
		end,
		Click_Equipped = function(number: number)
			return `You've equipped the Click x{number}.`
		end,
		Click_Desequipped = function(number: number)
			return `You've desquipped the Click x{number}.`
		end,
		Buy_Click_First = function(number: number)
			return `You need to unlock Click x{number} before this one.`
		end,

		Tool_Not_Exists = "This tools does not exists.",
		Tool_Allready_Bought = "You've already bought this tool.",
		Tool_Not_Unlocked = "You need to unlock this tool before using it.",
		Tool_Alreay_Equipped = "You've already equipped this tool.",
		Tool_Bought = function(name: string)
			return `You've bought the{name:gsub("Pillows", ""):gsub("_", " ")} Tool.`
		end,
		Tool_Equipped = function(name: string)
			return `You've equipped the{name:gsub("Pillows", ""):gsub("_", " ")} Tool.`
		end,
		Tool_Desequipped = function(name: string)
			return `You've desquipped the{name:gsub("Pillows", ""):gsub("_", " ")} Tool.`
		end,
		Buy_Tool_First = function(name: string)
			return `You need to buy the{name:gsub("Pillows", ""):gsub("_", " ")} Tool before this one.`
		end,

		Dance_Not_Exists = "This dance does not exists.",
		Dance_Allready_Owned = "You've already owned this dance.",
		Dance_Not_Owned = "You need to own this dance before using it.",
		Dance_Equipped = function(name: string)
			return `You've equipped the {name} dance.`
		end,
		Dance_Not_Equipped = "You need to equip this dance before using it.",

		Code_Not_Exists = "This code does not exists.",
		Code_Already_Redeemed = "You've already redeemed this code.",
		Code_Redeemed = "You've redeemed the code !",

		No_Name_Provided = "Please, provide your username.",
		Already_Verified = "You are already verified.",
		User_Verified = "You've been successfully verified !",

		Player_Alreay_Invited = "You've already invited this player to play.",
		Player_Invited = "You've invited this player to play with you !",
		Player_Cant_Invite = "You can't invite this player to play with you.",

		Friend_Shop_No_Item = "This item does not exists in the shop.",
		Friend_Shop_Buy = function(name: string)
			return `You've bought {name} from the friend shop !`
		end,

		Coach_Not_Exists = function(name: string)
			return `This coach ({name}) does not exists.`
		end,
		Coach_Not_Owned = function(name: string)
			return `You don't own this coach ({name}).`
		end,
		Max_Coach_Equipped = function(max: number)
			return `You can't equip more than {max} coaches at the time.`
		end,
		Coach_Not_Equipped = function(name: string)
			return `This coach ({name}) is not equipped.`
		end,
		Coach_Bought = function(name: string)
			return `You bought the {name} coach.`
		end,
		Coach_Equipped = function(name: string)
			return `You've equipped the {name} coach.`
		end,
		Coach_Unequipped = function(name: string)
			return `You've unequipped the {name} coach.`
		end,
		Coaches_Best_Equipped = function(max: number)
			return `You've equipped your {max} best coaches.`
		end,
		Coach_Deleted = function(name: string)
			return `You've deleted {name} coach!`
		end,
		Buy_Previous_Coach_First = function(name: string)
			return `Unlock {name} first before buying this coach.`
		end,

		Pet_Not_Exists = function(name: string)
			return `This pet ({name}) does not exists.`
		end,
		Pet_Not_Yours = function(name: string)
			return `You don't own this pet ({name}).`
		end,
		Max_Pet_Stored = function(max: number)
			return `You can't store more than {max} pets at the time.`
		end,
		Max_Pet_Equipped = function(max: number)
			return `You can't equip more than {max} pets at the time.`
		end,
		Pet_Not_Equipped = function(name: string)
			return `This pet ({name}) is not equipped.`
		end,
		Pet_Deleted = function(name: string)
			return `You've deleted {name} pet!`
		end,
		Pet_Equipped = function(name: string)
			return `You've equipped the {name} pet.`
		end,
		Pet_Unequipped = function(name: string)
			return `You've unequipped the {name} pet.`
		end,
		Pets_Best_Equipped = function(max: number)
			return `You've equipped your {max} best pets.`
		end,
		Pets_Best_Equipeed = function(max: number)
			return `You've equipped your {max} best pets.`
		end,
		Pet_Claimed = function(name: string)
			return `You've claimed your {name} pet!`
		end,
		No_Pet_Claimable = "No pet is claimable right now.",

		SoccerCharacter_Not_Exists = function(name: string)
			return `This character ({name}) does not exists.`
		end,
		SoccerCharacter_Not_Yours = function(name: string)
			return `You don't own this character.`
		end,
		Max_SoccerCharacter_Stored = function(max: number)
			return `You can't store more than {max} characters at te time.`
		end,
		SoccerCharacter_Deleted = function(name: string)
			return `You've deleted {name} character !`
		end,
		SoccerCharacter_Equipped = function(name: string)
			return `You've equipped the {name} !`
		end,
		SoccerCharacter_Claimed = function(name)
			return `You've claimed your {name} character !`
		end,
		Buy_Previous_Character_First = function(name: string)
			return `Unlock {name} first before buying this character.`
		end,

		Reward_Already_Claimed = "You've already claimed this reward.",
		Reward_Not_Ready = "This reward is not ready yet.",
		Reward_Claimed_Success = "You've claimed your reward !",
		Reward_Reseted = "Your rewards have been reset !",

		Coach_Claimed = function(name)
			return `You've claimed your {name} Coach!`
		end,

		Already_Spining = "Wait for your current spin to finish.",
		Wheel_Not_Found = function(name)
			return `This wheel ({name}) has not been found.`
		end,
		No_More_Spins = function(name)
			return `You don't have any {name} Spin left.`
		end,
		Wheel_Won = function(name)
			return `You've won {name} in the wheel !`
		end,
		Free_Spin = function(number)
			return `You got +{number} Free Spin.`
		end,

		Not_Trading = "You are currently not trading.",
		No_Request = "You don't have any pending request.",

		Already_Trading = "You're already trading with someone else.",
		Already_Requesting = "Please, wait a bit between each trade request.",
		Trade_Completed = "The trade has been processed !",
		Cant_Trade_Yoursel = "You can't trade yourself.",
		Enable_Trade = "You need to enable trade requests before sending one.",
		Trade_Proceeding = "You can't cancel the trade while it is proceeding the exchange.",

		Trade_Disabled = function(name)
			return `{name} does not accepts trade requests.`
		end,
		Player_Already_Trading = function(name)
			return `{name} is already in a trading with a player.`
		end,
		Player_Is_Fighting = function(name)
			return `{name} is currently fighting.`
		end,
		Pet_Alreay_Added = function(name)
			return `You've already added this pet ({name}) to the trade.`
		end,
		Pet_Not_Added = function(name)
			return `You've not added this pet ({name}) to the trade.`
		end,
		Request_Declined = function(name)
			return `{name} has declined your trade request.`
		end,
		Request_Declined_Receiver = function(name)
			return `You declined the trade request from {name}.`
		end,
		Request_Sent = function(name)
			return `You've send a trade request to {name}.`
		end,

		Quest_Completed = "You've completed the quest!",
		Quest_Not_Completed = "You've not completed the quest.",
		Quest_Reward_Claimed = "You've claimed your reward!",
		Quest_Reward_Not_Claimed = "This reward is not available at the moment.",

		Not_Enough_Storage_Space = "You do not have enough storage space.",
		Egg_Not_Robux = "This egg is not buyable with Robux.",
		Egg_Not_Exists = function(name)
			return `This egg ({name}) does not exists.`
		end,
		Unwanted_Coach_Obtained = "This reward gave you an unwanted coach",

		Pass_Needed = function(name)
			return `You need the {name} Gamepass to perform this action.`
		end,

		Cant_Buy = "You can't buy this item right now.",
		Cant_Buy_In_Region = " You can't buy this item in your region",
		Cant_Buy_Pass = "You can't buy this item more than once.",

		Not_In_Group = "You need to join the Roblox Group to perform this action.",
		Chest_Not_Ready = "This chest is not ready.",
		Chest_Claimed = function(msg: string)
			return `You've won {msg}!`
		end,
		Chest_Already_Claimed = "You have already claimed this chest",

		Not_Same_Pet = "This pet is not the same as the first one.",
		Not_Gold_Pet = "This pet is not a Gold pet.",
		Cant_Add_More_Than_4 = "You can't add more than 4 pets to the craft.",
		Select_At_Least_One = "You need to select at least one pet to craft.",
		No_Gold_Variant = function(name)
			return `This pet ({name}) has no Gold variant.`
		end,
		No_Rainbow_Variant = function(name)
			return `This pet ({name}) has no Rainbow variant.`
		end,
		Craft_Done = function(name, goldName)
			return `You {name} pet has been upgraded to {goldName}!`
		end,
		Craft_Failed = "The craft of your gold pet has failed.",
		Craft_Rainbow_Failed = "The craft of your rainbow pet has failed.",

		Can_Rebirth_X_Times = function(number: number)
			return `You can rebirth {number} time!`
		end,
		Can_Buy_X_Areas = function(number: number)
			return `You can buy {number} areas!`
		end,
		Can_Buy_X_Auras = function(number: number)
			return `You can buy {number} auras!`
		end,
		Can_Buy_X_Trails = function(number: number)
			return `You can buy {number} trails!`
		end,
		Can_Buy_X_Coaches = function(number: number)
			return `You can buy {number} coaches!`
		end,
		Can_Buy_X_Bodies = function(number: number)
			return `You can buy {number} skins!`
		end,
		Can_Buy_X_Characters = function(number: number)
			return `You can buy {number} characters!`
		end,

		Can_Buy_Claim_Daily_Reward = "You can claim your daily reward!",
		Can_access_new_area = "You can access a new Area",
		Can_Claim_Season_Reward = "You can claim your season pass reward!",

		Badge_Obtained = function(badgename: string)
			return `You've obtained the {badgename:gsub("Badge_", "")} Badge`
		end,

		["Action1"] = {
			Start = "Start jumping to gain Agility !",
		},

		["Action2"] = {
			Start = "Start clicking to gain Disco Ball !",
		},

		Rejoin_Reward_Not_Ready = "Your rejoin reward is not ready yet.",
		Rejoin_Reward_Claimed = "You've claimed your rejoin reward!",
		Rejoin_Reward_Claimed_Done = "You've claimed your rejoin reward!",

		Dont_Have_Season_Pass = "You don't have season pass!",
		Prerequisite_Not_Met = function(reqValue: number, key: string)
			return `You need {reqValue} {key} to buy this!`
		end,
	},
})
