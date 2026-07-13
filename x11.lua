-- [[ REAPER HUB V9 - HYBRID CLICKS ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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

-- Mobile/PC Settings
local farmMode = nil -- "PC" or "Mobile"
local mobileClickPos = nil

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

-- === [ DRAGGABLE SYSTEM ] ===
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
screenGui.IgnoreGuiInset = true

-- Main Frame
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 200, 0, 280)
main.Position = UDim2.new(0.5, -100, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", main)
makeDraggable(main, main)

local function createBtn(text, pos, color, parent)
    local btn = Instance.new("TextButton", parent or main)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    return btn
end

local farmBtn = createBtn("AUTO FARM: OFF", UDim2.new(0.05, 0, 0.15, 0), Color3.fromRGB(30, 30, 30))
local followBtn = createBtn("FOLLOW: OFF", UDim2.new(0.05, 0, 0.30, 0), Color3.fromRGB(30, 30, 30))
local antiVoidBtn = createBtn("ANTI-VOID: ON", UDim2.new(0.05, 0, 0.45, 0), Color3.fromRGB(0, 120, 0))
local skipBtn = createBtn("SKIP PLAYER", UDim2.new(0.05, 0, 0.60, 0), Color3.fromRGB(120, 0, 0))

-- === [ MODE SELECTION UI ] ===
local modeFrame = Instance.new("Frame", screenGui)
modeFrame.Size = UDim2.new(0, 250, 0, 150)
modeFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
modeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
modeFrame.Visible = false
Instance.new("UICorner", modeFrame)
local mStroke = Instance.new("UIStroke", modeFrame)
mStroke.Color = Color3.fromRGB(255, 0, 0)

local mTitle = Instance.new("TextLabel", modeFrame)
mTitle.Size = UDim2.new(1, 0, 0, 40)
mTitle.Text = "SELECT DEVICE MODE"
mTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
mTitle.BackgroundTransparency = 1

local pcBtn = createBtn("PC (MOUSE 1)", UDim2.new(0.05, 0, 0.35, 0), Color3.fromRGB(50, 50, 50), modeFrame)
local mbBtn = createBtn("MOBILE (TAP POS)", UDim2.new(0.05, 0, 0.65, 0), Color3.fromRGB(50, 50, 50), modeFrame)

-- === [ MOBILE TAP SETUP UI ] ===
local tapSetup = Instance.new("Frame", screenGui)
tapSetup.Size = UDim2.new(0, 60, 0, 60)
tapSetup.Position = UDim2.new(0.8, 0, 0.8, 0)
tapSetup.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
tapSetup.BackgroundTransparency = 0.5
tapSetup.Visible = false
Instance.new("UICorner", tapSetup).CornerRadius = UDim.new(1, 0)
makeDraggable(tapSetup, tapSetup)

local saveTap = createBtn("SAVE POS", UDim2.new(0, 100, 0, 40), UDim2.new(0.5, -50, 1.2, 0), Color3.fromRGB(0, 150, 0), tapSetup)

-- === [ FARMING LOOPS ] ===

-- Auto Click / Tap
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoFarmEnabled and isEnabled and currentTarget and farmMode then
            if farmMode == "PC" then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            elseif farmMode == "Mobile" and mobileClickPos then
                VirtualInputManager:SendTouchEvent(mobileClickPos.X, mobileClickPos.Y, Enum.UserInputState.Begin, game)
                task.wait(0.01)
                VirtualInputManager:SendTouchEvent(mobileClickPos.X, mobileClickPos.Y, Enum.UserInputState.End, game)
            end
        end
    end
end)

-- Auto G (15 Seconds)
task.spawn(function()
    while true do
        task.wait(15)
        if autoFarmEnabled and isEnabled and currentTarget then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
        end
    end
end)

-- Skills (1,2,3,4)
task.spawn(function()
    local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
    while true do
        for _, key in ipairs(keys) do
            if autoFarmEnabled and isEnabled and currentTarget then
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                task.wait(1)
            else task.wait(0.5) break end
        end
    end
end)

-- === [ CORE FOLLOW LOOP ] ===
RunService.Heartbeat:Connect(function()
    if antiVoidEnabled and rootPart and rootPart.Position.Y < voidThreshold then
        rootPart.CFrame = CFrame.new(rootPart.Position.X, recoveryHeight, rootPart.Position.Z)
        rootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
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

-- === [ BUTTON LOGIC ] ===
farmBtn.MouseButton1Click:Connect(function()
    if not autoFarmEnabled then
        modeFrame.Visible = true -- ถามทุกครั้งที่เปิด
    else
        autoFarmEnabled = false
        farmMode = nil
        farmBtn.Text = "AUTO FARM: OFF"
        farmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)

pcBtn.MouseButton1Click:Connect(function()
    farmMode = "PC"
    autoFarmEnabled = true
    modeFrame.Visible = false
    farmBtn.Text = "AUTO FARM: PC"
    farmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
end)

mbBtn.MouseButton1Click:Connect(function()
    modeFrame.Visible = false
    tapSetup.Visible = true
    main.Visible = false -- ซ่อนเมนูหลักชั่วคราวเพื่อตั้งค่า
end)

saveTap.MouseButton1Click:Connect(function()
    mobileClickPos = Vector2.new(tapSetup.AbsolutePosition.X + (tapSetup.AbsoluteSize.X/2), tapSetup.AbsolutePosition.Y + (tapSetup.AbsoluteSize.Y/2))
    farmMode = "Mobile"
    autoFarmEnabled = true
    tapSetup.Visible = false
    main.Visible = true
    farmBtn.Text = "AUTO FARM: MOBILE"
    farmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
end)

followBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    updateCharCache()
    followBtn.Text = isEnabled and "FOLLOW: ACTIVE" or "FOLLOW: OFF"
    followBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
    humanoid.PlatformStand = isEnabled
end)

antiVoidBtn.MouseButton1Click:Connect(function()
    antiVoidEnabled = not antiVoidEnabled
    antiVoidBtn.Text = antiVoidEnabled and "ANTI-VOID: ON" or "ANTI-VOID: OFF"
end)

skipBtn.MouseButton1Click:Connect(function() currentTarget = getNearestPlayer(currentTarget) end)

player.CharacterAdded:Connect(function(char)
    character, rootPart, humanoid = char, char:WaitForChild("HumanoidRootPart"), char:WaitForChild("Humanoid")
    updateCharCache()
end)

print("Reaper Hub V9.1 Loaded")
