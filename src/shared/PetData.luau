local types = require(script.Parent.types)

type Pet = types.Pet

local PetData: { Pet } = {
	{
		id = "dog",
		name = "Dog",
		description = "A loyal companion that follows you everywhere!",
		price = 100,
		emoji = "🐕",
		rarity = "Common",
	},
	{
		id = "cat",
		name = "Cat",
		description = "An independent feline friend.",
		price = 150,
		emoji = "🐈",
		rarity = "Common",
	},
	{
		id = "rabbit",
		name = "Rabbit",
		description = "A fluffy hopper with boundless energy.",
		price = 200,
		emoji = "🐇",
		rarity = "Uncommon",
	},
	{
		id = "fox",
		name = "Fox",
		description = "A clever and agile creature.",
		price = 350,
		emoji = "🦊",
		rarity = "Uncommon",
	},
	{
		id = "panda",
		name = "Panda",
		description = "A rare and adorable bamboo lover.",
		price = 500,
		emoji = "🐼",
		rarity = "Rare",
	},
	{
		id = "lion",
		name = "Lion",
		description = "The king of all pets!",
		price = 800,
		emoji = "🦁",
		rarity = "Epic",
	},
	{
		id = "dragon",
		name = "Dragon",
		description = "A mythical beast of immense power!",
		price = 1500,
		emoji = "🐉",
		rarity = "Legendary",
	},
	{
		id = "unicorn",
		name = "Unicorn",
		description = "A magical creature from legends.",
		price = 2000,
		emoji = "🦄",
		rarity = "Legendary",
	},
}

-- Create a lookup table for quick access
local PetLookup: { [string]: Pet } = {}
for _, pet in PetData do
	PetLookup[pet.id] = pet
end

return {
	Pets = PetData,
	GetPet = function(id: string): Pet?
		return PetLookup[id]
	end,
}
