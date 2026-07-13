-- [[ REAPER HUB V11 - STRICT INITIALIZATION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- === [ SETTINGS - ALL RESET TO FALSE ] ===
local isEnabled = false
local autoFarmEnabled = false
local antiVoidEnabled = true -- ปิดไว้ก่อน
local currentTarget = nil
local followDistance = 4
local voidThreshold = -450 
local recoveryHeight = 600
local charParts = {}
local farmMode = nil 
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
screenGui.Name = "ReaperV11_Strict"
screenGui.ResetOnSpawn = false

-- Toggle Logo
local toggleFrame = Instance.new("Frame", screenGui)
toggleFrame.Size = UDim2.new(0, 55, 0, 55)
toggleFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
toggleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", toggleFrame)
local tStroke = Instance.new("UIStroke", toggleFrame)
tStroke.Color = Color3.fromRGB(255, 0, 0)

local img = Instance.new("ImageButton", toggleFrame)
img.Size = UDim2.new(0.8, 0, 0.8, 0)
img.Position = UDim2.new(0.1, 0, 0.1, 0)
img.BackgroundTransparency = 1
img.Image = "rbxassetid://86279908104891"

-- Main Frame
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 200, 0, 280)
main.Position = UDim2.new(0.5, -100, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.Visible = true
Instance.new("UICorner", main)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(200, 0, 0)

makeDraggable(img, toggleFrame)
makeDraggable(main, main)
img.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

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
local followBtn = createBtn("FOLLOW: OFF", UDim2.new(0.05, 0, 0.28, 0), Color3.fromRGB(30, 30, 30))
local antiVoidBtn = createBtn("ANTI-VOID: OFF", UDim2.new(0.05, 0, 0.41, 0), Color3.fromRGB(30, 30, 30))
local skipBtn = createBtn("SKIP PLAYER", UDim2.new(0.05, 0, 0.54, 0), Color3.fromRGB(120, 0, 0))

-- Mode Selection
local modeFrame = Instance.new("Frame", screenGui)
modeFrame.Size = UDim2.new(0, 250, 0, 150)
modeFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
modeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
modeFrame.Visible = false
Instance.new("UICorner", modeFrame)
local pcBtn = createBtn("PC MODE (M1)", UDim2.new(0.05, 0, 0.3, 0), Color3.fromRGB(50, 50, 50), modeFrame)
local mbBtn = createBtn("MOBILE MODE (TAP)", UDim2.new(0.05, 0, 0.65, 0), Color3.fromRGB(50, 50, 50), modeFrame)

-- Mobile Tap Setup
local tapSetup = Instance.new("Frame", screenGui)
tapSetup.Size = UDim2.new(0, 60, 0, 60)
tapSetup.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
tapSetup.BackgroundTransparency = 0.5
tapSetup.Visible = false
Instance.new("UICorner", tapSetup).CornerRadius = UDim.new(1, 0)
makeDraggable(tapSetup, tapSetup)
local saveTap = createBtn("SAVE POS", UDim2.new(0, 100, 0, 30), UDim2.new(0.5, -50, 1.2, 0), Color3.fromRGB(0, 150, 0), tapSetup)

-- === [ LOOPS ] ===

-- Click Loop (Hybrid)
task.spawn(function()
    while true do
        task.wait(0.05)
        -- เช็คเงื่อนไขอย่างเข้มงวด: ต้องเปิดฟาร์ม + เปิดติดตาม + มีเป้าหมาย และเมนูต้องปิดอยู่
        if autoFarmEnabled and isEnabled and currentTarget and farmMode and not main.Visible and not modeFrame.Visible then
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

-- Skill & G Loop
task.spawn(function()
    local lastG = tick()
    while true do
        task.wait(0.1)
        if autoFarmEnabled and isEnabled and currentTarget and not main.Visible then
            -- Skills 1-4
            local skills = {"One", "Two", "Three", "Four"}
            for _, k in ipairs(skills) do
                if not autoFarmEnabled then break end
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[k], false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[k], false, game)
                task.wait(1)
            end
            -- G (15s)
            if tick() - lastG >= 15 then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                lastG = tick()
            end
        end
    end
end)

-- Core Follow & Anti-Void
RunService.Heartbeat:Connect(function()
    if isEnabled and rootPart then
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
    
    if antiVoidEnabled and rootPart and rootPart.Position.Y < voidThreshold then
        rootPart.CFrame = CFrame.new(rootPart.Position.X, recoveryHeight, rootPart.Position.Z)
        rootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
end)

-- === [ EVENTS ] ===
farmBtn.MouseButton1Click:Connect(function()
    if not autoFarmEnabled then 
        modeFrame.Visible = true 
    else
        autoFarmEnabled = false
        farmMode = nil
        farmBtn.Text = "AUTO FARM: OFF"
        farmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)

pcBtn.MouseButton1Click:Connect(function()
    farmMode = "PC"; autoFarmEnabled = true; modeFrame.Visible = false
    farmBtn.Text = "AUTO FARM: PC"; farmBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
end)

mbBtn.MouseButton1Click:Connect(function()
    modeFrame.Visible = false; tapSetup.Visible = true; main.Visible = false
end)

saveTap.MouseButton1Click:Connect(function()
    mobileClickPos = Vector2.new(tapSetup.AbsolutePosition.X + 30, tapSetup.AbsolutePosition.Y + 30)
    farmMode = "Mobile"; autoFarmEnabled = true; tapSetup.Visible = false; main.Visible = true
    farmBtn.Text = "AUTO FARM: MOBILE"; farmBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
end)

followBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled; updateCharCache()
    followBtn.Text = isEnabled and "FOLLOW: ON" or "FOLLOW: OFF"
    followBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
    humanoid.PlatformStand = isEnabled
end)

antiVoidBtn.MouseButton1Click:Connect(function()
    antiVoidEnabled = not antiVoidEnabled
    antiVoidBtn.Text = antiVoidEnabled and "ANTI-VOID: ON" or "ANTI-VOID: OFF"
    antiVoidBtn.BackgroundColor3 = antiVoidEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
end)

skipBtn.MouseButton1Click:Connect(function() currentTarget = getNearestPlayer(currentTarget) end)

player.CharacterAdded:Connect(function(char)
    character, rootPart, humanoid = char, char:WaitForChild("HumanoidRootPart"), char:WaitForChild("Humanoid")
    updateCharCache()
end)

print("Reaper V11 Loaded - Strict Mode")
