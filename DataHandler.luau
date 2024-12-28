local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local database = DataStoreService:GetDataStore("TestData2")
local sessionData = {}

local LevelSystem = require(ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("LevelSystem"))

local function playerJoined(player)
	local dataFolder = Instance.new("Folder")
	dataFolder.Name = "Data"

	--/ Stats Setup
	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = 1
	level.Parent = dataFolder

	local exp = Instance.new("NumberValue")
	exp.Name = "Exp"
	exp.Value = 0
	exp.Parent = dataFolder

	local expNext = Instance.new("NumberValue")
	expNext.Name = "ExpNext"
	expNext.Value = 120
	expNext.Parent = dataFolder

	local money = Instance.new("NumberValue")
	money.Name = "Money"
	money.Value = 10
	money.Parent = dataFolder

	local playerLoaded = Instance.new("BoolValue")
	playerLoaded.Name = "PlayerLoaded"
	playerLoaded.Value = false
	playerLoaded.Parent = player

	local statsFolder = Instance.new("Folder")
	statsFolder.Name = "Stats"
	statsFolder.Parent = dataFolder

	local luck = Instance.new("IntValue")
	luck.Name = "Luck"
	luck.Value = 1
	luck.Parent = statsFolder

	local strength = Instance.new("IntValue")
	strength.Name = "Strength"
	strength.Value = 0
	strength.Parent = statsFolder

	local defense = Instance.new("IntValue")
	defense.Name = "Defense"
	defense.Value = 0
	defense.Parent = statsFolder

	local mistery = Instance.new("IntValue")
	mistery.Name = "Mistery"
	mistery.Value = 0
	mistery.Parent = statsFolder

	local availablePoints = Instance.new("IntValue")
	availablePoints.Name = "AvailablePoints"
	availablePoints.Value = 0
	availablePoints.Parent = statsFolder

	local success = nil
	local playerData = nil
	local attempt = 1

	repeat
		success, playerData = pcall(function()
			return database:GetAsync(player.UserId)
		end)

		attempt += 1
		if not success then
			warn(playerData)
			task.wait(2.5)
		end
	until success or attempt == 5

	if success then
		print("Connected to database")
		-- Initialize default data structure if no data exists
		playerData = playerData or {
			Stats = {
				Level = 1,
				Exp = 0,
				Money = 10,
				Strength = 0,
				Defense = 0,
				Luck = 1,
				Mistery = 0,
				ExpNext = 120,
				AvailablePoints = 0
			}
		}
		sessionData[player.UserId] = playerData

		-- Ensure all stats exist in the loaded data
		sessionData[player.UserId].Stats = sessionData[player.UserId].Stats or {}
		local stats = sessionData[player.UserId].Stats

		stats.Level = stats.Level or 1
		stats.Exp = stats.Exp or 0
		stats.Money = stats.Money or 10
		stats.Strength = stats.Strength or 0
		stats.Defense = stats.Defense or 0
		stats.Luck = stats.Luck or 1
		stats.Mistery = stats.Mistery or 0
		stats.ExpNext = stats.ExpNext or (120 * stats.Level)
		stats.AvailablePoints = stats.AvailablePoints or 0
	else
		warn("Unable to get data for: "..player.Name)
		player:Kick("Unable to load your data, rejoin please.")
		return
	end

	-- Set values after ensuring they exist
	level.Value = sessionData[player.UserId].Stats.Level
	exp.Value = sessionData[player.UserId].Stats.Exp
	expNext.Value = sessionData[player.UserId].Stats.ExpNext
	money.Value = sessionData[player.UserId].Stats.Money
	strength.Value = sessionData[player.UserId].Stats.Strength
	defense.Value = sessionData[player.UserId].Stats.Defense
	luck.Value = sessionData[player.UserId].Stats.Luck
	mistery.Value = sessionData[player.UserId].Stats.Mistery
	availablePoints.Value = sessionData[player.UserId].Stats.AvailablePoints

	-- Connect value changed events
	level.Changed:Connect(function()
		sessionData[player.UserId].Stats.Level = level.Value
	end)
	exp.Changed:Connect(function()
		sessionData[player.UserId].Stats.Exp = exp.Value
	end)
	expNext.Changed:Connect(function()
		sessionData[player.UserId].Stats.ExpNext = expNext.Value
	end)
	money.Changed:Connect(function()
		sessionData[player.UserId].Stats.Money = money.Value
	end)
	strength.Changed:Connect(function()
		sessionData[player.UserId].Stats.Strength = strength.Value
	end)
	defense.Changed:Connect(function()
		sessionData[player.UserId].Stats.Defense = defense.Value
	end)
	luck.Changed:Connect(function()
		sessionData[player.UserId].Stats.Luck = luck.Value
	end)
	mistery.Changed:Connect(function()
		sessionData[player.UserId].Stats.Mistery = mistery.Value
	end)
	availablePoints.Changed:Connect(function()
		sessionData[player.UserId].Stats.AvailablePoints = availablePoints.Value
	end)

	dataFolder.Parent = player
	playerLoaded.Value = true
	
	LevelSystem.Initialize(player)
end

Players.PlayerAdded:Connect(playerJoined)

local function playerLeaving(player)
	if sessionData[player.UserId] then
		local success = nil
		local errorMsg = nil
		local attempt = 1

		repeat
			success, errorMsg = pcall(function()
				database:SetAsync(player.UserId, sessionData[player.UserId])
			end)

			attempt += 1
			if not success then
				warn(errorMsg)
				task.wait(2.5)
			end
		until success or attempt == 5

		if success then
			print("Data Saved for player: "..player.Name)
		else
			warn("Couldn't save data for player: "..player.Name)
		end
	end
end

Players.PlayerRemoving:Connect(playerLeaving)

local function serverShutdown()
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			playerLeaving(player)
		end)
	end
end

game:BindToClose(serverShutdown)
