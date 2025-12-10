local Remo = require(game.ReplicatedStorage.packages.remo)
local store = require(script.Parent.store)

local ShopRemotes = Remo.namespace("Shop")

local LeaderboardController = {}

-- Fetch leaderboard data from server
function LeaderboardController.FetchLeaderboard()
	task.spawn(function()
		local success, leaderboardData = ShopRemotes.Client:call("GetLeaderboard"):await()
		
		if success and leaderboardData then
			store.setLeaderboardData(leaderboardData)
		else
			warn("Failed to fetch leaderboard data")
		end
	end)
end

-- Fetch player rank from server
function LeaderboardController.FetchPlayerRank()
	task.spawn(function()
		local success, rank = ShopRemotes.Client:call("GetPlayerRank"):await()
		
		if success and rank then
			store.setPlayerRank(rank)
		else
			warn("Failed to fetch player rank")
		end
	end)
end

-- Open leaderboard (fetch data and show UI)
function LeaderboardController.OpenLeaderboard()
	store.toggleLeaderboard(true)
	LeaderboardController.FetchLeaderboard()
	LeaderboardController.FetchPlayerRank()
end

-- Close leaderboard
function LeaderboardController.CloseLeaderboard()
	store.toggleLeaderboard(false)
end

-- Toggle leaderboard
function LeaderboardController.ToggleLeaderboard()
	local currentState = store()
	if currentState.isLeaderboardOpen then
		LeaderboardController.CloseLeaderboard()
	else
		LeaderboardController.OpenLeaderboard()
	end
end

return LeaderboardController
