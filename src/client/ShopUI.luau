--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PetTypes = require(ReplicatedStorage:WaitForChild("src"):WaitForChild("shared"):WaitForChild("PetTypes"))

-- Wait for shop remotes
local shopFolder = ReplicatedStorage:WaitForChild("ShopRemotes")
local purchasePetEvent = shopFolder:WaitForChild("PurchasePet")
local getShopDataEvent = shopFolder:WaitForChild("GetShopData")

-- Create shop GUI
local function createShopGUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PetShopGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 600, 0, 500)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	-- Corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	title.BorderSizePixel = 0
	title.Text = "Pet Shop"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = title

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = mainFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
	end)

	-- Coins display
	local coinsLabel = Instance.new("TextLabel")
	coinsLabel.Name = "CoinsLabel"
	coinsLabel.Size = UDim2.new(0, 200, 0, 30)
	coinsLabel.Position = UDim2.new(0, 20, 0, 60)
	coinsLabel.BackgroundTransparency = 1
	coinsLabel.Text = "Coins: 0"
	coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	coinsLabel.TextSize = 18
	coinsLabel.Font = Enum.Font.Gotham
	coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
	coinsLabel.Parent = mainFrame

	-- Scrolling frame for pets
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "PetList"
	scrollFrame.Size = UDim2.new(1, -40, 1, -120)
	scrollFrame.Position = UDim2.new(0, 20, 0, 100)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.Parent = mainFrame

	local scrollCorner = Instance.new("UICorner")
	scrollCorner.CornerRadius = UDim.new(0, 8)
	scrollCorner.Parent = scrollFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.Name
	listLayout.Parent = scrollFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = scrollFrame

	-- Status label
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -40, 0, 30)
	statusLabel.Position = UDim2.new(0, 20, 1, -40)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = ""
	statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	statusLabel.TextSize = 14
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = mainFrame

	return screenGui, scrollFrame, coinsLabel, statusLabel
end

-- Create pet card
local function createPetCard(pet: PetTypes.Pet, owned: boolean, playerCoins: number)
	local card = Instance.new("Frame")
	card.Name = pet.id
	card.Size = UDim2.new(1, -20, 0, 120)
	card.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	card.BorderSizePixel = 0

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card

	-- Pet name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0.5, -10, 0, 30)
	nameLabel.Position = UDim2.new(0, 10, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = pet.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 20
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card

	-- Rarity badge
	local rarityColors = {
		Common = Color3.fromRGB(200, 200, 200),
		Uncommon = Color3.fromRGB(100, 255, 100),
		Rare = Color3.fromRGB(100, 150, 255),
		Epic = Color3.fromRGB(200, 100, 255),
		Legendary = Color3.fromRGB(255, 215, 0),
	}

	local rarityBadge = Instance.new("TextLabel")
	rarityBadge.Name = "RarityBadge"
	rarityBadge.Size = UDim2.new(0, 100, 0, 25)
	rarityBadge.Position = UDim2.new(0.5, 10, 0, 10)
	rarityBadge.BackgroundColor3 = rarityColors[pet.rarity] or Color3.fromRGB(200, 200, 200)
	rarityBadge.BorderSizePixel = 0
	rarityBadge.Text = pet.rarity
	rarityBadge.TextColor3 = Color3.fromRGB(0, 0, 0)
	rarityBadge.TextSize = 14
	rarityBadge.Font = Enum.Font.GothamBold
	rarityBadge.Parent = card

	local rarityCorner = Instance.new("UICorner")
	rarityCorner.CornerRadius = UDim.new(0, 6)
	rarityCorner.Parent = rarityBadge

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, -20, 0, 30)
	descLabel.Position = UDim2.new(0, 10, 0, 45)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = pet.description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextSize = 14
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = card

	-- Price
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "PriceLabel"
	priceLabel.Size = UDim2.new(0, 150, 0, 25)
	priceLabel.Position = UDim2.new(1, -160, 0, 85)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = `{pet.price} Coins`
	priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	priceLabel.TextSize = 16
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Parent = card

	-- Purchase button
	local purchaseButton = Instance.new("TextButton")
	purchaseButton.Name = "PurchaseButton"
	purchaseButton.Size = UDim2.new(0, 120, 0, 35)
	purchaseButton.Position = UDim2.new(1, -130, 0, 10)
	
	if owned then
		purchaseButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		purchaseButton.Text = "Owned"
		purchaseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
		purchaseButton.Active = false
	elseif playerCoins >= pet.price then
		purchaseButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		purchaseButton.Text = "Buy"
		purchaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		purchaseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		purchaseButton.Text = "Can't Afford"
		purchaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		purchaseButton.Active = false
	end
	
	purchaseButton.BorderSizePixel = 0
	purchaseButton.TextSize = 16
	purchaseButton.Font = Enum.Font.GothamBold
	purchaseButton.Parent = card

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = purchaseButton

	if not owned and playerCoins >= pet.price then
		purchaseButton.MouseButton1Click:Connect(function()
			purchasePetEvent:FireServer(pet.id)
		end)
	end

	return card
end

-- Update shop display
local function updateShopDisplay(petData: PetTypes.PetData, playerCoins: number, ownedPets: { PetTypes.PetId }, scrollFrame: ScrollingFrame, coinsLabel: TextLabel)
	-- Clear existing cards
	for _, child in scrollFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Update coins display
	coinsLabel.Text = `Coins: {playerCoins}`

	-- Create pet cards
	local petIds = {}
	for petId, _ in petData do
		table.insert(petIds, petId)
	end
	table.sort(petIds)

	for _, petId in petIds do
		local pet = petData[petId]
		local owned = false
		for _, ownedPetId in ownedPets do
			if ownedPetId == petId then
				owned = true
				break
			end
		end
		local card = createPetCard(pet, owned, playerCoins)
		card.Parent = scrollFrame
	end

	-- Update canvas size
	task.wait()
	local contentSize = 0
	for _, child in scrollFrame:GetChildren() do
		if child:IsA("Frame") then
			contentSize += child.Size.Y.Offset + 10
		end
	end
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize)
end

-- Initialize shop
local screenGui, scrollFrame, coinsLabel, statusLabel = createShopGUI()
screenGui.Enabled = false

-- Handle purchase response
purchasePetEvent.OnClientEvent:Connect(function(success: boolean, message: string)
	if success then
		statusLabel.Text = message
		statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		-- Refresh shop data
		getShopDataEvent:FireServer()
	else
		statusLabel.Text = message
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end)

-- Handle shop data response
getShopDataEvent.OnClientEvent:Connect(function(petData: PetTypes.PetData, playerCoins: number, ownedPets: { PetTypes.PetId })
	updateShopDisplay(petData, playerCoins, ownedPets, scrollFrame, coinsLabel)
end)

-- Open shop with 'P' key or create a button
UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end
	
	if input.KeyCode == Enum.KeyCode.P then
		screenGui.Enabled = not screenGui.Enabled
		if screenGui.Enabled then
			getShopDataEvent:FireServer()
		end
	end
end)

-- Create open shop button (optional - for mobile/touch devices)
local openButton = Instance.new("TextButton")
openButton.Name = "OpenShopButton"
openButton.Size = UDim2.new(0, 150, 0, 50)
openButton.Position = UDim2.new(1, -170, 0, 20)
openButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
openButton.BorderSizePixel = 0
openButton.Text = "Pet Shop (P)"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextSize = 18
openButton.Font = Enum.Font.GothamBold
openButton.Parent = playerGui

local openButtonCorner = Instance.new("UICorner")
openButtonCorner.CornerRadius = UDim.new(0, 8)
openButtonCorner.Parent = openButton

openButton.MouseButton1Click:Connect(function()
	screenGui.Enabled = not screenGui.Enabled
	if screenGui.Enabled then
		getShopDataEvent:FireServer()
	end
end)

print("[ShopUI] Initialized - Press P to open shop")
