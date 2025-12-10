local Players = game:GetService("Players")

local vide = require(game.ReplicatedStorage.packages.vide)
local store = require(script.Parent.Parent.store)

local create = vide.create

local localPlayer = Players.LocalPlayer
local localUserId = localPlayer and localPlayer.UserId or 0

return function()
	local state = store()
	local leaderboard = state.leaderboard or {}
	
	return create "ScreenGui" {
		Name = "LeaderboardUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		
		create "Frame" {
			Name = "LeaderboardContainer",
			Size = UDim2.new(0, 320, 0, 420),
			Position = UDim2.new(1, -340, 0, 40),
			BackgroundColor3 = Color3.fromRGB(20, 20, 26),
			BorderSizePixel = 0,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 14),
			},
			
			create "UIStroke" {
				Color = Color3.fromRGB(45, 45, 60),
				Thickness = 2,
			},
			
			-- Header
			create "TextLabel" {
				Size = UDim2.new(1, -40, 0, 40),
				Position = UDim2.new(0, 20, 0, 16),
				BackgroundTransparency = 1,
				Text = "🏆 Top 50 Players",
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 24,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
			},
			
			create "TextLabel" {
				Size = UDim2.new(1, -40, 0, 24),
				Position = UDim2.new(0, 20, 0, 56),
				BackgroundTransparency = 1,
				Text = if #leaderboard > 0 then "Track the richest collectors" else "Waiting for leaderboard data...",
				TextColor3 = Color3.fromRGB(200, 200, 210),
				TextSize = 14,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
			},
			
			-- Leaderboard rows
			create "ScrollingFrame" {
				Name = "LeaderboardList",
				Size = UDim2.new(1, -24, 1, -110),
				Position = UDim2.new(0, 12, 0, 96),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 6,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(),
				
				create "UIListLayout" {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 6),
				},
				
				create "UIPadding" {
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 8),
				},
				
				function()
					if #leaderboard == 0 then
						return {
							create "TextLabel" {
								Size = UDim2.new(1, -8, 0, 32),
								BackgroundTransparency = 1,
								Text = "No players to show yet.",
								TextColor3 = Color3.fromRGB(180, 180, 190),
								TextSize = 16,
								Font = Enum.Font.Gotham,
								TextXAlignment = Enum.TextXAlignment.Center,
							},
						}
					end
					
					local rows = {}
					
					for index, entry in leaderboard do
						local isLocalPlayer = entry.userId == localUserId
						
						rows[index] = create "Frame" {
							Size = UDim2.new(1, -8, 0, 34),
							BackgroundColor3 = if isLocalPlayer then Color3.fromRGB(60, 100, 200) else Color3.fromRGB(32, 32, 40),
							BackgroundTransparency = if isLocalPlayer then 0 else 0.15,
							BorderSizePixel = 0,
							
							create "UICorner" {
								CornerRadius = UDim.new(0, 8),
							},
							
							create "TextLabel" {
								Size = UDim2.new(0, 50, 1, 0),
								BackgroundTransparency = 1,
								Text = `#{entry.rank}`,
								TextColor3 = if isLocalPlayer then Color3.new(1, 1, 1) else Color3.fromRGB(220, 220, 230),
								TextSize = 16,
								Font = Enum.Font.GothamBold,
							},
							
							create "TextLabel" {
								Size = UDim2.new(1, -140, 1, 0),
								Position = UDim2.new(0, 50, 0, 0),
								BackgroundTransparency = 1,
								Text = entry.name,
								TextColor3 = if isLocalPlayer then Color3.new(1, 1, 1) else Color3.fromRGB(220, 220, 230),
								TextSize = 16,
								Font = Enum.Font.GothamSemibold,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							
							create "TextLabel" {
								Size = UDim2.new(0, 90, 1, 0),
								Position = UDim2.new(1, -90, 0, 0),
								BackgroundTransparency = 1,
								Text = `🪙 {entry.coins}`,
								TextColor3 = if isLocalPlayer then Color3.new(1, 1, 1) else Color3.fromRGB(230, 210, 110),
								TextSize = 16,
								Font = Enum.Font.GothamBold,
								TextXAlignment = Enum.TextXAlignment.Right,
							},
						}
					end
					
					return rows
				end,
			},
		},
	}
end
