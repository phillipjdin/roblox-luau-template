local vide = require(game.ReplicatedStorage.packages.vide)
local PetData = require(game.ReplicatedStorage.shared.PetData)
local ShopController = require(script.Parent.Parent.ShopController)
local store = require(script.Parent.Parent.store)
local PetCard = require(script.Parent.PetCard)

local create = vide.create
local source = vide.source

return function()
	local state = store()
	local shopState = state.shop
	
	-- Only render if shop is open
	if not shopState.isShopOpen then
		return nil
	end
	
	return create "ScreenGui" {
		Name = "ShopUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		
		-- Background overlay
		create "Frame" {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			
			-- Close when clicking background
			create "TextButton" {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				
				MouseButton1Click = function()
					ShopController.CloseShop()
				end,
			},
		},
		
		-- Main shop frame
		create "Frame" {
			Size = UDim2.new(0, 800, 0, 600),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(30, 30, 35),
			BorderSizePixel = 0,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 16),
			},
			
			-- Header
			create "Frame" {
				Size = UDim2.new(1, 0, 0, 70),
				BackgroundColor3 = Color3.fromRGB(40, 40, 45),
				BorderSizePixel = 0,
				
				create "UICorner" {
					CornerRadius = UDim.new(0, 16),
				},
				
				-- Title
				create "TextLabel" {
					Size = UDim2.new(0, 200, 1, 0),
					Position = UDim2.new(0, 20, 0, 0),
					BackgroundTransparency = 1,
					Text = "🏪 Pet Shop",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 28,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
				
				-- Coins display
				create "Frame" {
					Size = UDim2.new(0, 150, 0, 40),
					Position = UDim2.new(1, -170, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(50, 130, 255),
					BorderSizePixel = 0,
					
					create "UICorner" {
						CornerRadius = UDim.new(0, 8),
					},
					
					create "TextLabel" {
						Size = UDim2.new(1, -20, 1, 0),
						Position = UDim2.new(0, 10, 0, 0),
						BackgroundTransparency = 1,
						Text = function()
							return `🪙 {shopState.playerData and shopState.playerData.coins or 0}`
						end,
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 20,
						Font = Enum.Font.GothamBold,
					},
				},
				
				-- Close button
				create "TextButton" {
					Size = UDim2.new(0, 40, 0, 40),
					Position = UDim2.new(1, -50, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(220, 60, 60),
					BorderSizePixel = 0,
					Text = "✕",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 24,
					Font = Enum.Font.GothamBold,
					
					MouseButton1Click = function()
						ShopController.CloseShop()
					end,
					
					create "UICorner" {
						CornerRadius = UDim.new(0, 8),
					},
				},
			},
			
			-- Message display
			function()
				if not shopState.lastMessage then
					return nil
				end
				
				return create "Frame" {
					Size = UDim2.new(1, -40, 0, 50),
					Position = UDim2.new(0, 20, 0, 80),
					BackgroundColor3 = Color3.fromRGB(50, 130, 255),
					BorderSizePixel = 0,
					
					create "UICorner" {
						CornerRadius = UDim.new(0, 8),
					},
					
					create "TextLabel" {
						Size = UDim2.new(1, -20, 1, 0),
						Position = UDim2.new(0, 10, 0, 0),
						BackgroundTransparency = 1,
						Text = shopState.lastMessage,
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 16,
						Font = Enum.Font.Gotham,
						TextWrapped = true,
					},
				}
			end,
			
			-- Pets grid
			create "ScrollingFrame" {
				Size = function()
					if shopState.lastMessage then
						return UDim2.new(1, -40, 1, -160)
					else
						return UDim2.new(1, -40, 1, -100)
					end
				end,
				Position = function()
					if shopState.lastMessage then
						return UDim2.new(0, 20, 0, 140)
					else
						return UDim2.new(0, 20, 0, 90)
					end
				end,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 8,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				
				create "UIGridLayout" {
					CellSize = UDim2.new(0, 180, 0, 240),
					CellPadding = UDim2.new(0, 20, 0, 20),
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				
				create "UIPadding" {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
				},
				
				-- Generate pet cards
				function()
					local cards = {}
					
					for i, pet in PetData.Pets do
						local isOwned = shopState.playerData 
							and table.find(shopState.playerData.ownedPets, pet.id) ~= nil
						local canAfford = shopState.playerData 
							and shopState.playerData.coins >= pet.price
						
						cards[i] = PetCard({
							pet = pet,
							isOwned = isOwned,
							canAfford = canAfford or false,
							onPurchase = function()
								ShopController.PurchasePet(pet.id)
							end,
							isPurchasing = shopState.isPurchasing,
						})
					end
					
					return cards
				end,
			},
		},
	}
end
