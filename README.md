# Roblox Pet Shop & Leaderboard System

A complete game system featuring a pet shop where players can purchase pets with coins, and a competitive leaderboard to track the top 50 players. Built with modern Roblox development practices using Vide, Reflex, and Remo.

## 🎮 Features

### Pet Shop System 🏪
- **8 Unique Pets** - From common dogs to legendary unicorns
- **Rarity System** - Common, Uncommon, Rare, Epic, and Legendary tiers
- **Currency System** - Players start with 1000 coins
- **Secure Purchases** - Server-side validation prevents exploits
- **Ownership Tracking** - No duplicate purchases allowed
- **Beautiful UI** - Color-coded cards with smooth animations

### Leaderboard System 🏆
- **Top 50 Rankings** - Real-time competitive leaderboard
- **Multiple Metrics** - Ranks by coins, shows pet count
- **Special Recognition** - Gold, silver, bronze medals for top 3
- **Player Highlighting** - Your entry is highlighted in blue
- **Auto-Refresh** - Updates every 10 seconds when open
- **Smart Display** - Shows your stats even if not in top 50

## 🚀 Quick Start

1. Open Roblox Studio with your project
2. The system initializes automatically
3. Test in Play mode:
   - Click "🏪 Shop" to browse and buy pets
   - Click "🏆 Leaderboard" to see rankings
   - Each player starts with 1000 coins

## 📁 Project Structure

```
src/
├── client/                          # Client-side code
│   ├── init.client.luau            # Client entry point
│   ├── store.luau                  # Reflex state management
│   ├── ShopController.luau         # Shop logic
│   ├── LeaderboardController.luau  # Leaderboard logic
│   └── Components/                 # UI components
│       ├── ShopUI.luau            # Main shop interface
│       ├── ShopButton.luau        # Shop toggle button
│       ├── PetCard.luau           # Individual pet card
│       ├── LeaderboardUI.luau     # Main leaderboard interface
│       ├── LeaderboardButton.luau # Leaderboard toggle button
│       └── LeaderboardEntry.luau  # Individual rank entry
│
├── server/                         # Server-side code
│   ├── init.server.luau           # Server entry point
│   ├── PlayerDataManager.luau     # Player data & coins
│   ├── ShopService.luau           # Purchase validation
│   ├── LeaderboardService.luau    # Ranking calculations
│   └── Remotes.luau               # Client-server communication
│
└── shared/                         # Shared code
    ├── types.luau                 # Pet & player data types
    ├── PetData.luau               # Pet definitions
    └── LeaderboardTypes.luau      # Leaderboard types
```

## 🐾 Available Pets

| Rank | Pet | Emoji | Price | Rarity |
|------|-----|-------|-------|--------|
| 1 | Dog | 🐕 | 100 | Common |
| 2 | Cat | 🐈 | 150 | Common |
| 3 | Rabbit | 🐇 | 200 | Uncommon |
| 4 | Fox | 🦊 | 350 | Uncommon |
| 5 | Panda | 🐼 | 500 | Rare |
| 6 | Lion | 🦁 | 800 | Epic |
| 7 | Dragon | 🐉 | 1500 | Legendary |
| 8 | Unicorn | 🦄 | 2000 | Legendary |

## 🎨 UI Overview

### Shop Interface
```
┌──────────────────────────────────────────┐
│  🏪 Pet Shop    [🪙 1000]         [X]   │
├──────────────────────────────────────────┤
│  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐    │
│  │ 🐕  │  │ 🐈  │  │ 🐇  │  │ 🦊  │    │
│  │ Dog │  │ Cat │  │Rabbit│  │ Fox │    │
│  │ 100 │  │ 150 │  │ 200 │  │ 350 │    │
│  └─────┘  └─────┘  └─────┘  └─────┘    │
│  ... (scrollable grid)                  │
└──────────────────────────────────────────┘
```

### Leaderboard Interface
```
┌──────────────────────────────────────────┐
│  🏆 Leaderboard                    [X]   │
│  Top 50 Players by Coins                 │
├──────────────────────────────────────────┤
│  🥇  Player1      🐾 8    🪙 5000       │
│  🥈  Player2      🐾 6    🪙 3200       │
│  🥉  Player3      🐾 5    🪙 2800       │
│  #4  You (You)    🐾 3    🪙 1500       │
│  ... (scrollable list)                  │
└──────────────────────────────────────────┘
```

## 🔧 Technologies Used

- **[Vide](https://github.com/centau/vide)** - Reactive UI framework for declarative interfaces
- **[Reflex](https://github.com/littensy/reflex)** - Predictable state management
- **[Remo](https://github.com/littensy/remo)** - Type-safe remote communication
- **Luau** - Typed Lua for type safety and better performance

## 📊 How It Works

### Shop System Flow

1. **Client** opens shop and views available pets
2. **Client** clicks purchase button for a pet
3. **Server** validates:
   - Pet exists
   - Player has enough coins
   - Player doesn't already own it
4. **Server** processes transaction atomically
5. **Client** receives confirmation and updates UI

### Leaderboard System Flow

1. **Server** automatically collects player data every 5 seconds
2. **Server** sorts players by coins (primary) and pets (secondary)
3. **Server** caches top 50 entries
4. **Client** requests leaderboard when opened
5. **Client** auto-refreshes every 10 seconds while open
6. **Client** highlights local player's entry

## 🎯 Key Features & Benefits

### Security
- ✅ Server-side purchase validation
- ✅ No client-side coin manipulation possible
- ✅ Atomic transactions (all-or-nothing)
- ✅ Ownership verification

### Performance
- ✅ Leaderboard caching reduces server load
- ✅ Client-side throttling prevents spam
- ✅ Efficient rendering with Vide
- ✅ Optimized state updates with Reflex

### User Experience
- ✅ Instant UI feedback
- ✅ Clear visual hierarchy
- ✅ Responsive animations
- ✅ Intuitive controls
- ✅ Mobile-friendly design

## 🛠️ Customization Guide

### Add New Pets

Edit `src/shared/PetData.luau`:

```lua
{
    id = "tiger",
    name = "Tiger",
    description = "A fierce and majestic feline!",
    price = 1200,
    emoji = "🐯",
    rarity = "Epic",
}
```

### Adjust Starting Coins

Edit `src/server/PlayerDataManager.luau`:

```lua
local DEFAULT_COINS = 1000 -- Change this value
```

### Change Leaderboard Size

Edit `src/server/LeaderboardService.luau`:

```lua
for i = 1, math.min(50, #entries) do -- Change 50 to desired size
```

### Modify Ranking Criteria

Edit `src/server/LeaderboardService.luau`:

```lua
table.sort(entries, function(a, b)
    -- Customize sorting logic
    return a.coins > b.coins
end)
```

### Customize Colors

Pet rarity colors in `src/client/Components/PetCard.luau`:
```lua
local RARITY_COLORS = {
    Common = Color3.fromRGB(150, 150, 150),
    -- ... modify as needed
}
```

Leaderboard rank colors in `src/client/Components/LeaderboardEntry.luau`:
```lua
local RANK_COLORS = {
    [1] = Color3.fromRGB(255, 215, 0), -- Gold
    -- ... modify as needed
}
```

## 📈 Future Enhancements

### Shop System
- [ ] DataStore integration for persistence
- [ ] Pet inventory UI
- [ ] Pet equip/unequip system
- [ ] Daily login rewards
- [ ] Pet trading system
- [ ] Pet abilities and stats
- [ ] Limited-time offers
- [ ] Discount system

### Leaderboard System
- [ ] Multiple leaderboard types (all-time, weekly, monthly)
- [ ] Persistent rankings with DataStores
- [ ] Achievement badges
- [ ] Friends-only view
- [ ] Profile viewing on click
- [ ] Animated rank changes
- [ ] Export/share functionality
- [ ] Season resets

### General
- [ ] Sound effects and music
- [ ] Particle effects on purchase
- [ ] Tutorial system
- [ ] Notifications system
- [ ] Mobile optimization
- [ ] Localization support

## 🐛 Troubleshooting

### Shop not opening?
- Check that client scripts are running
- Verify ReplicatedStorage has the packages folder
- Check for errors in Output window

### Purchases not working?
- Ensure server scripts are initialized
- Check that Remotes are set up correctly
- Verify player has enough coins

### Leaderboard shows no data?
- Make sure multiple players are in the game
- Check that LeaderboardService is running
- Verify server console for errors

### UI looks wrong?
- Confirm Vide package is properly installed
- Check that all UI components are in Components folder
- Verify no naming conflicts

## 📝 Notes

- Player data is stored in-memory (resets on server restart)
- In production, integrate DataStoreService for persistence
- Leaderboard only shows currently connected players
- All purchases are validated server-side to prevent exploits
- UI is designed for both desktop and mobile

## 📚 Additional Documentation

- [SHOP_README.md](./SHOP_README.md) - Detailed shop system documentation
- [LEADERBOARD_README.md](./LEADERBOARD_README.md) - Detailed leaderboard documentation

## 🤝 Contributing

Feel free to extend this system with:
- New pet types and rarities
- Additional leaderboard categories
- Enhanced UI effects
- Social features
- Mini-games to earn coins

## 📄 License

This project structure is provided as-is for Roblox game development.

---

Built with ❤️ using modern Roblox development practices
