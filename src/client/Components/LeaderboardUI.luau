local vide = require(game.ReplicatedStorage.packages.vide)
local store = require(script.Parent.Parent.store)

local create = vide.create

-- Get color based on rank
local function getRankColor(rank: number): Color3
	if rank == 1 then
		return Color3.fromRGB(255, 215, 0) -- Gold
	elseif rank == 2 then
		return Color3.fromRGB(192, 192, 192) -- Silver
	elseif rank == 3 then
		return Color3.fromRGB(205, 127, 50) -- Bronze
	else
		return Color3.new(1, 1, 1) -- White
	end
end

-- Get rank emoji
local function getRankEmoji(rank: number): string
	if rank == 1 then
		return "🥇"
	elseif rank == 2 then
		return "🥈"
	elseif rank == 3 then
		return "🥉"
	else
		return tostring(rank)
	end
end

return function(props: { onClose: () -> () })
	local state = store()
	
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
					props.onClose()
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
				Size = UDim2.new(1, 0, 0, 70),
				BackgroundColor3 = Color3.fromRGB(40, 40, 45),
				BorderSizePixel = 0,
				
				create "UICorner" {
					CornerRadius = UDim.new(0, 16),
				},
				
				-- Title
				create "TextLabel" {
					Size = UDim2.new(0, 300, 1, 0),
					Position = UDim2.new(0, 20, 0, 0),
					BackgroundTransparency = 1,
					Text = "🏆 Leaderboard",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 28,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
				
				-- Player rank display
				function()
					if state.playerRank then
						return create "Frame" {
							Size = UDim2.new(0, 150, 0, 40),
							Position = UDim2.new(1, -200, 0.5, 0),
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
								Text = `Your Rank: #{state.playerRank}`,
								TextColor3 = Color3.new(1, 1, 1),
								TextSize = 16,
								Font = Enum.Font.GothamBold,
							},
						}
					end
					return nil
				end,
				
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
						props.onClose()
					end,
					
					create "UICorner" {
						CornerRadius = UDim.new(0, 8),
					},
				},
			},
			
			-- Column headers
			create "Frame" {
				Size = UDim2.new(1, -40, 0, 40),
				Position = UDim2.new(0, 20, 0, 80),
				BackgroundColor3 = Color3.fromRGB(40, 40, 45),
				BorderSizePixel = 0,
				
				create "UICorner" {
					CornerRadius = UDim.new(0, 8),
				},
				
				-- Rank header
				create "TextLabel" {
					Size = UDim2.new(0, 60, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					Text = "Rank",
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 16,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
				
				-- Player header
				create "TextLabel" {
					Size = UDim2.new(0, 250, 1, 0),
					Position = UDim2.new(0, 80, 0, 0),
					BackgroundTransparency = 1,
					Text = "Player",
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 16,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
				
				-- Coins header
				create "TextLabel" {
					Size = UDim2.new(0, 100, 1, 0),
					Position = UDim2.new(0, 350, 0, 0),
					BackgroundTransparency = 1,
					Text = "🪙 Coins",
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 16,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
				
				-- Pets header
				create "TextLabel" {
					Size = UDim2.new(0, 100, 1, 0),
					Position = UDim2.new(0, 500, 0, 0),
					BackgroundTransparency = 1,
					Text = "🐾 Pets",
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 16,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
			},
			
			-- Leaderboard entries
			create "ScrollingFrame" {
				Size = UDim2.new(1, -40, 1, -150),
				Position = UDim2.new(0, 20, 0, 130),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 8,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				
				create "UIListLayout" {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 5),
				},
				
				-- Generate leaderboard entries
				function()
					if not state.leaderboardData then
						return create "TextLabel" {
							Size = UDim2.new(1, 0, 0, 100),
							BackgroundTransparency = 1,
							Text = "Loading leaderboard...",
							TextColor3 = Color3.fromRGB(200, 200, 200),
							TextSize = 18,
							Font = Enum.Font.Gotham,
						}
					end
					
					local entries = {}
					
					for rank, entry in ipairs(state.leaderboardData) do
						local isCurrentPlayer = game.Players.LocalPlayer.UserId == entry.userId
						
						entries[rank] = create "Frame" {
							Name = `Entry{rank}`,
							Size = UDim2.new(1, 0, 0, 50),
							BackgroundColor3 = function()
								if isCurrentPlayer then
									return Color3.fromRGB(50, 130, 255)
								else
									return Color3.fromRGB(40, 40, 45)
								end
							end,
							BorderSizePixel = 0,
							LayoutOrder = rank,
							
							create "UICorner" {
								CornerRadius = UDim.new(0, 8),
							},
							
							-- Rank
							create "TextLabel" {
								Size = UDim2.new(0, 60, 1, 0),
								Position = UDim2.new(0, 10, 0, 0),
								BackgroundTransparency = 1,
								Text = getRankEmoji(rank),
								TextColor3 = getRankColor(rank),
								TextSize = 20,
								Font = Enum.Font.GothamBold,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							
							-- Player name
							create "TextLabel" {
								Size = UDim2.new(0, 250, 1, 0),
								Position = UDim2.new(0, 80, 0, 0),
								BackgroundTransparency = 1,
								Text = entry.displayName,
								TextColor3 = Color3.new(1, 1, 1),
								TextSize = 16,
								Font = Enum.Font.Gotham,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextTruncate = Enum.TextTruncate.AtEnd,
							},
							
							-- Coins
							create "TextLabel" {
								Size = UDim2.new(0, 100, 1, 0),
								Position = UDim2.new(0, 350, 0, 0),
								BackgroundTransparency = 1,
								Text = tostring(entry.coins),
								TextColor3 = Color3.fromRGB(255, 215, 0),
								TextSize = 16,
								Font = Enum.Font.GothamBold,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
							
							-- Pet count
							create "TextLabel" {
								Size = UDim2.new(0, 100, 1, 0),
								Position = UDim2.new(0, 500, 0, 0),
								BackgroundTransparency = 1,
								Text = tostring(entry.petCount),
								TextColor3 = Color3.fromRGB(150, 255, 150),
								TextSize = 16,
								Font = Enum.Font.GothamBold,
								TextXAlignment = Enum.TextXAlignment.Left,
							},
						}
					end
					
					return entries
				end,
			},
		},
	}
end
