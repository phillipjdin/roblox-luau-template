local vide = require(game.ReplicatedStorage.packages.vide)
local LeaderboardController = require(script.Parent.Parent.LeaderboardController)

local create = vide.create
local source = vide.source

return function()
	local isHovered = source(false)
	
	return create "ScreenGui" {
		Name = "LeaderboardButtonUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		
		create "TextButton" {
			Size = UDim2.new(0, 150, 0, 50),
			Position = UDim2.new(0, 150, 1, -70),
			BackgroundColor3 = function()
				if isHovered() then
					return Color3.fromRGB(255, 220, 80)
				else
					return Color3.fromRGB(255, 200, 50)
				end
			end,
			BorderSizePixel = 0,
			Text = "🏆 Leaderboard",
			TextColor3 = Color3.new(0, 0, 0),
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
				LeaderboardController.OpenLeaderboard()
			end,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 12),
			},
			
			create "UIStroke" {
				Color = Color3.fromRGB(200, 150, 30),
				Thickness = 2,
			},
		},
	}
end
