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
local followDistance = 2.5 

-- === [ CORE FUNCTIONS ] ===

local function getNearestPlayer(exclude)
    local closestPlayer = nil
    local shortestDistance = math.huge
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

local function startFollowing()
    if followConnection then followConnection:Disconnect() end
    if humanoid then humanoid.PlatformStand = true end

    followConnection = RunService.Heartbeat:Connect(function()
        if not isEnabled then 
            if followConnection then followConnection:Disconnect() followConnection = nil end
            if humanoid then humanoid.PlatformStand = false end
            return 
        end

        if not currentTarget or not currentTarget.Parent or not currentTarget.Character or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getNearestPlayer()
            return
        end

        local targetRoot = currentTarget.Character.HumanoidRootPart
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        
        local goalCFrame = targetRoot.CFrame * CFrame.new(0, 0, followDistance)
        rootPart.CFrame = rootPart.CFrame:Lerp(goalCFrame, 0.25)
    end)
end

-- === [ UI CREATION ] ===

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ReaperV6_Fix"
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 200, 0, 180)
main.Position = UDim2.new(0.5, -100, 0.5, -90)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BorderSizePixel = 0
main.Active = true 
main.Selectable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 2

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "REAPER ASSISTANT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 32)
toggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.Text = "STATUS: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamMedium
Instance.new("UICorner", toggleBtn)

local skipBtn = Instance.new("TextButton", main)
skipBtn.Size = UDim2.new(0.9, 0, 0, 32)
skipBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
skipBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
skipBtn.Text = "SKIP PLAYER"
skipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skipBtn.Font = Enum.Font.GothamMedium
Instance.new("UICorner", skipBtn)

local distInput = Instance.new("TextBox", main)
distInput.Size = UDim2.new(0.4, 0, 0, 25)
distInput.Position = UDim2.new(0.55, 0, 0.7, 0)
distInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
distInput.Text = tostring(followDistance)
distInput.TextColor3 = Color3.fromRGB(255, 255, 255)
distInput.Font = Enum.Font.GothamMedium
Instance.new("UICorner", distInput)

local distLabel = Instance.new("TextLabel", main)
distLabel.Size = UDim2.new(0.45, 0, 0, 25)
distLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
distLabel.Text = "Distance:"
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.BackgroundTransparency = 1
distLabel.Font = Enum.Font.Gotham
distLabel.TextXAlignment = Enum.TextXAlignment.Left

-- === [ FIX DRAGGABLE LOGIC ] ===

local dragStart, startPos, dragging
local function updateDrag(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

-- === [ INTERACTION ] ===

toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    toggleBtn.Text = isEnabled and "STATUS: ACTIVE" or "STATUS: OFF"
    toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
    if isEnabled then startFollowing() end
end)

skipBtn.MouseButton1Click:Connect(function()
    local old = currentTarget
    currentTarget = getNearestPlayer(old)
end)

distInput.FocusLost:Connect(function(enter)
    local n = tonumber(distInput.Text)
    if n then followDistance = n else distInput.Text = tostring(followDistance) end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    if isEnabled then task.wait(0.2) startFollowing() end
end)
