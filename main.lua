local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local remote1 = ReplicatedStorage
	:WaitForChild("rbxts_include")
	:WaitForChild("node_modules")
	:WaitForChild("@rbxts")
	:WaitForChild("net")
	:WaitForChild("out")
	:WaitForChild("_NetManaged")
	:WaitForChild("fLafXsVXagmlXhlc/kyduresvxnennbphKo")

local args3 = {
	"7EA093B9-0C2A-4FA9-ABAB-6E68A6E17D0B",
	{
		{
			altFireKind = "HOLD"
		}
	}
}

local SAFE_DISTANCE = 10
local BACKUP_FORCE = 30
local ATTACK_RANGE = 50
local MOVE_SPEED = 16

local enabled = true
local currentTarget = nil
local currentDistance = 0
local lastFireTime = 0
local fireInterval = 1 / 10
local isMoving = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GatysMobFarm"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 520)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -30, 1, 0)
titleText.Position = UDim2.new(0, 5, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Gatys Mob Farm"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.ScrollBarThickness = 6
contentFrame.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 10)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = contentFrame

local statusSection = Instance.new("Frame")
statusSection.Size = UDim2.new(1, -20, 0, 140)
statusSection.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusSection.BackgroundTransparency = 0.3
statusSection.BorderSizePixel = 0
statusSection.Parent = contentFrame

local function makeLabel(parent, size, pos, text, textSize, bold)
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = pos
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	label.TextSize = textSize or 12
	label.Parent = parent
	return label
end

local statusLabel    = makeLabel(statusSection, UDim2.new(1,0,0,25), UDim2.new(0,5,0,5),   "Status: Idle",         14, true)
local entityInfoLabel= makeLabel(statusSection, UDim2.new(1,0,0,25), UDim2.new(0,5,0,35),  "Target: None",         12)
local distanceLabel  = makeLabel(statusSection, UDim2.new(1,0,0,25), UDim2.new(0,5,0,65),  "Distance: N/A",        12)
local movementLabel  = makeLabel(statusSection, UDim2.new(1,0,0,25), UDim2.new(0,5,0,95),  "Movement: Stopped",    12)
local combatLabel    = makeLabel(statusSection, UDim2.new(1,0,0,25), UDim2.new(0,5,0,125), "Combat: Not firing",   12)

statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local settingsSection = Instance.new("Frame")
settingsSection.Size = UDim2.new(1, -20, 0, 310)
settingsSection.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
settingsSection.BackgroundTransparency = 0.3
settingsSection.BorderSizePixel = 0
settingsSection.Parent = contentFrame

makeLabel(settingsSection, UDim2.new(1,0,0,25), UDim2.new(0,5,0,5), "Settings", 14, true).TextColor3 = Color3.fromRGB(255,255,255)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -10, 0, 35)
toggleButton.Position = UDim2.new(0, 5, 0, 35)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
toggleButton.Text = "Enabled"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.BorderSizePixel = 0
toggleButton.Parent = settingsSection

local function makeSliderPair(parent, labelText, yOffset)
	local lbl = makeLabel(parent, UDim2.new(0.5,0,0,25), UDim2.new(0,5,0,yOffset), labelText, 12)
	local slider = Instance.new("TextButton")
	slider.Size = UDim2.new(1, -10, 0, 25)
	slider.Position = UDim2.new(0, 5, 0, yOffset + 25)
	slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	slider.Text = "─────●─────"
	slider.TextColor3 = Color3.fromRGB(255, 255, 255)
	slider.Font = Enum.Font.Gotham
	slider.TextSize = 14
	slider.BorderSizePixel = 0
	slider.Parent = parent
	return lbl, slider
end

local safeDistLabel,    safeDistSlider    = makeSliderPair(settingsSection, "Safe Distance: 10",  80)
local backupForceLabel, backupForceSlider = makeSliderPair(settingsSection, "Backup Force: 30",  140)
local attackRangeLabel, attackRangeSlider = makeSliderPair(settingsSection, "Attack Range: 50",  200)
local speedLabel,       speedSlider       = makeSliderPair(settingsSection, "Move Speed: 16",    260)

local function updateSlider(slider, value, min, max)
	local pct = (value - min) / (max - min)
	local filled = math.floor(pct * 20)
	slider.Text = string.rep("─", filled) .. "●" .. string.rep("─", 20 - filled)
end

local function bindSlider(slider, getVal, setVal, min, max, step)
	slider.MouseButton1Down:Connect(function()
		local mouse = LocalPlayer:GetMouse()
		local startX = mouse.X
		local startValue = getVal()
		local conn
		conn = mouse.Move:Connect(function()
			local newVal = math.clamp(startValue + (mouse.X - startX) / 20, min, max)
			setVal(newVal)
		end)
		mouse.Button1Up:Connect(function() conn:Disconnect() end)
	end)
end

local function setSafeDist(v)
	SAFE_DISTANCE = math.clamp(v, 1, 10)
	safeDistLabel.Text = "Safe Distance: " .. string.format("%.1f", SAFE_DISTANCE)
	updateSlider(safeDistSlider, SAFE_DISTANCE, 1, 10)
end

local function setBackupForce(v)
	BACKUP_FORCE = math.clamp(v, 5, 30)
	backupForceLabel.Text = "Backup Force: " .. math.floor(BACKUP_FORCE)
	updateSlider(backupForceSlider, BACKUP_FORCE, 5, 30)
end

local function setAttackRange(v)
	ATTACK_RANGE = math.clamp(v, 1, 50)
	attackRangeLabel.Text = "Attack Range: " .. string.format("%.1f", ATTACK_RANGE)
	updateSlider(attackRangeSlider, ATTACK_RANGE, 1, 50)
end

local function setMoveSpeed(v)
	MOVE_SPEED = math.clamp(v, 8, 30)
	speedLabel.Text = "Move Speed: " .. math.floor(MOVE_SPEED)
	Humanoid.WalkSpeed = MOVE_SPEED
	updateSlider(speedSlider, MOVE_SPEED, 8, 30)
end

bindSlider(safeDistSlider,    function() return SAFE_DISTANCE end,  setSafeDist,    1,  10)
bindSlider(backupForceSlider, function() return BACKUP_FORCE end,   setBackupForce, 5,  30)
bindSlider(attackRangeSlider, function() return ATTACK_RANGE end,   setAttackRange, 1,  50)
bindSlider(speedSlider,       function() return MOVE_SPEED end,     setMoveSpeed,   8,  30)

updateSlider(safeDistSlider,    SAFE_DISTANCE,  1,  10)
updateSlider(backupForceSlider, BACKUP_FORCE,   5,  30)
updateSlider(attackRangeSlider, ATTACK_RANGE,   1,  50)
updateSlider(speedSlider,       MOVE_SPEED,     8,  30)

toggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggleButton.Text = enabled and "Enabled" or "Disabled"
	toggleButton.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
	if not enabled then
		Humanoid:MoveTo(HumanoidRootPart.Position)
		isMoving = false
		movementLabel.Text = "Movement: Stopped"
	end
end)

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local dragging = false
local dragStartPos, dragStartMousePos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStartPos = mainFrame.Position
		dragStartMousePos = input.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStartMousePos
		mainFrame.Position = UDim2.new(
			dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X,
			dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

local function getClosestEntity()
	local rootPart = Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil, nil end

	local entitiesFolder = Workspace:FindFirstChild("WildernessIsland")
	if not entitiesFolder then return nil, nil end
	entitiesFolder = entitiesFolder:FindFirstChild("Entities")
	if not entitiesFolder then return nil, nil end

	local closest, closestDist = nil, math.huge

	for _, entity in ipairs(entitiesFolder:GetChildren()) do
		local entityRoot = entity:IsA("BasePart") and entity or entity:FindFirstChild("HumanoidRootPart")
		if entityRoot and entityRoot.Position then
			local dist = (rootPart.Position - entityRoot.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closest = entity
			end
		end
	end

	return closest, closestDist
end

local function getEntityRoot(entity)
	if not entity then return nil end
	return entity:IsA("BasePart") and entity or entity:FindFirstChild("HumanoidRootPart")
end

local function handleMovement(target, distance, targetRoot)
	if not target or not enabled then return false end

	local currentPos = HumanoidRootPart.Position
	local directionToTarget = (targetRoot.Position - currentPos).Unit

	if distance < SAFE_DISTANCE then
		local backupDir = -directionToTarget
		local backupPos = currentPos + backupDir * BACKUP_FORCE

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {Character}
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist

		local hit = workspace:Raycast(currentPos, backupDir * BACKUP_FORCE, rayParams)

		if not hit or hit.Distance > BACKUP_FORCE - 1 then
			Humanoid:MoveTo(backupPos)
			movementLabel.Text = string.format("BACKING UP (%.1f < %.1f)", distance, SAFE_DISTANCE)
			movementLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		else
			local angle = math.rad(45)
			local right = Vector3.new(-backupDir.Z, 0, backupDir.X).Unit
			local adjusted = (backupDir * math.cos(angle) + right * math.sin(angle)).Unit
			Humanoid:MoveTo(currentPos + adjusted * BACKUP_FORCE)
			movementLabel.Text = "BACKING UP (obstacle)"
			movementLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
		end
		return true

	elseif distance > SAFE_DISTANCE + 1 then
		local movePos = currentPos + directionToTarget * math.min(distance - SAFE_DISTANCE, 10)
		Humanoid:MoveTo(movePos)
		movementLabel.Text = string.format("Approaching (%.1f / %.1f)", distance, SAFE_DISTANCE)
		movementLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		return true

	else
		Humanoid:MoveTo(currentPos)
		movementLabel.Text = string.format("In position (%.1f / %.1f)", distance, SAFE_DISTANCE)
		movementLabel.TextColor3 = Color3.fromRGB(100, 255, 200)
		return false
	end
end

local function fireRemote()
	local now = tick()
	if now - lastFireTime >= fireInterval then
		remote1:FireServer(unpack(args3))
		lastFireTime = now
		combatLabel.Text = "FIRING"
		combatLabel.TextColor3 = Color3.fromRGB(255, 50, 50)

		task.delay(0.2, function()
			if currentTarget and currentDistance <= ATTACK_RANGE then
				combatLabel.Text = "Firing (in range)"
				combatLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			else
				combatLabel.Text = "Combat: Not firing"
				combatLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
		end)
	end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
	Character = newChar
	Humanoid = Character:WaitForChild("Humanoid")
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	Humanoid.WalkSpeed = MOVE_SPEED
	isMoving = false
end)

Humanoid.WalkSpeed = MOVE_SPEED

RunService.RenderStepped:Connect(function()
	if not enabled or not Character or not HumanoidRootPart or not Humanoid then return end

	local closestEntity, distance = getClosestEntity()
	currentTarget = closestEntity
	currentDistance = distance

	if closestEntity then
		local targetRoot = getEntityRoot(closestEntity)
		if not targetRoot then return end

		local name = closestEntity.Name
		entityInfoLabel.Text = "Target: " .. (if #name > 30 then string.sub(name, 1, 27) .. "..." else name)

		if distance <= SAFE_DISTANCE then
			distanceLabel.Text = string.format("Distance: %.1f  TOO CLOSE", distance)
			distanceLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		elseif distance <= ATTACK_RANGE then
			distanceLabel.Text = string.format("Distance: %.1f  IN RANGE", distance)
			distanceLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
		else
			distanceLabel.Text = string.format("Distance: %.1f", distance)
			distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end

		statusLabel.Text = "Status: Active"
		statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)

		handleMovement(closestEntity, distance, targetRoot)

		if distance <= ATTACK_RANGE then
			fireRemote()
		else
			combatLabel.Text = string.format("Need to get closer (%.1f / %.1f)", distance, ATTACK_RANGE)
			combatLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	else
		entityInfoLabel.Text = "Target: None"
		distanceLabel.Text = "Distance: N/A"
		distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		statusLabel.Text = "Status: Searching"
		statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		movementLabel.Text = "Movement: Idle"
		movementLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		combatLabel.Text = "Combat: No target"
		combatLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		Humanoid:MoveTo(HumanoidRootPart.Position)
	end
end)
