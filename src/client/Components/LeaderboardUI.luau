local vide = require(game.ReplicatedStorage.packages.vide)
local store = require(script.Parent.Parent.store)
local LeaderboardController = require(script.Parent.Parent.LeaderboardController)

local create = vide.create

local function getRowColors(rank: number)
	if rank == 1 then
		return Color3.fromRGB(255, 239, 169), Color3.fromRGB(120, 95, 35)
	elseif rank == 2 then
		return Color3.fromRGB(230, 235, 246), Color3.fromRGB(80, 90, 120)
	elseif rank == 3 then
		return Color3.fromRGB(252, 224, 200), Color3.fromRGB(120, 80, 50)
	end
	
	return Color3.fromRGB(45, 45, 55), Color3.fromRGB(200, 200, 200)
end

return function()
	local state = store()
	
	if not state.isLeaderboardOpen then
		return nil
	end
	
	local leaderboard = state.leaderboard or {}
	
	return create "ScreenGui" {
		Name = "LeaderboardUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		
		create "Frame" {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			
			create "TextButton" {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				MouseButton1Click = function()
					LeaderboardController.Close()
				end,
			},
		},
		
		create "Frame" {
			Size = UDim2.new(0, 700, 0, 520),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(25, 25, 35),
			BorderSizePixel = 0,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 16),
			},
			
			create "Frame" {
				Size = UDim2.new(1, 0, 0, 80),
				BackgroundColor3 = Color3.fromRGB(30, 30, 45),
				BorderSizePixel = 0,
				
				create "UICorner" {
					CornerRadius = UDim.new(0, 16),
				},
				
				create "TextLabel" {
					Size = UDim2.new(1, -160, 1, 0),
					Position = UDim2.new(0, 30, 0, 0),
					BackgroundTransparency = 1,
					Text = "🏆 Top 50 Players",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 30,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
				
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
						LeaderboardController.Close()
					end,
					
					create "UICorner" {
						CornerRadius = UDim.new(0, 8),
					},
				},
			},
			
			create "TextLabel" {
				Size = UDim2.new(1, -60, 0, 30),
				Position = UDim2.new(0, 30, 0, 100),
				BackgroundTransparency = 1,
				Text = string.format("Tracking %d player%s", #leaderboard, #leaderboard == 1 and "" or "s"),
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextSize = 18,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
			},
			
			function()
				if state.isLeaderboardLoading then
					return create "TextLabel" {
						Size = UDim2.new(1, -60, 0, 50),
						Position = UDim2.new(0, 30, 0, 140),
						BackgroundTransparency = 1,
						Text = "Loading leaderboard...",
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 20,
						Font = Enum.Font.GothamSemibold,
						TextXAlignment = Enum.TextXAlignment.Left,
					}
				end
				
				return create "ScrollingFrame" {
					Size = UDim2.new(1, -60, 1, -190),
					Position = UDim2.new(0, 30, 0, 140),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 6,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					
					create "UIListLayout" {
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					
					function()
						if #leaderboard == 0 then
							return {
								create "TextLabel" {
									Size = UDim2.new(1, 0, 0, 40),
									BackgroundTransparency = 1,
									Text = "No players tracked yet. Join the game to claim the top spot!",
									TextColor3 = Color3.fromRGB(220, 220, 220),
									TextSize = 18,
									Font = Enum.Font.Gotham,
									TextWrapped = true,
								},
							}
						end
						
						local rows = table.create(#leaderboard)
						
						for index, entry in ipairs(leaderboard) do
							local backgroundColor, textColor = getRowColors(index)
							
							rows[index] = create "Frame" {
								LayoutOrder = index,
								Size = UDim2.new(1, 0, 0, 50),
								BackgroundColor3 = backgroundColor,
								BorderSizePixel = 0,
								
								create "UICorner" {
									CornerRadius = UDim.new(0, 12),
								},
								
								create "TextLabel" {
									Size = UDim2.new(0, 80, 1, 0),
									BackgroundTransparency = 1,
									Text = `#{index}`,
									TextColor3 = textColor,
									TextSize = 22,
									Font = Enum.Font.GothamBold,
								},
								
								create "TextLabel" {
									Size = UDim2.new(1, -200, 1, 0),
									Position = UDim2.new(0, 80, 0, 0),
									BackgroundTransparency = 1,
									Text = entry.playerName,
									TextColor3 = textColor,
									TextSize = 20,
									Font = Enum.Font.Gotham,
									TextXAlignment = Enum.TextXAlignment.Left,
								},
								
								create "TextLabel" {
									Size = UDim2.new(0, 120, 1, 0),
									Position = UDim2.new(1, -130, 0, 0),
									BackgroundTransparency = 1,
									Text = `🪙 {entry.coins}`,
									TextColor3 = textColor,
									TextSize = 20,
									Font = Enum.Font.GothamBold,
									TextXAlignment = Enum.TextXAlignment.Right,
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
