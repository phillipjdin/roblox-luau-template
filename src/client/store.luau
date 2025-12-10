local Reflex = require(game.ReplicatedStorage.packages.reflex)
local types = require(game.ReplicatedStorage.shared.types)

type PlayerData = types.PlayerData
type LeaderboardEntry = types.LeaderboardEntry

export type ShopState = {
	playerData: PlayerData?,
	isShopOpen: boolean,
	isPurchasing: boolean,
	lastMessage: string?,
	leaderboard: { LeaderboardEntry },
	isLeaderboardOpen: boolean,
	isLeaderboardLoading: boolean,
}

local initialState: ShopState = {
	playerData = nil,
	isShopOpen = false,
	isPurchasing = false,
	lastMessage = nil,
	leaderboard = {},
	isLeaderboardOpen = false,
	isLeaderboardLoading = false,
}

local shopSlice = Reflex.createProducer(initialState, {
	setPlayerData = function(state, playerData: PlayerData)
		return {
			playerData = playerData,
		}
	end,
	
	updateCoins = function(state, coins: number)
		if not state.playerData then
			return {}
		end
		
		return {
			playerData = {
				coins = coins,
				ownedPets = state.playerData.ownedPets,
			},
		}
	end,
	
	addOwnedPet = function(state, petId: string)
		if not state.playerData then
			return {}
		end
		
		local newOwnedPets = table.clone(state.playerData.ownedPets)
		if not table.find(newOwnedPets, petId) then
			table.insert(newOwnedPets, petId)
		end
		
		return {
			playerData = {
				coins = state.playerData.coins,
				ownedPets = newOwnedPets,
			},
		}
	end,
	
	toggleShop = function(state, isOpen: boolean?)
		return {
			isShopOpen = if isOpen ~= nil then isOpen else not state.isShopOpen,
		}
	end,
	
	setPurchasing = function(state, isPurchasing: boolean)
		return {
			isPurchasing = isPurchasing,
		}
	end,
	
	setMessage = function(state, message: string?)
		return {
			lastMessage = message,
		}
	end,
	
	setLeaderboard = function(state, entries: { LeaderboardEntry }?)
		return {
			leaderboard = entries or {},
		}
	end,
	
	setLeaderboardLoading = function(state, isLoading: boolean)
		return {
			isLeaderboardLoading = isLoading,
		}
	end,
	
	toggleLeaderboard = function(state, isOpen: boolean?)
		return {
			isLeaderboardOpen = if isOpen ~= nil then isOpen else not state.isLeaderboardOpen,
		}
	end,
})

return shopSlice
