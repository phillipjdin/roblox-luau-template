local Players = game:GetService("Players")
local PlayerDataManager = require(script.Parent.PlayerDataManager)
local types = require(game.ReplicatedStorage.shared.types)

type LeaderboardEntry = types.LeaderboardEntry

local LeaderboardService = {}

-- Get top N players sorted by coins
function LeaderboardService.GetTopPlayers(limit: number?): { LeaderboardEntry }
	local maxPlayers = limit or 50
	local leaderboard: { LeaderboardEntry } = {}
	
	-- Collect all player data
	for _, player in Players:GetPlayers() do
		local data = PlayerDataManager.GetData(player)
		if data then
			table.insert(leaderboard, {
				userId = player.UserId,
				displayName = player.DisplayName,
				username = player.Name,
				coins = data.coins,
				petCount = #data.ownedPets,
			})
		end
	end
	
	-- Sort by coins (descending), then by pet count (descending)
	table.sort(leaderboard, function(a, b)
		if a.coins == b.coins then
			return a.petCount > b.petCount
		end
		return a.coins > b.coins
	end)
	
	-- Return only top N players
	local topPlayers = {}
	for i = 1, math.min(maxPlayers, #leaderboard) do
		topPlayers[i] = leaderboard[i]
	end
	
	return topPlayers
end

-- Get a specific player's rank
function LeaderboardService.GetPlayerRank(player: Player): number?
	local leaderboard = LeaderboardService.GetTopPlayers(1000) -- Get all players
	
	for rank, entry in ipairs(leaderboard) do
		if entry.userId == player.UserId then
			return rank
		end
	end
	
	return nil
end

return LeaderboardService
