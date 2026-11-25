--[[
    VeySell Hub | Shoot Arrows For Animals
    UI: ProxyLib (Key: FREE)  |  Icon buka/tutup: VeySell
    Discord : https://discord.gg/vrTQZJVcPA
    Channel : https://www.youtube.com/@VeySell_Hub
]]
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local VIM     = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local LP      = Players.LocalPlayer

local DISCORD = "https://discord.gg/vrTQZJVcPA"
local YOUTUBE = "https://www.youtube.com/@VeySell_Hub"
local ICON    = "rbxassetid://13026626364"
local THROW_POS = Vector3.new(2.92, 5.50, -36.00)
local THROW_POWER = 0.0098407018059532749

local genv = (getgenv and getgenv()) or _G
if genv.VeySellArrowStop then pcall(genv.VeySellArrowStop) end

-- ================= state =================
local S = { dead = false, throw = false, equip = false, upgrade = false, bonus = false }

-- ================= remotes =================
local function R(...)
    local o = RS:FindFirstChild("Remotes")
    for _, n in ipairs({ ... }) do o = o and o:FindFirstChild(n) end
    return o
end
local function invoke(remote, ...)
    if not remote then return end
    local args = { ... }
    pcall(function()
        if remote:IsA("RemoteFunction") then remote:InvokeServer(unpack(args))
        else remote:FireServer(unpack(args)) end
    end)
end

local function root() local c = LP.Character return c and c:FindFirstChild("HumanoidRootPart") end

local function tpThrow()
    local r = root()
    if r and (r.Position - THROW_POS).Magnitude > 6 then
        r.CFrame = CFrame.new(THROW_POS)
        r.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.35)
    end
end

-- ================= loops =================
task.spawn(function() -- Auto Throw Best: TP dulu, baru throw
    while not S.dead do
        if S.throw then
            tpThrow()
            invoke(R("Shot", "Start"), THROW_POWER)
            task.wait(0.1)
            invoke(R("Shot", "Complete"), { Skipped = true })
        end
        task.wait(0.2)
    end
end)
task.spawn(function()
    while not S.dead do
        if S.equip then invoke(R("Plot", "EquipBest")) end
        task.wait(0.5)
    end
end)
task.spawn(function()
    while not S.dead do
        if S.upgrade then invoke(R("Training", "Upgrade")) end
        task.wait(0.25)
    end
end)
task.spawn(function()
    while not S.dead do
        if S.bonus then
            pcall(function()
                local gui = LP:FindFirstChild("PlayerGui")
                local b = gui and gui:FindFirstChild("TrainingGui")
                b = b and b:FindFirstChild("Bonus")
                b = b and b:FindFirstChild("TapBonus")
                if not b then return end
                if b:IsA("BindableEvent") then b:Fire() return end
                if b:IsA("RemoteEvent") then b:FireServer() return end
                if b:IsA("GuiObject") and b.Visible then
                    local fired = false
                    if getconnections then
                        for _, ev in ipairs({ "MouseButton1Click", "Activated" }) do
                            local ok, list = pcall(getconnections, b[ev])
                            if ok then
                                for _, c in ipairs(list) do pcall(function() c:Fire() end) fired = true end
                            end
                        end
                    end
                    if not fired then
                        local p, s = b.AbsolutePosition, b.AbsoluteSize
                        local x, y = p.X + s.X / 2, p.Y + s.Y / 2 + 36
                        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
                        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
                    end
                end
            end)
        end
        task.wait(0.15)
    end
end)
local idle = LP.Idled:Connect(function()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController() vu:ClickButton2(Vector2.new())
    end)
end)

-- ================= helpers UI =================
local function mountParent()
    local ok, p = pcall(function() return (gethui and gethui()) or CoreGui end)
    return ok and p or LP:WaitForChild("PlayerGui")
end
local function snapshot()
    local set = {}
    for _, root_ in ipairs({ mountParent(), CoreGui, LP:FindFirstChild("PlayerGui") }) do
        if root_ then
            pcall(function() for _, g in ipairs(root_:GetChildren()) do set[g] = true end end)
        end
    end
    return set
end
local function copy(t, label)
    if setclipboard then setclipboard(t) end
    return label
end

local ProxyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProxyHubDev/ProxyLib/refs/heads/main/Documents/ProxyLibrary"))()
local Lib = ProxyLib.new()

local KS = Lib:CreateKeySystem({ Title = "Authentication", Theme = "Blue" })
pcall(function() KS:CreateSocialButton({ Type = "Discord", Link = DISCORD, Order = 1 }) end)
pcall(function() KS:CreateSocialButton({ Type = "YouTube", Link = YOUTUBE, Order = 2 }) end)

local Window, floatGui
local uiVisible = true

local function toggleUI()
    uiVisible = not uiVisible
    local found = false
    if genv.VeySellArrowGuis then
        for _, g in ipairs(genv.VeySellArrowGuis) do
            if g and g.Parent then
                found = true
                pcall(function() g.Enabled = uiVisible end)
            end
        end
    end
    if not found and Window then
        for _, m in ipairs({ "Toggle", "SetVisible", "Minimize" }) do
            if pcall(function() Window[m](Window, uiVisible) end) then break end
        end
    end
end

local function makeFloating()
    floatGui = Instance.new("ScreenGui")
    floatGui.Name = "VeySellToggle"
    floatGui.ResetOnSpawn = false
    floatGui.DisplayOrder = 999
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(floatGui) end end)
    floatGui.Parent = mountParent()

    local b = Instance.new("ImageButton")
    b.Size = UDim2.fromOffset(56, 56)
    b.Position = UDim2.new(0, 20, 0.35, 0)
    b.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
    b.Image = ICON
    b.AutoButtonColor = false
    b.Parent = floatGui
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    local st = Instance.new("UIStroke", b)
    st.Thickness = 2.5
    st.Color = Color3.fromRGB(80, 160, 255)
    local sc = Instance.new("UIScale", b)

    local drag, ds, dp, moved
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag, ds, dp, moved = true, i.Position, b.Position, 0
            TS:Create(sc, TweenInfo.new(.15), { Scale = .88 }):Play()
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            moved = math.max(moved, d.Magnitude)
            b.Position = UDim2.new(dp.X.Scale, dp.X.Offset + d.X, dp.Y.Scale, dp.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            drag = false
            TS:Create(sc, TweenInfo.new(.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
            if moved < 8 then toggleUI() end
        end
    end)
end

-- toggle: coba CreateToggle, kalau gagal fallback ke tombol ON/OFF
local function addToggle(tab, name, desc, cb)
    local ok = pcall(function()
        tab:CreateToggle({ Title = name, Name = name, Text = name, Description = desc, Default = false,
            Value = false, CurrentValue = false, Callback = cb })
    end)
    if not ok then
        local state = false
        tab:CreateButton({
            Description = name .. " : OFF",
            Callback = function()
                state = not state
                cb(state)
                pcall(function()
                    Window:Notify({ Title = name, Description = state and "ON" or "OFF", Duration = 1.5 })
                end)
            end,
        })
    end
end

local function build()
    local before = snapshot()
    Window = Lib:CreateWindow({
        Title = "VeySell Hub",
        Subtitle = "Shoot Arrows For Animals",
        Theme = "Blue",
        Size = Vector2.new(560, 420),
        ConfigPanel = { Enabled = true, Theme = true, Fps = true, Ping = true, Profile = true },
        TitleConfig = {
            Gradient = true,
            Words = { "VeySell", { Text = "Hub", Colors = { Color3.fromRGB(80, 160, 255), Color3.fromRGB(50, 220, 100) } } },
        },
    })
    -- cari ScreenGui milik ProxyLib untuk tombol buka/tutup
    task.delay(0.6, function()
        genv.VeySellArrowGuis = {}
        for _, root_ in ipairs({ mountParent(), CoreGui, LP:FindFirstChild("PlayerGui") }) do
            if root_ then
                pcall(function()
                    for _, g in ipairs(root_:GetChildren()) do
                        if g:IsA("ScreenGui") and not before[g] and g ~= floatGui then
                            table.insert(genv.VeySellArrowGuis, g)
                        end
                    end
                end)
            end
        end
    end)

    Window:CreateSeparator({ Text = "MENUS" })
    local Main = Window:CreateTab({ Title = "Farming", Icon = "rbxassetid://90806903018673" })

    Main:CreateSection({ Text = "Farming" })
    Main:CreateParagraph({
        Title = "Auto Throw Best",
        Description = "INSTANT THROW.",
    })
    addToggle(Main, "Auto Farming", "Auto Throw", function(v)
        S.throw = v
        if v then task.spawn(tpThrow) end
    end)
    addToggle(Main, "Equip Best Animals", "Auto equip hewan terbaik", function(v) S.equip = v end)
    addToggle(Main, "Auto Upgrade Base", "Auto upgrade training", function(v) S.upgrade = v end)
    addToggle(Main, "Auto Train Bonus", "Auto tap bonus training", function(v) S.bonus = v end)

    Main:CreateSection({ Text = "React" })
    Main:CreateButton({
        Description = "Sell All",
        Callback = function()
            local r = R("Plot", "SellAll")
            if r then invoke(r) else warn("[VeySell] Remote SellAll tidak ditemukan") end
        end,
    })
    Main:CreateButton({
        Description = "TP ke Titik Throw",
        Callback = function()
            local r = root()
            if r then r.CFrame = CFrame.new(THROW_POS) end
        end,
    })
    Main:CreateButton({
        Description = "Buka / Tutup UI",
        Callback = toggleUI,
    })

    local Info = Window:CreateTab({ Title = "Information", Icon = "rbxassetid://129908128358520" })
    Info:CreateSection({ Text = "VeySell Hub" })
    Info:CreateParagraph({
        Title = "VeySell Hub",
        Description = "Dev: VeySell / GGSIHLUH\nIkon bulat di layar = buka/tutup UI (bisa digeser).",
    })
    Info:CreateButton({
        Description = "Copy Discord",
        Callback = function()
            copy(DISCORD)
            pcall(function() Window:Notify({ Title = "Discord disalin", Description = DISCORD, Duration = 3 }) end)
        end,
    })
    Info:CreateButton({
        Description = "Copy Channel YouTube",
        Callback = function()
            copy(YOUTUBE)
            pcall(function() Window:Notify({ Title = "YouTube disalin", Description = YOUTUBE, Duration = 3 }) end)
        end,
    })

    makeFloating()
    Window:Notify({ Title = "Welcome!", Description = "VeySell Hub berhasil dimuat.", Duration = 4 })
end

KS:CreateButton({
    Description = "INPUT FREE",
    Callback = function()
        if KS:GetText() == "FREE" then
            KS:Destroy()
            build()
        else
            KS:Notify({ Title = "Invalid key!", Duration = 3 })
        end
    end,
})

genv.VeySellArrowStop = function()
    S.dead = true
    pcall(function() idle:Disconnect() end)
    pcall(function() if floatGui then floatGui:Destroy() end end)
    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
end
