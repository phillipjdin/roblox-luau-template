local Players = game:GetService("Players")
local vide = require(game.ReplicatedStorage.packages.vide)

print("Hello world, from client!")

-- Import modules
local ShopController = require(script.ShopController)
local ShopUI = require(script.Components.ShopUI)
local ShopButton = require(script.Components.ShopButton)
local LeaderboardUI = require(script.Components.Leaderboard)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Fetch initial player data
ShopController.FetchPlayerData()
ShopController.FetchLeaderboard()

Players.PlayerAdded:Connect(function()
	ShopController.FetchLeaderboard()
end)

Players.PlayerRemoving:Connect(function()
	-- Allow the server to clean up before we refresh the data
	task.delay(0.1, function()
		ShopController.FetchLeaderboard()
	end)
end)

-- Mount UI components
local root = vide.root(function()
	return {
		ShopButton(),
		ShopUI(),
		LeaderboardUI(),
	}
end)

-- Mount to PlayerGui
local cleanup = root(playerGui)

print("Shop client initialized!")
