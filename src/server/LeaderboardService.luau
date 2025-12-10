local Players = game:GetService("Players")
local PlayerDataManager = require(script.Parent.PlayerDataManager)

local LeaderboardService = {}

export type LeaderboardEntry = {
	playerName: string,
	userId: number,
	coins: number,
	rank: number,
}

-- Get top 50 players by coins
function LeaderboardService.GetTopPlayers(limit: number?): { LeaderboardEntry }
	limit = limit or 50
	
	-- Collect all player data
	local entries: { LeaderboardEntry } = {}
	
	for player, data in pairs(PlayerDataManager.GetAllPlayers()) do
		table.insert(entries, {
			playerName = player.Name,
			userId = player.UserId,
			coins = data.coins,
			rank = 0, -- Will be set after sorting
		})
	end
	
	-- Sort by coins (descending)
	table.sort(entries, function(a, b)
		return a.coins > b.coins
	end)
	
	-- Assign ranks and limit to top N
	local topEntries: { LeaderboardEntry } = {}
	for i = 1, math.min(limit, #entries) do
		local entry = entries[i]
		entry.rank = i
		table.insert(topEntries, entry)
	end
	
	return topEntries
end

return LeaderboardService
