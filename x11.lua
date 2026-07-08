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
local followDistance = 3 
local voidThreshold = -450 
local recoveryHeight = 150 
local charParts = {}

-- === [ FIXED DRAGGABLE FUNCTION ] ===
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- === [ UTILITY ] ===
local function updateCharCache()
    charParts = {}
    if not character then return end
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") then table.insert(charParts, v) end
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

-- === [ GUI SETUP ] ===
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ReaperHub"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 99999999 -- อยู่ชั้นบนสุดเสมอ

-- Toggle Logo (40x40 ลากแยกได้)
local toggleFrame = Instance.new("Frame", screenGui)
toggleFrame.Size = UDim2.new(0, 40, 0, 40)
toggleFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
toggleFrame.Active = true
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 10)
local tStroke = Instance.new("UIStroke", toggleFrame)
tStroke.Color = Color3.fromRGB(200, 0, 0)
tStroke.Thickness = 1.5

local img = Instance.new("ImageButton", toggleFrame)
img.Size = UDim2.new(0.8, 0, 0.8, 0)
img.Position = UDim2.new(0.1, 0, 0.1, 0)
img.BackgroundTransparency = 1
img.Image = "rbxassetid://86279908104891"
makeDraggable(toggleFrame)

-- Main Frame
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 200, 0, 235)
main.Position = UDim2.new(0.5, -100, 0.5, -115)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel = 0
main.Active = true 
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(200, 0, 0)
stroke.Thickness = 2
makeDraggable(main)

img.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- UI Elements
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "REAPER HUB V6"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1

local followBtn = Instance.new("TextButton", main)
followBtn.Size = UDim2.new(0.9, 0, 0, 32)
followBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
followBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
followBtn.Text = "FOLLOW: OFF"
followBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
followBtn.Font = Enum.Font.GothamMedium
Instance.new("UICorner", followBtn)

-- ปุ่ม Anti-Void (ยังอยู่นะครับ)
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

-- === [ CORE LOGIC ] ===
RunService.Heartbeat:Connect(function()
    -- Anti-Void Loop
    if antiVoidEnabled and rootPart and rootPart.Position.Y < voidThreshold then
        rootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        rootPart.CFrame = CFrame.new(rootPart.Position.X, recoveryHeight, rootPart.Position.Z)
    end

    -- Follow Loop
    if isEnabled then
        if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getNearestPlayer()
        else
            local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and character then
                character:PivotTo(targetRoot.CFrame * CFrame.new(0, 0, followDistance))
                rootPart.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity
                for _, v in ipairs(charParts) do if v then v.CanCollide = false end end
            end
        end
    end
end)

-- Buttons Interaction
followBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    updateCharCache()
    followBtn.Text = isEnabled and "FOLLOW: ACTIVE" or "FOLLOW: OFF"
    followBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
    humanoid.PlatformStand = isEnabled
    if not isEnabled then
        for _, v in ipairs(charParts) do if v then v.CanCollide = true end end
    end
end)

antiVoidBtn.MouseButton1Click:Connect(function()
    antiVoidEnabled = not antiVoidEnabled
    antiVoidBtn.Text = antiVoidEnabled and "ANTI-VOID: ON" or "ANTI-VOID: OFF"
    antiVoidBtn.BackgroundColor3 = antiVoidEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(30, 30, 30)
end)

skipBtn.MouseButton1Click:Connect(function() currentTarget = getNearestPlayer(currentTarget) end)

distInput.FocusLost:Connect(function()
    local n = tonumber(distInput.Text:match("%d+"))
    if n then followDistance = n end
    distInput.Text = "Distance: " .. tostring(followDistance)
end)

player.CharacterAdded:Connect(function(char)
    character, rootPart, humanoid = char, char:WaitForChild("HumanoidRootPart"), char:WaitForChild("Humanoid")
    updateCharCache()
end)
