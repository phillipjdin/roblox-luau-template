local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remo = require(ReplicatedStorage.packages.littensy_remo@1.5.2.remo)
local PlayerData = require(ReplicatedStorage.shared.types.PlayerData)

-- Store player data in memory (in production, use DataStore)
local playerDataStore: { [Player]: PlayerData.PlayerData } = {}

-- Initialize default player data
local function getPlayerData(player: Player): PlayerData.PlayerData
	if not playerDataStore[player] then
		playerDataStore[player] = {
			coins = 1000, -- Starting coins
			ownedPets = {},
		}
	end
	return playerDataStore[player]
end

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
	playerDataStore[player] = nil
end)

-- Create remotes for player data
local getPlayerDataRemote = remo.createRemote("getPlayerData")
local addCoinsRemote = remo.createRemote("addCoins")

getPlayerDataRemote:onRequest(function(player: Player): PlayerData.PlayerData
	return getPlayerData(player)
end)

addCoinsRemote:onRequest(function(player: Player, amount: number): boolean
	local data = getPlayerData(player)
	data.coins += amount
	return true
end)

return {
	getPlayerData = getPlayerData,
}