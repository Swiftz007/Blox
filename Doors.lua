local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Advanced/refs/heads/main/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--=========================
-- 🔥 WINDOW
--=========================
local Window = Fluent:CreateWindow({
Title = "Reaper Hub",
SubTitle = "Doors Beta", -- 3
TabWidth = 160,
Size = UDim2.fromOffset(520, 360),
Theme = "Reaper",
MinimizeKey = Enum.KeyCode.RightControl
})
-- Left icon ui
-- =========================
-- WAIT GUI
-- =========================
task.wait(0.3)

local GUI = Fluent.GUI
if not GUI then
    return warn("Fluent GUI not found")
end

-- =========================
-- FIND TITLE
-- =========================
local Title

for i = 1, 30 do
    for _, v in pairs(GUI:GetDescendants()) do
        if v:IsA("TextLabel") and string.find(string.lower(v.Text), "reaper") then
            Title = v
            break
        end
    end
    if Title then break end
    task.wait(0.1)
end

if not Title then
    return warn("Title not found")
end

-- =========================
-- GET TOPBAR
-- =========================
local TopBar = Title.Parent
if not TopBar then
    return warn("TopBar not found")
end

-- =========================
-- FIX LAYOUT (สำคัญ)
-- =========================
local Layout
for _, v in pairs(TopBar:GetChildren()) do
    if v:IsA("UIListLayout") then
        Layout = v
        break
    end
end

if Layout then
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0, 6)
end

-- =========================
-- CREATE LOGO (เข้า Layout)
-- =========================
local Logo = Instance.new("ImageLabel")
Logo.Name = "ReaperLogo"
Logo.Parent = TopBar

Logo.Image = "rbxassetid://131279093559313"
Logo.BackgroundTransparency = 1
Logo.Size = UDim2.new(0, 30, 0, 30) -- ปรับให้บาลานซ์กับฟอนต์
Logo.ScaleType = Enum.ScaleType.Fit

-- ให้อยู่ซ้ายสุด
Logo.LayoutOrder = -1

-- =========================
-- ALIGN CENTER (ละเอียด)
-- =========================
Logo.AnchorPoint = Vector2.new(0, 0.5)
Logo.Position = UDim2.new(0, 0, 0.5, 1) -- +1 ช่วยแก้ baseline ฟอนต์

-- =========================
-- OPTIONAL STYLE
-- =========================
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 0
Stroke.Transparency = 1
Stroke.Parent = Logo

-- Tab
local Tabs = {
Main = Window:AddTab({ Title = "Main", Icon = "home" }),
Player = Window:AddTab({ Title = "Player", Icon = "user" }),
ESP = Window:AddTab({ Title = "ESP", Icon = "box" }),
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}


-- Full Function Here
--=========================
-- 🛠 CONFIGURATION & STATE
--=========================
local Config = {
    Speed = 22,
    SpeedEnabled = false,
    AutoHide = false,
    AutoLoot = false,
    AutoUnlock = false,
    Fullbright = false,
    ESP = { Doors = false, Items = false, Entities = false }
}

local lp = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- ฟังก์ชันแจ้งเตือน (ใช้ Fluent Notify)
local function Notify(title, content)
    Fluent:Notify({
        Title = title,
        Content = content,
        Duration = 5
    })
end

-- ฟังก์ชันเรียกใช้ ProximityPrompt แบบ Bypass ระยะ
local function SafePrompt(v)
    if v and v:IsA("ProximityPrompt") then
        task.spawn(function()
            fireproximityprompt(v)
        end)
    end
end

--=========================
-- 🛡️ CORE LOGIC (FIXED & BYPASS)
--=========================

-- 1. SMART LOOP (Auto Loot & Auto Unlock) - แก้ไขระยะและการทำงาน
task.spawn(function()
    while task.wait(0.2) do
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = lp.Character.HumanoidRootPart
        local hasKey = lp.Character:FindFirstChild("Key") or lp.Backpack:FindFirstChild("Key")

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local p = v.Parent
                if p then
                    local dist = (hrp.Position - (p:IsA("Model") and p:GetPivot().Position or p.Position)).Magnitude
                    
                    -- [FIX] Auto Unlock: ระยะ 15 studs (ก่อนถึงตัว)
                    if Config.AutoUnlock and hasKey and (v.ActionText == "Unlock" or v.ObjectText == "Locked Door" or p.Name == "Lock") then
                        if dist < 15 then SafePrompt(v) end
                    
                    -- [FIX] Auto Loot: เจาะจง Item มากขึ้น
                    elseif Config.AutoLoot then
                        if v.ObjectText == "Gold" or v.ObjectText == "Key" or p.Name == "KeyObtain" or p.Name == "LiveHintBook" or p:FindFirstChild("GoldPile") then
                            if dist < 18 then SafePrompt(v) end
                        end
                    end
                end
            end
        end
    end
end)

-- 2. AUTO HIDE (FIXED: ANCHOR & NOTIFY)
local isHiding = false
workspace.ChildAdded:Connect(function(child)
    local entities = {"RushMoving", "AmbushMoving", "A60", "A120"}
    local isEntity = false
    for _, name in pairs(entities) do
        if child.Name:find(name) then isEntity = true break end
    end

    if isEntity then
        Notify("ENTITY DETECTED!", "Monster: " .. child.Name .. " is coming!")
        
        if Config.AutoHide then
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp and not isHiding then
                isHiding = true
                local oldCF = hrp.CFrame
                
                -- มุดดินและล็อคตัว (Anchor) กัน Glitch
                hrp.CFrame = oldCF * CFrame.new(0, -7, 0)
                task.wait(0.1)
                hrp.Anchored = true 
                
                child.Destroying:Wait()
                
                -- ปลดล็อคและกลับที่เดิม
                hrp.Anchored = false
                hrp.CFrame = oldCF
                isHiding = false
                Notify("SAFE", "The entity is gone.")
            end
        end
    end
end)

-- 3. ESP SYSTEM (OPTIMIZED)
local function ApplyESP(obj, name, color)
    if obj:FindFirstChild("ReaperESP") then return end
    local bgui = Instance.new("BillboardGui", obj)
    bgui.Name = "ReaperESP"; bgui.AlwaysOnTop = true; bgui.Size = UDim2.new(0, 80, 0, 40)
    local tl = Instance.new("TextLabel", bgui)
    tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = name; tl.TextColor3 = color; tl.TextScaled = true; tl.Font = Enum.Font.SourceSansBold
end

task.spawn(function()
    while task.wait(1.5) do
        if not (Config.ESP.Doors or Config.ESP.Items or Config.ESP.Entities) then
            for _, v in pairs(workspace:GetDescendants()) do if v.Name == "ReaperESP" then v:Destroy() end end
            continue
        end
        for _, v in pairs(workspace:GetDescendants()) do
            if Config.ESP.Doors and v.Name == "Door" and v:IsA("Model") then ApplyESP(v, "DOOR", Color3.new(0,1,0))
            elseif Config.ESP.Items and (v.Name == "KeyObtain" or v.Name == "LiveHintBook") then ApplyESP(v, "KEY/BOOK", Color3.new(1,1,0))
            elseif Config.ESP.Entities and (v.Name == "RushMoving" or v.Name == "AmbushMoving" or v.Name == "Figure" or v.Name == "Seek") then ApplyESP(v, "ENTITY", Color3.new(1,0,0)) end
        end
    end
end)

--=========================
-- 🏠 CONNECT TO UI TABS
--=========================

Tabs.Main:AddToggle("AutoHide", {Title = "Auto-Hide (Anchor Mode)", Default = false}):OnChanged(function(v) Config.AutoHide = v end)
Tabs.Main:AddToggle("AutoLoot", {Title = "Auto Loot (Fixed)", Default = false}):OnChanged(function(v) Config.AutoLoot = v end)
Tabs.Main:AddToggle("AutoUnlock", {Title = "Auto Unlock (Near)", Default = false}):OnChanged(function(v) Config.AutoUnlock = v end)

Tabs.Player:AddToggle("SpeedToggle", {Title = "Enable Speed Bypass", Default = false}):OnChanged(function(v) Config.SpeedEnabled = v end)
Tabs.Player:AddSlider("SpeedSlider", {Title = "WalkSpeed", Default = 22, Min = 16, Max = 45, Rounding = 1, Callback = function(v) Config.Speed = v end})
Tabs.Player:AddToggle("Fullbright", {Title = "Fullbright (No Fog)", Default = false}):OnChanged(function(v) Config.Fullbright = v end)

Tabs.ESP:AddToggle("ED", {Title = "Show Doors", Default = false}):OnChanged(function(v) Config.ESP.Doors = v end)
Tabs.ESP:AddToggle("EI", {Title = "Show Items", Default = false}):OnChanged(function(v) Config.ESP.Items = v end)
Tabs.ESP:AddToggle("EE", {Title = "Show Entities", Default = false}):OnChanged(function(v) Config.ESP.Entities = v end)

-- [BYPASS] RUNTIME LOOP
RunService.RenderStepped:Connect(function()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        if Config.SpeedEnabled then
            -- Bypass แบบต่อเนื่องเพื่อลดอาการวาร์ป
            lp.Character.Humanoid.WalkSpeed = Config.Speed
        else
            -- Reset ความเร็วเมื่อปิด
            if lp.Character.Humanoid.WalkSpeed ~= 16 then
                lp.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
    
    if Config.Fullbright then 
         Lighting.Brightness = 2; Lighting.FogEnd = 9e9; Lighting.GlobalShadows = false 
    end
end)




--=========================
-- ⚙ SETTINGS TAB
--=========================

InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("ReaperHub")
SaveManager:SetFolder("ReaperHub/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig() -- 🔥 ตัวนี้แหละ

Window:SelectTab(1)
--=========================
-- TOGGLE BUTTON + PURE BLUR
--=========================
if game.CoreGui:FindFirstChild("ToggleUI") then
    game.CoreGui.ToggleUI:Destroy()
end

pcall(function()
    game:GetService("Lighting"):FindFirstChild("MenuBlur"):Destroy()
end)

--=========================
-- SERVICES
--=========================
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

--=========================
-- BLUR
--=========================
local Blur = Instance.new("BlurEffect")
Blur.Name = "MenuBlur"
Blur.Size = 40
Blur.Parent = Lighting

--=========================
-- GUI
--=========================
local gui = Instance.new("ScreenGui")
gui.Name = "ToggleUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = game.CoreGui

--=========================
-- BORDER
--=========================
local border = Instance.new("Frame")
border.Parent = gui
border.Size = UDim2.new(0,0,0,0)
border.BackgroundColor3 = Color3.fromRGB(0,0,0)
border.ZIndex = 1
border.AnchorPoint = Vector2.new(0,0)

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0,14)
borderCorner.Parent = border

--=========================
-- BUTTON
--=========================
local button = Instance.new("ImageButton")
button.Parent = gui
button.Size = UDim2.new(0,60,0,60)
button.Position = UDim2.new(0,20,0.5,0)
button.AnchorPoint = Vector2.new(0,0)

button.BackgroundTransparency = 1
button.ZIndex = 999999
button.AutoButtonColor = false

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = button

--=========================
-- IMAGE
--=========================
local imgOn = "rbxassetid://86279908104891"
local imgOff = "rbxassetid://86279908104891"

button.Image = imgOn
button.ScaleType = Enum.ScaleType.Fit

--=========================
-- AUTO ALIGN
--=========================
local function UpdateBorder()

    local offset = (border.Size.X.Offset - button.Size.X.Offset) / 2

    border.Position = UDim2.new(
        button.Position.X.Scale,
        button.Position.X.Offset - offset,
        button.Position.Y.Scale,
        button.Position.Y.Offset - offset
    )
end

UpdateBorder()

--=========================
-- DRAG SYSTEM
--=========================
local dragging = false
local dragStart, startPos

button.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = button.Position
    end
end)

UIS.InputChanged:Connect(function(input)

    if dragging then

        local delta = input.Position - dragStart

        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

        UpdateBorder()
    end
end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

--=========================
-- BLUR FUNCTIONS
--=========================
local function OpenBlur()

    TweenService:Create(
        Blur,
        TweenInfo.new(
            0.3,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size = 40
        }
    ):Play()
end

local function CloseBlur()

    TweenService:Create(
        Blur,
        TweenInfo.new(
            0.25,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size = 0
        }
    ):Play()
end

--=========================
-- TOGGLE
--=========================
local isOpen = true

button.MouseButton1Click:Connect(function()

    isOpen = not isOpen

    if Window then
        Window:Minimize(not isOpen)
    end

    button.Image = isOpen and imgOn or imgOff

    -- BLUR
    if isOpen then
        OpenBlur()
    else
        CloseBlur()
    end
end)
