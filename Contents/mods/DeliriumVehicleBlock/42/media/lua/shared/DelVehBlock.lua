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
--============================================================--

DelVehBlock = DelVehBlock or {}

-- Vehicle mod id -> its spawn-list file (what to require before cleaning).
-- A mod that is not active is skipped.
DelVehBlock.spawnLists = {
	["92jeepYJ"]         = "92jeepYJ_SpawnList",
	["78amgeneralM35A2"] = "78amgeneralM35A2SpawnList",
	["78lamboCountach"]  = "78lamboCountach_SpawnList",
}

-- Full script names that must never spawn on their own.
-- Includes the variants the mods do not put into the distribution today, in
-- case an update starts doing so.
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
}

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

loadSpawnLists()
print("[DelVehBlock] removed " .. tostring(DelVehBlock.clean()) .. " vehicle spawn entries")
