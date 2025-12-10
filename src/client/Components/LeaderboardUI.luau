local Players = game:GetService("Players")
local vide = require(game.ReplicatedStorage.packages.vide)
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
		DisplayOrder = 10,
		
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
			Size = UDim2.new(0, 500, 0, 700),
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
				BackgroundColor3 = Color3.fromRGB(255, 170, 0),
				BorderSizePixel = 0,
				
				create "UICorner" {
					CornerRadius = UDim.new(0, 16),
				},
				
				-- Fix corner overlap at bottom
				create "Frame" {
					Size = UDim2.new(1, 0, 0, 20),
					Position = UDim2.new(0, 0, 1, -20),
					BackgroundColor3 = Color3.fromRGB(255, 170, 0),
					BorderSizePixel = 0,
				},
				
				-- Title
				create "TextLabel" {
					Size = UDim2.new(1, -60, 1, 0),
					Position = UDim2.new(0, 20, 0, 0),
					BackgroundTransparency = 1,
					Text = "🏆 Top 50 Leaderboard",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 26,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
				
				-- Close button
				create "TextButton" {
					Size = UDim2.new(0, 40, 0, 40),
					Position = UDim2.new(1, -50, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(200, 100, 0),
					BorderSizePixel = 0,
					Text = "✕",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 24,
					Font = Enum.Font.GothamBold,
					
					MouseButton1Click = function()
						LeaderboardController.CloseLeaderboard()
					end,
					
					create "UICorner" {
						CornerRadius = UDim.new(0, 8),
					},
				},
			},
			
			-- Player's rank display (if not in top 50)
			function()
				if not state.playerRank or state.playerRank.rank <= 50 then
					return nil
				end
				
				return create "Frame" {
					Size = UDim2.new(1, -40, 0, 70),
					Position = UDim2.new(0, 20, 0, 80),
					BackgroundColor3 = Color3.fromRGB(40, 60, 40),
					BorderSizePixel = 0,
					
					create "UICorner" {
						CornerRadius = UDim.new(0, 8),
					},
					
					create "UIStroke" {
						Color = Color3.fromRGB(100, 200, 100),
						Thickness = 2,
					},
					
					create "TextLabel" {
						Size = UDim2.new(1, -20, 0, 20),
						Position = UDim2.new(0, 10, 0, 5),
						BackgroundTransparency = 1,
						Text = "Your Ranking",
						TextColor3 = Color3.fromRGB(150, 255, 150),
						TextSize = 14,
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					
					create "TextLabel" {
						Size = UDim2.new(1, -20, 0, 30),
						Position = UDim2.new(0, 10, 0, 28),
						BackgroundTransparency = 1,
						Text = `#{state.playerRank.rank} • 🪙 {state.playerRank.coins} • 🐾 {state.playerRank.petsOwned} pets`,
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 18,
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
				}
			end,
			
			-- Loading indicator
			function()
				if not state.isLoadingLeaderboard then
					return nil
				end
				
				return create "Frame" {
					Size = UDim2.new(1, -40, 1, -100),
					Position = UDim2.new(0, 20, 0, 80),
					BackgroundTransparency = 1,
					
					create "TextLabel" {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "⏳ Loading leaderboard...",
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 20,
						Font = Enum.Font.Gotham,
					},
				}
			end,
			
			-- Leaderboard list
			function()
				if state.isLoadingLeaderboard then
					return nil
				end
				
				local listYOffset = 80
				if state.playerRank and state.playerRank.rank > 50 then
					listYOffset = 160
				end
				
				return create "ScrollingFrame" {
					Size = UDim2.new(1, -40, 1, -listYOffset - 20),
					Position = UDim2.new(0, 20, 0, listYOffset),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 8,
					ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					
					create "UIListLayout" {
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					
					create "UIPadding" {
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 5),
					},
					
					-- Empty state
					function()
						if #state.leaderboardData > 0 then
							return nil
						end
						
						return create "TextLabel" {
							Size = UDim2.new(1, 0, 0, 100),
							BackgroundTransparency = 1,
							Text = "No players on the leaderboard yet!",
							TextColor3 = Color3.fromRGB(150, 150, 150),
							TextSize = 16,
							Font = Enum.Font.Gotham,
						}
					end,
					
					-- Generate leaderboard entries
					function()
						local entries = {}
						
						for i, entry in state.leaderboardData do
							local isCurrentPlayer = entry.userId == localPlayer.UserId
							
							entries[i] = LeaderboardEntry({
								entry = entry,
								isCurrentPlayer = isCurrentPlayer,
							})
						end
						
						return entries
					end,
				}
			end,
			
			-- Refresh button
			create "TextButton" {
				Size = UDim2.new(0, 100, 0, 36),
				Position = UDim2.new(1, -120, 1, -50),
				BackgroundColor3 = function()
					if state.isLoadingLeaderboard then
						return Color3.fromRGB(100, 100, 100)
					else
						return Color3.fromRGB(50, 130, 255)
					end
				end,
				BorderSizePixel = 0,
				Text = function()
					if state.isLoadingLeaderboard then
						return "⏳..."
					else
						return "🔄 Refresh"
					end
				end,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 14,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				
				MouseButton1Click = function()
					if not state.isLoadingLeaderboard then
						LeaderboardController.FetchLeaderboard()
					end
				end,
				
				create "UICorner" {
					CornerRadius = UDim.new(0, 8),
				},
			},
		},
	}
end
