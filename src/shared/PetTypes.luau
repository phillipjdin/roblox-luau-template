--!strict

export type PetId = string
export type PetRarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"

export type Pet = {
	id: PetId
	name: string
	description: string
	rarity: PetRarity
	price: number
	icon: string? -- Asset ID for pet icon
}

export type PetData = {
	[id: PetId]: Pet
}

return {}
