local Pet = require(script.Parent.Pet)

export type PlayerData = {
	coins: number,
	ownedPets: { Pet.OwnedPet },
}

return {}