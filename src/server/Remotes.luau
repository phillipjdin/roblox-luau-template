local Remo = require(game.ReplicatedStorage.packages.remo)
local ShopService = require(script.Parent.ShopService)
local LeaderboardService = require(script.Parent.LeaderboardService)

-- Create namespace for shop remotes
local ShopRemotes = Remo.createNamespace("Shop", function()
	return {
		PurchasePet = Remo.createRemote("PurchasePet"),
		GetPlayerData = Remo.createRemote("GetPlayerData"),
		GetLeaderboard = Remo.createRemote("GetLeaderboard"),
		GetPlayerRank = Remo.createRemote("GetPlayerRank"),
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
ShopRemotes.Server:on("GetLeaderboard", function(player)
	return LeaderboardService.GetTopPlayers(50)
end)

-- Handle player rank requests
ShopRemotes.Server:on("GetPlayerRank", function(player)
	return LeaderboardService.GetPlayerRank(player)
end)

return ShopRemotes
