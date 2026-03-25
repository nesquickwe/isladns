-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")


local remote1 = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("fLafXsVXagmlXhlc/kyduresvxnennbphKo")

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
local APPROACH_DISTANCE = 8 

local enabled = true
local currentTarget = nil
local currentDistance = 0
local lastFireTime = 0
local fireInterval = 1/10 
local isMoving = false
local lastBackupTime = 0
local backupCooldown = 0.2 

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Gatypvp"
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
titleText.Text = "Combat Movement System"
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

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Parent = statusSection

local entityInfoLabel = Instance.new("TextLabel")
entityInfoLabel.Size = UDim2.new(1, 0, 0, 25)
entityInfoLabel.Position = UDim2.new(0, 5, 0, 35)
entityInfoLabel.BackgroundTransparency = 1
entityInfoLabel.Text = "Target: None"
entityInfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
entityInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
entityInfoLabel.Font = Enum.Font.Gotham
entityInfoLabel.TextSize = 12
entityInfoLabel.Parent = statusSection

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(1, 0, 0, 25)
distanceLabel.Position = UDim2.new(0, 5, 0, 65)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Text = "Distance: N/A"
distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextSize = 12
distanceLabel.Parent = statusSection

local movementLabel = Instance.new("TextLabel")
movementLabel.Size = UDim2.new(1, 0, 0, 25)
movementLabel.Position = UDim2.new(0, 5, 0, 95)
movementLabel.BackgroundTransparency = 1
movementLabel.Text = "Movement: Stopped"
movementLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
movementLabel.TextXAlignment = Enum.TextXAlignment.Left
movementLabel.Font = Enum.Font.Gotham
movementLabel.TextSize = 12
movementLabel.Parent = statusSection

local combatLabel = Instance.new("TextLabel")
combatLabel.Size = UDim2.new(1, 0, 0, 25)
combatLabel.Position = UDim2.new(0, 5, 0, 125)
combatLabel.BackgroundTransparency = 1
combatLabel.Text = "Combat: Not firing"
combatLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
combatLabel.TextXAlignment = Enum.TextXAlignment.Left
combatLabel.Font = Enum.Font.Gotham
combatLabel.TextSize = 12
combatLabel.Parent = statusSection
local settingsSection = Instance.new("Frame")
settingsSection.Size = UDim2.new(1, -20, 0, 260)
settingsSection.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
settingsSection.BackgroundTransparency = 0.3
settingsSection.BorderSizePixel = 0
settingsSection.Parent = contentFrame

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, 25)
settingsTitle.Position = UDim2.new(0, 5, 0, 5)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "Movement Settings"
settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 14
settingsTitle.Parent = settingsSection

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
local safeDistLabel = Instance.new("TextLabel")
safeDistLabel.Size = UDim2.new(0.5, 0, 0, 25)
safeDistLabel.Position = UDim2.new(0, 5, 0, 80)
safeDistLabel.BackgroundTransparency = 1
safeDistLabel.Text = "Safe Distance: 3"
safeDistLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
safeDistLabel.TextXAlignment = Enum.TextXAlignment.Left
safeDistLabel.Font = Enum.Font.Gotham
safeDistLabel.TextSize = 12
safeDistLabel.Parent = settingsSection

local safeDistSlider = Instance.new("TextButton")
safeDistSlider.Size = UDim2.new(1, -10, 0, 25)
safeDistSlider.Position = UDim2.new(0, 5, 0, 105)
safeDistSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
safeDistSlider.Text = "─────●─────"
safeDistSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
safeDistSlider.Font = Enum.Font.Gotham
safeDistSlider.TextSize = 14
safeDistSlider.BorderSizePixel = 0
safeDistSlider.Parent = settingsSection
local backupForceLabel = Instance.new("TextLabel")
backupForceLabel.Size = UDim2.new(0.5, 0, 0, 25)
backupForceLabel.Position = UDim2.new(0, 5, 0, 140)
backupForceLabel.BackgroundTransparency = 1
backupForceLabel.Text = "Backup Force: 15"
backupForceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
backupForceLabel.TextXAlignment = Enum.TextXAlignment.Left
backupForceLabel.Font = Enum.Font.Gotham
backupForceLabel.TextSize = 12
backupForceLabel.Parent = settingsSection

local backupForceSlider = Instance.new("TextButton")
backupForceSlider.Size = UDim2.new(1, -10, 0, 25)
backupForceSlider.Position = UDim2.new(0, 5, 0, 165)
backupForceSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
backupForceSlider.Text = "─────●─────"
backupForceSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
backupForceSlider.Font = Enum.Font.Gotham
backupForceSlider.TextSize = 14
backupForceSlider.BorderSizePixel = 0
backupForceSlider.Parent = settingsSection

local attackRangeLabel = Instance.new("TextLabel")
attackRangeLabel.Size = UDim2.new(0.5, 0, 0, 25)
attackRangeLabel.Position = UDim2.new(0, 5, 0, 200)
attackRangeLabel.BackgroundTransparency = 1
attackRangeLabel.Text = "Attack Range: 4"
attackRangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
attackRangeLabel.TextXAlignment = Enum.TextXAlignment.Left
attackRangeLabel.Font = Enum.Font.Gotham
attackRangeLabel.TextSize = 12
attackRangeLabel.Parent = settingsSection

local attackRangeSlider = Instance.new("TextButton")
attackRangeSlider.Size = UDim2.new(1, -10, 0, 25)
attackRangeSlider.Position = UDim2.new(0, 5, 0, 225)
attackRangeSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
attackRangeSlider.Text = "─────●─────"
attackRangeSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
attackRangeSlider.Font = Enum.Font.Gotham
attackRangeSlider.TextSize = 14
attackRangeSlider.BorderSizePixel = 0
attackRangeSlider.Parent = settingsSection

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 5, 0, 260)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Move Speed: 16"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.Parent = settingsSection

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(1, -10, 0, 25)
speedSlider.Position = UDim2.new(0, 5, 0, 285)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
speedSlider.Text = "─────●─────"
speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
speedSlider.Font = Enum.Font.Gotham
speedSlider.TextSize = 14
speedSlider.BorderSizePixel = 0
speedSlider.Parent = settingsSection

local function updateSlider(slider, value, min, max)
	local percentage = (value - min) / (max - min)
	local filled = math.floor(percentage * 20)
	local empty = 20 - filled
	slider.Text = string.rep("─", filled) .. "●" .. string.rep("─", empty)
end

local function updateSafeDistance(value)
	SAFE_DISTANCE = math.clamp(value, 1, 10)
	safeDistLabel.Text = "Safe Distance: " .. string.format("%.1f", SAFE_DISTANCE)
	updateSlider(safeDistSlider, SAFE_DISTANCE, 1, 10)
end

safeDistSlider.MouseButton1Down:Connect(function()
	local mouse = LocalPlayer:GetMouse()
	local connection
	local startX = mouse.X
	local startValue = SAFE_DISTANCE
	
	connection = mouse.Move:Connect(function()
		local deltaX = mouse.X - startX
		local newValue = math.clamp(startValue + deltaX / 20, 1, 10)
		updateSafeDistance(newValue)
	end)
	
	mouse.Button1Up:Connect(function()
		connection:Disconnect()
	end)
end)
local function updateBackupForce(value)
	BACKUP_FORCE = math.clamp(value, 5, 30)
	backupForceLabel.Text = "Backup Force: " .. math.floor(BACKUP_FORCE)
	updateSlider(backupForceSlider, BACKUP_FORCE, 5, 30)
end

backupForceSlider.MouseButton1Down:Connect(function()
	local mouse = LocalPlayer:GetMouse()
	local connection
	local startX = mouse.X
	local startValue = BACKUP_FORCE
	
	connection = mouse.Move:Connect(function()
		local deltaX = mouse.X - startX
		local newValue = math.clamp(startValue + deltaX / 20, 5, 30)
		updateBackupForce(newValue)
	end)
	
	mouse.Button1Up:Connect(function()
		connection:Disconnect()
	end)
end)

local function updateAttackRange(value)
	ATTACK_RANGE = math.clamp(value, 1, 50)
	attackRangeLabel.Text = "Attack Range: " .. string.format("%.1f", ATTACK_RANGE)
	updateSlider(attackRangeSlider, ATTACK_RANGE, 1, 50)
end

attackRangeSlider.MouseButton1Down:Connect(function()
	local mouse = LocalPlayer:GetMouse()
	local connection
	local startX = mouse.X
	local startValue = ATTACK_RANGE
	
	connection = mouse.Move:Connect(function()
		local deltaX = mouse.X - startX
		local newValue = math.clamp(startValue + deltaX / 20, 1, 15)
		updateAttackRange(newValue)
	end)
	
	mouse.Button1Up:Connect(function()
		connection:Disconnect()
	end)
end)

local function updateMoveSpeed(value)
	MOVE_SPEED = math.clamp(value, 8, 30)
	speedLabel.Text = "Move Speed: " .. math.floor(MOVE_SPEED)
	Humanoid.WalkSpeed = MOVE_SPEED
	updateSlider(speedSlider, MOVE_SPEED, 8, 30)
end

speedSlider.MouseButton1Down:Connect(function()
	local mouse = LocalPlayer:GetMouse()
	local connection
	local startX = mouse.X
	local startValue = MOVE_SPEED
	
	connection = mouse.Move:Connect(function()
		local deltaX = mouse.X - startX
		local newValue = math.clamp(startValue + deltaX / 20, 8, 30)
		updateMoveSpeed(newValue)
	end)
	
	mouse.Button1Up:Connect(function()
		connection:Disconnect()
	end)
end)

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
local dragStartPos
local dragStartMousePos

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
		mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
local function getClosestEntity()
	local closestEntity = nil
	local closestDistance = math.huge
	local rootPart = Character:FindFirstChild("HumanoidRootPart")
	
	if not rootPart then return nil, nil end
	
	local entities = Workspace:FindFirstChild("WildernessIsland")
	if entities then
		entities = entities:FindFirstChild("Entities")
		if entities then
			for _, entity in ipairs(entities:GetChildren()) do
				if entity:IsA("BasePart") or entity:FindFirstChild("HumanoidRootPart") then
					local entityRoot = entity:IsA("BasePart") and entity or entity:FindFirstChild("HumanoidRootPart")
					if entityRoot and entityRoot.Position then
						local distance = (rootPart.Position - entityRoot.Position).Magnitude
						if distance < closestDistance then
							closestDistance = distance
							closestEntity = entity
						end
					end
				end
			end
		end
	end
	
	return closestEntity, closestDistance
end

local function getEntityRoot(entity)
	if not entity then return nil end
	return entity:IsA("BasePart") and entity or entity:FindFirstChild("HumanoidRootPart")
end

-- Function to handle movement
local function handleMovement(target, distance, targetRoot)
	if not target or not enabled then return false end
	
	local currentPos = HumanoidRootPart.Position
	local targetPos = targetRoot.Position
	
	local toTarget = (targetPos - currentPos)
	local directionToTarget = toTarget.Unit

	if distance < SAFE_DISTANCE then
		local backupDirection = -directionToTarget
		local backupPosition = currentPos + (backupDirection * BACKUP_FORCE)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {Character}
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		
		local raycastResult = workspace:Raycast(currentPos, backupDirection * BACKUP_FORCE, raycastParams)
		
		if not raycastResult or raycastResult.Distance > BACKUP_FORCE - 1 then
			Humanoid:MoveTo(backupPosition)
			movementLabel.Text = string.format(" BACKING UP (%.1f < %.1f)", distance, SAFE_DISTANCE)
			movementLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			return true
		else

			local angle = math.rad(45)
			local rightDirection = Vector3.new(-backupDirection.Z, 0, backupDirection.X).Unit
			local adjustedDirection = (backupDirection * math.cos(angle) + rightDirection * math.sin(angle)).Unit
			local adjustedPosition = currentPos + (adjustedDirection * BACKUP_FORCE)
			Humanoid:MoveTo(adjustedPosition)
			movementLabel.Text = " BACKING UP (avoiding obstacle)"
			movementLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
			return true
		end
	

	elseif distance > SAFE_DISTANCE + 1 then

		local moveDistance = math.min(distance - SAFE_DISTANCE, 10)
		local movePosition = currentPos + (directionToTarget * moveDistance)
		Humanoid:MoveTo(movePosition)
		movementLabel.Text = string.format("→ Moving towards target (%.1f/%.1f)", distance, SAFE_DISTANCE)
		movementLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		return true
	
	else
		Humanoid:MoveTo(currentPos)
		movementLabel.Text = string.format("✓ Perfect distance! (%.1f/%.1f)", distance, SAFE_DISTANCE)
		movementLabel.TextColor3 = Color3.fromRGB(100, 255, 200)
		return false
	end
end

local function fireRemote()
	local currentTime = tick()
	if currentTime - lastFireTime >= fireInterval then
		remote1:FireServer(unpack(args3))
		lastFireTime = currentTime
		combatLabel.Text = "⚔️ FIRING! ⚔️"
		combatLabel.TextColor3 = Color3.fromRGB(255, 50, 50)

		task.delay(0.2, function()
			if currentTarget and currentDistance <= ATTACK_RANGE then
				combatLabel.Text = " Firing in range"
				combatLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			else
				combatLabel.Text = "Combat: Not firing"
				combatLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
		end)
	end
end

local function onCharacterAdded(newChar)
	Character = newChar
	Humanoid = Character:WaitForChild("Humanoid")
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	Humanoid.WalkSpeed = MOVE_SPEED
	

	isMoving = false
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

Humanoid.WalkSpeed = MOVE_SPEED

updateSlider(safeDistSlider, SAFE_DISTANCE, 1, 10)
updateSlider(backupForceSlider, BACKUP_FORCE, 5, 30)
updateSlider(attackRangeSlider, ATTACK_RANGE, 1, 15)
updateSlider(speedSlider, MOVE_SPEED, 8, 30)

RunService.RenderStepped:Connect(function(deltaTime)
	if not enabled or not Character or not HumanoidRootPart or not Humanoid then return end
	

	local closestEntity, distance = getClosestEntity()
	currentTarget = closestEntity
	currentDistance = distance
	
	if closestEntity then
		local targetRoot = getEntityRoot(closestEntity)
		if not targetRoot then return end
		

		local entityName = closestEntity.Name
		if #entityName > 30 then
			entityName = string.sub(entityName, 1, 27) .. "..."
		end
		entityInfoLabel.Text = "Target: " .. entityName
		

		if distance <= SAFE_DISTANCE then
			distanceLabel.Text = string.format("Distance: %.1f studs  TOO CLOSE!", distance)
			distanceLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		elseif distance <= ATTACK_RANGE then
			distanceLabel.Text = string.format("Distance: %.1f studs  IN RANGE", distance)
			distanceLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
		else
			distanceLabel.Text = string.format("Distance: %.1f studs", distance)
			distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
		
		statusLabel.Text = "Status: Active "
		statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		
		handleMovement(closestEntity, distance, targetRoot)
		
		if distance <= ATTACK_RANGE then
			fireRemote()
		else
			combatLabel.Text = string.format("Combat: Need to get closer (%.1f/%.1f)", distance, ATTACK_RANGE)
			combatLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	else
		entityInfoLabel.Text = "Target: None"
		distanceLabel.Text = "Distance: N/A"
		distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		statusLabel.Text = "Status: Searching..."
		statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		movementLabel.Text = "Movement: Idle (no target)"
		movementLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		combatLabel.Text = "Combat: No target"
		combatLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		
		Humanoid:MoveTo(HumanoidRootPart.Position)
	end
end)
