local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local leaderstats = player:WaitForChild("leaderstats")
local coinsStat = leaderstats:WaitForChild("Coins")

local remotesFolder = ReplicatedStorage:WaitForChild("PetShopRemotes")
local getCatalogFunction = remotesFolder:WaitForChild("GetPetCatalog")
local getInventoryFunction = remotesFolder:WaitForChild("GetPetInventory")
local purchaseFunction = remotesFolder:WaitForChild("PurchasePet")
local inventoryChangedEvent = remotesFolder:WaitForChild("InventoryChanged")

local catalog = getCatalogFunction:InvokeServer()
table.sort(catalog, function(left, right)
    return left.price < right.price
end)

local ownedPets = {}

local function rebuildOwnedSet(inventory)
    table.clear(ownedPets)

    if not inventory then
        return
    end

    for _, petId in inventory do
        ownedPets[petId] = true
    end
end

rebuildOwnedSet(getInventoryFunction:InvokeServer())

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetShopGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "Container"
container.BackgroundColor3 = Color3.fromRGB(18, 20, 25)
container.BackgroundTransparency = 0.1
container.Size = UDim2.fromScale(0.38, 0.65)
container.Position = UDim2.fromScale(0.05, 0.2)
container.BorderSizePixel = 0
container.Parent = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 12)
containerCorner.Parent = container

local containerPadding = Instance.new("UIPadding")
containerPadding.PaddingTop = UDim.new(0, 18)
containerPadding.PaddingBottom = UDim.new(0, 18)
containerPadding.PaddingLeft = UDim.new(0, 18)
containerPadding.PaddingRight = UDim.new(0, 18)
containerPadding.Parent = container

local headerSection = Instance.new("Frame")
headerSection.Name = "Header"
headerSection.BackgroundTransparency = 1
headerSection.Size = UDim2.new(1, 0, 0, 110)
headerSection.Parent = container

local textLayout = Instance.new("UIListLayout")
textLayout.FillDirection = Enum.FillDirection.Vertical
textLayout.VerticalAlignment = Enum.VerticalAlignment.Top
textLayout.SortOrder = Enum.SortOrder.LayoutOrder
textLayout.Padding = UDim.new(0, 6)
textLayout.Parent = headerSection

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Pet Shop"
titleLabel.TextSize = 36
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Size = UDim2.fromScale(1, 0)
titleLabel.AutomaticSize = Enum.AutomaticSize.Y
titleLabel.Parent = headerSection

local messageLabel = Instance.new("TextLabel")
messageLabel.BackgroundTransparency = 1
messageLabel.Font = Enum.Font.Gotham
messageLabel.Text = "Grab a companion using your coins."
messageLabel.TextSize = 18
messageLabel.TextColor3 = Color3.fromRGB(205, 214, 244)
messageLabel.TextXAlignment = Enum.TextXAlignment.Left
messageLabel.Size = UDim2.fromScale(1, 0)
messageLabel.AutomaticSize = Enum.AutomaticSize.Y
messageLabel.Parent = headerSection

local balanceLabel = Instance.new("TextLabel")
balanceLabel.BackgroundTransparency = 1
balanceLabel.Font = Enum.Font.Gotham
balanceLabel.TextSize = 20
balanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
balanceLabel.TextXAlignment = Enum.TextXAlignment.Left
balanceLabel.Size = UDim2.fromScale(1, 0)
balanceLabel.AutomaticSize = Enum.AutomaticSize.Y
balanceLabel.Parent = headerSection

local listFrame = Instance.new("ScrollingFrame")
listFrame.Name = "PetList"
listFrame.BackgroundTransparency = 1
listFrame.Size = UDim2.new(1, 0, 1, -110)
listFrame.Position = UDim2.new(0, 0, 0, 120)
listFrame.BorderSizePixel = 0
listFrame.CanvasSize = UDim2.new()
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.ScrollBarThickness = 6
listFrame.Parent = container

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = listFrame
listLayout.Padding = UDim.new(0, 10)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local petCards = {}

local function updateBalanceLabel()
    balanceLabel.Text = string.format("Coins: %d", coinsStat.Value)
end

local function setMessage(text)
    messageLabel.Text = text
end

local function formatPrice(price)
    return string.format("%d coins", price)
end

local function disableButton(button, text)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(60, 63, 81)
    button.AutoButtonColor = false
    button.Active = false
end

local function enableButton(button, text)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(54, 119, 48)
    button.AutoButtonColor = true
    button.Active = true
end

local function updateCard(petId)
    local card = petCards[petId]

    if not card then
        return
    end

    local coins = coinsStat.Value
    local price = card.pet.price
    local owned = ownedPets[petId] == true

    if owned then
        disableButton(card.button, "Owned")
        card.status.Text = "Already in your collection"
    elseif coins < price then
        disableButton(card.button, "Not enough coins")
        card.status.Text = formatPrice(price)
    else
        enableButton(card.button, string.format("Buy (%d)", price))
        card.status.Text = formatPrice(price)
    end
end

local function updateAllCards()
    for petId in petCards do
        updateCard(petId)
    end
end

local function createPetCard(pet)
    local card = Instance.new("Frame")
    card.Name = pet.id
    card.BackgroundColor3 = Color3.fromRGB(30, 33, 40)
    card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Size = UDim2.new(1, 0, 0, 0)
    card.Parent = listFrame

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local cardPadding = Instance.new("UIPadding")
    cardPadding.PaddingTop = UDim.new(0, 12)
    cardPadding.PaddingBottom = UDim.new(0, 12)
    cardPadding.PaddingLeft = UDim.new(0, 16)
    cardPadding.PaddingRight = UDim.new(0, 16)
    cardPadding.Parent = card

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = pet.name
    nameLabel.TextSize = 22
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.AutomaticSize = Enum.AutomaticSize.Y
    nameLabel.Size = UDim2.fromScale(1, 0)
    nameLabel.Parent = card

    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Font = Enum.Font.Gotham
    descriptionLabel.Text = pet.description
    descriptionLabel.TextSize = 16
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextColor3 = Color3.fromRGB(210, 214, 234)
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
    descriptionLabel.AutomaticSize = Enum.AutomaticSize.Y
    descriptionLabel.Size = UDim2.fromScale(1, 0)
    descriptionLabel.Parent = card

    local statusLabel = Instance.new("TextLabel")
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.Text = formatPrice(pet.price)
    statusLabel.TextSize = 18
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.AutomaticSize = Enum.AutomaticSize.Y
    statusLabel.Size = UDim2.fromScale(1, 0)
    statusLabel.Parent = card

    local button = Instance.new("TextButton")
    button.Name = "PurchaseButton"
    button.AnchorPoint = Vector2.new(1, 1)
    button.Position = UDim2.fromScale(1, 1)
    button.Size = UDim2.new(0, 150, 0, 38)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(54, 119, 48)
    button.Parent = card

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    petCards[pet.id] = {
        frame = card,
        button = button,
        status = statusLabel,
        pet = pet,
    }

    button.MouseButton1Click:Connect(function()
        if not button.Active then
            return
        end

        disableButton(button, "Purchasing...")
        setMessage(string.format("Buying %s...", pet.name))

        local callSucceeded, purchaseSucceeded, message = pcall(function()
            return purchaseFunction:InvokeServer(pet.id)
        end)

        if not callSucceeded then
            setMessage(string.format("Purchase failed: %s", tostring(purchaseSucceeded)))
        else
            if purchaseSucceeded then
                setMessage(message or string.format("You now own %s!", pet.name))
            else
                setMessage(message or "Unable to complete purchase.")
            end
        end

        updateCard(pet.id)
    end)
end

for _, pet in catalog do
    createPetCard(pet)
end

coinsStat:GetPropertyChangedSignal("Value"):Connect(function()
    updateBalanceLabel()
    updateAllCards()
end)

inventoryChangedEvent.OnClientEvent:Connect(function(newInventory)
    rebuildOwnedSet(newInventory)
    updateAllCards()
end)

updateBalanceLabel()
updateAllCards()
setMessage("Pick a pet to purchase.")
