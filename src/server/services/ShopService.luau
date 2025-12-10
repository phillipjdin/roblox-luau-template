local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remo = require(ReplicatedStorage.packages.littensy_remo@1.5.2.remo)
local ShopData = require(ReplicatedStorage.shared.data.ShopData)
local Pet = require(ReplicatedStorage.shared.types.Pet)
local PlayerDataService = require(script.Parent.PlayerDataService)

-- Create remote for purchasing pets
local purchasePetRemote = remo.createRemote("purchasePet")

purchasePetRemote:onRequest(function(player: Player, petId: Pet.PetId): (boolean, string?)
	local pet = ShopData.pets[petId]
	if not pet then
		return false, "Pet not found"
	end

	local playerData = PlayerDataService.getPlayerData(player)
	
	-- Check if player already owns this pet
	for _, ownedPet in playerData.ownedPets do
		if ownedPet.petId == petId then
			return false, "You already own this pet"
		end
	end

	-- Check if player has enough coins
	if playerData.coins < pet.price then
		return false, "Not enough coins"
	end

	-- Deduct coins and add pet
	playerData.coins -= pet.price
	table.insert(playerData.ownedPets, {
		id = `{player.UserId}_{petId}_{os.time()}`,
		petId = petId,
		obtainedAt = os.time(),
	})

	return true, nil
end)

-- Create remote to get shop catalog
local getShopCatalogRemote = remo.createRemote("getShopCatalog")

getShopCatalogRemote:onRequest(function(): Pet.ShopData
	return ShopData
end)

return {}