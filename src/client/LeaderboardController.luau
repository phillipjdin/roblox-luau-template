local Remo = require(game.ReplicatedStorage.packages.remo)
local store = require(script.Parent.store)

local LeaderboardRemotes = Remo.namespace("Leaderboard")

local LeaderboardController = {}

-- Fetch leaderboard data from server
function LeaderboardController.FetchLeaderboard(limit: number?)
	limit = limit or 50
	store.setLoadingLeaderboard(true)
	
	task.spawn(function()
		local success, leaderboardData = LeaderboardRemotes.Client:call("GetTopPlayers", limit):await()
		
		store.setLoadingLeaderboard(false)
		
		if success and leaderboardData then
			store.setLeaderboardData(leaderboardData)
		else
			warn("Failed to fetch leaderboard data")
			store.setLeaderboardData({})
		end
	end)
end

-- Toggle leaderboard UI
function LeaderboardController.ToggleLeaderboard()
	store.toggleLeaderboard()
	
	-- Fetch data when opening
	if store().isLeaderboardOpen then
		LeaderboardController.FetchLeaderboard()
	end
end

function LeaderboardController.OpenLeaderboard()
	store.toggleLeaderboard(true)
	LeaderboardController.FetchLeaderboard()
end

function LeaderboardController.CloseLeaderboard()
	store.toggleLeaderboard(false)
end

return LeaderboardController
