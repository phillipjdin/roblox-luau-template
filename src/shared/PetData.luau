--!strict
-- PetData.luau
-- Shared pet definitions and configuration for the Pet Shop

export type PetRarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"

export type PetInfo = {
	id: string,
	name: string,
	description: string,
	price: number,
	rarity: PetRarity,
	imageId: string, -- Roblox asset ID for the pet image
	stats: {
		happiness: number,
		energy: number,
		strength: number,
	},
}

export type PlayerPet = {
	petId: string,
	uniqueId: string,
	nickname: string?,
	level: number,
	experience: number,
	acquiredAt: number,
}

-- Rarity colors for UI
local RarityColors: { [PetRarity]: Color3 } = {
	Common = Color3.fromRGB(180, 180, 180),
	Uncommon = Color3.fromRGB(76, 175, 80),
	Rare = Color3.fromRGB(33, 150, 243),
	Epic = Color3.fromRGB(156, 39, 176),
	Legendary = Color3.fromRGB(255, 193, 7),
}

-- Available pets in the shop
local Pets: { [string]: PetInfo } = {
	dog = {
		id = "dog",
		name = "Puppy",
		description = "A loyal and friendly companion who loves to play fetch!",
		price = 100,
		rarity = "Common",
		imageId = "rbxassetid://6764432293", -- Dog icon
		stats = {
			happiness = 80,
			energy = 90,
			strength = 50,
		},
	},
	cat = {
		id = "cat",
		name = "Kitten",
		description = "An independent and curious feline friend.",
		price = 100,
		rarity = "Common",
		imageId = "rbxassetid://6764432408", -- Cat icon
		stats = {
			happiness = 70,
			energy = 60,
			strength = 40,
		},
	},
	bunny = {
		id = "bunny",
		name = "Bunny",
		description = "A soft and fluffy hopper who loves carrots!",
		price = 150,
		rarity = "Uncommon",
		imageId = "rbxassetid://6764432518", -- Bunny icon
		stats = {
			happiness = 85,
			energy = 75,
			strength = 30,
		},
	},
	parrot = {
		id = "parrot",
		name = "Parrot",
		description = "A colorful bird that can learn to speak!",
		price = 250,
		rarity = "Uncommon",
		imageId = "rbxassetid://6764432628", -- Bird icon
		stats = {
			happiness = 90,
			energy = 85,
			strength = 35,
		},
	},
	fox = {
		id = "fox",
		name = "Fox",
		description = "A clever and mischievous woodland creature.",
		price = 500,
		rarity = "Rare",
		imageId = "rbxassetid://6764432738", -- Fox icon
		stats = {
			happiness = 75,
			energy = 95,
			strength = 70,
		},
	},
	owl = {
		id = "owl",
		name = "Owl",
		description = "A wise nocturnal bird with piercing eyes.",
		price = 750,
		rarity = "Rare",
		imageId = "rbxassetid://6764432848", -- Owl icon
		stats = {
			happiness = 65,
			energy = 50,
			strength = 60,
		},
	},
	wolf = {
		id = "wolf",
		name = "Wolf Pup",
		description = "A powerful pack animal with unwavering loyalty.",
		price = 1500,
		rarity = "Epic",
		imageId = "rbxassetid://6764432958", -- Wolf icon
		stats = {
			happiness = 70,
			energy = 100,
			strength = 95,
		},
	},
	phoenix = {
		id = "phoenix",
		name = "Phoenix",
		description = "A mythical fire bird that rises from the ashes!",
		price = 5000,
		rarity = "Legendary",
		imageId = "rbxassetid://6764433068", -- Phoenix/fire icon
		stats = {
			happiness = 100,
			energy = 100,
			strength = 100,
		},
	},
	dragon = {
		id = "dragon",
		name = "Baby Dragon",
		description = "A legendary creature of immense power!",
		price = 10000,
		rarity = "Legendary",
		imageId = "rbxassetid://6764433178", -- Dragon icon
		stats = {
			happiness = 95,
			energy = 100,
			strength = 100,
		},
	},
}

-- Get ordered list of pets for display (sorted by price)
local function GetPetsList(): { PetInfo }
	local list: { PetInfo } = {}
	for _, pet in Pets do
		table.insert(list, pet)
	end
	table.sort(list, function(a, b)
		return a.price < b.price
	end)
	return list
end

local PetData = {
	Pets = Pets,
	RarityColors = RarityColors,
	GetPetsList = GetPetsList,

	-- Default starting currency for new players
	DEFAULT_CURRENCY = 500,

	-- Remote event names
	REMOTES = {
		PURCHASE_PET = "PetShop_PurchasePet",
		GET_PLAYER_DATA = "PetShop_GetPlayerData",
		OPEN_SHOP = "PetShop_OpenShop",
	},
}

return PetData
