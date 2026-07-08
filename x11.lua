local Load = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Libwtf/refs/heads/main/LoadLib.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- === [ SETTINGS ] ===
local isEnabled = false
local antiVoidEnabled = true
local currentTarget = nil
local followConnection = nil
local noclipConnection = nil
local followDistance = 3 
local voidThreshold = -450 -- จุดที่ลึกที่สุดก่อนวาร์ปกลับ
local recoveryHeight = 150 -- ความสูงที่จะวาร์ปกลับขึ้นมา
local charParts = {}

-- === [ UTILITY FUNCTIONS ] ===

local function updateCharCache()
    charParts = {}
    if not character then return end
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") then table.insert(charParts, v) end
    end
end

local function handleAntiVoid()
    if not rootPart or not antiVoidEnabled then return end
    if rootPart.Position.Y < voidThreshold then
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        rootPart.CFrame = CFrame.new(rootPart.Position.X, recoveryHeight, rootPart.Position.Z)
    end
end

local function getNearestPlayer(exclude)
    local closestPlayer, shortestDistance = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p ~= exclude and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (rootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = p
                end
            end
        end
    end
    return closestPlayer
end

-- === [ CORE SYSTEM ] ===

local function stopFollowing()
    if followConnection then followConnection:Disconnect() followConnection = nil end
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if humanoid then humanoid.PlatformStand = false end
    for i = 1, #charParts do
        if charParts[i] then charParts[i].CanCollide = true end
    end
    if rootPart then
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

local function startFollowing()
    stopFollowing()
    if humanoid then humanoid.PlatformStand = true end
    updateCharCache()

    noclipConnection = RunService.Stepped:Connect(function()
        for i = 1, #charParts do
            if charParts[i] then charParts[i].CanCollide = false end
        end
    end)

    followConnection = RunService.Heartbeat:Connect(function()
        handleAntiVoid() -- รันระบบกันตกแมพตลอดเวลาในขณะที่สคริปต์ทำงาน
        
        if not isEnabled then return end

        if not currentTarget or not currentTarget.Parent or not currentTarget.Character or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getNearestPlayer()
            return
        end

        local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and character then
            character:PivotTo(targetRoot.CFrame * CFrame.new(0, 0, followDistance))
            rootPart.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity
            rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

-- === [ GUI SETUP ] ===

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ReaperPro"
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 200, 0, 230) -- ขยายขนาดรองรับปุ่มใหม่
main.Position = UDim2.new(0.5, -100, 0.5, -115)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel = 0
main.Active = true 
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(200, 0, 0)
stroke.Thickness = 2

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "REAPER HUB V4"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 32)
toggleBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.Text = "FOLLOW: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamMedium
Instance.new("UICorner", toggleBtn)

local antiVoidBtn = Instance.new("TextButton", main)
antiVoidBtn.Size = UDim2.new(0.9, 0, 0, 32)
antiVoidBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
antiVoidBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
antiVoidBtn.Text = "ANTI-VOID: ON"
antiVoidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
antiVoidBtn.Font = Enum.Font.GothamMedium
Instance.new("UICorner", antiVoidBtn)

local skipBtn = Instance.new("TextButton", main)
skipBtn.Size = UDim2.new(0.9, 0, 0, 32)
skipBtn.Position = UDim2.new(0.05, 0, 0.52, 0)
skipBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
skipBtn.Text = "SKIP PLAYER"
skipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skipBtn.Font = Enum.Font.GothamMedium
Instance.new("UICorner", skipBtn)

local distInput = Instance.new("TextBox", main)
distInput.Size = UDim2.new(0.9, 0, 0, 30)
distInput.Position = UDim2.new(0.05, 0, 0.72, 0)
distInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
distInput.Text = "Distance: " .. tostring(followDistance)
distInput.TextColor3 = Color3.fromRGB(255, 255, 255)
distInput.Font = Enum.Font.GothamMedium
Instance.new("UICorner", distInput)

-- === [ INTERACTIONS ] ===

toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    toggleBtn.Text = isEnabled and "FOLLOW: ACTIVE" or "FOLLOW: OFF"
    toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
    if isEnabled then startFollowing() else stopFollowing() end
end)

antiVoidBtn.MouseButton1Click:Connect(function()
    antiVoidEnabled = not antiVoidEnabled
    antiVoidBtn.Text = antiVoidEnabled and "ANTI-VOID: ON" or "ANTI-VOID: OFF"
    antiVoidBtn.BackgroundColor3 = antiVoidEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(30, 30, 30)
end)

skipBtn.MouseButton1Click:Connect(function()
    currentTarget = getNearestPlayer(currentTarget)
end)

distInput.FocusLost:Connect(function()
    local n = tonumber(distInput.Text:match("%d+"))
    if n then followDistance = n end
    distInput.Text = "Distance: " .. tostring(followDistance)
end)

-- Draggable Script
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = frame.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end
makeDraggable(main)

-- Character Auto-Update
player.CharacterAdded:Connect(function(char)
    character, rootPart, humanoid = char, char:WaitForChild("HumanoidRootPart"), char:WaitForChild("Humanoid")
    updateCharCache()
    if isEnabled then task.wait(0.1) startFollowing() end
end)


print("Credit : Reaper Hub")
print("Credit : x2sxqz_")

-- Load Success 
task.wait(0.5)
print("Reaper Hub Loaded")
