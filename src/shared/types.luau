-- Shared type definitions

export type Pet = {
	id: string,
	name: string,
	description: string,
	price: number,
	emoji: string,
	rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary",
}

export type PlayerData = {
	coins: number,
	ownedPets: { string },
}

export type LeaderboardEntry = {
	playerName: string,
	userId: number,
	coins: number,
	rank: number,
}

return {}
