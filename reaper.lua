loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Libwtf/refs/heads/main/lib2.lua"))()

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Advanced/refs/heads/main/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--=========================
-- 🔥 WINDOW
--=========================
local Window = Fluent:CreateWindow({
Title = "Reaper Hub",
SubTitle = "Blox Fruits",
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
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}


-- Function Auto Farm
--=========================
-- 🔥 SETTINGS & VARIABLES (เพิ่มต่อจากบรรทัดแรกๆ)
--=========================
_G.AutoLevel = false
_G.BringMob = true
_G.FastAttack = true
_G.SelectWeapon = "Melee" -- ค่าเริ่มต้น

local NameQuest, QuestLv, Ms, CFrameQ, CFrameMon, NameMon
local bringmob = false

--=========================
-- 🛠 UTILITY FUNCTIONS
--=========================
local function Tween(Target)
    if not Target then return end
    local dist = (Target.Position - player.Character.HumanoidRootPart.Position).Magnitude
    local speed = 350
    local info = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(player.Character.HumanoidRootPart, info, {CFrame = Target})
    tween:Play()
end

local function Attack()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(851, 158))
end

--=========================
-- 📜 QUEST LOGIC (นำไปขยายต่อตาม List ของคุณ)
--=========================
function CheckLevel()
    local MyLevel = game:GetService("Players").LocalPlayer.Data.Level.Value
    if Sea1 then
        if MyLevel >= 0 and MyLevel <= 9 then
            NameQuest = "BanditQuest1" QuestLv = 1 Ms = "Bandit" NameMon = "Bandit"
            CFrameQ = CFrame.new(1059.37, 15.44, 1549.12)
            CFrameMon = CFrame.new(1038.55, 41.29, 1576.50)
        elseif MyLevel >= 10 and MyLevel <= 14 then
            NameQuest = "JungleQuest" QuestLv = 1 Ms = "Monkey" NameMon = "Monkey"
            CFrameQ = CFrame.new(-1598.46, 35.55, 153.30)
            CFrameMon = CFrame.new(-1448.14, 50.85, 63.60)
        elseif MyLevel >= 15 and MyLevel <= 29 then
            NameQuest = "JungleQuest" QuestLv = 2 Ms = "Gorilla" NameMon = "Gorilla"
            CFrameQ = CFrame.new(-1598.46, 35.55, 153.30)
            CFrameMon = CFrame.new(-1142.64, 40.46, -515.39)
        elseif MyLevel >= 30 and MyLevel <= 39 then
            NameQuest = "BuggyQuest1" QuestLv = 1 Ms = "Pirate" NameMon = "Pirate"
            CFrameQ = CFrame.new(-1141.07, 4.10, 3831.54)
            CFrameMon = CFrame.new(-1201.08, 40.62, 3857.59)
        elseif MyLevel >= 40 and MyLevel <= 59 then
            NameQuest = "BuggyQuest1" QuestLv = 2 Ms = "Brute" NameMon = "Brute"
            CFrameQ = CFrame.new(-1141.07, 4.10, 3831.54)
            CFrameMon = CFrame.new(-1387.53, 24.59, 4100.95)
        elseif MyLevel >= 60 and MyLevel <= 74 then
            NameQuest = "DesertQuest" QuestLv = 1 Ms = "Desert Bandit" NameMon = "Desert Bandit"
            CFrameQ = CFrame.new(894.48, 6.43, 4392.13)
            CFrameMon = CFrame.new(984.99, 16.10, 4417.91)
        elseif MyLevel >= 75 and MyLevel <= 89 then
            NameQuest = "DesertQuest" QuestLv = 2 Ms = "Desert Officer" NameMon = "Desert Officer"
            CFrameQ = CFrame.new(894.48, 6.43, 4392.13)
            CFrameMon = CFrame.new(1547.15, 14.45, 4381.80)
        elseif MyLevel >= 90 and MyLevel <= 99 then
            NameQuest = "SnowQuest" QuestLv = 1 Ms = "Snow Bandit" NameMon = "Snow Bandit"
            CFrameQ = CFrame.new(1389.74, 87.27, -1297.30)
            CFrameMon = CFrame.new(1356.30, 105.76, -1328.24)
        elseif MyLevel >= 100 and MyLevel <= 119 then
            NameQuest = "SnowQuest" QuestLv = 2 Ms = "Snowman" NameMon = "Snowman"
            CFrameQ = CFrame.new(1389.74, 87.27, -1297.30)
            CFrameMon = CFrame.new(1218.79, 138.01, -1488.02)
        elseif MyLevel >= 120 and MyLevel <= 149 then
            NameQuest = "MarineQuest2" QuestLv = 1 Ms = "Chief Petty Officer" NameMon = "Chief Petty Officer"
            CFrameQ = CFrame.new(-5039.58, 27.35, 4324.10)
            CFrameMon = CFrame.new(-4931.15, 65.79, 4121.83)
        elseif MyLevel >= 150 and MyLevel <= 174 then
            NameQuest = "SkyQuest" QuestLv = 1 Ms = "Sky Bandit" NameMon = "Sky Bandit"
            CFrameQ = CFrame.new(-4839.53, 716.34, -2622.38)
            CFrameMon = CFrame.new(-4955.64, 365.46, -2908.18)
        elseif MyLevel >= 175 and MyLevel <= 189 then
            NameQuest = "SkyQuest" QuestLv = 2 Ms = "Dark Master" NameMon = "Dark Master"
            CFrameQ = CFrame.new(-4839.53, 716.34, -2622.38)
            CFrameMon = CFrame.new(-5148.16, 439.04, -2332.96)
        elseif MyLevel >= 190 and MyLevel <= 209 then
            NameQuest = "PrisonerQuest" QuestLv = 1 Ms = "Prisoner" NameMon = "Prisoner"
            CFrameQ = CFrame.new(5307.83, 1.34, 474.06)
            CFrameMon = CFrame.new(4937.31, 0.33, 649.57)
        elseif MyLevel >= 210 and MyLevel <= 249 then
            NameQuest = "PrisonerQuest" QuestLv = 2 Ms = "Dangerous Prisoner" NameMon = "Dangerous Prisoner"
            CFrameQ = CFrame.new(5307.83, 1.34, 474.06)
            CFrameMon = CFrame.new(5099.66, 0.35, 1055.75)
        elseif MyLevel >= 250 and MyLevel <= 274 then
            NameQuest = "ColosseumQuest" QuestLv = 1 Ms = "Toga Warrior" NameMon = "Toga Warrior"
            CFrameQ = CFrame.new(-1580.44, 6.38, -2986.35)
            CFrameMon = CFrame.new(-1872.51, 49.08, -2913.81)
        elseif MyLevel >= 275 and MyLevel <= 299 then
            NameQuest = "ColosseumQuest" QuestLv = 2 Ms = "Gladiator" NameMon = "Gladiator"
            CFrameQ = CFrame.new(-1580.44, 6.38, -2986.35)
            CFrameMon = CFrame.new(-1521.37, 81.20, -3066.31)
        elseif MyLevel >= 300 and MyLevel <= 324 then
            NameQuest = "MagmaQuest" QuestLv = 1 Ms = "Military Soldier" NameMon = "Military Soldier"
            CFrameQ = CFrame.new(-5313.37, 10.97, 8515.15)
            CFrameMon = CFrame.new(-5369.00, 61.24, 8556.49)
        elseif MyLevel >= 325 and MyLevel <= 374 then
            NameQuest = "MagmaQuest" QuestLv = 2 Ms = "Military Spy" NameMon = "Military Spy"
            CFrameQ = CFrame.new(-5313.37, 10.97, 8515.15)
            CFrameMon = CFrame.new(-5787.00, 75.82, 8651.69)
        elseif MyLevel >= 375 and MyLevel <= 399 then
            NameQuest = "FishmanQuest" QuestLv = 1 Ms = "Fishman Warrior" NameMon = "Fishman Warrior"
            CFrameQ = CFrame.new(61122.65, 18.49, 1569.39)
            CFrameMon = CFrame.new(60844.10, 98.46, 1298.39)
        elseif MyLevel >= 400 and MyLevel <= 449 then
            NameQuest = "FishmanQuest" QuestLv = 2 Ms = "Fishman Commando" NameMon = "Fishman Commando"
            CFrameQ = CFrame.new(61122.65, 18.49, 1569.39)
            CFrameMon = CFrame.new(61738.39, 64.20, 1433.83)
        elseif MyLevel >= 450 and MyLevel <= 474 then
            NameQuest = "SkyExp1Quest" QuestLv = 1 Ms = "God's Guard" NameMon = "God's Guard"
            CFrameQ = CFrame.new(-4721.86, 845.30, -1953.84)
            CFrameMon = CFrame.new(-4628.04, 866.92, -1931.23)
        elseif MyLevel >= 475 and MyLevel <= 524 then
            NameQuest = "SkyExp1Quest" QuestLv = 2 Ms = "Shanda" NameMon = "Shanda"
            CFrameQ = CFrame.new(-7863.15, 5545.51, -378.42)
            CFrameMon = CFrame.new(-7685.14, 5601.07, -441.38)
        elseif MyLevel >= 525 and MyLevel <= 549 then
            NameQuest = "SkyExp2Quest" QuestLv = 1 Ms = "Royal Squad" NameMon = "Royal Squad"
            CFrameQ = CFrame.new(-7903.38, 5635.98, -1410.92)
            CFrameMon = CFrame.new(-7654.25, 5637.10, -1407.75)
        elseif MyLevel >= 550 and MyLevel <= 624 then
            NameQuest = "SkyExp2Quest" QuestLv = 2 Ms = "Royal Soldier" NameMon = "Royal Soldier"
            CFrameQ = CFrame.new(-7903.38, 5635.98, -1410.92)
            CFrameMon = CFrame.new(-7760.41, 5679.90, -1884.81)
        elseif MyLevel >= 625 and MyLevel <= 649 then
            NameQuest = "FountainQuest" QuestLv = 1 Ms = "Galley Pirate" NameMon = "Galley Pirate"
            CFrameQ = CFrame.new(5258.27, 38.52, 4050.04)
            CFrameMon = CFrame.new(5557.16, 152.32, 3998.77)
        elseif MyLevel >= 650 then
            NameQuest = "FountainQuest" QuestLv = 2 Ms = "Galley Captain" NameMon = "Galley Captain"
            CFrameQ = CFrame.new(5258.27, 38.52, 4050.04)
            CFrameMon = CFrame.new(5677.67, 92.78, 4966.63)
        end
    end
end


--=========================
-- 🖱 MAIN TAB UI (เพิ่มเข้าใน Tabs.Main)
--=========================
local ToggleFarm = Tabs.Main:AddToggle("AutoLevel", {Title = "Auto Farm", Default = false})
ToggleFarm:OnChanged(function(Value)
    _G.AutoLevel = Value
end)

local ToggleBring = Tabs.Main:AddToggle("BringMob", {Title = "Bring Mob", Default = true})
ToggleBring:OnChanged(function(Value)
    _G.BringMob = Value
end)

local WeaponDropdown = Tabs.Main:AddDropdown("Weapon", {
    Title = "Select Weapon",
    Values = {"Melee", "Sword", "Fruit"},
    Default = "Melee",
})
WeaponDropdown:OnChanged(function(Value)
    _G.SelectWeapon = Value
end)

--=========================
-- 🔄 CORE LOOPS
--=========================

-- Loop: Auto Quest & Tween
task.spawn(function()
    while task.wait() do
        if _G.AutoLevel then
            pcall(function()
                CheckLevel()
                local questVisible = player.PlayerGui.Main.Quest.Visible
                
                if not questVisible then
                    bringmob = false
                    Tween(CFrameQ)
                    if (CFrameQ.Position - player.Character.HumanoidRootPart.Position).Magnitude <= 10 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", NameQuest, QuestLv)
                    end
                else
                    bringmob = true
                    local enemy = workspace.Enemies:FindFirstChild(Ms) or workspace.Enemies:FindFirstChild(NameMon)
                    if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        -- ติดตั้งอาวุธ
                        for _, v in pairs(player.Backpack:GetChildren()) do
                            if v:IsA("Tool") and v.ToolTip == _G.SelectWeapon then
                                player.Character.Humanoid:EquipTool(v)
                            end
                        end
                        -- ล็อคตำแหน่งเหนือมอนสเตอร์
                        player.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0)
                        Attack()
                    else
                        Tween(CFrameMon) -- ไปจุดเกิดมอน
                    end
                end
            end)
        end
    end
end)

-- Loop: Bring Mob & Hitbox (ใช้ Heartbeat เพื่อความลื่นไหล)
RunService.Heartbeat:Connect(function()
    if _G.AutoLevel and _G.BringMob and bringmob then
        pcall(function()
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == Ms and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -12, 0)
                    v.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    sethiddenproperty(player, "SimulationRadius", math.huge)
                end
            end
        end)
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

SaveManager:LoadAutoloadConfig()

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
