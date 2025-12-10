local Remo = require(game.ReplicatedStorage.packages.remo)
local store = require(script.Parent.store)

local ShopRemotes = Remo.namespace("Shop")

local LeaderboardController = {}

function LeaderboardController.FetchTopPlayers()
	store.setLeaderboardLoading(true)
	
	task.spawn(function()
		local success, leaderboard = ShopRemotes.Client:call("GetLeaderboard"):await()
		
		store.setLeaderboardLoading(false)
		
		if success and leaderboard then
			store.setLeaderboard(leaderboard)
		else
			store.setLeaderboard({})
			warn("Failed to fetch leaderboard data")
		end
	end)
end

function LeaderboardController.Open()
	store.toggleLeaderboard(true)
	LeaderboardController.FetchTopPlayers()
end

function LeaderboardController.Close()
	store.toggleLeaderboard(false)
end

return LeaderboardController
