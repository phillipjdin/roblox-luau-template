local Players = game:GetService("Players")
local PlayerDataManager = require(script.Parent.PlayerDataManager)
local LeaderboardTypes = require(game.ReplicatedStorage.shared.LeaderboardTypes)

type LeaderboardEntry = LeaderboardTypes.LeaderboardEntry
type LeaderboardData = LeaderboardTypes.LeaderboardData

local LeaderboardService = {}

-- Cache leaderboard data to avoid recalculating every time
local cachedLeaderboard: { LeaderboardEntry } = {}
local lastCacheUpdate = 0
local CACHE_DURATION = 5 -- Refresh every 5 seconds

function LeaderboardService.GetLeaderboardData(requestingPlayer: Player?): LeaderboardData
	local currentTime = os.clock()
	
	-- Update cache if needed
	if currentTime - lastCacheUpdate > CACHE_DURATION or #cachedLeaderboard == 0 then
		LeaderboardService.UpdateLeaderboard()
		lastCacheUpdate = currentTime
	end
	
	-- Find requesting player's rank if provided
	local playerRank = nil
	if requestingPlayer then
		for i, entry in cachedLeaderboard do
			if entry.userId == requestingPlayer.UserId then
				playerRank = i
				break
			end
		end
	end
	
	return {
		entries = cachedLeaderboard,
		lastUpdated = lastCacheUpdate,
		playerRank = playerRank,
	}
end

function LeaderboardService.UpdateLeaderboard()
	local entries: { LeaderboardEntry } = {}
	
	-- Collect data from all players
	for _, player in Players:GetPlayers() do
		local playerData = PlayerDataManager.GetData(player)
		if playerData then
			table.insert(entries, {
				userId = player.UserId,
				username = player.Name,
				coins = playerData.coins,
				petCount = #playerData.ownedPets,
				rank = 0, -- Will be set after sorting
			})
		end
	end
	
	-- Sort by coins (descending), then by pet count (descending)
	table.sort(entries, function(a, b)
		if a.coins == b.coins then
			return a.petCount > b.petCount
		end
		return a.coins > b.coins
	end)
	
	-- Assign ranks and limit to top 50
	local topEntries: { LeaderboardEntry } = {}
	for i = 1, math.min(50, #entries) do
		entries[i].rank = i
		topEntries[i] = entries[i]
	end
	
	cachedLeaderboard = topEntries
	print(`Leaderboard updated with {#topEntries} entries`)
end

-- Auto-update leaderboard periodically
task.spawn(function()
	while true do
		task.wait(CACHE_DURATION)
		LeaderboardService.UpdateLeaderboard()
	end
end)

-- Initial update
LeaderboardService.UpdateLeaderboard()

return LeaderboardService
