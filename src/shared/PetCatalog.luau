export type PetInfo = {
    id: string,
    displayName: string,
    description: string,
    price: number,
    rarity: "Common" | "Uncommon" | "Rare" | "Legendary",
    icon: string?,
}

local catalog: { PetInfo } = table.freeze({
    {
        id = "sunny_pup",
        displayName = "Sunny Pup",
        description = "A cheerful dog that boosts morale anywhere it goes.",
        price = 150,
        rarity = "Common",
        icon = "rbxassetid://18474459",
    },
    {
        id = "ember_cat",
        displayName = "Ember Cat",
        description = "Leaves a warm trail of embers when it sprints.",
        price = 275,
        rarity = "Uncommon",
        icon = "rbxassetid://18474477",
    },
    {
        id = "tidal_turtle",
        displayName = "Tidal Turtle",
        description = "A relaxed turtle that surfs ripples it creates.",
        price = 425,
        rarity = "Rare",
        icon = "rbxassetid://18474497",
    },
    {
        id = "starlit_dragon",
        displayName = "Starlit Dragon",
        description = "A tiny dragon whose scales shimmer like constellations.",
        price = 850,
        rarity = "Legendary",
        icon = "rbxassetid://18474515",
    },
})

local catalogById: { [string]: PetInfo } = {}
for _, pet in catalog do
    catalogById[pet.id] = pet
end

local PetCatalog = {}

function PetCatalog.getAll(): { PetInfo }
    local snapshot = {}
    for index, pet in catalog do
        snapshot[index] = table.clone(pet)
    end

    return snapshot
end

function PetCatalog.getById(petId: string): PetInfo?
    return catalogById[petId]
end

return table.freeze(PetCatalog)
