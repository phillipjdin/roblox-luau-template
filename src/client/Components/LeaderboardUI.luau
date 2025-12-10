local vide = require(game.ReplicatedStorage.packages.vide)
local Players = game:GetService("Players")
local LeaderboardController = require(script.Parent.Parent.LeaderboardController)
local store = require(script.Parent.Parent.store)
local LeaderboardEntry = require(script.Parent.LeaderboardEntry)

local create = vide.create
local source = vide.source

return function()
	local state = store()
	local localPlayer = Players.LocalPlayer
	
	-- Only render if leaderboard is open
	if not state.isLeaderboardOpen then
		return nil
	end
	
	return create "ScreenGui" {
		Name = "LeaderboardUI",
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
					LeaderboardController.CloseLeaderboard()
				end,
			},
		},
		
		-- Main leaderboard frame
		create "Frame" {
			Size = UDim2.new(0, 700, 0, 650),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(30, 30, 35),
			BorderSizePixel = 0,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 16),
			},
			
			-- Header
			create "Frame" {
				Size = UDim2.new(1, 0, 0, 80),
				BackgroundColor3 = Color3.fromRGB(40, 40, 45),
				BorderSizePixel = 0,
				
				create "UICorner" {
					CornerRadius = UDim.new(0, 16),
				},
				
				-- Title
				create "TextLabel" {
					Size = UDim2.new(1, -100, 0, 35),
					Position = UDim2.new(0, 20, 0, 10),
					BackgroundTransparency = 1,
					Text = "🏆 Leaderboard",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 32,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
				
				-- Subtitle
				create "TextLabel" {
					Size = UDim2.new(1, -100, 0, 20),
					Position = UDim2.new(0, 20, 0, 50),
					BackgroundTransparency = 1,
					Text = "Top 50 Players by Coins",
					TextColor3 = Color3.fromRGB(180, 180, 180),
					TextSize = 14,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
				
				-- Close button
				create "TextButton" {
					Size = UDim2.new(0, 45, 0, 45),
					Position = UDim2.new(1, -60, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(220, 60, 60),
					BorderSizePixel = 0,
					Text = "✕",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 26,
					Font = Enum.Font.GothamBold,
					
					MouseButton1Click = function()
						LeaderboardController.CloseLeaderboard()
					end,
					
					create "UICorner" {
						CornerRadius = UDim.new(0, 8),
					},
				},
			},
			
			-- Loading indicator or entries list
			function()
				if state.isLoadingLeaderboard then
					return create "Frame" {
						Size = UDim2.new(1, -40, 1, -120),
						Position = UDim2.new(0, 20, 0, 100),
						BackgroundTransparency = 1,
						
						create "TextLabel" {
							Size = UDim2.new(1, 0, 0, 40),
							Position = UDim2.new(0, 0, 0.5, -20),
							BackgroundTransparency = 1,
							Text = "Loading leaderboard...",
							TextColor3 = Color3.fromRGB(180, 180, 180),
							TextSize = 18,
							Font = Enum.Font.Gotham,
						},
					}
				end
				
				if not state.leaderboardData or #state.leaderboardData.entries == 0 then
					return create "Frame" {
						Size = UDim2.new(1, -40, 1, -120),
						Position = UDim2.new(0, 20, 0, 100),
						BackgroundTransparency = 1,
						
						create "TextLabel" {
							Size = UDim2.new(1, 0, 0, 40),
							Position = UDim2.new(0, 0, 0.5, -20),
							BackgroundTransparency = 1,
							Text = "No players on the leaderboard yet!",
							TextColor3 = Color3.fromRGB(180, 180, 180),
							TextSize = 18,
							Font = Enum.Font.Gotham,
						},
					}
				end
				
				return create "ScrollingFrame" {
					Size = UDim2.new(1, -40, 1, -120),
					Position = UDim2.new(0, 20, 0, 100),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 8,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					
					create "UIListLayout" {
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					
					create "UIPadding" {
						PaddingTop = UDim.new(0, 10),
						PaddingBottom = UDim.new(0, 10),
					},
					
					-- Generate leaderboard entries
					function()
						if not state.leaderboardData then
							return {}
						end
						
						local entries = {}
						
						for i, entry in state.leaderboardData.entries do
							local isLocalPlayer = entry.userId == localPlayer.UserId
							
							entries[i] = LeaderboardEntry({
								entry = entry,
								isLocalPlayer = isLocalPlayer,
								layoutOrder = i,
							})
						end
						
						return entries
					end,
				}
			end,
			
			-- Your rank footer (if not in top 50)
			function()
				if not state.leaderboardData or state.leaderboardData.playerRank then
					return nil
				end
				
				-- Player is not in top 50, show their data at bottom
				local playerData = state.playerData
				if not playerData then
					return nil
				end
				
				return create "Frame" {
					Size = UDim2.new(1, 0, 0, 70),
					Position = UDim2.new(0, 0, 1, 0),
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = Color3.fromRGB(40, 40, 45),
					BorderSizePixel = 0,
					
					create "UICorner" {
						CornerRadius = UDim.new(0, 16),
					},
					
					create "TextLabel" {
						Size = UDim2.new(1, -20, 0, 20),
						Position = UDim2.new(0, 10, 0, 5),
						BackgroundTransparency = 1,
						Text = "Your Stats:",
						TextColor3 = Color3.fromRGB(180, 180, 180),
						TextSize = 12,
						Font = Enum.Font.Gotham,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					
					create "Frame" {
						Size = UDim2.new(1, -20, 0, 40),
						Position = UDim2.new(0, 10, 0, 25),
						BackgroundColor3 = Color3.fromRGB(50, 130, 255),
						BorderSizePixel = 0,
						
						create "UICorner" {
							CornerRadius = UDim.new(0, 8),
						},
						
						create "TextLabel" {
							Size = UDim2.new(1, -200, 1, 0),
							Position = UDim2.new(0, 10, 0, 0),
							BackgroundTransparency = 1,
							Text = `{localPlayer.Name} (You)`,
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 14,
							Font = Enum.Font.GothamBold,
							TextXAlignment = Enum.TextXAlignment.Left,
						},
						
						create "TextLabel" {
							Size = UDim2.new(0, 90, 1, 0),
							Position = UDim2.new(1, -100, 0, 0),
							BackgroundTransparency = 1,
							Text = `🪙 {playerData.coins}`,
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 14,
							Font = Enum.Font.GothamBold,
						},
						
						create "TextLabel" {
							Size = UDim2.new(0, 90, 1, 0),
							Position = UDim2.new(1, -200, 0, 0),
							BackgroundTransparency = 1,
							Text = `🐾 {#playerData.ownedPets}`,
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 14,
							Font = Enum.Font.GothamBold,
						},
					},
				}
			end,
		},
	}
end
