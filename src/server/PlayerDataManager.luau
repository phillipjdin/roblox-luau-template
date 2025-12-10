local Players = game:GetService("Players")
local types = require(game.ReplicatedStorage.shared.types)

type PlayerData = types.PlayerData

-- In-memory storage for player data (in production, use DataStoreService)
local playerData: { [Player]: PlayerData } = {}

local DEFAULT_COINS = 1000 -- Starting coins

local PlayerDataManager = {}

function PlayerDataManager.Initialize(player: Player)
	-- Initialize player data with default values
	playerData[player] = {
		coins = DEFAULT_COINS,
		ownedPets = {},
	}
	
	print(`Initialized data for {player.Name}`)
end

function PlayerDataManager.GetData(player: Player): PlayerData?
	return playerData[player]
end

function PlayerDataManager.AddCoins(player: Player, amount: number): boolean
	local data = playerData[player]
	if not data then
		return false
	end
	
	data.coins += amount
	return true
end

function PlayerDataManager.RemoveCoins(player: Player, amount: number): boolean
	local data = playerData[player]
	if not data or data.coins < amount then
		return false
	end
	
	data.coins -= amount
	return true
end

function PlayerDataManager.HasPet(player: Player, petId: string): boolean
	local data = playerData[player]
	if not data then
		return false
	end
	
	return table.find(data.ownedPets, petId) ~= nil
end

function PlayerDataManager.AddPet(player: Player, petId: string): boolean
	local data = playerData[player]
	if not data then
		return false
	end
	
	if PlayerDataManager.HasPet(player, petId) then
		return false -- Already owned
	end
	
	table.insert(data.ownedPets, petId)
	return true
end

function PlayerDataManager.Cleanup(player: Player)
	playerData[player] = nil
	print(`Cleaned up data for {player.Name}`)
end

function PlayerDataManager.GetAllPlayers(): { [Player]: PlayerData }
	return playerData
end

-- Connect to player events
Players.PlayerAdded:Connect(function(player)
	PlayerDataManager.Initialize(player)
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerDataManager.Cleanup(player)
end)

-- Initialize existing players (for testing)
for _, player in Players:GetPlayers() do
	PlayerDataManager.Initialize(player)
end

return PlayerDataManager
