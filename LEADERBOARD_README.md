# Leaderboard System

A real-time leaderboard system displaying the top 50 players, built with Vide for UI, Reflex for state management, and Remo for server-client communication.

## Features

- 🏆 **Top 50 Rankings** - Displays the top 50 players ranked by coins
- 🥇 **Special Top 3 Styling** - Gold, Silver, and Bronze medals with special colors
- 👤 **Player Highlighting** - Your entry is highlighted in blue
- 🔄 **Auto-Refresh** - Updates every 10 seconds when open, server refreshes every 5 seconds
- 📊 **Multiple Metrics** - Shows coins and pet count for each player
- 💫 **Real-time Updates** - Reflects changes as players earn coins and buy pets
- 📱 **Beautiful UI** - Modern design with smooth animations

## How It Works

### Ranking System

Players are ranked by:
1. **Primary**: Total coins (descending)
2. **Secondary**: Number of pets owned (descending - tiebreaker)

### Visual Design

**Rank Indicators:**
- 🥇 **1st Place** - Gold border and emoji
- 🥈 **2nd Place** - Silver border and emoji
- 🥉 **3rd Place** - Bronze border and emoji
- **4th-50th** - Standard rank number display

**Entry Components:**
- Rank badge (left)
- Player username (center)
- 🐾 Pet count (right-center)
- 🪙 Coin count (right)

**Special Highlights:**
- Your entry is highlighted in blue
- If you're not in top 50, your stats appear in a footer

## Project Structure

```
src/
├── client/
│   ├── LeaderboardController.luau   # Controller for leaderboard logic
│   ├── store.luau                   # Extended with leaderboard state
│   └── Components/
│       ├── LeaderboardUI.luau       # Main leaderboard interface
│       ├── LeaderboardEntry.luau    # Individual entry component
│       └── LeaderboardButton.luau   # Toggle button
│
├── server/
│   └── LeaderboardService.luau      # Leaderboard calculation and caching
│
└── shared/
    └── LeaderboardTypes.luau        # Type definitions
```

## Technical Details

### Server-Side

**LeaderboardService.luau**
- Collects data from all connected players
- Sorts by coins (primary) and pet count (secondary)
- Limits to top 50 entries
- Caches results for 5 seconds to reduce computation
- Auto-updates every 5 seconds in background

**Remote Endpoints:**
- `GetLeaderboard` - Returns leaderboard data with player's rank

### Client-Side

**LeaderboardController.luau**
- Fetches leaderboard data from server
- Auto-refreshes every 10 seconds when open
- Manages leaderboard open/close state

**State Management (Reflex):**
- `isLeaderboardOpen` - Whether leaderboard UI is visible
- `leaderboardData` - Current leaderboard entries
- `isLoadingLeaderboard` - Loading state indicator

**UI Components:**
- `LeaderboardUI` - Main frame with scrollable entries list
- `LeaderboardEntry` - Individual player card with styling
- `LeaderboardButton` - Toggle button in bottom-left

## Usage

### For Players

1. Click the "🏆 Leaderboard" button in the bottom-left corner
2. View the top 50 players ranked by coins
3. Your entry is highlighted in blue if you're in top 50
4. If not in top 50, your stats appear at the bottom
5. Leaderboard auto-refreshes every 10 seconds
6. Click the X button or background to close

### For Developers

**Customize Ranking Criteria:**

Edit `src/server/LeaderboardService.luau` line 42:

```lua
table.sort(entries, function(a, b)
    -- Change sorting logic here
    if a.coins == b.coins then
        return a.petCount > b.petCount
    end
    return a.coins > b.coins
end)
```

**Change Leaderboard Size:**

Edit `src/server/LeaderboardService.luau` line 52:

```lua
for i = 1, math.min(50, #entries) do -- Change 50 to desired size
```

**Adjust Refresh Rates:**

Server refresh (line 5):
```lua
local CACHE_DURATION = 5 -- seconds
```

Client refresh (LeaderboardController.luau line 46):
```lua
task.wait(10) -- seconds
```

**Customize Colors:**

Edit `src/client/Components/LeaderboardEntry.luau`:

```lua
local RANK_COLORS = {
    [1] = Color3.fromRGB(255, 215, 0), -- Gold
    [2] = Color3.fromRGB(192, 192, 192), -- Silver
    [3] = Color3.fromRGB(205, 127, 50), -- Bronze
}
```

## Data Structure

### LeaderboardEntry

```lua
{
    userId: number,      -- Player's UserId
    username: string,    -- Player's display name
    coins: number,       -- Total coins
    petCount: number,    -- Number of pets owned
    rank: number,        -- Position on leaderboard (1-50)
}
```

### LeaderboardData

```lua
{
    entries: { LeaderboardEntry },  -- Array of top 50 players
    lastUpdated: number,            -- Unix timestamp of last update
    playerRank: number?,            -- Requesting player's rank (nil if not in top 50)
}
```

## Performance Considerations

- **Server caching** prevents recalculation on every request
- **Client-side throttling** limits updates to every 10 seconds
- **Top 50 limit** reduces data transmission and rendering load
- **Efficient sorting** using Luau's optimized table.sort

## Integration with Shop System

The leaderboard automatically:
- Updates when players purchase pets (pet count increases)
- Updates when players spend coins (coin count decreases)
- Shows real-time changes in player rankings
- Works seamlessly with the existing PlayerDataManager

## Future Enhancements

Potential features to add:
- Filter by different metrics (pets, total spent, etc.)
- All-time leaderboards with DataStore persistence
- Weekly/monthly leaderboard resets
- Achievement badges on entries
- Friends-only leaderboard view
- Pagination for viewing beyond top 50
- Animated rank changes
- Profile pictures/avatars
- Click entries to view player profiles
- Export/share leaderboard standings

## UI Layout

```
┌──────────────────────────────────────────┐
│  🏆 Leaderboard            [X]           │
│  Top 50 Players by Coins                 │
├──────────────────────────────────────────┤
│ ┌────────────────────────────────────┐  │
│ │ 🥇  Username    🐾 5    🪙 2000   │  │ Gold border
│ └────────────────────────────────────┘  │
│ ┌────────────────────────────────────┐  │
│ │ 🥈  Player2     🐾 4    🪙 1800   │  │ Silver border
│ └────────────────────────────────────┘  │
│ ┌────────────────────────────────────┐  │
│ │ 🥉  Player3     🐾 3    🪙 1500   │  │ Bronze border
│ └────────────────────────────────────┘  │
│ ┌────────────────────────────────────┐  │
│ │ #4  You (You)   🐾 2    🪙 1200   │  │ Blue highlight
│ └────────────────────────────────────┘  │
│            ... (scrollable)              │
└──────────────────────────────────────────┘
```

## Technologies Used

- **Vide** - Reactive UI framework
- **Reflex** - State management
- **Remo** - Remote communication
- **Luau** - Typed Lua

## Notes

- Leaderboard shows real-time data from connected players
- Only players currently in the server appear on the leaderboard
- Rankings update automatically without page refresh
- Performance optimized with caching and throttling
- Mobile-friendly responsive design
