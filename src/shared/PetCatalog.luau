local Catalog = {}

Catalog.StartingCoins = 250

Catalog.Pets = {
    {
        id = "corgi",
        name = "Corgi Pup",
        price = 150,
        description = "Loyal companion with boundless energy.",
    },
    {
        id = "tabby",
        name = "Tabby Cat",
        price = 200,
        description = "Independent cat that loves naps.",
    },
    {
        id = "hopper",
        name = "Hopper Bunny",
        price = 120,
        description = "Springy bunny that never sits still.",
    },
    {
        id = "shellby",
        name = "Shellby Turtle",
        price = 90,
        description = "Relaxed turtle with a sturdy shell.",
    },
    {
        id = "ember",
        name = "Ember Dragon",
        price = 400,
        description = "Tiny dragon that leaves warm embers behind.",
    },
}

local petsById = {}
for _, pet in Catalog.Pets do
    petsById[pet.id] = pet
end

function Catalog.getPetById(petId)
    return petsById[petId]
end

function Catalog.clonePets()
    local cloned = {}

    for index, pet in Catalog.Pets do
        cloned[index] = table.clone(pet)
    end

    return cloned
end

return Catalog
