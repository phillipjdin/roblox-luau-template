local vide = require(game.ReplicatedStorage.packages.vide)
local store = require(script.Parent.Parent.store)
local LeaderboardController = require(script.Parent.Parent.LeaderboardController)

local create = vide.create
local source = vide.source

local Players = game:GetService("Players")

-- Helper function to format numbers with commas
local function formatNumber(num: number): string
	local formatted = tostring(num)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end

-- Helper function to get rank emoji
local function getRankEmoji(rank: number): string
	if rank == 1 then
		return "🥇"
	elseif rank == 2 then
		return "🥈"
	elseif rank == 3 then
		return "🥉"
	else
		return `#{rank}`
	end
end

return function()
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
					LeaderboardController.CloseLeaderboard()
				end,
			},
		},
		
		-- Main leaderboard frame
		create "Frame" {
			Size = UDim2.new(0, 700, 0, 600),
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
			
			-- Loading indicator
			function()
				if not state.isLoadingLeaderboard then
					return nil
				end
				
				return create "Frame" {
					Size = UDim2.new(1, -40, 1, -90),
					Position = UDim2.new(0, 20, 0, 90),
					BackgroundTransparency = 1,
					
					create "TextLabel" {
						Size = UDim2.new(1, 0, 0, 50),
						Position = UDim2.new(0, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Text = "Loading leaderboard...",
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 20,
						Font = Enum.Font.Gotham,
					},
				}
			end,
			
			-- Leaderboard list
			function()
				if state.isLoadingLeaderboard or #state.leaderboardData == 0 then
					return nil
				end
				
				return create "ScrollingFrame" {
					Size = UDim2.new(1, -40, 1, -90),
					Position = UDim2.new(0, 20, 0, 90),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 8,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					
					create "UIListLayout" {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 8),
					},
					
					create "UIPadding" {
						PaddingTop = UDim.new(0, 10),
						PaddingBottom = UDim.new(0, 10),
					},
					
					-- Generate leaderboard entries
					function()
						local entries = {}
						local localPlayer = Players.LocalPlayer
						
						for i, entry in state.leaderboardData do
							local isLocalPlayer = entry.userId == localPlayer.UserId
							
							entries[i] = create "Frame" {
								Size = UDim2.new(1, 0, 0, 60),
								BackgroundColor3 = if isLocalPlayer 
									then Color3.fromRGB(50, 100, 200)
									else Color3.fromRGB(40, 40, 45),
								BorderSizePixel = 0,
								LayoutOrder = i,
								
								create "UICorner" {
									CornerRadius = UDim.new(0, 8),
								},
								
								-- Rank
								create "TextLabel" {
									Size = UDim2.new(0, 80, 1, 0),
									Position = UDim2.new(0, 15, 0, 0),
									BackgroundTransparency = 1,
									Text = getRankEmoji(entry.rank),
									TextColor3 = Color3.new(1, 1, 1),
									TextSize = if entry.rank <= 3 then 24 else 20,
									Font = Enum.Font.GothamBold,
									TextXAlignment = Enum.TextXAlignment.Left,
								},
								
								-- Player name
								create "TextLabel" {
									Size = UDim2.new(0, 300, 1, 0),
									Position = UDim2.new(0, 100, 0, 0),
									BackgroundTransparency = 1,
									Text = entry.playerName,
									TextColor3 = Color3.new(1, 1, 1),
									TextSize = 18,
									Font = Enum.Font.GothamBold,
									TextXAlignment = Enum.TextXAlignment.Left,
									TextTruncate = Enum.TextTruncate.AtEnd,
								},
								
								-- Coins
								create "Frame" {
									Size = UDim2.new(0, 150, 0, 35),
									Position = UDim2.new(1, -20, 0.5, 0),
									AnchorPoint = Vector2.new(1, 0.5),
									BackgroundColor3 = Color3.fromRGB(50, 130, 255),
									BorderSizePixel = 0,
									
									create "UICorner" {
										CornerRadius = UDim.new(0, 6),
									},
									
									create "TextLabel" {
										Size = UDim2.new(1, -10, 1, 0),
										Position = UDim2.new(0, 5, 0, 0),
										BackgroundTransparency = 1,
										Text = `🪙 {formatNumber(entry.coins)}`,
										TextColor3 = Color3.new(1, 1, 1),
										TextSize = 16,
										Font = Enum.Font.GothamBold,
									},
								},
							}
						end
						
						return entries
					end,
				}
			end,
			
			-- Empty state
			function()
				if state.isLoadingLeaderboard or #state.leaderboardData > 0 then
					return nil
				end
				
				return create "Frame" {
					Size = UDim2.new(1, -40, 1, -90),
					Position = UDim2.new(0, 20, 0, 90),
					BackgroundTransparency = 1,
					
					create "TextLabel" {
						Size = UDim2.new(1, 0, 0, 50),
						Position = UDim2.new(0, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Text = "No players found",
						TextColor3 = Color3.new(0.7, 0.7, 0.7),
						TextSize = 20,
						Font = Enum.Font.Gotham,
					},
				}
			end,
		},
	}
end
