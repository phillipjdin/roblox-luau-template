local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local vide = require(ReplicatedStorage.packages.centau_vide@0.3.1.vide)
local ShopUI, ShopController = require(script.components.ShopUI)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Mount the shop UI
local shopGui = ShopUI()
shopGui:mount(playerGui)

-- Toggle shop with 'P' key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.P then
		ShopController.setVisible(not ShopController.getVisible())
	end
end)

-- Create a button to open the shop
local openShopButton = vide.create("TextButton", {
	Size = UDim2.new(0, 150, 0, 50),
	Position = UDim2.new(0, 10, 1, -60),
	AnchorPoint = Vector2.new(0, 1),
	BackgroundColor3 = Color3.fromRGB(50, 150, 255),
	Text = "Open Pet Shop",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 18,
	Font = Enum.Font.GothamBold,
	[ vide.OnEvent("Activated") ] = function()
		ShopController.setVisible(true)
	end,
}, {
	UICorner = vide.create("UICorner", {
		CornerRadius = UDim.new(0, 8),
	}),
})

openShopButton:mount(playerGui)

print("Client initialized!")
