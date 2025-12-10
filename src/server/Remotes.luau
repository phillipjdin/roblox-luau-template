local Remo = require(game.ReplicatedStorage.packages.remo)
local ShopService = require(script.Parent.ShopService)
local LeaderboardService = require(script.Parent.LeaderboardService)

-- Create namespace for shop remotes
local ShopRemotes = Remo.createNamespace("Shop", function()
	return {
		PurchasePet = Remo.createRemote("PurchasePet"),
		GetPlayerData = Remo.createRemote("GetPlayerData"),
	}
end)

-- Create namespace for leaderboard remotes
local LeaderboardRemotes = Remo.createNamespace("Leaderboard", function()
	return {
		GetLeaderboard = Remo.createRemote("GetLeaderboard"),
	}
end)

-- Handle purchase requests
ShopRemotes.Server:on("PurchasePet", function(player, petId: string)
	return ShopService.PurchasePet(player, petId)
end)

-- Handle player data requests
ShopRemotes.Server:on("GetPlayerData", function(player)
	return ShopService.GetPlayerData(player)
end)

-- Handle leaderboard requests
LeaderboardRemotes.Server:on("GetLeaderboard", function(player)
	return LeaderboardService.GetLeaderboardData(player)
end)

return {
	Shop = ShopRemotes,
	Leaderboard = LeaderboardRemotes,
}
