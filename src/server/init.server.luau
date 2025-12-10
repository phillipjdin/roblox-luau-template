local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local PetCatalog = require(sharedFolder:WaitForChild("PetCatalog"))

local remotesFolder = ReplicatedStorage:FindFirstChild("PetShopRemotes")
if remotesFolder then
    remotesFolder:ClearAllChildren()
else
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "PetShopRemotes"
    remotesFolder.Parent = ReplicatedStorage
end

local getCatalogFunction = Instance.new("RemoteFunction")
getCatalogFunction.Name = "GetPetCatalog"
getCatalogFunction.Parent = remotesFolder

local getInventoryFunction = Instance.new("RemoteFunction")
getInventoryFunction.Name = "GetPetInventory"
getInventoryFunction.Parent = remotesFolder

local purchaseFunction = Instance.new("RemoteFunction")
purchaseFunction.Name = "PurchasePet"
purchaseFunction.Parent = remotesFolder

local inventoryChangedEvent = Instance.new("RemoteEvent")
inventoryChangedEvent.Name = "InventoryChanged"
inventoryChangedEvent.Parent = remotesFolder

local playerInventories = {}

local function cloneInventory(inventory)
    local copy = {}

    for index, petId in inventory do
        copy[index] = petId
    end

    return copy
end

local function getInventory(player)
    local inventory = playerInventories[player]

    if not inventory then
        inventory = {}
        playerInventories[player] = inventory
    end

    return inventory
end

local function sendInventory(player)
    inventoryChangedEvent:FireClient(player, cloneInventory(getInventory(player)))
end

local function ownsPet(player, petId)
    for _, ownedPetId in getInventory(player) do
        if ownedPetId == petId then
            return true
        end
    end

    return false
end

local function setupLeaderstats(player)
    local leaderstats = player:FindFirstChild("leaderstats")

    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end

    local coins = leaderstats:FindFirstChild("Coins")

    if not coins then
        coins = Instance.new("IntValue")
        coins.Name = "Coins"
        coins.Parent = leaderstats
    end

    coins.Value = PetCatalog.StartingCoins
end

local function getCoins(player)
    local leaderstats = player:FindFirstChild("leaderstats")

    if not leaderstats then
        return nil
    end

    return leaderstats:FindFirstChild("Coins")
end

Players.PlayerAdded:Connect(function(player)
    setupLeaderstats(player)
    getInventory(player)
    sendInventory(player)
end)

Players.PlayerRemoving:Connect(function(player)
    playerInventories[player] = nil
end)

getCatalogFunction.OnServerInvoke = function()
    return PetCatalog.clonePets()
end

getInventoryFunction.OnServerInvoke = function(player)
    return cloneInventory(getInventory(player))
end

purchaseFunction.OnServerInvoke = function(player, petId)
    local catalogEntry = PetCatalog.getPetById(petId)

    if not catalogEntry then
        return false, "That pet is not for sale."
    end

    if ownsPet(player, petId) then
        return false, "You already own that pet."
    end

    local coins = getCoins(player)

    if not coins then
        return false, "Coins stat is missing."
    end

    if coins.Value < catalogEntry.price then
        return false, "You do not have enough coins."
    end

    coins.Value = coins.Value - catalogEntry.price

    table.insert(getInventory(player), petId)
    sendInventory(player)

    return true, string.format("Enjoy your new %s!", catalogEntry.name)
end
