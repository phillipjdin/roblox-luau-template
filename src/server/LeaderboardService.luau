local Players = game:GetService("Players")
local PlayerDataManager = require(script.Parent.PlayerDataManager)

local LeaderboardService = {}

export type LeaderboardEntry = {
	playerName: string,
	userId: number,
	coins: number,
	rank: number,
}

-- Get top 50 players ranked by coins
function LeaderboardService.GetTopPlayers(limit: number?): { LeaderboardEntry }
	limit = limit or 50
	
	local entries: { LeaderboardEntry } = {}
	
	-- Collect data from all players
	for _, player in Players:GetPlayers() do
		local data = PlayerDataManager.GetData(player)
		if data then
			table.insert(entries, {
				playerName = player.Name,
				userId = player.UserId,
				coins = data.coins,
				rank = 0, -- Will be set after sorting
			})
		end
	end
	
	-- Sort by coins (descending)
	table.sort(entries, function(a, b)
		return a.coins > b.coins
	end)
	
	-- Assign ranks
	for i, entry in entries do
		entry.rank = i
	end
	
	-- Return top N players
	local topPlayers = {}
	for i = 1, math.min(limit, #entries) do
		table.insert(topPlayers, entries[i])
	end
	
	return topPlayers
end

return LeaderboardService
