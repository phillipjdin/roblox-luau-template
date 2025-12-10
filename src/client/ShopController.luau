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
			store.setPlayerData(playerData)
		else
			warn("Failed to fetch player data")
		end
	end)
end

-- Purchase a pet
function ShopController.PurchasePet(petId: string)
	store.setPurchasing(true)
	store.setMessage(nil)
	
	task.spawn(function()
		local success, result = ShopRemotes.Client:call("PurchasePet", petId):await()
		
		store.setPurchasing(false)
		
		if success and result then
			store.setMessage(result.message)
			
			if result.success then
				-- Update local state
				if result.newBalance then
					store.updateCoins(result.newBalance)
				end
				store.addOwnedPet(petId)
			end
		else
			store.setMessage("Failed to purchase pet!")
			warn("Purchase failed:", result)
		end
		
		-- Clear message after 3 seconds
		task.delay(3, function()
			store.setMessage(nil)
		end)
	end)
end

-- Toggle shop UI
function ShopController.ToggleShop()
	store.toggleShop()
end

function ShopController.OpenShop()
	store.toggleShop(true)
end

function ShopController.CloseShop()
	store.toggleShop(false)
end

return ShopController
