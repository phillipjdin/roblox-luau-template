## Pet Shop Sample Experience

This template now ships with a lightweight pet shop so you can purchase collectible pets in-game with virtual coins. It demonstrates a basic end-to-end flow across shared modules, server-side validation, remotes, and a simple client UI.

### How it Works
- `ReplicatedStorage.shared.PetCatalog` defines the pets that can be stocked, along with their prices, rarity, and optional icons.
- `ServerScriptService.server.PetShopService` awards each player 500 starting coins, exposes safe RemoteFunctions for catalog lookup and purchases, and replicates owned pets through the `ReplicatedStorage.PetShop` folder.
- The client LocalScript builds an in-game GUI that lists every pet, displays the player’s balance, and calls back to the server to complete purchases.

### Trying It Out
1. Run the experience in Studio or via `rojo build` + `run-in-roblox`.
2. When the session starts you’ll see the shop panel on the left side of the screen with your coin balance.
3. Click `Buy` on any pet. Successful purchases update the balance, disable the button, and place the pet inside your owned list.
4. Purchase attempts are validated server-side, so insufficient funds or duplicate purchases will respond with clear error messaging in the UI.

### Extending the Shop
- Add or adjust pets inside `src/shared/PetCatalog.luau`; the catalog is data-driven.
- Update the starting balance or hook into a real data store by editing `src/server/PetShopService.luau`.
- The client UI is intentionally minimal—feel free to rebuild it or move the logic into your own controller.
