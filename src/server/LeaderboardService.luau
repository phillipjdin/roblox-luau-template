local Players = game:GetService("Players")
local PlayerDataManager = require(script.Parent.PlayerDataManager)

local LeaderboardService = {}

local MAX_LEADERBOARD_SIZE = 50

export type LeaderboardEntry = {
	rank: number,
	playerName: string,
	userId: number,
	coins: number,
	petsOwned: number,
}

-- Get the top 50 players sorted by coins
function LeaderboardService.GetTopPlayers(): { LeaderboardEntry }
	local leaderboard: { LeaderboardEntry } = {}
	
	-- Collect all player data
	for _, player in Players:GetPlayers() do
		local data = PlayerDataManager.GetData(player)
		if data then
			table.insert(leaderboard, {
				rank = 0, -- Will be set after sorting
				playerName = player.DisplayName,
				userId = player.UserId,
				coins = data.coins,
				petsOwned = #data.ownedPets,
			})
		end
	end
	
	-- Sort by coins (descending)
	table.sort(leaderboard, function(a, b)
		if a.coins == b.coins then
			-- Secondary sort by pets owned if coins are equal
			return a.petsOwned > b.petsOwned
		end
		return a.coins > b.coins
	end)
	
	-- Limit to top 50 and assign ranks
	local topPlayers: { LeaderboardEntry } = {}
	for i = 1, math.min(#leaderboard, MAX_LEADERBOARD_SIZE) do
		local entry = leaderboard[i]
		entry.rank = i
		table.insert(topPlayers, entry)
	end
	
	return topPlayers
end

-- Get a specific player's rank and stats
function LeaderboardService.GetPlayerRank(player: Player): LeaderboardEntry?
	local topPlayers = LeaderboardService.GetTopPlayers()
	
	for _, entry in topPlayers do
		if entry.userId == player.UserId then
			return entry
		end
	end
	
	-- Player not in top 50, calculate their actual rank
	local allPlayers: { { userId: number, coins: number, petsOwned: number } } = {}
	
	for _, p in Players:GetPlayers() do
		local data = PlayerDataManager.GetData(p)
		if data then
			table.insert(allPlayers, {
				userId = p.UserId,
				coins = data.coins,
				petsOwned = #data.ownedPets,
			})
		end
	end
	
	-- Sort all players
	table.sort(allPlayers, function(a, b)
		if a.coins == b.coins then
			return a.petsOwned > b.petsOwned
		end
		return a.coins > b.coins
	end)
	
	-- Find player's rank
	local playerData = PlayerDataManager.GetData(player)
	if not playerData then
		return nil
	end
	
	for i, entry in allPlayers do
		if entry.userId == player.UserId then
			return {
				rank = i,
				playerName = player.DisplayName,
				userId = player.UserId,
				coins = playerData.coins,
				petsOwned = #playerData.ownedPets,
			}
		end
	end
	
	return nil
end

return LeaderboardService
