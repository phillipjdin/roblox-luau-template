local Remo = require(game.ReplicatedStorage.packages.remo)
local store = require(script.Parent.store)

local LeaderboardRemotes = Remo.namespace("Leaderboard")

local LeaderboardController = {}

-- Fetch leaderboard data from server
function LeaderboardController.FetchLeaderboard()
	store.setLoadingLeaderboard(true)
	
	task.spawn(function()
		-- Fetch both top players and current player's rank in parallel
		local topPlayersPromise = LeaderboardRemotes.Client:call("GetTopPlayers")
		local playerRankPromise = LeaderboardRemotes.Client:call("GetPlayerRank")
		
		local topSuccess, topPlayers = topPlayersPromise:await()
		local rankSuccess, playerRank = playerRankPromise:await()
		
		store.setLoadingLeaderboard(false)
		
		if topSuccess and topPlayers then
			store.setLeaderboardData(topPlayers)
		else
			warn("Failed to fetch leaderboard data")
			store.setLeaderboardData({})
		end
		
		if rankSuccess and playerRank then
			store.setPlayerRank(playerRank)
		else
			store.setPlayerRank(nil)
		end
	end)
end

-- Open leaderboard UI
function LeaderboardController.OpenLeaderboard()
	store.toggleLeaderboard(true)
	LeaderboardController.FetchLeaderboard()
end

-- Close leaderboard UI
function LeaderboardController.CloseLeaderboard()
	store.toggleLeaderboard(false)
end

-- Toggle leaderboard UI
function LeaderboardController.ToggleLeaderboard()
	local state = store()
	if state.isLeaderboardOpen then
		LeaderboardController.CloseLeaderboard()
	else
		LeaderboardController.OpenLeaderboard()
	end
end

return LeaderboardController
