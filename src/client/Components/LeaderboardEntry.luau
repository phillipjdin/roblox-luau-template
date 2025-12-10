local vide = require(game.ReplicatedStorage.packages.vide)
local LeaderboardTypes = require(game.ReplicatedStorage.shared.LeaderboardTypes)

type LeaderboardEntry = LeaderboardTypes.LeaderboardEntry

local create = vide.create

local RANK_COLORS = {
	[1] = Color3.fromRGB(255, 215, 0), -- Gold
	[2] = Color3.fromRGB(192, 192, 192), -- Silver
	[3] = Color3.fromRGB(205, 127, 50), -- Bronze
}

local RANK_EMOJIS = {
	[1] = "🥇",
	[2] = "🥈",
	[3] = "🥉",
}

return function(props: {
	entry: LeaderboardEntry,
	isLocalPlayer: boolean,
	layoutOrder: number,
})
	local entry = props.entry
	local isTopThree = entry.rank <= 3
	
	return create "Frame" {
		Size = UDim2.new(1, -20, 0, 50),
		BackgroundColor3 = if props.isLocalPlayer 
			then Color3.fromRGB(50, 130, 255)
			elseif isTopThree
			then Color3.fromRGB(60, 60, 70)
			else Color3.fromRGB(45, 45, 50),
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		
		create "UICorner" {
			CornerRadius = UDim.new(0, 8),
		},
		
		create "UIStroke" {
			Color = if isTopThree 
				then RANK_COLORS[entry.rank] or Color3.fromRGB(100, 100, 100)
				else Color3.fromRGB(60, 60, 65),
			Thickness = if isTopThree then 2 else 1,
		},
		
		-- Rank display
		create "Frame" {
			Size = UDim2.new(0, 60, 1, -10),
			Position = UDim2.new(0, 5, 0, 5),
			BackgroundColor3 = if isTopThree 
				then RANK_COLORS[entry.rank] or Color3.fromRGB(70, 70, 80)
				else Color3.fromRGB(55, 55, 60),
			BorderSizePixel = 0,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 6),
			},
			
			create "TextLabel" {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = if RANK_EMOJIS[entry.rank] 
					then RANK_EMOJIS[entry.rank]
					else `#{entry.rank}`,
				TextColor3 = if isTopThree 
					then Color3.fromRGB(20, 20, 20)
					else Color3.fromRGB(200, 200, 200),
				TextSize = if isTopThree then 24 else 18,
				Font = Enum.Font.GothamBold,
			},
		},
		
		-- Username
		create "TextLabel" {
			Size = UDim2.new(1, -280, 1, 0),
			Position = UDim2.new(0, 75, 0, 0),
			BackgroundTransparency = 1,
			Text = props.isLocalPlayer and `{entry.username} (You)` or entry.username,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 16,
			Font = if props.isLocalPlayer then Enum.Font.GothamBold else Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		},
		
		-- Pet count
		create "Frame" {
			Size = UDim2.new(0, 80, 0, 30),
			Position = UDim2.new(1, -190, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(100, 70, 150),
			BorderSizePixel = 0,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 6),
			},
			
			create "TextLabel" {
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.new(0, 5, 0, 0),
				BackgroundTransparency = 1,
				Text = `🐾 {entry.petCount}`,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 14,
				Font = Enum.Font.GothamBold,
			},
		},
		
		-- Coins display
		create "Frame" {
			Size = UDim2.new(0, 90, 0, 30),
			Position = UDim2.new(1, -95, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 180, 40),
			BorderSizePixel = 0,
			
			create "UICorner" {
				CornerRadius = UDim.new(0, 6),
			},
			
			create "TextLabel" {
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.new(0, 5, 0, 0),
				BackgroundTransparency = 1,
				Text = `🪙 {entry.coins}`,
				TextColor3 = Color3.fromRGB(20, 20, 20),
				TextSize = 14,
				Font = Enum.Font.GothamBold,
			},
		},
	}
end
