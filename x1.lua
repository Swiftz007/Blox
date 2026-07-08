local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local isEnabled = false
local currentTarget = nil
local followConnection = nil

-- === [ SYSTEM FUNCTIONS ] ===

local function getNearestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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

local function stopFollowing()
    if followConnection then followConnection:Disconnect() followConnection = nil end
    if humanoid then humanoid.PlatformStand = false end
    currentTarget = nil
end

local function startFollowing()
    stopFollowing()
    if humanoid then humanoid.PlatformStand = true end

    followConnection = RunService.RenderStepped:Connect(function()
        if not isEnabled then stopFollowing() return end

        -- ตรวจสอบความถูกต้องของเป้าหมาย (ต้องไม่ตาย, ไม่หลุด)
        local valid = currentTarget and currentTarget.Parent and currentTarget.Character and 
                      currentTarget.Character:FindFirstChild("HumanoidRootPart") and 
                      currentTarget.Character:FindFirstChild("Humanoid") and 
                      currentTarget.Character.Humanoid.Health > 0

        if not valid then
            currentTarget = getNearestPlayer()
            return
        end

        local targetRoot = currentTarget.Character.HumanoidRootPart
        
        -- แก้ปัญหาตัวสั่น/วาร์ป: ล้างแรงฟิสิกส์ทิ้งทุกเฟรม
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        
        -- คำนวณ CFrame ติดหลัง (1.8 studs)
        local goalCFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.8)
        
        -- ใช้ Lerp 0.3 เพื่อความติดหนึบและสมูท (ปรับค่านี้ได้ 0.1 - 1.0)
        rootPart.CFrame = rootPart.CFrame:Lerp(goalCFrame, 0.3)
    end)
end

-- === [ MODERN REAPER GUI ] ===

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ReaperV4_Final"
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 200, 0, 120)
main.Position = UDim2.new(0.5, -100, 0.8, -150)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(180, 0, 0)
stroke.Thickness = 2

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "REAPER ASSISTANT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 32)
toggleBtn.Position = UDim2.new(0.05, 0, 0.32, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggleBtn.Text = "STATUS: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
toggleBtn.Font = Enum.Font.GothamMedium
toggleBtn.TextSize = 12
Instance.new("UICorner", toggleBtn)

local skipBtn = Instance.new("TextButton", main)
skipBtn.Size = UDim2.new(0.9, 0, 0, 32)
skipBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
skipBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
skipBtn.Text = "SKIP PLAYER"
skipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skipBtn.Font = Enum.Font.GothamMedium
skipBtn.TextSize = 12
Instance.new("UICorner", skipBtn)

-- === [ INTERACTION & DRAGGABLE ] ===

toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    toggleBtn.Text = isEnabled and "STATUS: ACTIVE" or "STATUS: OFF"
    toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(25, 25, 25)
    if isEnabled then startFollowing() else stopFollowing() end
end)

skipBtn.MouseButton1Click:Connect(function() currentTarget = nil end)

-- Smooth Draggable UI Logic
local dragStart, startPos, dragging
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Re-setup on Respawn
player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    if isEnabled then task.wait(0.1) startFollowing() end
end)
