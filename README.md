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

## How it works

The vehicle mods add themselves to vanilla's `VehicleZoneDistribution` table
(parking lots, traffic jams, military zones...). This mod loads their spawn
lists first and then removes the listed scripts from every zone, before the
game reads the table at world load. The original mods are not modified.

Only newly generated chunks are affected - vehicles that already spawned stay.

## Adding a vehicle

Edit `42/media/lua/shared/DelVehBlock.lua`:

- add the full script name (`Base.<name>`) to `DelVehBlock.banned`;
- add `["<mod id>"] = "<spawn list file without .lua>"` to
  `DelVehBlock.spawnLists`, so that file is loaded before the cleanup.

The server log prints `[DelVehBlock] removed N vehicle spawn entries` on start.
