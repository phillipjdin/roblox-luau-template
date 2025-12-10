local vide = require(game.ReplicatedStorage.packages.vide)
local types = require(game.ReplicatedStorage.shared.types)

type Pet = types.Pet
type Source<T> = vide.Source<T>

local create = vide.create
local source = vide.source

local RARITY_COLORS = {
	Common = Color3.fromRGB(150, 150, 150),
	Uncommon = Color3.fromRGB(85, 170, 85),
	Rare = Color3.fromRGB(85, 130, 220),
	Epic = Color3.fromRGB(170, 85, 220),
	Legendary = Color3.fromRGB(255, 170, 0),
}

return function(props: {
	pet: Pet,
	isOwned: boolean,
	canAfford: boolean,
	onPurchase: () -> (),
	isPurchasing: boolean,
})
	local isHovered = source(false)
	
	return create "Frame" {
		Size = UDim2.new(0, 180, 0, 240),
		BackgroundColor3 = Color3.fromRGB(45, 45, 50),
		BorderSizePixel = 0,
		
		create "UICorner" {
			CornerRadius = UDim.new(0, 12),
		},
		
		create "UIStroke" {
			Color = RARITY_COLORS[props.pet.rarity],
			Thickness = 2,
		},
		
		-- Rarity badge
		create "Frame" {
			Size = UDim2.new(0, 80, 0, 24),
			Position = UDim2.new(0, 8, 0, 8),
			BackgroundColor3 = RARITY_COLORS[props.pet.rarity],
			BorderSizePixel = 0,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 6),
			},
			
			create "TextLabel" {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = props.pet.rarity,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 12,
				Font = Enum.Font.GothamBold,
			},
		},
		
		-- Pet emoji
		create "TextLabel" {
			Size = UDim2.new(1, -20, 0, 60),
			Position = UDim2.new(0, 10, 0, 40),
			BackgroundTransparency = 1,
			Text = props.pet.emoji,
			TextSize = 48,
		},
		
		-- Pet name
		create "TextLabel" {
			Size = UDim2.new(1, -20, 0, 24),
			Position = UDim2.new(0, 10, 0, 110),
			BackgroundTransparency = 1,
			Text = props.pet.name,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 18,
			Font = Enum.Font.GothamBold,
		},
		
		-- Pet description
		create "TextLabel" {
			Size = UDim2.new(1, -20, 0, 48),
			Position = UDim2.new(0, 10, 0, 140),
			BackgroundTransparency = 1,
			Text = props.pet.description,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		},
		
		-- Purchase button
		create "TextButton" {
			Size = UDim2.new(1, -20, 0, 36),
			Position = UDim2.new(0, 10, 1, -46),
			BackgroundColor3 = function()
				if props.isOwned then
					return Color3.fromRGB(70, 130, 70)
				elseif not props.canAfford then
					return Color3.fromRGB(100, 50, 50)
				elseif isHovered() then
					return Color3.fromRGB(70, 170, 255)
				else
					return Color3.fromRGB(50, 130, 255)
				end
			end,
			BorderSizePixel = 0,
			Text = function()
				if props.isPurchasing then
					return "Purchasing..."
				elseif props.isOwned then
					return "✓ Owned"
				else
					return `🪙 {props.pet.price}`
				end
			end,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
			Active = not props.isOwned and props.canAfford and not props.isPurchasing,
			
			MouseEnter = function()
				isHovered(true)
			end,
			
			MouseLeave = function()
				isHovered(false)
			end,
			
			MouseButton1Click = function()
				if not props.isOwned and props.canAfford and not props.isPurchasing then
					props.onPurchase()
				end
			end,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 8),
			},
		},
	}
end
