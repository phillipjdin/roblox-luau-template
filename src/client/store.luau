local Reflex = require(game.ReplicatedStorage.packages.reflex)
local types = require(game.ReplicatedStorage.shared.types)

type PlayerData = types.PlayerData

export type ShopState = {
	playerData: PlayerData?,
	isShopOpen: boolean,
	isPurchasing: boolean,
	lastMessage: string?,
}

export type LeaderboardEntry = {
	playerName: string,
	userId: number,
	coins: number,
	rank: number,
}

export type LeaderboardState = {
	entries: { LeaderboardEntry },
	isLeaderboardOpen: boolean,
	isLoading: boolean,
}

local shopInitialState: ShopState = {
	playerData = nil,
	isShopOpen = false,
	isPurchasing = false,
	lastMessage = nil,
}

local leaderboardInitialState: LeaderboardState = {
	entries = {},
	isLeaderboardOpen = false,
	isLoading = false,
}

local shopSlice = Reflex.createProducer(shopInitialState, {
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
})

local leaderboardSlice = Reflex.createProducer(leaderboardInitialState, {
	setEntries = function(state, entries: { LeaderboardEntry })
		return {
			entries = entries,
		}
	end,
	
	toggleLeaderboard = function(state, isOpen: boolean?)
		return {
			isLeaderboardOpen = if isOpen ~= nil then isOpen else not state.isLeaderboardOpen,
		}
	end,
	
	setLoading = function(state, isLoading: boolean)
		return {
			isLoading = isLoading,
		}
	end,
})

-- Combine both slices
local combinedStore = Reflex.combineProducers({
	shop = shopSlice,
	leaderboard = leaderboardSlice,
})

return combinedStore
