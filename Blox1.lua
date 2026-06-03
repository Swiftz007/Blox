local Load = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Libwtf/refs/heads/main/LoadLib.lua"))() 

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Advanced/refs/heads/main/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Advanced/refs/heads/main/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Advanced/refs/heads/main/InterfaceManager.lua"))()

local attack = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Libblox/refs/heads/main/libattack.lua"))()

--=========================
-- 🔥 SERVICES
--=========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--=========================
-- 🔥 WINDOW
--=========================
local Window = Fluent:CreateWindow({
Title = "Reaper Hub",
SubTitle = "BloxFruits",
TabWidth = 160,
Size = UDim2.fromOffset(520, 360),
Theme = "Reaper",
MinimizeKey = Enum.KeyCode.RightControl
})

local icon = loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Libwtf/refs/heads/main/Icon.lua"))()

-- Tab
local Tabs = {
Main = Window:AddTab({ Title = "Main", Icon = "home" }),
Player = Window:AddTab({ Title = "Player", Icon = "user" }),
ESP = Window:AddTab({ Title = "ESP", Icon = "box" }),
Teleport = Window:AddTab({ Title = "Teleport", Icon = "menu" }),
Server = Window:AddTab({ Title = "Server", Icon = "server" }),
Misc = Window:AddTab({ Title = "Misc", Icon = "hash" }),
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

--=========================
-- 🔥 GLOBAL VARIABLES
--=========================
_G.AutoFarm = false
_G.SelectWeapon = "Melee"
local World1 = game.PlaceId == 2753915549
local Mon, LevelQuest, NameQuest, NameMon, CFrameQuest, CFrameMon
local CurrentTween

--=========================
-- 🛠 SUPPORT FUNCTIONS
--=========================
local function TweenTo(Pos, CustomSpeed)
    local Root = LP.Character:FindFirstChild("HumanoidRootPart")
    if not Root or not _G.AutoFarm then 
        if CurrentTween then CurrentTween:Cancel() end
        return 
    end
    
    local Distance = (Pos.Position - Root.Position).Magnitude
    if Distance < 5 then 
        if CurrentTween then CurrentTween:Cancel() end
        return 
    end

    -- [FIXED] สั่งหยุดของเก่าทันทีเพื่อเริ่ม Tween ใหม่ (ทำให้ตอบสนองไวขึ้น)
    if CurrentTween then CurrentTween:Cancel() end

    local Speed = CustomSpeed or 300
    local TargetCFrame = Pos
    
    -- [FIXED] กันจมน้ำ: ถ้าไกลเกิน 500 บินสูงทันที
    if Distance > 500 then
        TargetCFrame = CFrame.new(Pos.X, 500, Pos.Z)
    end

    CurrentTween = TS:Create(Root, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
    CurrentTween:Play()
end

local function EquipWeapon()
    pcall(function()
        if LP.Character:FindFirstChildOfClass("Tool") then return end
        for _, v in pairs(LP.Backpack:GetChildren()) do
            if v:IsA("Tool") and (v.ToolTip == _G.SelectWeapon or v.Name == _G.SelectWeapon) then
                LP.Character.Humanoid:EquipTool(v)
            end
        end
    end)
end

--=========================
-- 📜 CHECKQUEST DATA
--=========================
function CheckQuest() 
    local MyLevel = LP.Data.Level.Value
    if World1 then
        if MyLevel >= 1 and MyLevel <= 9 then
            Mon = "Bandit"; LevelQuest = 1; NameQuest = "BanditQuest1"; NameMon = "Bandit"
            CFrameQuest = CFrame.new(1059.37, 15.45, 1550.42); CFrameMon = CFrame.new(1045.96, 27.00, 1560.82)
        elseif MyLevel >= 10 and MyLevel <= 14 then
            Mon = "Monkey"; LevelQuest = 1; NameQuest = "JungleQuest"; NameMon = "Monkey"
            CFrameQuest = CFrame.new(-1598.08, 35.55, 153.37); CFrameMon = CFrame.new(-1448.51, 67.85, 11.46)
        elseif MyLevel >= 15 and MyLevel <= 29 then
            Mon = "Gorilla"; LevelQuest = 2; NameQuest = "JungleQuest"; NameMon = "Gorilla"
            CFrameQuest = CFrame.new(-1598.08, 35.55, 153.37); CFrameMon = CFrame.new(-1129.88, 40.46, -525.42)
        elseif MyLevel >= 30 and MyLevel <= 39 then
            Mon = "Pirate"; LevelQuest = 1; NameQuest = "BuggyQuest1"; NameMon = "Pirate"
            CFrameQuest = CFrame.new(-1141.07, 4.10, 3831.54); CFrameMon = CFrame.new(-1103.51, 13.75, 3896.09)
        elseif MyLevel >= 40 and MyLevel <= 59 then
            Mon = "Brute"; LevelQuest = 2; NameQuest = "BuggyQuest1"; NameMon = "Brute"
            CFrameQuest = CFrame.new(-1141.07, 4.10, 3831.54); CFrameMon = CFrame.new(-1140.08, 14.80, 4322.92)
        elseif MyLevel >= 60 and MyLevel <= 74 then
            Mon = "Desert Bandit"; LevelQuest = 1; NameQuest = "DesertQuest"; NameMon = "Desert Bandit"
            CFrameQuest = CFrame.new(894.48, 5.14, 4392.43); CFrameMon = CFrame.new(924.79, 6.44, 4481.58)
        elseif MyLevel >= 75 and MyLevel <= 89 then
            Mon = "Desert Officer"; LevelQuest = 2; NameQuest = "DesertQuest"; NameMon = "Desert Officer"
            CFrameQuest = CFrame.new(894.48, 5.14, 4392.43); CFrameMon = CFrame.new(1608.28, 8.61, 4371.00)
        elseif MyLevel >= 90 and MyLevel <= 99 then
            Mon = "Snow Bandit"; LevelQuest = 1; NameQuest = "SnowQuest"; NameMon = "Snow Bandit"
            CFrameQuest = CFrame.new(1389.74, 88.15, -1298.90); CFrameMon = CFrame.new(1354.34, 87.27, -1393.94)
        elseif MyLevel >= 100 and MyLevel <= 119 then
            Mon = "Snowman"; LevelQuest = 2; NameQuest = "SnowQuest"; NameMon = "Snowman"
            CFrameQuest = CFrame.new(1389.74, 88.15, -1298.90); CFrameMon = CFrame.new(1201.64, 144.57, -1550.06)
        elseif MyLevel >= 120 and MyLevel <= 149 then
            Mon = "Chief Petty Officer"; LevelQuest = 1; NameQuest = "MarineQuest2"; NameMon = "Chief Petty Officer"
            CFrameQuest = CFrame.new(-5039.58, 27.35, 4324.68); CFrameMon = CFrame.new(-4881.23, 22.65, 4273.75)
        elseif MyLevel >= 150 and MyLevel <= 174 then
            Mon = "Sky Bandit"; LevelQuest = 1; NameQuest = "SkyQuest"; NameMon = "Sky Bandit"
            CFrameQuest = CFrame.new(-4839.53, 716.36, -2619.44); CFrameMon = CFrame.new(-4953.20, 295.74, -2899.22)
        elseif MyLevel >= 175 and MyLevel <= 189 then
            Mon = "Dark Master"; LevelQuest = 2; NameQuest = "SkyQuest"; NameMon = "Dark Master"
            CFrameQuest = CFrame.new(-4839.53, 716.36, -2619.44); CFrameMon = CFrame.new(-5259.84, 391.39, -2229.03)
        elseif MyLevel >= 190 and MyLevel <= 209 then
            Mon = "Prisoner"; LevelQuest = 1; NameQuest = "PrisonerQuest"; NameMon = "Prisoner"
            CFrameQuest = CFrame.new(5308.93, 1.65, 475.12); CFrameMon = CFrame.new(5098.97, -0.32, 474.23)
        elseif MyLevel >= 210 and MyLevel <= 249 then
            Mon = "Dangerous Prisoner"; LevelQuest = 2; NameQuest = "PrisonerQuest"; NameMon = "Dangerous Prisoner"
            CFrameQuest = CFrame.new(5308.93, 1.65, 475.12); CFrameMon = CFrame.new(5654.56, 15.63, 866.29)
        elseif MyLevel >= 250 and MyLevel <= 274 then
            Mon = "Toga Warrior"; LevelQuest = 1; NameQuest = "ColosseumQuest"; NameMon = "Toga Warrior"
            CFrameQuest = CFrame.new(-1580.04, 6.35, -2986.47); CFrameMon = CFrame.new(-1820.21, 51.68, -2740.66)
        elseif MyLevel >= 275 and MyLevel <= 299 then
            Mon = "Gladiator"; LevelQuest = 2; NameQuest = "ColosseumQuest"; NameMon = "Gladiator"
            CFrameQuest = CFrame.new(-1580.04, 6.35, -2986.47); CFrameMon = CFrame.new(-1292.83, 56.38, -3339.03)
        elseif MyLevel >= 300 and MyLevel <= 324 then
            Mon = "Military Soldier"; LevelQuest = 1; NameQuest = "MagmaQuest"; NameMon = "Military Soldier"
            CFrameQuest = CFrame.new(-5313.37, 10.95, 8515.29); CFrameMon = CFrame.new(-5411.16, 11.08, 8454.29)
        elseif MyLevel >= 325 and MyLevel <= 374 then
            Mon = "Military Spy"; LevelQuest = 2; NameQuest = "MagmaQuest"; NameMon = "Military Spy"
            CFrameQuest = CFrame.new(-5313.37, 10.95, 8515.29); CFrameMon = CFrame.new(-5802.86, 86.26, 8828.85)
        elseif MyLevel >= 375 and MyLevel <= 399 then
            Mon = "Fishman Warrior"; LevelQuest = 1; NameQuest = "FishmanQuest"; NameMon = "Fishman Warrior"
            CFrameQuest = CFrame.new(61122.65, 18.49, 1569.39); CFrameMon = CFrame.new(60878.30, 18.48, 1543.75)
        elseif MyLevel >= 400 and MyLevel <= 449 then
            Mon = "Fishman Commando"; LevelQuest = 2; NameQuest = "FishmanQuest"; NameMon = "Fishman Commando"
            CFrameQuest = CFrame.new(61122.65, 18.49, 1569.39); CFrameMon = CFrame.new(61922.63, 18.48, 1493.93)
        elseif MyLevel >= 450 and MyLevel <= 474 then
            Mon = "God's Guard"; LevelQuest = 1; NameQuest = "SkyExp1Quest"; NameMon = "God's Guard"
            CFrameQuest = CFrame.new(-4721.88, 843.87, -1949.96); CFrameMon = CFrame.new(-4710.04, 845.27, -1927.30)
        elseif MyLevel >= 475 and MyLevel <= 524 then
            Mon = "Shanda"; LevelQuest = 2; NameQuest = "SkyExp1Quest"; NameMon = "Shanda"
            CFrameQuest = CFrame.new(-7859.09, 5544.19, -381.47); CFrameMon = CFrame.new(-7678.48, 5566.40, -497.21)
        elseif MyLevel >= 525 and MyLevel <= 549 then
            Mon = "Royal Squad"; LevelQuest = 1; NameQuest = "SkyExp2Quest"; NameMon = "Royal Squad"
            CFrameQuest = CFrame.new(-7906.81, 5634.66, -1411.99); CFrameMon = CFrame.new(-7624.25, 5658.13, -1467.35)
        elseif MyLevel >= 550 and MyLevel <= 624 then
            Mon = "Royal Soldier"; LevelQuest = 2; NameQuest = "SkyExp2Quest"; NameMon = "Royal Soldier"
            CFrameQuest = CFrame.new(-7906.81, 5634.66, -1411.99); CFrameMon = CFrame.new(-7836.75, 5645.66, -1790.62)
        elseif MyLevel >= 625 and MyLevel <= 649 then
            Mon = "Galley Pirate"; LevelQuest = 1; NameQuest = "FountainQuest"; NameMon = "Galley Pirate"
            CFrameQuest = CFrame.new(5259.81, 37.35, 4050.02); CFrameMon = CFrame.new(5551.02, 78.90, 3930.41)
        elseif MyLevel >= 650 then
            Mon = "Galley Captain"; LevelQuest = 2; NameQuest = "FountainQuest"; NameMon = "Galley Captain"
            CFrameQuest = CFrame.new(5259.81, 37.35, 4050.02); CFrameMon = CFrame.new(5441.95, 42.50, 4950.09)
        end
    end
end

--=========================
-- 🛡 NOCLIP SYSTEM
--=========================
RunService.Stepped:Connect(function()
    if _G.AutoFarm and LP.Character then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)


Tabs.Main:AddDropdown("WeaponSelect", {
    Title = "Select Weapon",
    Values = {"Melee", "Sword", "Fruit", "Gun"},
    Default = "Melee",
    Callback = function(v) _G.SelectWeapon = v end
})

Tabs.Main:AddToggle("AutoFarmLevel", {
    Title = "Farm Level",
    Default = false,
    Callback = function(v) _G.AutoFarm = v end
})

--=========================
-- 🔄 MAIN FARMING LOOP
--=========================
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                CheckQuest() 
                
                local HasQuest = LP.PlayerGui.Main.Quest.Visible
                
                if not HasQuest then
                    TweenTo(CFrameQuest, 300)
                    if (CFrameQuest.Position - LP.Character.HumanoidRootPart.Position).Magnitude < 15 then
                        if CurrentTween then CurrentTween:Cancel() end
                        task.wait(0.1)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                    end
                else
                    local Target = workspace.Enemies:FindFirstChild(Mon) or workspace.Camera:FindFirstChild(Mon)
                    
                    if Target and Target:FindFirstChild("HumanoidRootPart") and Target.Humanoid.Health > 0 then
                        local RootPos = LP.Character.HumanoidRootPart.Position
                        local MonsterPos = Target.HumanoidRootPart.Position
                        local DistToMon = (MonsterPos - RootPos).Magnitude
                        
                        EquipWeapon()

                        if DistToMon > 150 then
                            TweenTo(Target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0), 300)
                        else
                            -- [FIXED] ใช้พารามิเตอร์ 1500 เข้า TweenTo โดยตรงเพื่อให้ยกเลิก Tween เก่าอัตโนมัติ
                            TweenTo(Target.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0), 1500)
                        end
                    else
                        TweenTo(CFrameMon, 300)
                    end
                end
            end)
        else
            if CurrentTween then CurrentTween:Cancel() end
        end
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
button.Position = UDim2.new(0,60,0.2,0)
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

-- Load Success
task.wait(2)
print("Reaper Hub Loaded")


-- Send notify webhook 
task.wait(1)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Swiftz007/Libwtf/refs/heads/main/Libwebhook.lua"))()
