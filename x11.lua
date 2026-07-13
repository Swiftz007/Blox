-- [[ REAPER HUB V8 - AUTO G ADDED ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- === [ SETTINGS ] ===
local isEnabled = false
local autoFarmEnabled = false
local antiVoidEnabled = true
local currentTarget = nil
local followDistance = 4
local voidThreshold = -450 
local recoveryHeight = 600
local charParts = {}

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

-- === [ DRAGGABLE ] ===
local function makeDraggable(clickObject, targetFrame)
    local dragging, dragInput, dragStart, startPos
    clickObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    clickObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- === [ GUI SETUP ] ===
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ReaperPro"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 99999999

local toggleFrame = Instance.new("Frame", screenGui)
toggleFrame.Size = UDim2.new(0, 50, 0, 50)
toggleFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 12)
local tStroke = Instance.new("UIStroke", toggleFrame)
tStroke.Color = Color3.fromRGB(200, 0, 0)
tStroke.Thickness = 2

local img = Instance.new("ImageButton", toggleFrame)
img.Size = UDim2.new(0.8, 0, 0.8, 0)
img.Position = UDim2.new(0.1, 0, 0.1, 0)
img.BackgroundTransparency = 1
img.Image = "rbxassetid://86279908104891"

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 200, 0, 280)
main.Position = UDim2.new(0.5, -100, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(200, 0, 0)
stroke.Thickness = 2

makeDraggable(img, toggleFrame)
makeDraggable(main, main)
img.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn)
    return btn
end

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "REAPER HUB V8"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

local farmBtn = createBtn("AUTO FARM: OFF", UDim2.new(0.05, 0, 0.15, 0), Color3.fromRGB(30, 30, 30))
local followBtn = createBtn("FOLLOW: OFF", UDim2.new(0.05, 0, 0.28, 0), Color3.fromRGB(30, 30, 30))
local antiVoidBtn = createBtn("ANTI-VOID: ON", UDim2.new(0.05, 0, 0.41, 0), Color3.fromRGB(0, 120, 0))
local skipBtn = createBtn("SKIP PLAYER", UDim2.new(0.05, 0, 0.54, 0), Color3.fromRGB(120, 0, 0))

local distInput = Instance.new("TextBox", main)
distInput.Size = UDim2.new(0.9, 0, 0, 30)
distInput.Position = UDim2.new(0.05, 0, 0.72, 0)
distInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
distInput.Text = "Distance: " .. tostring(followDistance)
distInput.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", distInput)

-- === [ FARM LOGIC ] ===

-- Click Loop (M1)
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoFarmEnabled and isEnabled and currentTarget then
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end
    end
end)

-- Skill Loop (1, 2, 3, 4)
task.spawn(function()
    local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
    while true do
        for _, key in ipairs(keys) do
            if autoFarmEnabled and isEnabled and currentTarget then
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                task.wait(1)
            else
                task.wait(0.5)
                break
            end
        end
    end
end)

-- Auto G Loop (ทุก 15 วินาที)
task.spawn(function()
    while true do
        if autoFarmEnabled and isEnabled and currentTarget then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
            task.wait(15) -- ดีเลย์ 15 วินาที
        else
            task.wait(1)
        end
    end
end)

-- === [ CORE LOOP ] ===
RunService.Heartbeat:Connect(function()
    if antiVoidEnabled and rootPart and rootPart.Position.Y < voidThreshold then
        rootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        rootPart.CFrame = CFrame.new(rootPart.Position.X, recoveryHeight, rootPart.Position.Z)
    end
    if isEnabled then
        if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getNearestPlayer()
        else
            local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                character:PivotTo(targetRoot.CFrame * CFrame.new(0, 0, followDistance))
                rootPart.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity
                for _, v in ipairs(charParts) do if v then v.CanCollide = false end end
            end
        end
    end
end)

-- === [ BUTTON EVENTS ] ===
farmBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    farmBtn.Text = autoFarmEnabled and "AUTO FARM: ON" or "AUTO FARM: OFF"
    farmBtn.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(30, 30, 30)
end)

followBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    updateCharCache()
    followBtn.Text = isEnabled and "FOLLOW: ACTIVE" or "FOLLOW: OFF"
    followBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
    humanoid.PlatformStand = isEnabled
    if not isEnabled then for _, v in ipairs(charParts) do if v then v.CanCollide = true end end end
end)

antiVoidBtn.MouseButton1Click:Connect(function()
    antiVoidEnabled = not antiVoidEnabled
    antiVoidBtn.Text = antiVoidEnabled and "ANTI-VOID: ON" or "ANTI-VOID: OFF"
    antiVoidBtn.BackgroundColor3 = antiVoidEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(30, 30, 30)
end)

skipBtn.MouseButton1Click:Connect(function() currentTarget = getNearestPlayer(currentTarget) end)

distInput.FocusLost:Connect(function()
    followDistance = tonumber(distInput.Text:match("%d+")) or followDistance
    distInput.Text = "Distance: " .. tostring(followDistance)
end)

player.CharacterAdded:Connect(function(char)
    character, rootPart, humanoid = char, char:WaitForChild("HumanoidRootPart"), char:WaitForChild("Humanoid")
    updateCharCache()
end)

print("Reaper Hub V8 Loaded")
