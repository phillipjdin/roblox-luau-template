--!strict

local PetTypes = require(script.Parent.PetTypes)

local PetData: PetTypes.PetData = {
	["pet_cat"] = {
		id = "pet_cat",
		name = "Cat",
		description = "A friendly feline companion",
		rarity = "Common",
		price = 100,
		icon = nil,
	},
	["pet_dog"] = {
		id = "pet_dog",
		name = "Dog",
		description = "A loyal canine friend",
		rarity = "Common",
		price = 100,
		icon = nil,
	},
	["pet_rabbit"] = {
		id = "pet_rabbit",
		name = "Rabbit",
		description = "A cute fluffy bunny",
		rarity = "Uncommon",
		price = 250,
		icon = nil,
	},
	["pet_penguin"] = {
		id = "pet_penguin",
		name = "Penguin",
		description = "A cool arctic friend",
		rarity = "Rare",
		price = 500,
		icon = nil,
	},
	["pet_dragon"] = {
		id = "pet_dragon",
		name = "Dragon",
		description = "A majestic fire-breathing companion",
		rarity = "Epic",
		price = 1000,
		icon = nil,
	},
	["pet_phoenix"] = {
		id = "pet_phoenix",
		name = "Phoenix",
		description = "A legendary bird of fire and rebirth",
		rarity = "Legendary",
		price = 2500,
		icon = nil,
	},
}

return PetData
