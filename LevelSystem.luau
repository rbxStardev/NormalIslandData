local LevelSystem = {}

LevelSystem.BaseExp = 120
LevelSystem.ExpMultiplier = 1.25

function LevelSystem.CalculateExpToNextLevel(level)
	return math.floor(LevelSystem.BaseExp * (LevelSystem.ExpMultiplier ^ (level - 1)))
end

function LevelSystem.Initialize(player)
	local stats = player:WaitForChild("Data")
	local level = stats:WaitForChild("Level")
	local exp = stats:WaitForChild("Exp")
	local expNext = stats:WaitForChild("ExpNext")

	expNext.Value = LevelSystem.CalculateExpToNextLevel(level.Value)

	LevelSystem.CheckLevelUp(player)

	exp.Changed:Connect(function()
		LevelSystem.CheckLevelUp(player)
	end)
end

function LevelSystem.CheckLevelUp(player)
	local dataFolder = player:WaitForChild("Data")
	local level = dataFolder:WaitForChild("Level")
	local availablePoints = dataFolder:WaitForChild("Stats"):WaitForChild("AvailablePoints")
	local exp = dataFolder:WaitForChild("Exp")
	local expNext = dataFolder:WaitForChild("ExpNext")

	while exp.Value >= expNext.Value do
		exp.Value = exp.Value - expNext.Value
		level.Value += 1
		availablePoints.Value += 3
		expNext.Value = LevelSystem.CalculateExpToNextLevel(level.Value)
	end
end

return LevelSystem
