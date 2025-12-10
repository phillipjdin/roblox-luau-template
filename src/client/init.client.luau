local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local shopFolder = ReplicatedStorage:WaitForChild("PetShop")
local getCatalogRemote = shopFolder:WaitForChild("GetCatalog") :: RemoteFunction
local purchaseRemote = shopFolder:WaitForChild("PurchasePet") :: RemoteFunction
local playerPetsFolder = shopFolder:WaitForChild("PlayerPets") :: Folder

local purchaseButtons: { [string]: TextButton } = {}
local petDataById: { [string]: any } = {}

local function formatCoins(amount: number?): string
    return string.format("Coins: %d", amount or 0)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetShopGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local shopFrame = Instance.new("Frame")
shopFrame.Size = UDim2.new(0, 340, 0, 420)
shopFrame.Position = UDim2.new(0, 24, 0.5, -210)
shopFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
shopFrame.BorderSizePixel = 0
shopFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = shopFrame

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -20, 0, 40)
header.Position = UDim2.new(0, 10, 0, 10)
header.BackgroundTransparency = 1
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Font = Enum.Font.GothamBold
header.TextScaled = true
header.Text = "Pet Shop"
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = shopFrame

local balanceLabel = Instance.new("TextLabel")
balanceLabel.Size = UDim2.new(1, -20, 0, 24)
balanceLabel.Position = UDim2.new(0, 10, 0, 60)
balanceLabel.BackgroundTransparency = 1
balanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
balanceLabel.Font = Enum.Font.Gotham
balanceLabel.TextXAlignment = Enum.TextXAlignment.Left
balanceLabel.Text = formatCoins(localPlayer:GetAttribute("Coins"))
balanceLabel.Parent = shopFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 24)
statusLabel.Position = UDim2.new(0, 10, 1, -30)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Choose a pet to purchase."
statusLabel.Parent = shopFrame

local listHolder = Instance.new("ScrollingFrame")
listHolder.Size = UDim2.new(1, -20, 0, 290)
listHolder.Position = UDim2.new(0, 10, 0, 100)
listHolder.BackgroundTransparency = 1
listHolder.BorderSizePixel = 0
listHolder.ScrollBarThickness = 6
listHolder.CanvasSize = UDim2.new()
listHolder.Parent = shopFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = listHolder

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    listHolder.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

local function setOwnedState(petId: string, owned: boolean)
    local button = purchaseButtons[petId]
    local pet = petDataById[petId]

    if not button or not pet then
        return
    end

    if owned then
        button.Text = "Owned"
        button.AutoButtonColor = false
        button.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
    else
        button.Text = string.format("Buy (%d)", pet.price)
        button.AutoButtonColor = true
        button.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
    end

    button.Active = not owned
end

local function attemptPurchase(petId: string)
    local success, result = pcall(function()
        return purchaseRemote:InvokeServer(petId)
    end)

    if not success or typeof(result) ~= "table" then
        statusLabel.Text = "The shop is currently unavailable."
        return
    end

    statusLabel.Text = result.message

    if result.success then
        balanceLabel.Text = formatCoins(result.balance)
        setOwnedState(petId, true)
    end
end

local function createPetEntry(pet)
    petDataById[pet.id] = pet

    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, 0, 0, 80)
    entry.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    entry.BorderSizePixel = 0
    entry.Parent = listHolder

    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 8)
    entryCorner.Parent = entry

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 0, 26)
    title.Position = UDim2.new(0, 12, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = string.format("%s (%s)", pet.displayName, pet.rarity)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = entry

    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, -120, 0, 36)
    description.Position = UDim2.new(0, 12, 0, 40)
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.Gotham
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.Text = pet.description
    description.TextColor3 = Color3.fromRGB(200, 200, 200)
    description.TextSize = 14
    description.Parent = entry

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 96, 0, 36)
    button.Position = UDim2.new(1, -108, 0, 22)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.Parent = entry

    button.MouseButton1Click:Connect(function()
        attemptPurchase(pet.id)
    end)

    purchaseButtons[pet.id] = button
    setOwnedState(pet.id, false)
end

local function hydrateOwnedPets(folder: Folder)
    for _, child in folder:GetChildren() do
        setOwnedState(child.Name, true)
    end

    folder.ChildAdded:Connect(function(child)
        setOwnedState(child.Name, true)
    end)

    folder.ChildRemoved:Connect(function(child)
        setOwnedState(child.Name, false)
    end)
end

local function loadCatalog()
    local ok, catalog = pcall(function()
        return getCatalogRemote:InvokeServer()
    end)

    if not ok or typeof(catalog) ~= "table" then
        statusLabel.Text = "Unable to load the shop catalog."
        return
    end

    table.sort(catalog, function(left, right)
        return left.price < right.price
    end)

    for _, pet in catalog do
        createPetEntry(pet)
    end
end

local function watchCoins()
    localPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
        balanceLabel.Text = formatCoins(localPlayer:GetAttribute("Coins"))
    end)
end

local function watchOwnedPets()
    local userFolder = playerPetsFolder:FindFirstChild(tostring(localPlayer.UserId))
    if userFolder then
        hydrateOwnedPets(userFolder)
        return
    end

    local connection
    connection = playerPetsFolder.ChildAdded:Connect(function(child)
        if child.Name == tostring(localPlayer.UserId) then
            hydrateOwnedPets(child)
            connection:Disconnect()
        end
    end)
end

loadCatalog()
watchCoins()
watchOwnedPets()
