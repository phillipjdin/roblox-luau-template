local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("shared")
local PetCatalog = require(sharedFolder:WaitForChild("PetCatalog"))

export type PurchaseResult = {
    success: boolean,
    message: string,
    balance: number,
}

local REMOTES_FOLDER_NAME = "PetShop"
local PLAYER_PETS_FOLDER_NAME = "PlayerPets"
local STARTING_COINS = 500

type PlayerState = {
    coins: number,
    ownedPets: { [string]: boolean },
}

local playerStateByUserId: { [number]: PlayerState } = {}
local remotesFolder = ReplicatedStorage:FindFirstChild(REMOTES_FOLDER_NAME) :: Folder?

if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = REMOTES_FOLDER_NAME
    remotesFolder.Parent = ReplicatedStorage
end

local function ensureRemote(name: string, className: string): Instance
    local remote = remotesFolder:FindFirstChild(name)
    if remote then
        return remote
    end

    remote = Instance.new(className)
    remote.Name = name
    remote.Parent = remotesFolder

    return remote
end

local getCatalogRemote = ensureRemote("GetCatalog", "RemoteFunction") :: RemoteFunction
local purchaseRemote = ensureRemote("PurchasePet", "RemoteFunction") :: RemoteFunction

local playerPetsContainer = remotesFolder:FindFirstChild(PLAYER_PETS_FOLDER_NAME) :: Folder?
if not playerPetsContainer then
    playerPetsContainer = Instance.new("Folder")
    playerPetsContainer.Name = PLAYER_PETS_FOLDER_NAME
    playerPetsContainer.Parent = remotesFolder
end

local function getPlayerState(player: Player): PlayerState
    local userId = player.UserId
    local state = playerStateByUserId[userId]

    if state then
        return state
    end

    state = {
        coins = STARTING_COINS,
        ownedPets = {},
    }

    playerStateByUserId[userId] = state

    return state
end

local function updateCoinSignals(player: Player, coins: number)
    player:SetAttribute("Coins", coins)

    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end

    local coinsValue = leaderstats:FindFirstChild("Coins") :: IntValue?
    if not coinsValue then
        coinsValue = Instance.new("IntValue")
        coinsValue.Name = "Coins"
        coinsValue.Parent = leaderstats
    end

    coinsValue.Value = coins
end

local function getOwnedPetsFolder(player: Player): Folder
    local userFolder = playerPetsContainer:FindFirstChild(tostring(player.UserId)) :: Folder?
    if userFolder then
        return userFolder
    end

    userFolder = Instance.new("Folder")
    userFolder.Name = tostring(player.UserId)
    userFolder.Parent = playerPetsContainer

    return userFolder
end

local function syncOwnedPetsFolder(player: Player, state: PlayerState)
    local userFolder = getOwnedPetsFolder(player)

    -- Remove any values that no longer exist in server state.
    for _, valueObject in userFolder:GetChildren() do
        if not state.ownedPets[valueObject.Name] then
            valueObject:Destroy()
        end
    end

    for petId in state.ownedPets do
        if not userFolder:FindFirstChild(petId) then
            local flag = Instance.new("BoolValue")
            flag.Name = petId
            flag.Value = true
            flag.Parent = userFolder
        end
    end
end

local function handlePurchase(player: Player, petId: string): PurchaseResult
    local pet = PetCatalog.getById(petId)
    if not pet then
        return {
            success = false,
            message = "That pet does not exist.",
            balance = getPlayerState(player).coins,
        }
    end

    local state = getPlayerState(player)

    if state.ownedPets[pet.id] then
        return {
            success = false,
            message = "You already own this pet.",
            balance = state.coins,
        }
    end

    if state.coins < pet.price then
        return {
            success = false,
            message = "Not enough coins.",
            balance = state.coins,
        }
    end

    state.coins -= pet.price
    state.ownedPets[pet.id] = true

    updateCoinSignals(player, state.coins)
    syncOwnedPetsFolder(player, state)

    return {
        success = true,
        message = string.format("You purchased %s!", pet.displayName),
        balance = state.coins,
    }
end

local function onPlayerAdded(player: Player)
    local state = getPlayerState(player)
    updateCoinSignals(player, state.coins)
    syncOwnedPetsFolder(player, state)
end

local function onPlayerRemoving(player: Player)
    playerStateByUserId[player.UserId] = nil

    local userFolder = playerPetsContainer:FindFirstChild(tostring(player.UserId))
    if userFolder then
        userFolder:Destroy()
    end
end

local PetShopService = {}
local started = false

function PetShopService.start()
    if started then
        return
    end

    started = true

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in Players:GetPlayers() do
        task.spawn(onPlayerAdded, player)
    end

    getCatalogRemote.OnServerInvoke = function(_: Player)
        return PetCatalog.getAll()
    end

    purchaseRemote.OnServerInvoke = function(player: Player, petId: string)
        if typeof(petId) ~= "string" then
            return {
                success = false,
                message = "Invalid pet selection.",
                balance = getPlayerState(player).coins,
            }
        end

        return handlePurchase(player, petId)
    end
end

return PetShopService
