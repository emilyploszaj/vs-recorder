
local PARTY_ADDR = 0xdcd7
local PARTY_END_ADDR = 0xde83

local playerData
local inventoryData
local battleTrainerClass = 0
local battleTrainerId = 0
local battleStartParty
local battleEndParty
local newboxMetadata
local newboxDatabase1
local newboxDatabase2

local battlesCollected = 0
local enabled = false

local lastPlayerData
local lastInventoryData
local lastParty
local lastNewboxMetadata
local lastNewboxDatabase1
local lastNewboxDatabase2

battleMode = -1

local function getMemoryString(start, length)
	local v = ""
	for i = start, start + length do
		local byte = emu:read8(i)
		v = v .. prettyByte(byte)
	end
	return v
end

local function saveNewbox()
	local ss = emu:saveStateBuffer(2)
	local length = ss:len()
	local start = length - 32816 + 1;
	newboxMetadata =  stringToHex(ss:sub(start + 0x2d10, start + 0x2f20 - 1))
	newboxDatabase1 = stringToHex(ss:sub(start + 0x4000, start + 0x5ff2 - 1))
	newboxDatabase2 = stringToHex(ss:sub(start + 0x6000, start + 0x7ff2 - 1))
end

local function getPartyString()
	return getMemoryString(PARTY_ADDR, PARTY_END_ADDR - PARTY_ADDR)
end

local function getBattleInfo()
	return string.format(
		"{\n" ..
		"  Version: %s\n" ..
		"  Fight: %s %s\n" ..
		"  PlayerData: %s\n" ..
		"  InventoryData: %s\n" ..
		"  StartParty: %s\n" ..
		"  EndParty: %s\n" ..
		"  NewboxMetadata: %s\n" ..
		"  NewboxDatabase1: %s\n" ..
		"  NewboxDatabase2: %s\n" ..
		"}\n",
		VERSION,
		prettyByte(battleTrainerClass), prettyByte(battleTrainerId),
		playerData,
		inventoryData,
		battleStartParty,
		battleEndParty,
		newboxMetadata,
		newboxDatabase1,
		newboxDatabase2
	)
end

local function writeBattleInfo()
	local data = getBattleInfo()
	local file = io.open(wd .. "fights.vs", "a")
	io.output(file)
	io.write(data)
	io.close(file)
	battlesCollected = battlesCollected + 1
	console:log("Battle saved!")
end

local function checkForCrystalKaizoPlus()
	if not emu then
		return "No game loaded"
	end
	if emu:getGameTitle() ~= "PM_CRYSTAL" then
		return "Game is " .. emu:getGameTitle() .. " instead of PM_CRYSTAL"
	end
	return nil
end

local function getWramBank()
	return emu:read8(0xff70) % 8
end

function updateGame()
	local check = checkForCrystalKaizoPlus()
	if check then
		enabled = false
		console:log("Updated game seems to not be CK+, ignoring:")
		console:log(check)
		buf:clear()
		buf:print("Game seems to not be CK+, not tracking fights!")
	else
		enabled = true
		console:log("Updated game seems to be CK+, tracking fights")
	end
end

function update()
	if enabled == false then
		return
	end
	local battle = emu:read8(0xd22d)
	if getWramBank() <= 1 then
		if battleMode ~= battle then
			if battleMode == 2 then
				console:log("Finished Battle")
				battleEndParty = getPartyString()
				writeBattleInfo()
			end
			battleMode = battle
			if battleMode == 2 then
				battleTrainerClass = emu:read8(0xd22f)
				battleTrainerId = emu:read8(0xd231)
				battleStartParty = getPartyString()
				playerData = getMemoryString(0xd472, 0xd4cd - 0xd472)
				inventoryData = getMemoryString(0xd848, 0xd963 - 0xd848)
				saveNewbox()
				console:log(string.format("Started battle against %s (%s)", TRAINER_CLASSES[battleTrainerClass - 1], battleTrainerId))
			end
			updateDisplay()
		end
		if emu:currentFrame() % 20 == 0 then
			updateDisplay()
		end
	end
end

function updateDisplay()
	buf:clear()
	buf:print("Vs. Recorder (Version " .. VERSION .. ") by Emi\n\n")
	if battleMode ~= 2 then
		buf:print("\n")
	else
		if TRAINER_CLASSES[battleTrainerClass - 1] then
			buf:print(string.format("Battling: %s (%s)\n", TRAINER_CLASSES[battleTrainerClass - 1], battleTrainerId))
		else
			buf:print(string.format("Battling: %s (%s)\n", battleTrainerClass, battleTrainerId))
		end
	end
	buf:print(string.format("%s Battles collected this session\n\n", battlesCollected))
	buf:print("Party:\n")
	local partyCount = emu:read8(0xdcd7);
	local baseAddress = 0xdcdf
	for i = 0, 5 do
		if i < partyCount then
			local address = baseAddress + i * 48
			local name = mons[emu:read8(address + 0)]
			local item = items[emu:read8(address + 1)]
			local level = emu:read8(address + 31)
			local hp = read16S(address + 34)
			local hpMax = read16S(address + 36)
			buf:print(string.format("%s L:%s @ %s\n", pad(name, 10), pad("" .. level, 3), item))
			buf:print(string.format("    HP: %s/%s\n", pad("" .. hp, 3), pad("" .. hpMax, 3)))
		else
			buf:print(" ---\n\n")
		end
	end
end

function getNetworkData()
	local ss = emu:saveStateBuffer(2)
	local length = ss:len()
	local start = length - 32816 + 1;
	lastPlayerData =      ss:sub(-0x7c00 + 1 + 0xd472, 0xd4cd - 0x7c00)
	lastInventoryData =   ss:sub(-0x7c00 + 1 + 0xd848, 0xd963 - 0x7c00)
	lastParty =           ss:sub(-0x7c00 + 1 + PARTY_ADDR, PARTY_END_ADDR - 0x7c00)
	lastNewboxMetadata =  ss:sub(start + 0x2d10, start + 0x2f20 - 1)
	lastNewboxDatabase1 = ss:sub(start + 0x4000, start + 0x5ff2 - 1)
	lastNewboxDatabase2 = ss:sub(start + 0x6000, start + 0x7ff2 - 1)
	return string.format(
		"{\n" ..
		"  Version: %s\n" ..
		"  PlayerData: %s\n" ..
		"  InventoryData: %s\n" ..
		"  Party: %s\n" ..
		"  NewboxMetadata: %s\n" ..
		"  NewboxDatabase1: %s\n" ..
		"  NewboxDatabase2: %s\n" ..
		"}\n",
		VERSION,
		stringToHex(lastPlayerData),
		stringToHex(lastInventoryData),
		stringToHex(lastParty),
		stringToHex(lastNewboxMetadata),
		stringToHex(lastNewboxDatabase1),
		stringToHex(lastNewboxDatabase2)
	)
end
