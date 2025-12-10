local PetData = require(game.ReplicatedStorage.shared.PetData)
local PlayerDataManager = require(script.Parent.PlayerDataManager)

local ShopService = {}

export type PurchaseResult = {
	success: boolean,
	message: string,
	newBalance: number?,
}

function ShopService.PurchasePet(player: Player, petId: string): PurchaseResult
	-- Get the pet data
	local pet = PetData.GetPet(petId)
	if not pet then
		return {
			success = false,
			message = "Pet not found!",
		}
	end
	
	-- Check if player already owns this pet
	if PlayerDataManager.HasPet(player, petId) then
		return {
			success = false,
			message = "You already own this pet!",
		}
	end
	
	-- Check if player has enough coins
	local playerData = PlayerDataManager.GetData(player)
	if not playerData then
		return {
			success = false,
			message = "Player data not found!",
		}
	end
	
	if playerData.coins < pet.price then
		return {
			success = false,
			message = `Not enough coins! You need {pet.price - playerData.coins} more coins.`,
		}
	end
	
	-- Process the purchase
	local coinsRemoved = PlayerDataManager.RemoveCoins(player, pet.price)
	if not coinsRemoved then
		return {
			success = false,
			message = "Failed to remove coins!",
		}
	end
	
	local petAdded = PlayerDataManager.AddPet(player, petId)
	if not petAdded then
		-- Refund coins if pet couldn't be added
		PlayerDataManager.AddCoins(player, pet.price)
		return {
			success = false,
			message = "Failed to add pet!",
		}
	end
	
	-- Success!
	print(`{player.Name} purchased {pet.name} for {pet.price} coins`)
	
	return {
		success = true,
		message = `Successfully purchased {pet.name}!`,
		newBalance = playerData.coins,
	}
end

function ShopService.GetPlayerData(player: Player)
	return PlayerDataManager.GetData(player)
end

function ShopService.GetLeaderboard()
	return PlayerDataManager.GetTopPlayers(50)
end

return ShopService
