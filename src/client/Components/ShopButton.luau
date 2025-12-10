local vide = require(game.ReplicatedStorage.packages.vide)
local ShopController = require(script.Parent.Parent.ShopController)

local create = vide.create
local source = vide.source

return function()
	local isHovered = source(false)
	
	return create "ScreenGui" {
		Name = "ShopButtonUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		
		create "TextButton" {
			Size = UDim2.new(0, 120, 0, 50),
			Position = UDim2.new(0, 20, 1, -70),
			BackgroundColor3 = function()
				if isHovered() then
					return Color3.fromRGB(70, 170, 255)
				else
					return Color3.fromRGB(50, 130, 255)
				end
			end,
			BorderSizePixel = 0,
			Text = "🏪 Shop",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 20,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
			
			MouseEnter = function()
				isHovered(true)
			end,
			
			MouseLeave = function()
				isHovered(false)
			end,
			
			MouseButton1Click = function()
				ShopController.OpenShop()
			end,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 12),
			},
			
			create "UIStroke" {
				Color = Color3.fromRGB(40, 100, 200),
				Thickness = 2,
			},
		},
	}
end
