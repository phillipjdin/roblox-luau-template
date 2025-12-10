local vide = require(game.ReplicatedStorage.packages.vide)
local Players = game:GetService("Players")
local LeaderboardController = require(script.Parent.Parent.LeaderboardController)
local store = require(script.Parent.Parent.store)

local create = vide.create
local source = vide.source

local function formatNumber(num: number): string
	if num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	else
		return tostring(num)
	end
end

local function getRankEmoji(rank: number): string
	if rank == 1 then
		return "🥇"
	elseif rank == 2 then
		return "🥈"
	elseif rank == 3 then
		return "🥉"
	else
		return ""
	end
end

return function()
	local state = store()
	local leaderboardState = state.leaderboard
	
	-- Only render if leaderboard is open
	if not leaderboardState.isLeaderboardOpen then
		return nil
	end
	
	local localPlayer = Players.LocalPlayer
	
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
			Size = UDim2.new(0, 700, 0, 700),
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
					Text = "🏆 Top 50 Leaderboard",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 28,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
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
						LeaderboardController.CloseLeaderboard()
					end,
					
					create "UICorner" {
						CornerRadius = UDim.new(0, 8),
					},
				},
			},
			
			-- Leaderboard content
			function()
				if leaderboardState.isLoading then
					return create "Frame" {
						Size = UDim2.new(1, -40, 1, -90),
						Position = UDim2.new(0, 20, 0, 80),
						BackgroundTransparency = 1,
						
						create "TextLabel" {
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "Loading leaderboard...",
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 24,
							Font = Enum.Font.Gotham,
						},
					}
				end
				
				local entries = leaderboardState.entries
				if #entries == 0 then
					return create "Frame" {
						Size = UDim2.new(1, -40, 1, -90),
						Position = UDim2.new(0, 20, 0, 80),
						BackgroundTransparency = 1,
						
						create "TextLabel" {
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "No players found.",
							TextColor3 = Color3.new(0.7, 0.7, 0.7),
							TextSize = 20,
							Font = Enum.Font.Gotham,
						},
					}
				end
				
				return create "ScrollingFrame" {
					Size = UDim2.new(1, -40, 1, -90),
					Position = UDim2.new(0, 20, 0, 80),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 8,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					
					create "UIListLayout" {
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					
					-- Generate leaderboard entries
					function()
						local rows = {}
						
						for i, entry in entries do
							local isLocalPlayer = entry.userId == localPlayer.UserId
							
							rows[i] = create "Frame" {
								Size = UDim2.new(1, 0, 0, 50),
								BackgroundColor3 = if isLocalPlayer 
									then Color3.fromRGB(50, 130, 255)
									else if i % 2 == 0
										then Color3.fromRGB(40, 40, 45)
										else Color3.fromRGB(35, 35, 40),
								BorderSizePixel = 0,
								LayoutOrder = i,
								
								create "UICorner" {
									CornerRadius = UDim.new(0, 8),
								},
								
								-- Rank
								create "TextLabel" {
									Size = UDim2.new(0, 60, 1, 0),
									Position = UDim2.new(0, 10, 0, 0),
									BackgroundTransparency = 1,
									Text = function()
										local emoji = getRankEmoji(entry.rank)
										return if emoji ~= "" then `{emoji} {entry.rank}` else `#{entry.rank}`
									end,
									TextColor3 = Color3.new(1, 1, 1),
									TextSize = 18,
									Font = Enum.Font.GothamBold,
									TextXAlignment = Enum.TextXAlignment.Left,
								},
								
								-- Player name
								create "TextLabel" {
									Size = UDim2.new(0, 300, 1, 0),
									Position = UDim2.new(0, 80, 0, 0),
									BackgroundTransparency = 1,
									Text = if isLocalPlayer then `{entry.playerName} (You)` else entry.playerName,
									TextColor3 = Color3.new(1, 1, 1),
									TextSize = 18,
									Font = Enum.Font.Gotham,
									TextXAlignment = Enum.TextXAlignment.Left,
									TextTruncate = Enum.TextTruncate.AtEnd,
								},
								
								-- Coins
								create "Frame" {
									Size = UDim2.new(0, 150, 0, 30),
									Position = UDim2.new(1, -20, 0.5, 0),
									AnchorPoint = Vector2.new(1, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 200, 0),
									BorderSizePixel = 0,
									
									create "UICorner" {
										CornerRadius = UDim.new(0, 6),
									},
									
									create "TextLabel" {
										Size = UDim2.new(1, -10, 1, 0),
										Position = UDim2.new(0, 5, 0, 0),
										BackgroundTransparency = 1,
										Text = `🪙 {formatNumber(entry.coins)}`,
										TextColor3 = Color3.new(0, 0, 0),
										TextSize = 16,
										Font = Enum.Font.GothamBold,
									},
								},
							}
						end
						
						return rows
					end,
				}
			end,
		},
	}
end
