--============================================================--
-- Delirium-VehicleBlock
--
-- Removes the listed vehicle scripts from vanilla's VehicleZoneDistribution so
-- the world never spawns them on its own. Admin spawning is unaffected: the
-- vanilla vehicle spawner lists every vehicle script, not the distribution.
--
-- The vehicle mods add themselves to VehicleZoneDistribution at the top level
-- of their shared/*_SpawnList.lua, and Java (VehicleType.init) reads the table
-- once at world load. So the cleanup must run after those files and before
-- world load - top level of this file, with the mods' files required first so
-- the order does not depend on how Lua files of different mods are sorted.
--
-- Some KI5 mods also force-spawn a car at a fixed map point through damnlib's
-- DAMN.Spawns:add (server/ file, so loaded after this one); those points are
-- dropped in OnInitGlobalModData, see cleanForcedSpawns.
--============================================================--

DelVehBlock = DelVehBlock or {}

-- Vehicle mod id -> its spawn-list file (what to require before cleaning).
-- A mod that is not active is skipped.
DelVehBlock.spawnLists = {
	["92jeepYJ"]               = "92jeepYJ_SpawnList",
	["78amgeneralM35A2"]       = "78amgeneralM35A2SpawnList",
	["78lamboCountach"]        = "78lamboCountach_SpawnList",
	["69mini"]                 = "69mini_SpawnList",
	["69mini_ItalianJob"]      = "69miniItalianJob_SpawnList",
	["69mini_MrBean"]          = "69miniMrBean_SpawnList",
	["69mini_PitbullSpecial"]  = "69miniPitbullSpecial_SpawnList",
	["74amgeneralM151A2"]      = "74amgeneralM151A2SpawnList",
	["84jeepXJ"]               = "84jeepXJ_SpawnList",
	["93fordF350"]             = "93fordF350_SpawnList",
	["83gmcGseriesVans"]       = "83gmcGseriesVans_SpawnList",
	["83gmcVanduraATeam"]      = "83gmcVanduraATeam_SpawnList",
	["92nissanGTR"]            = "92nissanGTRSpawnList",
	["96lancerEVO"]            = "96lancerEVO_SpawnList",
	["69fordMustang"]          = "69fordMustang_SpawnList",
}

-- Full script names that must never spawn on their own: every vehicle script
-- each mod declares, including the ones it does not put into the distribution
-- today, in case an update starts doing so.
DelVehBlock.banned = {
	-- 92jeepYJ
	"Base.92jeepYJs",
	"Base.92jeepYJse",
	"Base.92jeepYJranger",
	"Base.92jeepYJjp",
	-- 78amgeneralM35A2
	"Base.78amgeneralM35A2",
	"Base.78amgeneralM49A2C",
	"Base.78amgeneralM50A3",
	"Base.78amgeneralM62",
	-- 78lamboCountach
	"Base.78lamboCountachLP400",
	"Base.78lamboCountachLP400S",
	"Base.78lamboCountachLP400Scb",
	-- 69mini (+ ItalianJob, MrBean, PitbullSpecial)
	"Base.69mini",
	"Base.69miniUnionJack",
	"Base.69miniIJ",
	"Base.69miniMrB",
	"Base.69miniPS",
	-- 74amgeneralM151A2
	"Base.74amgeneralM151A2",
	"Base.74amgeneralM151A2MP",
	"Base.74amgeneralM151A2Burnt",
	-- 84jeepXJ
	"Base.84jeepXJ2",
	"Base.84jeepXJ4",
	"Base.84jeepXJksp",
	"Base.84jeepXJpd",
	"Base.84jeepXJranger",
	-- 93fordF350
	"Base.93fordF150",
	"Base.93fordF150S",
	"Base.93fordF250",
	"Base.93fordF350",
	"Base.93fordF350CCflatBed",
	"Base.93fordF350SCflatBed",
	"Base.93fordF350dually",
	"Base.93fordF350fd",
	"Base.93fordF350pd",
	"Base.93fordF350so",
	"Base.93fordF350utility",
	"Base.93fordF350utilityDpw",
	"Base.93fordF350utilityFd",
	"Base.93fordF450CCwrecker",
	"Base.93fordF450SCwrecker",
	"Base.93fordF450ambulance",
	"Base.93fordF450box",
	"Base.93fordF450dump",
	-- 83gmcGseriesVans (+ VanduraATeam)
	"Base.83gmcG1500lwb",
	"Base.83gmcG1500aTeam",
	-- 92nissanGTR
	"Base.92nissanGTR",
	"Base.92nissanGTRlhd",
	-- 96lancerEVO
	"Base.96lancerEVO",
	"Base.96lancerEVOlhd",
	-- 69fordMustang (EV6, TBC, UBC are DAMN.Spawns:add map points)
	"Base.69fordMustangBoss302",
	"Base.69fordMustangBoss429",
	"Base.69fordMustangMach1",
	"Base.69fordMustangEV6",
	"Base.69fordMustangTBC",
	"Base.69fordMustangUBC",
}

local bannedSet = {}
for _, script in ipairs(DelVehBlock.banned) do bannedSet[script] = true end

local function loadSpawnLists()
	local mods = getActivatedMods()
	for modId, file in pairs(DelVehBlock.spawnLists) do
		if mods:contains(modId) then
			require(file)
		end
	end
end

-- Returns how many entries were removed. Walks every zone rather than a fixed
-- list: the mods write into zones of their own choosing (and vanilla's traffic
-- jam zones share one vehicles table).
function DelVehBlock.clean()
	if not VehicleZoneDistribution then return 0 end
	local removed = 0
	for _, zone in pairs(VehicleZoneDistribution) do
		if type(zone) == "table" and type(zone.vehicles) == "table" then
			for _, script in ipairs(DelVehBlock.banned) do
				if zone.vehicles[script] then
					zone.vehicles[script] = nil
					removed = removed + 1
				end
			end
		end
	end
	return removed
end

-- damnlib keeps forced map-point spawns in DAMN.Spawns.byLocation (server
-- only) and reads it on every LoadGridsquare, so dropping the entries before
-- the world loads chunks is enough. Collect keys first, then delete.
function DelVehBlock.cleanForcedSpawns()
	if not (DAMN and DAMN.Spawns and type(DAMN.Spawns.byLocation) == "table") then return 0 end
	local drop = {}
	for key, cfg in pairs(DAMN.Spawns.byLocation) do
		if type(cfg) == "table" and bannedSet[cfg.script] then
			table.insert(drop, key)
		end
	end
	for _, key in ipairs(drop) do
		DAMN.Spawns.byLocation[key] = nil
	end
	return #drop
end

loadSpawnLists()
print("[DelVehBlock] removed " .. tostring(DelVehBlock.clean()) .. " vehicle spawn entries")

if not isClient() then
	Events.OnInitGlobalModData.Add(function()
		print("[DelVehBlock] removed " .. tostring(DelVehBlock.cleanForcedSpawns()) .. " forced map spawns")
	end)
end
