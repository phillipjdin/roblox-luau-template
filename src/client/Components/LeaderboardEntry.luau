local Players = game:GetService("Players")
local vide = require(game.ReplicatedStorage.packages.vide)
local store = require(script.Parent.Parent.store)

type LeaderboardEntry = store.LeaderboardEntry

local create = vide.create
local source = vide.source

-- Colors for top 3 ranks
local RANK_COLORS = {
	[1] = Color3.fromRGB(255, 215, 0),   -- Gold
	[2] = Color3.fromRGB(192, 192, 192), -- Silver
	[3] = Color3.fromRGB(205, 127, 50),  -- Bronze
}

-- Rank emojis
local RANK_EMOJIS = {
	[1] = "🥇",
	[2] = "🥈",
	[3] = "🥉",
}

return function(props: {
	entry: LeaderboardEntry,
	isCurrentPlayer: boolean,
})
	local isHovered = source(false)
	local localPlayer = Players.LocalPlayer
	
	local rankColor = RANK_COLORS[props.entry.rank] or Color3.fromRGB(150, 150, 150)
	local rankEmoji = RANK_EMOJIS[props.entry.rank] or ""
	
	return create "Frame" {
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundColor3 = function()
			if props.isCurrentPlayer then
				return Color3.fromRGB(50, 80, 50)
			elseif isHovered() then
				return Color3.fromRGB(55, 55, 60)
			else
				return Color3.fromRGB(45, 45, 50)
			end
		end,
		BorderSizePixel = 0,
		
		MouseEnter = function()
			isHovered(true)
		end,
		
		MouseLeave = function()
			isHovered(false)
		end,
		
		create "UICorner" {
			CornerRadius = UDim.new(0, 8),
		},
		
		-- Highlight border for current player
		props.isCurrentPlayer and create "UIStroke" {
			Color = Color3.fromRGB(100, 200, 100),
			Thickness = 2,
		} or nil,
		
		-- Rank display
		create "Frame" {
			Size = UDim2.new(0, 50, 0, 40),
			Position = UDim2.new(0, 10, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = rankColor,
			BorderSizePixel = 0,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 8),
			},
			
			create "TextLabel" {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = if props.entry.rank <= 3 then rankEmoji else `#{props.entry.rank}`,
				TextColor3 = if props.entry.rank <= 3 then Color3.new(0, 0, 0) else Color3.new(1, 1, 1),
				TextSize = if props.entry.rank <= 3 then 24 else 18,
				Font = Enum.Font.GothamBold,
			},
		},
		
		-- Player name
		create "TextLabel" {
			Size = UDim2.new(0, 200, 0, 24),
			Position = UDim2.new(0, 75, 0, 10),
			BackgroundTransparency = 1,
			Text = props.entry.playerName .. (props.isCurrentPlayer and " (You)" or ""),
			TextColor3 = if props.isCurrentPlayer then Color3.fromRGB(150, 255, 150) else Color3.new(1, 1, 1),
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		},
		
		-- Pets owned
		create "TextLabel" {
			Size = UDim2.new(0, 100, 0, 18),
			Position = UDim2.new(0, 75, 0, 34),
			BackgroundTransparency = 1,
			Text = `🐾 {props.entry.petsOwned} pets`,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		},
		
		-- Coins display
		create "Frame" {
			Size = UDim2.new(0, 120, 0, 36),
			Position = UDim2.new(1, -130, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(50, 130, 255),
			BorderSizePixel = 0,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 8),
			},
			
			create "TextLabel" {
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.new(0, 5, 0, 0),
				BackgroundTransparency = 1,
				Text = `🪙 {props.entry.coins}`,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 16,
				Font = Enum.Font.GothamBold,
			},
		},
	}
end
