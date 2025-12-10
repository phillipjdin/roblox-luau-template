# Pet Shop Demo

This project now includes a lightweight pet shop loop that demonstrates
client and server communication, currency spending, and inventory
tracking.

## Features

- Shared catalog defined in `src/shared/PetCatalog.luau`
- Server remotes that manage coins, validate purchases, and sync
  inventory (`src/server/init.server.luau`)
- Client UI that lists every pet, displays coin balance, and calls the
  purchase endpoint (`src/client/init.client.luau`)

## Trying it out

1. Run `rojo serve` (or build + import the provided `default.project.json`)
   and open the place in Roblox Studio.
2. Press Play. Every player starts with 250 coins and a clean inventory.
3. Open the Pet Shop panel (auto-loads on the left) and buy a pet. The
   server deducts coins, confirms the purchase, and the UI updates to
   show owned pets.
4. Attempt to buy the same pet or an expensive one to see validation
   errors and status messaging.
