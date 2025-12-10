-- Pet type definitions
export type PetId = string
export type PetRarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"

export type Pet = {
	id: PetId,
	name: string,
	description: string,
	price: number,
	rarity: PetRarity,
	icon: string?,
}

export type OwnedPet = {
	id: PetId,
	petId: PetId,
	obtainedAt: number, -- timestamp
}

export type ShopData = {
	pets: { [PetId]: Pet },
}

return {}