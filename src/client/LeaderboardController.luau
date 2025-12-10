local Remo = require(game.ReplicatedStorage.packages.remo)
local store = require(script.Parent.store)

local LeaderboardRemotes = Remo.namespace("Leaderboard")

local LeaderboardController = {}

-- Fetch leaderboard data from server
function LeaderboardController.FetchLeaderboard()
	store.leaderboard.setLoading(true)
	
	task.spawn(function()
		local success, entries = LeaderboardRemotes.Client:call("GetTopPlayers", 50):await()
		
		store.leaderboard.setLoading(false)
		
		if success and entries then
			store.leaderboard.setEntries(entries)
		else
			warn("Failed to fetch leaderboard data")
			store.leaderboard.setEntries({})
		end
	end)
end

-- Toggle leaderboard UI
function LeaderboardController.ToggleLeaderboard()
	-- Note: We can't easily check current state here, so we'll use OpenLeaderboard/CloseLeaderboard instead
	-- This is kept for API compatibility but delegates to Open/Close
	LeaderboardController.OpenLeaderboard()
end

function LeaderboardController.OpenLeaderboard()
	store.leaderboard.toggleLeaderboard(true)
	LeaderboardController.FetchLeaderboard()
end

function LeaderboardController.CloseLeaderboard()
	store.leaderboard.toggleLeaderboard(false)
end

return LeaderboardController
