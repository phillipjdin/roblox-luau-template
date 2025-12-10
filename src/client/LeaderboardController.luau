local Remo = require(game.ReplicatedStorage.packages.remo)
local store = require(script.Parent.store)

local LeaderboardRemotes = Remo.namespace("Leaderboard")

local LeaderboardController = {}

-- Fetch leaderboard data from server
function LeaderboardController.FetchLeaderboard()
	store.setLoadingLeaderboard(true)
	
	task.spawn(function()
		local success, leaderboardData = LeaderboardRemotes.Client:call("GetLeaderboard"):await()
		
		store.setLoadingLeaderboard(false)
		
		if success and leaderboardData then
			store.setLeaderboardData(leaderboardData)
		else
			warn("Failed to fetch leaderboard data")
		end
	end)
end

-- Toggle leaderboard UI
function LeaderboardController.ToggleLeaderboard()
	local state = store()
	
	-- Fetch data when opening
	if not state.isLeaderboardOpen then
		LeaderboardController.FetchLeaderboard()
	end
	
	store.toggleLeaderboard()
end

function LeaderboardController.OpenLeaderboard()
	LeaderboardController.FetchLeaderboard()
	store.toggleLeaderboard(true)
end

function LeaderboardController.CloseLeaderboard()
	store.toggleLeaderboard(false)
end

-- Auto-refresh leaderboard every 10 seconds when open
task.spawn(function()
	while true do
		task.wait(10)
		local state = store()
		if state.isLeaderboardOpen then
			LeaderboardController.FetchLeaderboard()
		end
	end
end)

return LeaderboardController
