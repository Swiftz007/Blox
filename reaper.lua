loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Libwtf/refs/heads/main/lib2.lua"))()

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Advanced/refs/heads/main/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--=========================
-- 🛠 REQUIRED GLOBAL VARIABLES (เพิ่มไว้บนสุด)
--=========================
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Sea1 = game.PlaceId == 2753915549
local Sea2 = game.PlaceId == 4442272160
local Sea3 = game.PlaceId == 7449423635 

-- ระบบป้องกันการถูกเตะ (Anti-AFK)
player.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)


--=========================
-- 🔥 WINDOW
--=========================
local Window = Fluent:CreateWindow({
Title = "Reaper Hub",
SubTitle = "Blox Fruits",   --6
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


local Tabs = {
Main = Window:AddTab({ Title = "Main", Icon = "home" }),
Stats = Window:AddTab({ Title = "Stats", Icon = "signal" }), -- เพิ่มอันนี้
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

--=========================
-- 📊 STATS TAB UI
--=========================
local StatList = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}
local SelectStat = Tabs.Stats:AddDropdown("SelectStat", {
    Title = "Select Stat to Upgrade",
    Values = StatList,
    Default = "Melee",
})

_G.SelectStat = "Melee" -- ตั้งค่าเริ่มต้น
SelectStat:OnChanged(function(Value)
    _G.SelectStat = Value
end)

_G.AutoStats = false
local ToggleStats = Tabs.Stats:AddToggle("AutoStats", {Title = "Auto Upgrade Stats", Default = false})
ToggleStats:OnChanged(function(Value)
    _G.AutoStats = Value
end)

--=========================
-- 🔄 AUTO STATS LOOP
--=========================
task.spawn(function()
    while task.wait(0.5) do -- เช็คทุกๆ 0.5 วินาที
        if _G.AutoStats then
            pcall(function()
                -- เช็คว่ามีแต้มเหลือไหม
                local points = player.Data.StatsPoints.Value
                if points > 0 then
                    -- ส่งคำสั่งไปที่ Server เพื่ออัพแต้ม (ครั้งละ 1 แต้ม)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", _G.SelectStat, 1)
                end
            end)
        end
    end
end)


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
    pcall(function()
        -- ส่ง Signal ไปที่ Server เพื่อเพิ่มความเร็วในการตี
        game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(math.random(1,100))
        
        -- ใช้ Button1Down แทน Click เพื่อความต่อเนื่อง
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(851, 158))
    end)
end


--=========================
-- 📜 QUEST LOGIC (นำไปขยายต่อตาม List ของคุณ)
--=========================
function CheckLevel()
    local MyLevel = player.Data.Level.Value
    if Sea1 then
        if MyLevel >= 0 and MyLevel <= 9 then
            NameQuest = "BanditQuest1" QuestLv = 1 Ms = "Bandit" NameMon = "Bandit"
            CFrameQ = CFrame.new(1059.37, 15.44, 1549.12)
            CFrameMon = CFrame.new(1038.55, 41.29, 1576.50)
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
        elseif Sea2 then
        if MyLevel >= 700 and MyLevel <= 724 then
            NameQuest = "Area1Quest" QuestLv = 1 Ms = "Raider" NameMon = "Raider"
            CFrameQ = CFrame.new(-424.12, 7.32, 1836.15)
            CFrameMon = CFrame.new(-423.83, 137.76, 1737.52)
        elseif MyLevel >= 725 and MyLevel <= 774 then
            NameQuest = "Area1Quest" QuestLv = 2 Ms = "Mercenary" NameMon = "Mercenary"
            CFrameQ = CFrame.new(-424.12, 7.32, 1836.15)
            CFrameMon = CFrame.new(-624.71, 73.19, 1551.92)
        elseif MyLevel >= 775 and MyLevel <= 799 then
            NameQuest = "Area2Quest" QuestLv = 1 Ms = "Swan Pirate" NameMon = "Swan Pirate"
            CFrameQ = CFrame.new(638.43, 73.19, 918.28)
            CFrameMon = CFrame.new(874.53, 121.31, 1287.12)
        elseif MyLevel >= 800 and MyLevel <= 874 then
            NameQuest = "Area2Quest" QuestLv = 2 Ms = "Factory Staff" NameMon = "Factory Staff"
            CFrameQ = CFrame.new(638.43, 73.19, 918.28)
            CFrameMon = CFrame.new(295.53, 73.19, -56.12)
        elseif MyLevel >= 875 and MyLevel <= 899 then
            NameQuest = "MarineQuest3" QuestLv = 1 Ms = "Marine Lieutenant" NameMon = "Marine Lieutenant"
            CFrameQ = CFrame.new(-2440.80, 73.11, -3221.03)
            CFrameMon = CFrame.new(-2835.65, 73.11, -3014.23)
        elseif MyLevel >= 900 and MyLevel <= 949 then
            NameQuest = "MarineQuest3" QuestLv = 2 Ms = "Marine Captain" NameMon = "Marine Captain"
            CFrameQ = CFrame.new(-2440.80, 73.11, -3221.03)
            CFrameMon = CFrame.new(-1870.04, 73.11, -3320.12)
        elseif MyLevel >= 950 and MyLevel <= 974 then
            NameQuest = "ZombieQuest" QuestLv = 1 Ms = "Zombie" NameMon = "Zombie"
            CFrameQ = CFrame.new(-5492.42, 48.51, -794.67)
            CFrameMon = CFrame.new(-5720.52, 12.63, -727.12)
        elseif MyLevel >= 975 and MyLevel <= 999 then
            NameQuest = "ZombieQuest" QuestLv = 2 Ms = "Vampire" NameMon = "Vampire"
            CFrameQ = CFrame.new(-5492.42, 48.51, -794.67)
            CFrameMon = CFrame.new(-6031.54, 6.38, -1316.53)
        elseif MyLevel >= 1000 and MyLevel <= 1049 then
            NameQuest = "SnowMountainQuest" QuestLv = 1 Ms = "Snow Trooper" NameMon = "Snow Trooper"
            CFrameQ = CFrame.new(609.11, 401.55, -5371.43)
            CFrameMon = CFrame.new(475.22, 401.55, -5290.41)
        elseif MyLevel >= 1050 and MyLevel <= 1099 then
            NameQuest = "SnowMountainQuest" QuestLv = 2 Ms = "Winter Warrior" NameMon = "Winter Warrior"
            CFrameQ = CFrame.new(609.11, 401.55, -5371.43)
            CFrameMon = CFrame.new(1151.04, 430.22, -5134.42)
        elseif MyLevel >= 1100 and MyLevel <= 1124 then
            NameQuest = "IceSideQuest" QuestLv = 1 Ms = "Lab Subordinate" NameMon = "Lab Subordinate"
            CFrameQ = CFrame.new(-6061.64, 15.68, -4904.72)
            CFrameMon = CFrame.new(-5793.12, 15.68, -4836.42)
        elseif MyLevel >= 1125 and MyLevel <= 1174 then
            NameQuest = "IceSideQuest" QuestLv = 2 Ms = "Horned Warrior" NameMon = "Horned Warrior"
            CFrameQ = CFrame.new(-6061.64, 15.68, -4904.72)
            CFrameMon = CFrame.new(-6423.42, 24.32, -5812.53)
        elseif MyLevel >= 1175 and MyLevel <= 1199 then
            NameQuest = "FireSideQuest" QuestLv = 1 Ms = "Magma Ninja" NameMon = "Magma Ninja"
            CFrameQ = CFrame.new(-5431.11, 15.68, -5296.22)
            CFrameMon = CFrame.new(-5395.23, 78.43, -5841.04)
        elseif MyLevel >= 1200 and MyLevel <= 1249 then
            NameQuest = "FireSideQuest" QuestLv = 2 Ms = "Lava Pirate" NameMon = "Lava Pirate"
            CFrameQ = CFrame.new(-5431.11, 15.68, -5296.22)
            CFrameMon = CFrame.new(-5248.53, 12.63, -4724.32)
        elseif MyLevel >= 1250 and MyLevel <= 1274 then
            NameQuest = "ShipQuest1" QuestLv = 1 Ms = "Ship Officer" NameMon = "Ship Officer"
            CFrameQ = CFrame.new(1038.52, 125.10, 32911.32)
            CFrameMon = CFrame.new(761.53, 125.10, 32895.42)
        elseif MyLevel >= 1275 and MyLevel <= 1299 then
            NameQuest = "ShipQuest1" QuestLv = 2 Ms = "Ship Steward" NameMon = "Ship Steward"
            CFrameQ = CFrame.new(1038.52, 125.10, 32911.32)
            CFrameMon = CFrame.new(912.42, 125.10, 33025.12)
        elseif MyLevel >= 1300 and MyLevel <= 1324 then
            NameQuest = "ShipQuest2" QuestLv = 1 Ms = "Ship Cook" NameMon = "Ship Cook"
            CFrameQ = CFrame.new(969.42, 125.10, 33245.23)
            CFrameMon = CFrame.new(620.43, 125.10, 33261.22)
        elseif MyLevel >= 1325 and MyLevel <= 1349 then
            NameQuest = "ShipQuest2" QuestLv = 2 Ms = "Ship Engineer" NameMon = "Ship Engineer"
            CFrameQ = CFrame.new(969.42, 125.10, 33245.23)
            CFrameMon = CFrame.new(912.12, 125.10, 33365.42)
        elseif MyLevel >= 1350 and MyLevel <= 1374 then
            NameQuest = "IceCastleQuest" QuestLv = 1 Ms = "Arctic Warrior" NameMon = "Arctic Warrior"
            CFrameQ = CFrame.new(6061.23, 28.53, -6475.22)
            CFrameMon = CFrame.new(6021.52, 28.53, -6812.43)
        elseif MyLevel >= 1375 and MyLevel <= 1424 then
            NameQuest = "IceCastleQuest" QuestLv = 2 Ms = "Snow Lurker" NameMon = "Snow Lurker"
            CFrameQ = CFrame.new(6061.23, 28.53, -6475.22)
            CFrameMon = CFrame.new(5721.42, 126.32, -6312.41)
        elseif MyLevel >= 1425 and MyLevel <= 1449 then
            NameQuest = "ForgottenQuest" QuestLv = 1 Ms = "Sea Soldier" NameMon = "Sea Soldier"
            CFrameQ = CFrame.new(-3055.22, 235.54, -10142.12)
            CFrameMon = CFrame.new(-3022.42, 15.63, -9714.52)
        elseif MyLevel >= 1450 then
            NameQuest = "ForgottenQuest" QuestLv = 2 Ms = "Water Tiger" NameMon = "Water Tiger"
            CFrameQ = CFrame.new(-3055.22, 235.54, -10142.12)
            CFrameMon = CFrame.new(-3125.53, 15.63, -10512.42)
        end
                elseif Sea3 then
        if MyLevel >= 1500 and MyLevel <= 1524 then
            NameQuest = "PortTownQuest" QuestLv = 1 Ms = "Pirate Millionaire" NameMon = "Pirate Millionaire"
            CFrameQ = CFrame.new(-290.07, 7.39, 5328.19)
            CFrameMon = CFrame.new(-338.53, 73.12, 5542.42)
        elseif MyLevel >= 1525 and MyLevel <= 1574 then
            NameQuest = "PortTownQuest" QuestLv = 2 Ms = "Pistol Billionaire" NameMon = "Pistol Billionaire"
            CFrameQ = CFrame.new(-290.07, 7.39, 5328.19)
            CFrameMon = CFrame.new(-588.42, 73.12, 5352.12)
        elseif MyLevel >= 1575 and MyLevel <= 1599 then
            NameQuest = "HydraIslandQuest" QuestLv = 1 Ms = "Dragon Crew Warrior" NameMon = "Dragon Crew Warrior"
            CFrameQ = CFrame.new(5463.42, 601.32, 171.42)
            CFrameMon = CFrame.new(5721.43, 601.32, -5.22)
        elseif MyLevel >= 1600 and MyLevel <= 1649 then
            NameQuest = "HydraIslandQuest" QuestLv = 2 Ms = "Dragon Crew Archer" NameMon = "Dragon Crew Archer"
            CFrameQ = CFrame.new(5463.42, 601.32, 171.42)
            CFrameMon = CFrame.new(6582.42, 601.32, -125.43)
        elseif MyLevel >= 1650 and MyLevel <= 1699 then
            NameQuest = "GreatTreeQuest" QuestLv = 1 Ms = "Female Island Marine" NameMon = "Female Island Marine"
            CFrameQ = CFrame.new(4062.12, 72.43, -1714.23)
            CFrameMon = CFrame.new(4652.42, 72.43, -1684.21)
        elseif MyLevel >= 1700 and MyLevel <= 1749 then
            NameQuest = "GreatTreeQuest" QuestLv = 2 Ms = "Giant Island Marine" NameMon = "Giant Island Marine"
            CFrameQ = CFrame.new(4062.12, 72.43, -1714.23)
            CFrameMon = CFrame.new(5125.53, 72.43, -2312.43)
        elseif MyLevel >= 1750 and MyLevel <= 1799 then
            NameQuest = "TurtleQuest" QuestLv = 1 Ms = "Fishman Raider" NameMon = "Fishman Raider"
            CFrameQ = CFrame.new(-13125.42, 514.43, -7542.42)
            CFrameMon = CFrame.new(-13342.12, 514.43, -7912.43)
        elseif MyLevel >= 1800 and MyLevel <= 1849 then
            NameQuest = "TurtleQuest" QuestLv = 2 Ms = "Fishman Captain" NameMon = "Fishman Captain"
            CFrameQ = CFrame.new(-13125.42, 514.43, -7542.42)
            CFrameMon = CFrame.new(-13425.53, 514.43, -8312.43)
        elseif MyLevel >= 1850 and MyLevel <= 1899 then
            NameQuest = "TurtleQuest" QuestLv = 3 Ms = "Forest Pirate" NameMon = "Forest Pirate"
            CFrameQ = CFrame.new(-13125.42, 514.43, -7542.42)
            CFrameMon = CFrame.new(-13312.42, 514.43, -7512.43)
        elseif MyLevel >= 1900 and MyLevel <= 1949 then
            NameQuest = "TurtleQuest" QuestLv = 4 Ms = "Mythical Pirate" NameMon = "Mythical Pirate"
            CFrameQ = CFrame.new(-13125.42, 514.43, -7542.42)
            CFrameMon = CFrame.new(-13512.42, 514.43, -7125.42)
        elseif MyLevel >= 1950 and MyLevel <= 1999 then
            NameQuest = "HauntedQuest1" QuestLv = 1 Ms = "Reborn Skeleton" NameMon = "Reborn Skeleton"
            CFrameQ = CFrame.new(-9485.42, 142.12, 5565.42)
            CFrameMon = CFrame.new(-8742.42, 142.12, 6012.43)
        elseif MyLevel >= 2000 and MyLevel <= 2049 then
            NameQuest = "HauntedQuest1" QuestLv = 2 Ms = "Living Zombie" NameMon = "Living Zombie"
            CFrameQ = CFrame.new(-9485.42, 142.12, 5565.42)
            CFrameMon = CFrame.new(-10124.42, 142.12, 6125.42)
        elseif MyLevel >= 2050 and MyLevel <= 2099 then
            NameQuest = "HauntedQuest2" QuestLv = 1 Ms = "Demonic Soul" NameMon = "Demonic Soul"
            CFrameQ = CFrame.new(-9525.42, 164.21, 5742.12)
            CFrameMon = CFrame.new(-9612.42, 164.21, 6012.43)
        elseif MyLevel >= 2100 and MyLevel <= 2149 then
            NameQuest = "IceCreamIslandQuest" QuestLv = 1 Ms = "Peanut Scout" NameMon = "Peanut Scout"
            CFrameQ = CFrame.new(-1152.12, 15.63, -12124.42)
            CFrameMon = CFrame.new(-1242.42, 15.63, -12412.43)
        elseif MyLevel >= 2150 and MyLevel <= 2199 then
            NameQuest = "IceCreamIslandQuest" QuestLv = 2 Ms = "Peanut President" NameMon = "Peanut President"
            CFrameQ = CFrame.new(-1152.12, 15.63, -12124.42)
            CFrameMon = CFrame.new(-1542.42, 15.63, -12412.43)
        elseif MyLevel >= 2200 and MyLevel <= 2249 then
            NameQuest = "CakeQuest1" QuestLv = 1 Ms = "Ice Cream Chef" NameMon = "Ice Cream Chef"
            CFrameQ = CFrame.new(-2124.42, 73.12, -12124.42)
            CFrameMon = CFrame.new(-2342.12, 73.12, -12512.43)
        elseif MyLevel >= 2250 and MyLevel <= 2299 then
            NameQuest = "CakeQuest1" QuestLv = 2 Ms = "Ice Cream Commander" NameMon = "Ice Cream Commander"
            CFrameQ = CFrame.new(-2124.42, 73.12, -12124.42)
            CFrameMon = CFrame.new(-2512.42, 73.12, -12812.43)
        elseif MyLevel >= 2300 and MyLevel <= 2349 then
            NameQuest = "CakeQuest2" QuestLv = 1 Ms = "Cookie Cracker" NameMon = "Cookie Cracker"
            CFrameQ = CFrame.new(-3124.42, 73.12, -12124.42)
            CFrameMon = CFrame.new(-3342.42, 73.12, -12512.43)
        elseif MyLevel >= 2350 and MyLevel <= 2399 then
            NameQuest = "CakeQuest2" QuestLv = 2 Ms = "Cake Guard" NameMon = "Cake Guard"
            CFrameQ = CFrame.new(-3124.42, 73.12, -12124.42)
            CFrameMon = CFrame.new(-3512.42, 73.12, -12812.43)
        elseif MyLevel >= 2400 and MyLevel <= 2449 then
            NameQuest = "CandyIslandQuest" QuestLv = 1 Ms = "Candy Pirate" NameMon = "Candy Pirate"
            CFrameQ = CFrame.new(-4124.42, 15.63, -12124.42)
            CFrameMon = CFrame.new(-4342.12, 15.63, -12512.43)
        elseif MyLevel >= 2450 then
            NameQuest = "CandyIslandQuest" QuestLv = 2 Ms = "Snow Cone Machine" NameMon = "Snow Cone Machine"
            CFrameQ = CFrame.new(-4124.42, 15.63, -12124.42)
            CFrameMon = CFrame.new(-4512.42, 15.63, -12812.43)
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
-- 🔄 CORE LOOPS (UPGRADED)
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
                    -- ✅ เช็คก่อนว่ามีพิกัดเควสไหม (กัน Error nil)
                    if CFrameQ then
                        Tween(CFrameQ)
                        if (CFrameQ.Position - player.Character.HumanoidRootPart.Position).Magnitude <= 15 then
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", NameQuest, QuestLv)
                        end
                    end
                else
                    local enemy = workspace.Enemies:FindFirstChild(Ms) or workspace.Enemies:FindFirstChild(NameMon)
                    if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        bringmob = true
                        
                        -- [[ ✅ AUTO BUSO HAKI ]]
                        if not player.Character:FindFirstChild("HasBuso") then
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                        end

                   -- ✅ ตรวจสอบและสวมใส่อาวุธ (รองรับ Melee, Sword, และ Fruit)
local toolName = _G.SelectWeapon
if toolName == "Fruit" then toolName = "Blox Fruit" end -- แปลงชื่อให้ตรงกับระบบของเกม

for _, v in pairs(player.Backpack:GetChildren()) do
    if v:IsA("Tool") and v.ToolTip == toolName then
        player.Character.Humanoid:EquipTool(v)
    end
end

                        
                        -- ล็อคตำแหน่งเหนือมอนสเตอร์
                        player.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0)
                        Attack()
                    else
                        bringmob = false
                        -- ✅ เช็คก่อนว่ามีพิกัดมอนไหม
                        if CFrameMon then
                            Tween(CFrameMon)
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop: Bring Mob & Hitbox (Heartbeat)
RunService.Heartbeat:Connect(function()
    if _G.AutoLevel and _G.BringMob and bringmob then
        pcall(function()
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == Ms and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                    v.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -12, 0)
                    v.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    
                    -- เช็ค sethiddenproperty กัน Executor บางตัว Error
                    if sethiddenproperty then
                        sethiddenproperty(player, "SimulationRadius", math.huge)
                    end
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
