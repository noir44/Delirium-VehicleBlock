# Delirium Vehicle Block

Project Zomboid Build 42 mod for the Delirium server. Stops selected modded
vehicles from spawning in the world on their own; admins can still spawn them
from the admin vehicle spawner.

Currently blocked:

| Mod (Workshop) | Vehicle scripts |
|---|---|
| '92 Jeep Wrangler YJ (3287727378) | `92jeepYJs`, `92jeepYJse`, `92jeepYJranger`, `92jeepYJjp` |
| '78 AM General M35 Series (2799152995) | `78amgeneralM35A2`, `78amgeneralM49A2C`, `78amgeneralM50A3`, `78amgeneralM62` |
| '78 Lamborghini Countach (3726526329) | `78lamboCountachLP400`, `78lamboCountachLP400S`, `78lamboCountachLP400Scb` |
| '69 Mini + Italian Job, Mr Bean, Pitbull Special (2937786633) | `69mini`, `69miniUnionJack`, `69miniIJ`, `69miniMrB`, `69miniPS` |
| '74 AM General M151A2 (2785549133) | `74amgeneralM151A2`, `74amgeneralM151A2MP`, `74amgeneralM151A2Burnt` |
| '84 Jeep Cherokee XJ (3409287192) | `84jeepXJ2`, `84jeepXJ4`, `84jeepXJksp`, `84jeepXJpd`, `84jeepXJranger` |
| '93 Ford F-series (3073430075) | all 18 `93fordF150*` / `93fordF250` / `93fordF350*` / `93fordF450*` scripts |
| '83 GMC G-series vans + A-Team (3799732653) | `83gmcG1500lwb`, `83gmcG1500aTeam` |
| '92 Nissan Skyline GT-R (2846036306) | `92nissanGTR`, `92nissanGTRlhd` |
| '96 Lancer Evolution (3647736504) | `96lancerEVO`, `96lancerEVOlhd` |
| '69 Ford Mustang (3756938756) | `69fordMustangBoss302`, `69fordMustangBoss429`, `69fordMustangMach1`, `69fordMustangEV6`, `69fordMustangTBC`, `69fordMustangUBC` |

## How it works

The vehicle mods add themselves to vanilla's `VehicleZoneDistribution` table
(parking lots, traffic jams, military zones...). This mod loads their spawn
lists first and then removes the listed scripts from every zone, before the
game reads the table at world load. Map-point spawns registered through
damnlib's `DAMN.Spawns:add` (the Mustang's EV6, TBC and UBC) are dropped
from `DAMN.Spawns.byLocation` on the server in `OnInitGlobalModData`. The
original mods are not modified.

Only newly generated chunks are affected - vehicles that already spawned stay.

## Adding a vehicle

Edit `42/media/lua/shared/DelVehBlock.lua`:

- add the full script name (`Base.<name>`) to `DelVehBlock.banned`;
- add `["<mod id>"] = "<spawn list file without .lua>"` to
  `DelVehBlock.spawnLists`, so that file is loaded before the cleanup.

The server log prints `[DelVehBlock] removed N vehicle spawn entries` and
`[DelVehBlock] removed N forced map spawns` on start.
