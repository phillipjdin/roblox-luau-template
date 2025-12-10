# Pet Shop System

A complete pet shop system for Roblox with a modern UI built using Vide, Reflex, and Remo.

## Features

- 🏪 **Interactive Shop UI** - Beautiful, modern shop interface with animated buttons
- 🐾 **8 Unique Pets** - Common to Legendary rarity pets with unique emojis
- 💰 **Currency System** - Players start with 1000 coins to purchase pets
- 🎨 **Rarity-Based Styling** - Color-coded pet cards based on rarity
- ✓ **Ownership Tracking** - Prevents duplicate purchases
- 📊 **Real-time State Management** - Using Reflex for reactive state
- 🔄 **Server-Client Communication** - Secure purchase validation using Remo

## Available Pets

| Pet | Emoji | Price | Rarity |
|-----|-------|-------|--------|
| Dog | 🐕 | 100 | Common |
| Cat | 🐈 | 150 | Common |
| Rabbit | 🐇 | 200 | Uncommon |
| Fox | 🦊 | 350 | Uncommon |
| Panda | 🐼 | 500 | Rare |
| Lion | 🦁 | 800 | Epic |
| Dragon | 🐉 | 1500 | Legendary |
| Unicorn | 🦄 | 2000 | Legendary |

## Project Structure

```
src/
├── client/
│   ├── init.client.luau          # Client entry point
│   ├── store.luau                # Reflex store for state management
│   ├── ShopController.luau       # Shop logic controller
│   └── Components/
│       ├── ShopUI.luau           # Main shop interface
│       ├── ShopButton.luau       # Shop toggle button
│       └── PetCard.luau          # Individual pet card component
│
├── server/
│   ├── init.server.luau          # Server entry point
│   ├── PlayerDataManager.luau    # Player data storage and management
│   ├── ShopService.luau          # Shop business logic
│   └── Remotes.luau              # Remo remote functions
│
└── shared/
    ├── types.luau                # Type definitions
    └── PetData.luau              # Pet definitions and data
```

## How It Works

### Client Side

1. **Shop Button** - A persistent button in the bottom-left corner opens the shop
2. **Shop UI** - Grid-based layout showing all available pets with:
   - Pet emoji and name
   - Rarity badge with color coding
   - Description
   - Price and purchase button
   - Current coin balance in header
3. **State Management** - Reflex store manages:
   - Player coins and owned pets
   - Shop open/closed state
   - Purchase status and messages

### Server Side

1. **Player Data Manager** - Handles:
   - Player initialization (1000 starting coins)
   - Coin transactions
   - Pet ownership tracking
2. **Shop Service** - Validates and processes purchases:
   - Checks pet existence
   - Verifies ownership
   - Validates sufficient funds
   - Processes transaction atomically
3. **Remotes** - Secure communication endpoints:
   - `PurchasePet` - Process pet purchase
   - `GetPlayerData` - Fetch player data

## Usage

### For Players

1. Click the "🏪 Shop" button in the bottom-left corner
2. Browse through available pets in the grid
3. Click on a pet's price button to purchase (if you have enough coins)
4. Owned pets show a "✓ Owned" badge and cannot be repurchased
5. Click the X button or background overlay to close the shop

### For Developers

To add more pets, edit `src/shared/PetData.luau`:

```lua
{
    id = "yourpet",           -- Unique identifier
    name = "Your Pet",         -- Display name
    description = "...",       -- Description text
    price = 1000,              -- Price in coins
    emoji = "🦖",             -- Pet emoji
    rarity = "Epic",           -- Common | Uncommon | Rare | Epic | Legendary
}
```

To give players more coins (for testing), modify the `DEFAULT_COINS` constant in `src/server/PlayerDataManager.luau`.

## Technologies Used

- **Vide** - Reactive UI framework for Roblox
- **Reflex** - State management library
- **Remo** - Type-safe remote communication
- **Luau** - Typed Lua for Roblox

## Future Enhancements

Potential features to add:
- DataStore integration for persistent data
- Pet inventory UI
- Pet equip/unequip system
- Daily login rewards for coins
- Pet trading between players
- Pet stats and abilities
- Search and filter functionality
- Animation effects on purchase
- Sound effects
- Mobile-responsive UI

## Notes

- Player data currently stored in-memory (resets on server restart)
- All purchases are validated server-side to prevent exploits
- UI is designed to be responsive and modern
- Color-coded rarity system makes valuable pets stand out
