--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PetData = require(ReplicatedStorage:WaitForChild("src"):WaitForChild("shared"):WaitForChild("PetData"))
local PetTypes = require(ReplicatedStorage:WaitForChild("src"):WaitForChild("shared"):WaitForChild("PetTypes"))

-- Create RemoteEvents for shop interactions
local shopFolder = Instance.new("Folder")
shopFolder.Name = "ShopRemotes"
shopFolder.Parent = ReplicatedStorage

local purchasePetEvent = Instance.new("RemoteEvent")
purchasePetEvent.Name = "PurchasePet"
purchasePetEvent.Parent = shopFolder

local getShopDataEvent = Instance.new("RemoteEvent")
getShopDataEvent.Name = "GetShopData"
getShopDataEvent.Parent = shopFolder

-- Player data storage (in a real game, use DataStore)
local playerData: { [Player]: { coins: number, pets: { PetTypes.PetId } } } = {}

-- Initialize player data
local function initializePlayerData(player: Player)
	playerData[player] = {
		coins = 1000, -- Starting coins
		pets = {},
	}
end

-- Get player coins (placeholder - replace with your currency system)
local function getPlayerCoins(player: Player): number
	if not playerData[player] then
		initializePlayerData(player)
	end
	return playerData[player].coins
end

-- Add coins to player
local function addCoins(player: Player, amount: number)
	if not playerData[player] then
		initializePlayerData(player)
	end
	playerData[player].coins += amount
end

-- Remove coins from player
local function removeCoins(player: Player, amount: number): boolean
	if not playerData[player] then
		initializePlayerData(player)
	end
	
	if playerData[player].coins >= amount then
		playerData[player].coins -= amount
		return true
	end
	return false
end

-- Check if player owns a pet
local function playerOwnsPet(player: Player, petId: PetTypes.PetId): boolean
	if not playerData[player] then
		return false
	end
	local pets = playerData[player].pets
	for _, ownedPetId in pets do
		if ownedPetId == petId then
			return true
		end
	end
	return false
end

-- Add pet to player's collection
local function addPetToPlayer(player: Player, petId: PetTypes.PetId)
	if not playerData[player] then
		initializePlayerData(player)
	end
	table.insert(playerData[player].pets, petId)
end

-- Handle pet purchase
purchasePetEvent.OnServerEvent:Connect(function(player: Player, petId: PetTypes.PetId)
	local pet = PetData[petId]
	if not pet then
		warn(`Invalid pet ID: {petId}`)
		purchasePetEvent:FireClient(player, false, "Invalid pet ID")
		return
	end

	-- Check if player already owns the pet
	if playerOwnsPet(player, petId) then
		purchasePetEvent:FireClient(player, false, "You already own this pet!")
		return
	end

	-- Check if player has enough coins
	local playerCoins = getPlayerCoins(player)
	if playerCoins < pet.price then
		purchasePetEvent:FireClient(player, false, `Not enough coins! You need {pet.price} coins.`)
		return
	end

	-- Purchase the pet
	if removeCoins(player, pet.price) then
		addPetToPlayer(player, petId)
		purchasePetEvent:FireClient(player, true, `Successfully purchased {pet.name}!`)
		
		-- Notify player of remaining coins
		local remainingCoins = getPlayerCoins(player)
		print(`[Shop] {player.Name} purchased {pet.name} for {pet.price} coins. Remaining: {remainingCoins}`)
	else
		purchasePetEvent:FireClient(player, false, "Failed to process purchase")
	end
end)

-- Handle shop data request
getShopDataEvent.OnServerEvent:Connect(function(player: Player)
	local playerCoins = getPlayerCoins(player)
	local ownedPets = {}
	
	if playerData[player] then
		ownedPets = playerData[player].pets
	end
	
	getShopDataEvent:FireClient(player, PetData, playerCoins, ownedPets)
end)

-- Initialize player data when they join
Players.PlayerAdded:Connect(function(player)
	initializePlayerData(player)
	print(`[Shop] Initialized shop data for {player.Name}`)
end)

-- Clean up player data when they leave
Players.PlayerRemoving:Connect(function(player)
	playerData[player] = nil
end)

print("[ShopService] Initialized")
