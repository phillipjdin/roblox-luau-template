local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local vide = require(ReplicatedStorage.packages.centau_vide@0.3.1.vide)
local remo = require(ReplicatedStorage.packages.littensy_remo@1.5.2.remo)
local Promise = require(ReplicatedStorage.packages.evaera_promise@4.0.0.promise)
local Pet = require(ReplicatedStorage.shared.types.Pet)
local PlayerData = require(ReplicatedStorage.shared.types.PlayerData)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create remotes
local getPlayerDataRemote = remo.getRemote("getPlayerData")
local purchasePetRemote = remo.getRemote("purchasePet")
local getShopCatalogRemote = remo.getRemote("getShopCatalog")

-- Rarity colors
local RARITY_COLORS = {
	Common = Color3.fromRGB(200, 200, 200),
	Uncommon = Color3.fromRGB(100, 255, 100),
	Rare = Color3.fromRGB(100, 150, 255),
	Epic = Color3.fromRGB(200, 100, 255),
	Legendary = Color3.fromRGB(255, 200, 0),
}

local shopVisibleState, setShopVisibleState = vide.create(false)

local function ShopUI()
	local shopVisible = shopVisibleState
	local playerData, setPlayerData = vide.create(nil :: PlayerData.PlayerData?)
	local shopCatalog, setShopCatalog = vide.create(nil :: Pet.ShopData?)
	local selectedPet, setSelectedPet = vide.create(nil :: Pet.PetId?)
	local purchaseStatus, setPurchaseStatus = vide.create("" :: string)

	-- Load initial data
	Promise.all({
		getPlayerDataRemote:request(),
		getShopCatalogRemote:request(),
	}):andThen(function(results)
		setPlayerData(results[1])
		setShopCatalog(results[2])
	end):catch(function(err)
		warn("Failed to load shop data:", err)
	end)

	-- Refresh player data
	local function refreshPlayerData()
		getPlayerDataRemote:request():andThen(function(data)
			setPlayerData(data)
		end):catch(warn)
	end

	-- Purchase pet function
	local function purchasePet(petId: Pet.PetId)
		if not playerData() or not shopCatalog() then
			return
		end

		setPurchaseStatus("Purchasing...")
		purchasePetRemote:request(petId):andThen(function(success, errorMessage)
			if success then
				setPurchaseStatus("Purchase successful!")
				refreshPlayerData()
				task.wait(1)
				setPurchaseStatus("")
			else
				setPurchaseStatus(errorMessage or "Purchase failed")
				task.wait(2)
				setPurchaseStatus("")
			end
		end):catch(function(err)
			setPurchaseStatus("Error: " .. tostring(err))
			task.wait(2)
			setPurchaseStatus("")
		end)
	end

	local gui = vide.create("ScreenGui", {
		Name = "ShopUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		MainFrame = vide.create("Frame", {
			Visible = shopVisible,
			Size = UDim2.new(0, 600, 0, 500),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
		}, {
			UICorner = vide.create("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
			Title = vide.create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundTransparency = 1,
				Text = "Pet Shop",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 32,
				Font = Enum.Font.GothamBold,
			}),
			CoinsDisplay = vide.create("TextLabel", {
				Size = UDim2.new(0, 200, 0, 30),
				Position = UDim2.new(1, -220, 0, 10),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Text = function()
					local data = playerData()
					return if data then `Coins: {data.coins}` else "Loading..."
				end,
				TextColor3 = Color3.fromRGB(255, 215, 0),
				TextSize = 20,
				Font = Enum.Font.Gotham,
			}, {
				UICorner = vide.create("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				UIPadding = vide.create("UIPadding", {
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}),
			}),
			CloseButton = vide.create("TextButton", {
				Size = UDim2.new(0, 30, 0, 30),
				Position = UDim2.new(1, -40, 0, 10),
				BackgroundColor3 = Color3.fromRGB(200, 50, 50),
				Text = "X",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 20,
				Font = Enum.Font.GothamBold,
				[ vide.OnEvent("Activated") ] = function()
					setShopVisibleState(false)
				end,
			}, {
				UICorner = vide.create("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
			}),
			PetsList = vide.create("ScrollingFrame", {
				Size = UDim2.new(0, 280, 1, -100),
				Position = UDim2.new(0, 10, 0, 60),
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				BorderSizePixel = 0,
				ScrollBarThickness = 8,
			}, {
				UICorner = vide.create("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				UIListLayout = vide.create("UIListLayout", {
					Padding = UDim.new(0, 5),
				}),
				UIPadding = vide.create("UIPadding", {
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5),
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
				}),
				Children = vide.create(function()
					local catalog = shopCatalog()
					if not catalog then
						return {}
					end

					local children = {}
					for petId, pet in catalog.pets do
						local isOwned = false
						local data = playerData()
						if data then
							for _, ownedPet in data.ownedPets do
								if ownedPet.petId == petId then
									isOwned = true
									break
								end
							end
						end

						local rarityColor = RARITY_COLORS[pet.rarity] or Color3.fromRGB(255, 255, 255)
						local canAfford = if data then data.coins >= pet.price else false

						children[petId] = vide.create("TextButton", {
							Size = UDim2.new(1, -10, 0, 80),
							BackgroundColor3 = if selectedPet() == petId
								then Color3.fromRGB(60, 60, 60)
								else Color3.fromRGB(50, 50, 50),
							Text = "",
							[ vide.OnEvent("Activated") ] = function()
								if not isOwned then
									setSelectedPet(petId)
								end
							end,
						}, {
							UICorner = vide.create("UICorner", {
								CornerRadius = UDim.new(0, 6),
							}),
							PetName = vide.create("TextLabel", {
								Size = UDim2.new(1, -10, 0, 25),
								Position = UDim2.new(0, 5, 0, 5),
								BackgroundTransparency = 1,
								Text = pet.name,
								TextColor3 = rarityColor,
								TextSize = 18,
								Font = Enum.Font.GothamBold,
								TextXAlignment = Enum.TextXAlignment.Left,
							}),
							PetPrice = vide.create("TextLabel", {
								Size = UDim2.new(1, -10, 0, 20),
								Position = UDim2.new(0, 5, 0, 30),
								BackgroundTransparency = 1,
								Text = `{pet.price} coins`,
								TextColor3 = if canAfford then Color3.fromRGB(100, 255, 100) else Color3.fromRGB(255, 100, 100),
								TextSize = 16,
								Font = Enum.Font.Gotham,
								TextXAlignment = Enum.TextXAlignment.Left,
							}),
							PetRarity = vide.create("TextLabel", {
								Size = UDim2.new(1, -10, 0, 20),
								Position = UDim2.new(0, 5, 0, 50),
								BackgroundTransparency = 1,
								Text = pet.rarity,
								TextColor3 = rarityColor,
								TextSize = 14,
								Font = Enum.Font.Gotham,
								TextXAlignment = Enum.TextXAlignment.Left,
							}),
							OwnedBadge = if isOwned then vide.create("TextLabel", {
								Size = UDim2.new(0, 60, 0, 20),
								Position = UDim2.new(1, -65, 0, 5),
								BackgroundColor3 = Color3.fromRGB(50, 200, 50),
								Text = "OWNED",
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextSize = 12,
								Font = Enum.Font.GothamBold,
							}, {
								UICorner = vide.create("UICorner", {
									CornerRadius = UDim.new(0, 4),
								}),
							}) else nil,
						})
					end
					return children
				end),
			}),
			PetDetails = vide.create("Frame", {
				Size = UDim2.new(0, 290, 1, -100),
				Position = UDim2.new(1, -300, 0, 60),
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				BorderSizePixel = 0,
			}, {
				UICorner = vide.create("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				UIPadding = vide.create("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}),
				DetailsContent = vide.create(function()
					local petId = selectedPet()
					local catalog = shopCatalog()
					if not petId or not catalog then
						return {
							Placeholder = vide.create("TextLabel", {
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundTransparency = 1,
								Text = "Select a pet to view details",
								TextColor3 = Color3.fromRGB(150, 150, 150),
								TextSize = 18,
								Font = Enum.Font.Gotham,
							}),
						}
					end

					local pet = catalog.pets[petId]
					if not pet then
						return {}
					end

					local isOwned = false
					local data = playerData()
					if data then
						for _, ownedPet in data.ownedPets do
							if ownedPet.petId == petId then
								isOwned = true
								break
							end
						end
					end

					local rarityColor = RARITY_COLORS[pet.rarity] or Color3.fromRGB(255, 255, 255)
					local canAfford = if data then data.coins >= pet.price else false

					return {
						PetName = vide.create("TextLabel", {
							Size = UDim2.new(1, 0, 0, 40),
							BackgroundTransparency = 1,
							Text = pet.name,
							TextColor3 = rarityColor,
							TextSize = 28,
							Font = Enum.Font.GothamBold,
						}),
						PetRarity = vide.create("TextLabel", {
							Size = UDim2.new(1, 0, 0, 25),
							Position = UDim2.new(0, 0, 0, 40),
							BackgroundTransparency = 1,
							Text = pet.rarity,
							TextColor3 = rarityColor,
							TextSize = 20,
							Font = Enum.Font.Gotham,
						}),
						PetDescription = vide.create("TextLabel", {
							Size = UDim2.new(1, 0, 0, 100),
							Position = UDim2.new(0, 0, 0, 70),
							BackgroundTransparency = 1,
							Text = pet.description,
							TextColor3 = Color3.fromRGB(200, 200, 200),
							TextSize = 16,
							Font = Enum.Font.Gotham,
							TextWrapped = true,
						}),
						PetPrice = vide.create("TextLabel", {
							Size = UDim2.new(1, 0, 0, 30),
							Position = UDim2.new(0, 0, 1, -80),
							BackgroundTransparency = 1,
							Text = `Price: {pet.price} coins`,
							TextColor3 = if canAfford then Color3.fromRGB(100, 255, 100) else Color3.fromRGB(255, 100, 100),
							TextSize = 22,
							Font = Enum.Font.GothamBold,
						}),
						PurchaseButton = if not isOwned then vide.create("TextButton", {
							Size = UDim2.new(1, 0, 0, 40),
							Position = UDim2.new(0, 0, 1, -40),
							BackgroundColor3 = if canAfford then Color3.fromRGB(50, 200, 50) else Color3.fromRGB(100, 100, 100),
							Text = if canAfford then "Purchase" else "Not Enough Coins",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 20,
							Font = Enum.Font.GothamBold,
							AutoButtonColor = canAfford,
							[ vide.OnEvent("Activated") ] = function()
								if canAfford then
									purchasePet(petId)
								end
							end,
						}, {
							UICorner = vide.create("UICorner", {
								CornerRadius = UDim.new(0, 8),
							}),
						}) else vide.create("TextLabel", {
							Size = UDim2.new(1, 0, 0, 40),
							Position = UDim2.new(0, 0, 1, -40),
							BackgroundColor3 = Color3.fromRGB(50, 200, 50),
							Text = "OWNED",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 20,
							Font = Enum.Font.GothamBold,
						}, {
							UICorner = vide.create("UICorner", {
								CornerRadius = UDim.new(0, 8),
							}),
						}),
						StatusMessage = if purchaseStatus() ~= "" then vide.create("TextLabel", {
							Size = UDim2.new(1, 0, 0, 30),
							Position = UDim2.new(0, 0, 1, -90),
							BackgroundTransparency = 1,
							Text = purchaseStatus(),
							TextColor3 = Color3.fromRGB(255, 255, 100),
							TextSize = 16,
							Font = Enum.Font.Gotham,
						}) else nil,
					}
				end),
			}),
		}),
	})
	
	return gui
end

-- Export controller
local ShopController = {
	setVisible = setShopVisibleState,
	getVisible = function() return shopVisibleState() end,
}

return ShopUI, ShopController