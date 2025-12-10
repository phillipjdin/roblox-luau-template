local Remo = require(game.ReplicatedStorage.packages.remo)
local LeaderboardService = require(script.Parent.LeaderboardService)

-- Create namespace for leaderboard remotes
local LeaderboardRemotes = Remo.createNamespace("Leaderboard", function()
	return {
		GetTopPlayers = Remo.createRemote("GetTopPlayers"),
		GetPlayerRank = Remo.createRemote("GetPlayerRank"),
	}
end)

-- Handle get top players request
LeaderboardRemotes.Server:on("GetTopPlayers", function(player)
	return LeaderboardService.GetTopPlayers()
end)

-- Handle get player rank request
LeaderboardRemotes.Server:on("GetPlayerRank", function(player)
	return LeaderboardService.GetPlayerRank(player)
end)

return LeaderboardRemotes
