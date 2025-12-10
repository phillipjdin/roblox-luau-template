local Players = game:GetService("Players")
local vide = require(game.ReplicatedStorage.packages.vide)

print("Hello world, from client!")

-- Import modules
local ShopController = require(script.ShopController)
local ShopUI = require(script.Components.ShopUI)
local ShopButton = require(script.Components.ShopButton)
local LeaderboardController = require(script.LeaderboardController)
local LeaderboardUI = require(script.Components.LeaderboardUI)
local LeaderboardButton = require(script.Components.LeaderboardButton)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Fetch initial player data
ShopController.FetchPlayerData()

-- Mount UI components
local root = vide.root(function()
	return {
		ShopButton(),
		ShopUI(),
		LeaderboardButton(),
		LeaderboardUI(),
	}
end)

-- Mount to PlayerGui
local cleanup = root(playerGui)

print("Shop client initialized!")
