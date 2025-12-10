--!strict
-- PetShopUI.luau
-- Client-side Pet Shop user interface

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PetData = require(ReplicatedStorage.shared.PetData)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local PetShopUI = {}

-- UI References
local shopGui: ScreenGui
local mainFrame: Frame
local petsContainer: ScrollingFrame
local currencyLabel: TextLabel
local closeButton: TextButton
local toggleButton: TextButton

-- Remote references
local purchaseRemote: RemoteFunction
local getDataRemote: RemoteFunction

-- Current player data cache
local currentCurrency = 0
local ownedPetIds: { [string]: boolean } = {}

-- UI Constants
local COLORS = {
	Background = Color3.fromRGB(30, 30, 40),
	CardBackground = Color3.fromRGB(45, 45, 60),
	CardHover = Color3.fromRGB(55, 55, 75),
	Primary = Color3.fromRGB(88, 101, 242),
	PrimaryHover = Color3.fromRGB(71, 82, 196),
	Success = Color3.fromRGB(67, 181, 129),
	Error = Color3.fromRGB(237, 66, 69),
	Text = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(185, 185, 195),
	Currency = Color3.fromRGB(255, 215, 0),
}

-- Create the main shop GUI
local function createShopGUI(): ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = "PetShopGui"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Main container frame
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 700, 0, 500)
	mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
	mainFrame.BackgroundColor3 = COLORS.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.Parent = gui

	-- Corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = mainFrame

	-- Drop shadow effect (subtle)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 40, 1, 40)
	shadow.Position = UDim2.new(0, -20, 0, -20)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5554236805"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.6
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(23, 23, 277, 277)
	shadow.ZIndex = 0
	shadow.Parent = mainFrame

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	header.BorderSizePixel = 0
	header.Parent = mainFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 16)
	headerCorner.Parent = header

	-- Fix bottom corners of header
	local headerFix = Instance.new("Frame")
	headerFix.Name = "CornerFix"
	headerFix.Size = UDim2.new(1, 0, 0, 20)
	headerFix.Position = UDim2.new(0, 0, 1, -20)
	headerFix.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	headerFix.BorderSizePixel = 0
	headerFix.Parent = header

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(0, 200, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "🐾 Pet Shop"
	title.TextColor3 = COLORS.Text
	title.TextSize = 24
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Currency display
	currencyLabel = Instance.new("TextLabel")
	currencyLabel.Name = "Currency"
	currencyLabel.Size = UDim2.new(0, 150, 0, 36)
	currencyLabel.Position = UDim2.new(1, -220, 0.5, -18)
	currencyLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	currencyLabel.Font = Enum.Font.GothamBold
	currencyLabel.Text = "💰 0"
	currencyLabel.TextColor3 = COLORS.Currency
	currencyLabel.TextSize = 18
	currencyLabel.Parent = header

	local currencyCorner = Instance.new("UICorner")
	currencyCorner.CornerRadius = UDim.new(0, 8)
	currencyCorner.Parent = currencyLabel

	-- Close button
	closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0.5, -20)
	closeButton.BackgroundColor3 = COLORS.Error
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "✕"
	closeButton.TextColor3 = COLORS.Text
	closeButton.TextSize = 20
	closeButton.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	-- Pets scrolling container
	petsContainer = Instance.new("ScrollingFrame")
	petsContainer.Name = "PetsContainer"
	petsContainer.Size = UDim2.new(1, -40, 1, -100)
	petsContainer.Position = UDim2.new(0, 20, 0, 80)
	petsContainer.BackgroundTransparency = 1
	petsContainer.BorderSizePixel = 0
	petsContainer.ScrollBarThickness = 6
	petsContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	petsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	petsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	petsContainer.Parent = mainFrame

	-- Grid layout for pets
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 200, 0, 260)
	gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = petsContainer

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.Parent = petsContainer

	return gui
end

-- Create toggle button to open/close shop
local function createToggleButton(): TextButton
	local button = Instance.new("TextButton")
	button.Name = "PetShopToggle"
	button.Size = UDim2.new(0, 120, 0, 45)
	button.Position = UDim2.new(0, 20, 0.5, -22)
	button.BackgroundColor3 = COLORS.Primary
	button.Font = Enum.Font.GothamBold
	button.Text = "🐾 Shop"
	button.TextColor3 = COLORS.Text
	button.TextSize = 16
	button.Parent = shopGui

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = button

	-- Hover effect
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.PrimaryHover }):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.Primary }):Play()
	end)

	return button
end

-- Create a pet card
local function createPetCard(petInfo: PetData.PetInfo, layoutOrder: number): Frame
	local card = Instance.new("Frame")
	card.Name = petInfo.id
	card.BackgroundColor3 = COLORS.CardBackground
	card.BorderSizePixel = 0
	card.LayoutOrder = layoutOrder

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card

	-- Rarity indicator bar
	local rarityBar = Instance.new("Frame")
	rarityBar.Name = "RarityBar"
	rarityBar.Size = UDim2.new(1, 0, 0, 4)
	rarityBar.Position = UDim2.new(0, 0, 0, 0)
	rarityBar.BackgroundColor3 = PetData.RarityColors[petInfo.rarity]
	rarityBar.BorderSizePixel = 0
	rarityBar.Parent = card

	local rarityCorner = Instance.new("UICorner")
	rarityCorner.CornerRadius = UDim.new(0, 12)
	rarityCorner.Parent = rarityBar

	-- Pet image
	local imageContainer = Instance.new("Frame")
	imageContainer.Name = "ImageContainer"
	imageContainer.Size = UDim2.new(0, 80, 0, 80)
	imageContainer.Position = UDim2.new(0.5, -40, 0, 20)
	imageContainer.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	imageContainer.Parent = card

	local imageCorner = Instance.new("UICorner")
	imageCorner.CornerRadius = UDim.new(0.5, 0)
	imageCorner.Parent = imageContainer

	local petImage = Instance.new("ImageLabel")
	petImage.Name = "PetImage"
	petImage.Size = UDim2.new(0.8, 0, 0.8, 0)
	petImage.Position = UDim2.new(0.1, 0, 0.1, 0)
	petImage.BackgroundTransparency = 1
	petImage.Image = petInfo.imageId
	petImage.ScaleType = Enum.ScaleType.Fit
	petImage.Parent = imageContainer

	-- Pet name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -20, 0, 24)
	nameLabel.Position = UDim2.new(0, 10, 0, 108)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = petInfo.name
	nameLabel.TextColor3 = COLORS.Text
	nameLabel.TextSize = 16
	nameLabel.Parent = card

	-- Rarity label
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "RarityLabel"
	rarityLabel.Size = UDim2.new(1, -20, 0, 18)
	rarityLabel.Position = UDim2.new(0, 10, 0, 130)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Font = Enum.Font.GothamMedium
	rarityLabel.Text = petInfo.rarity
	rarityLabel.TextColor3 = PetData.RarityColors[petInfo.rarity]
	rarityLabel.TextSize = 13
	rarityLabel.Parent = card

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, -20, 0, 36)
	descLabel.Position = UDim2.new(0, 10, 0, 152)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = petInfo.description
	descLabel.TextColor3 = COLORS.TextSecondary
	descLabel.TextSize = 11
	descLabel.TextWrapped = true
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = card

	-- Buy button
	local buyButton = Instance.new("TextButton")
	buyButton.Name = "BuyButton"
	buyButton.Size = UDim2.new(1, -20, 0, 36)
	buyButton.Position = UDim2.new(0, 10, 1, -46)
	buyButton.BackgroundColor3 = COLORS.Primary
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Text = string.format("💰 %d", petInfo.price)
	buyButton.TextColor3 = COLORS.Text
	buyButton.TextSize = 14
	buyButton.Parent = card

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 8)
	buyCorner.Parent = buyButton

	-- Hover effects for card
	card.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.CardHover }):Play()
		end
	end)

	card.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			TweenService:Create(card, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.CardBackground }):Play()
		end
	end)

	-- Hover effects for buy button
	buyButton.MouseEnter:Connect(function()
		TweenService:Create(buyButton, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.PrimaryHover }):Play()
	end)

	buyButton.MouseLeave:Connect(function()
		TweenService:Create(buyButton, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.Primary }):Play()
	end)

	-- Purchase handler
	buyButton.MouseButton1Click:Connect(function()
		PetShopUI.PurchasePet(petInfo.id)
	end)

	return card
end

-- Update currency display
local function updateCurrencyDisplay()
	currencyLabel.Text = string.format("💰 %d", currentCurrency)
end

-- Show notification
local function showNotification(message: string, isError: boolean)
	local notification = Instance.new("TextLabel")
	notification.Name = "Notification"
	notification.Size = UDim2.new(0, 300, 0, 50)
	notification.Position = UDim2.new(0.5, -150, 0, -60)
	notification.BackgroundColor3 = if isError then COLORS.Error else COLORS.Success
	notification.Font = Enum.Font.GothamBold
	notification.Text = message
	notification.TextColor3 = COLORS.Text
	notification.TextSize = 14
	notification.TextWrapped = true
	notification.Parent = shopGui

	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 10)
	notifCorner.Parent = notification

	-- Animate in
	local tweenIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -150, 0, 20),
	})
	tweenIn:Play()

	-- Remove after delay
	task.delay(3, function()
		local tweenOut = TweenService:Create(notification, TweenInfo.new(0.3), {
			Position = UDim2.new(0.5, -150, 0, -60),
		})
		tweenOut:Play()
		tweenOut.Completed:Connect(function()
			notification:Destroy()
		end)
	end)
end

-- Toggle shop visibility
function PetShopUI.ToggleShop()
	mainFrame.Visible = not mainFrame.Visible

	if mainFrame.Visible then
		-- Refresh data when opening
		PetShopUI.RefreshData()

		-- Animate open
		mainFrame.Size = UDim2.new(0, 700, 0, 0)
		TweenService
			:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
				Size = UDim2.new(0, 700, 0, 500),
			})
			:Play()
	end
end

-- Close shop
function PetShopUI.CloseShop()
	local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2), {
		Size = UDim2.new(0, 700, 0, 0),
	})
	tween:Play()
	tween.Completed:Connect(function()
		mainFrame.Visible = false
	end)
end

-- Refresh player data
function PetShopUI.RefreshData()
	local playerData = getDataRemote:InvokeServer()
	if playerData then
		currentCurrency = playerData.currency
		updateCurrencyDisplay()

		-- Update owned pets lookup
		ownedPetIds = {}
		for _, pet in playerData.pets do
			ownedPetIds[pet.petId] = true
		end
	end
end

-- Purchase a pet
function PetShopUI.PurchasePet(petId: string)
	local success, message, newData = purchaseRemote:InvokeServer(petId)

	if success then
		showNotification(message, false)
		if newData then
			currentCurrency = newData.currency
			updateCurrencyDisplay()
		end
	else
		showNotification(message, true)
	end
end

-- Initialize the UI
function PetShopUI.Init()
	-- Wait for remotes
	purchaseRemote = ReplicatedStorage:WaitForChild(PetData.REMOTES.PURCHASE_PET) :: RemoteFunction
	getDataRemote = ReplicatedStorage:WaitForChild(PetData.REMOTES.GET_PLAYER_DATA) :: RemoteFunction

	-- Create GUI
	shopGui = createShopGUI()
	shopGui.Parent = PlayerGui

	-- Create toggle button
	toggleButton = createToggleButton()

	-- Populate pets
	local petsList = PetData.GetPetsList()
	for i, petInfo in petsList do
		local card = createPetCard(petInfo, i)
		card.Parent = petsContainer
	end

	-- Connect events
	closeButton.MouseButton1Click:Connect(PetShopUI.CloseShop)
	toggleButton.MouseButton1Click:Connect(PetShopUI.ToggleShop)

	-- Initial data fetch
	task.spawn(function()
		task.wait(1) -- Wait for server to initialize
		PetShopUI.RefreshData()
	end)

	print("[PetShopUI] Initialized!")
end

return PetShopUI
