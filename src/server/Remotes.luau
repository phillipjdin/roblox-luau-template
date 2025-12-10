local Remo = require(game.ReplicatedStorage.packages.remo)
local ShopService = require(script.Parent.ShopService)

-- Create namespace for shop remotes
local ShopRemotes = Remo.createNamespace("Shop", function()
	return {
		PurchasePet = Remo.createRemote("PurchasePet"),
		GetPlayerData = Remo.createRemote("GetPlayerData"),
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

return ShopRemotes
