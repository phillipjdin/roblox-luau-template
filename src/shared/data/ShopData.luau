local Pet = require(script.Parent.Parent.types.Pet)

-- Shop catalog with available pets
local ShopData: Pet.ShopData = {
	pets = {
		["pet_cat_001"] = {
			id = "pet_cat_001",
			name = "Fluffy Cat",
			description = "A cute and fluffy cat companion",
			price = 100,
			rarity = "Common",
		},
		["pet_dog_001"] = {
			id = "pet_dog_001",
			name = "Loyal Dog",
			description = "A faithful dog friend",
			price = 150,
			rarity = "Common",
		},
		["pet_bird_001"] = {
			id = "pet_bird_001",
			name = "Colorful Bird",
			description = "A vibrant bird that loves to sing",
			price = 250,
			rarity = "Uncommon",
		},
		["pet_dragon_001"] = {
			id = "pet_dragon_001",
			name = "Baby Dragon",
			description = "A rare baby dragon with magical powers",
			price = 1000,
			rarity = "Rare",
		},
		["pet_phoenix_001"] = {
			id = "pet_phoenix_001",
			name = "Phoenix",
			description = "A legendary phoenix that never dies",
			price = 5000,
			rarity = "Legendary",
		},
		["pet_robot_001"] = {
			id = "pet_robot_001",
			name = "Robo Pet",
			description = "A futuristic robotic companion",
			price = 500,
			rarity = "Epic",
		},
	},
}

return ShopData