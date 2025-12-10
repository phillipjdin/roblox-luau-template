local Remo = require(game.ReplicatedStorage.packages.remo)
local store = require(script.Parent.store)
local PetData = require(game.ReplicatedStorage.shared.PetData)

local ShopRemotes = Remo.namespace("Shop")

local ShopController = {}

-- Fetch player data from server
function ShopController.FetchPlayerData()
	task.spawn(function()
		local success, playerData = ShopRemotes.Client:call("GetPlayerData"):await()
		
		if success and playerData then
			store.shop.setPlayerData(playerData)
		else
			warn("Failed to fetch player data")
		end
	end)
end

-- Purchase a pet
function ShopController.PurchasePet(petId: string)
	store.shop.setPurchasing(true)
	store.shop.setMessage(nil)
	
	task.spawn(function()
		local success, result = ShopRemotes.Client:call("PurchasePet", petId):await()
		
		store.shop.setPurchasing(false)
		
		if success and result then
			store.shop.setMessage(result.message)
			
			if result.success then
				-- Update local state
				if result.newBalance then
					store.shop.updateCoins(result.newBalance)
				end
				store.shop.addOwnedPet(petId)
			end
		else
			store.shop.setMessage("Failed to purchase pet!")
			warn("Purchase failed:", result)
		end
		
		-- Clear message after 3 seconds
		task.delay(3, function()
			store.shop.setMessage(nil)
		end)
	end)
end

-- Toggle shop UI
function ShopController.ToggleShop()
	store.shop.toggleShop()
end

function ShopController.OpenShop()
	store.shop.toggleShop(true)
end

function ShopController.CloseShop()
	store.shop.toggleShop(false)
end

return ShopController
