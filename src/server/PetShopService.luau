--!strict
-- PetShopService.luau
-- Server-side service for handling pet purchases and player data

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local PetData = require(ReplicatedStorage.shared.PetData)

export type PlayerData = {
	currency: number,
	pets: { PetData.PlayerPet },
}

-- In-memory player data storage (in production, use DataStore)
local playerDataStore: { [Player]: PlayerData } = {}

local PetShopService = {}

-- Initialize remote events
local function setupRemotes()
	local purchaseRemote = Instance.new("RemoteFunction")
	purchaseRemote.Name = PetData.REMOTES.PURCHASE_PET
	purchaseRemote.Parent = ReplicatedStorage

	local getDataRemote = Instance.new("RemoteFunction")
	getDataRemote.Name = PetData.REMOTES.GET_PLAYER_DATA
	getDataRemote.Parent = ReplicatedStorage

	return purchaseRemote, getDataRemote
end

-- Generate a unique ID for pets
local function generateUniqueId(): string
	return HttpService:GenerateGUID(false)
end

-- Get or create player data
function PetShopService.GetPlayerData(player: Player): PlayerData
	if not playerDataStore[player] then
		playerDataStore[player] = {
			currency = PetData.DEFAULT_CURRENCY,
			pets = {},
		}
	end
	return playerDataStore[player]
end

-- Purchase a pet for a player
function PetShopService.PurchasePet(player: Player, petId: string): (boolean, string)
	local petInfo = PetData.Pets[petId]
	if not petInfo then
		return false, "Invalid pet ID"
	end

	local playerData = PetShopService.GetPlayerData(player)

	-- Check if player has enough currency
	if playerData.currency < petInfo.price then
		return false, "Not enough coins! You need " .. petInfo.price .. " coins."
	end

	-- Deduct currency and add pet
	playerData.currency = playerData.currency - petInfo.price

	local newPet: PetData.PlayerPet = {
		petId = petId,
		uniqueId = generateUniqueId(),
		nickname = nil,
		level = 1,
		experience = 0,
		acquiredAt = os.time(),
	}

	table.insert(playerData.pets, newPet)

	print(string.format("[PetShop] %s purchased %s for %d coins", player.Name, petInfo.name, petInfo.price))

	return true, "Successfully purchased " .. petInfo.name .. "!"
end

-- Add currency to a player (for rewards, etc.)
function PetShopService.AddCurrency(player: Player, amount: number)
	local playerData = PetShopService.GetPlayerData(player)
	playerData.currency = playerData.currency + amount
	print(string.format("[PetShop] Added %d coins to %s", amount, player.Name))
end

-- Get player's owned pets
function PetShopService.GetOwnedPets(player: Player): { PetData.PlayerPet }
	local playerData = PetShopService.GetPlayerData(player)
	return playerData.pets
end

-- Initialize the service
function PetShopService.Init()
	local purchaseRemote, getDataRemote = setupRemotes()

	-- Handle purchase requests
	purchaseRemote.OnServerInvoke = function(player: Player, petId: string): (boolean, string, PlayerData?)
		local success, message = PetShopService.PurchasePet(player, petId)
		local playerData = PetShopService.GetPlayerData(player)
		return success, message, playerData
	end

	-- Handle data requests
	getDataRemote.OnServerInvoke = function(player: Player): PlayerData
		return PetShopService.GetPlayerData(player)
	end

	-- Clean up player data when they leave
	Players.PlayerRemoving:Connect(function(player)
		-- In production, save to DataStore here
		playerDataStore[player] = nil
	end)

	-- Initialize data for players already in the game
	for _, player in Players:GetPlayers() do
		PetShopService.GetPlayerData(player)
	end

	-- Initialize data for new players
	Players.PlayerAdded:Connect(function(player)
		PetShopService.GetPlayerData(player)
	end)

	print("[PetShopService] Initialized!")
end

return PetShopService
