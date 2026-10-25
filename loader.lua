-- Sp1ng Hub Loader
local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/sp1ngimsp1ng/MM2Script/refs/heads/main/core.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Sp1ng Hub — MM2",
    LoadingTitle = "Sp1ng Hub",
    LoadingSubtitle = "by Sp1ng",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Sp1ngHub",
        FileName = "MM2Config"
    },
    KeySystem = false,
})

local PlayerTab = Window:CreateTab("Player", 16485180075)
local ESPTab = Window:CreateTab("ESP", 13321848320)
local AutomationsTab = Window:CreateTab("Automations", 74133076168703)

local function notify(title, content)
    Rayfield:Notify({ Title = title, Content = content, Duration = 3, Image = 4483362458 })
end

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 150},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeedFlag",
    Callback = function(v)
        Core.MovementSettings.WalkSpeed = v
        local hum = Core.getHumanoid()
        if hum then hum.WalkSpeed = v end
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpFlag",
    Callback = function(v) Core.MovementSettings.InfJump = v end,
})

UserInputService.JumpRequest:Connect(function()
    if Core.MovementSettings.InfJump then
        local hum = Core.getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

PlayerTab:CreateToggle({
    Name = "Anti Fling",
    CurrentValue = false,
    Flag = "AntiFlingFlag",
    Callback = function(v)
        Core.MovementSettings.AntiFling = v
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CanCollide = not v end
            end
        end
    end,
})

PlayerTab:CreateButton({
    Name = "Fling Murder",
    Callback = function()
        local murderer = Core.getMurderer()
        if murderer then
            task.spawn(function() Core.flingPlayer(murderer) end)
        else
            notify("Erreur", "Aucun Murderer trouvé !")
        end
    end,
})

PlayerTab:CreateButton({
    Name = "Fling Sheriff",
    Callback = function()
        local sheriff = Core.getSheriff()
        if sheriff then
            task.spawn(function() Core.flingPlayer(sheriff) end)
        else
            notify("Erreur", "Aucun Sheriff trouvé !")
        end
    end,
})

local ESP_Highlights = { Innocent = {}, Sheriff = {}, Murderer = {} }

local function applyRoleESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    local role = Core.getMM2Role(plr)

    if Core.VisualSettings.InnocentESP and role == "Innocent" then
        if not ESP_Highlights.Innocent[plr] then
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(56, 255, 112)
            h.FillTransparency = 0.3
            h.Parent = char
            ESP_Highlights.Innocent[plr] = h
        end
    elseif ESP_Highlights.Innocent[plr] then
        ESP_Highlights.Innocent[plr]:Destroy()
        ESP_Highlights.Innocent[plr] = nil
    end

    if Core.VisualSettings.SheriffESP and role == "Sheriff" then
        if not ESP_Highlights.Sheriff[plr] then
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(0, 132, 255)
            h.FillTransparency = 0.3
            h.Parent = char
            ESP_Highlights.Sheriff[plr] = h
        end
    elseif ESP_Highlights.Sheriff[plr] then
        ESP_Highlights.Sheriff[plr]:Destroy()
        ESP_Highlights.Sheriff[plr] = nil
    end

    if Core.VisualSettings.MurderESP and role == "Murderer" then
        if not ESP_Highlights.Murderer[plr] then
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.FillTransparency = 0.3
            h.Parent = char
            ESP_Highlights.Murderer[plr] = h
        end
    elseif ESP_Highlights.Murderer[plr] then
        ESP_Highlights.Murderer[plr]:Destroy()
        ESP_Highlights.Murderer[plr] = nil
    end
end

ESPTab:CreateToggle({ Name = "Innocent ESP", CurrentValue = false, Callback = function(v) Core.VisualSettings.InnocentESP = v end })
ESPTab:CreateToggle({ Name = "Sheriff ESP", CurrentValue = false, Callback = function(v) Core.VisualSettings.SheriffESP = v end })
ESPTab:CreateToggle({ Name = "Murder ESP", CurrentValue = false, Callback = function(v) Core.VisualSettings.MurderESP = v end })

local gunEspHighlight = nil
ESPTab:CreateToggle({
    Name = "Gun ESP",
    CurrentValue = false,
    Callback = function(v)
        Core.VisualSettings.GunESP = v
        if not v and gunEspHighlight then
            gunEspHighlight:Destroy()
            gunEspHighlight = nil
        end
    end,
})

RunService.Heartbeat:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then applyRoleESP(plr) end
    end
    if Core.VisualSettings.GunESP then
        local gun = Core.findGunDrop()
        if gun and not gunEspHighlight then
            gunEspHighlight = Instance.new("Highlight")
            gunEspHighlight.FillColor = Color3.fromRGB(255, 200, 0)
            gunEspHighlight.Parent = gun
        elseif not gun and gunEspHighlight then
            gunEspHighlight:Destroy()
            gunEspHighlight = nil
        end
    end
end)

AutomationsTab:CreateToggle({
    Name = "Auto TP Gun",
    CurrentValue = false,
    Callback = function(v)
        Core.AutomationsSettings.AutoTpGun = v
        if v then
            task.spawn(function()
                while Core.AutomationsSettings.AutoTpGun do
                    task.wait(0.5)
                    local gun = Core.findGunDrop()
                    local hrp = Core.getHRP()
                    if gun and hrp then
                        pcall(function() gun.CFrame = hrp.CFrame end)
                    end
                end
            end)
        end
    end,
})

AutomationsTab:CreateToggle({
    Name = "Auto Shoot Murder",
    CurrentValue = false,
    Callback = function(v)
        Core.AutomationsSettings.AutoShootMurder = v
        if v then
            task.spawn(function()
                while Core.AutomationsSettings.AutoShootMurder do
                    task.wait(0.2)
                    local murderer = Core.getMurderer()
                    if murderer then Core.fireAt(murderer) end
                end
            end)
        end
    end,
})

AutomationsTab:CreateToggle({
    Name = "Coins Farm",
    CurrentValue = false,
    Callback = function(v)
        Core.AutomationsSettings.AutoFarm = v
        if v then
            task.spawn(function()
                while Core.AutomationsSettings.AutoFarm do
                    task.wait(0.2)
                    local cc = Core.getCoinContainer()
                    local hrp = Core.getHRP()
                    if cc and hrp then
                        for _, coin in ipairs(cc:GetChildren()) do
                            local part = coin:IsA("BasePart") and coin or (coin:IsA("Model") and coin.PrimaryPart)
                            if part and (part.Position - hrp.Position).Magnitude < 40 then
                                pcall(function() firetouchinterest(hrp, part, 0); firetouchinterest(hrp, part, 1) end)
                            end
                        end
                    end
                end
            end)
        end
    end,
})

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.S then
        Rayfield:ToggleUI()
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Sp1ngHubButton"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local sBtn = Instance.new("TextButton")
sBtn.Size = UDim2.new(0, 45, 0, 45)
sBtn.Position = UDim2.new(0, 15, 0, 200)
sBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
sBtn.TextColor3 = Color3.fromRGB(56, 255, 112)
sBtn.Text = "S"
sBtn.TextSize = 20
sBtn.Font = Enum.Font.GothamBold
sBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = sBtn

sBtn.MouseButton1Click:Connect(function()
    Rayfield:ToggleUI()
end)

notify("Sp1ng Hub", "Chargé avec succès !")
