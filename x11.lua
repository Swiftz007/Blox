local Load = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Libwtf/refs/heads/main/LoadLib.lua"))()
--1
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
local noclipConnection = nil
local followDistance = 3 
local charParts = {} -- Cached Table สำหรับ Noclip

-- === [ UTILITY FUNCTIONS ] ===

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

-- === [ CORE SYSTEM: START/STOP RESET ] ===

local function stopFollowing()
    -- 1. ตัดการเชื่อมต่อ Loop ทั้งหมด
    if followConnection then followConnection:Disconnect() followConnection = nil end
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    
    -- 2. คืนค่าฟิสิกส์ตัวละครให้กลับเป็นปกติ
    if humanoid then 
        humanoid.PlatformStand = false 
    end
    
    -- 3. คืนค่าการชนกัน (ปิด Noclip)
    for i = 1, #charParts do
        if charParts[i] then charParts[i].CanCollide = true end
    end

    -- 4. ล้างค่าแรงเหวี่ยงทิ้ง (กันตัวพุ่ง/กัน Fling ค้าง)
    if rootPart then
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

local function startFollowing()
    stopFollowing() -- Clean ตัวเองก่อนเริ่มใหม่
    if humanoid then humanoid.PlatformStand = true end
    updateCharCache()

    -- Noclip Loop (Stepped: ปิด Collision ก่อนฟิสิกส์คำนวณ)
    noclipConnection = RunService.Stepped:Connect(function()
        if not isEnabled then return end
        for i = 1, #charParts do
            if charParts[i] then charParts[i].CanCollide = false end
        end
    end)

    -- Movement Loop (Heartbeat: จัดการตำแหน่งและ Velocity)
    followConnection = RunService.Heartbeat:Connect(function()
        if not isEnabled then stopFollowing() return end

        if not currentTarget or not currentTarget.Parent or not currentTarget.Character or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getNearestPlayer()
            return
        end

        local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and character then
            -- [ COMBAT SYNC: LEVEL HEIGHT ]
            -- ย้ายตำแหน่งระดับ Y = 0 (ระดับเดียวกันเป๊ะตามที่ต้องการ)
            character:PivotTo(targetRoot.CFrame * CFrame.new(0, 0, followDistance))

            -- [ ANTI-FLING SYNC ]
            rootPart.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity
            rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0) -- ล็อคแรงหมุนป้องกันตัวดีด
        end
    end)
end

-- === [ GUI SETUP ] ===

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "Reaper_V2"
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 200, 0, 185)
main.Position = UDim2.new(0.5, -100, 0.5, -92)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel = 0
main.Active = true 
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(200, 0, 0)
stroke.Thickness = 2

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "Reaper Hub V3"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 32)
toggleBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamMedium
Instance.new("UICorner", toggleBtn)

local skipBtn = Instance.new("TextButton", main)
skipBtn.Size = UDim2.new(0.9, 0, 0, 32)
skipBtn.Position = UDim2.new(0.05, 0, 0.42, 0)
skipBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
skipBtn.Text = "SKIP PLAYER"
skipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skipBtn.Font = Enum.Font.GothamMedium
Instance.new("UICorner", skipBtn)

local distLabel = Instance.new("TextLabel", main)
distLabel.Size = UDim2.new(0.45, 0, 0, 30)
distLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
distLabel.Text = "Distance:"
distLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
distLabel.BackgroundTransparency = 1
distLabel.Font = Enum.Font.Gotham
distLabel.TextXAlignment = Enum.TextXAlignment.Left

local distInput = Instance.new("TextBox", main)
distInput.Size = UDim2.new(0.4, 0, 0, 25)
distInput.Position = UDim2.new(0.55, 0, 0.67, 0)
distInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
distInput.Text = tostring(followDistance)
distInput.TextColor3 = Color3.fromRGB(255, 255, 255)
distInput.Font = Enum.Font.GothamMedium
Instance.new("UICorner", distInput)

-- === [ INTERACTION & RESET ] ===

toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    toggleBtn.Text = isEnabled and "ACTIVE" or "OFF"
    toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
    
    if isEnabled then 
        startFollowing() 
    else 
        stopFollowing() 
    end
end)

skipBtn.MouseButton1Click:Connect(function()
    currentTarget = getNearestPlayer(currentTarget)
end)

distInput.FocusLost:Connect(function()
    local n = tonumber(distInput.Text)
    if n then followDistance = n else distInput.Text = tostring(followDistance) end
end)

player.CharacterAdded:Connect(function(char)
    character, rootPart, humanoid = char, char:WaitForChild("HumanoidRootPart"), char:WaitForChild("Humanoid")
    updateCharCache()
    if isEnabled then task.wait(0.1) startFollowing() end
end)

-- Draggable Engine
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, input.Position, frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
end
makeDraggable(main)

print("Credit : Reaper Hub")
print("Credit : x2sxqz_")

-- Load Success 
task.wait(0.5)
print("Reaper Hub Loaded")
