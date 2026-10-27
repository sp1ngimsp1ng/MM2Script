local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/sp1ngimsp1ng/MM2Script/refs/heads/main/core.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Sp1ng Hub",
    Subtitle = "MM2",
    Icon = "rbxassetid://4483362458",
    Author = "Sp1ng",
    Folder = "Sp1ngHub",
    Size = UDim2.fromOffset(580, 420),
    Transparent = true,
    Theme = "Dark",
})

Window:EditOpenButton({
    Title = "Sp1ng Hub",
    Icon = "rbxassetid://4483362458",
    CornerRadius = UDim.new(0, 10),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
    })
})

local StartTab = Window:Tab({ Title = "Start", Icon = "home" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local AutomationsTab = Window:Tab({ Title = "Automations", Icon = "bot" })

local function notify(title, content)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = 3,
        Icon = "info"
    })
end

StartTab:Paragraph({
    Title = "Information",
    Desc = "Roblox Username: Rafoufou281117"
})

StartTab:Button({
    Title = "Copy Discord Link",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/3xErtdKr2D") end)
        notify("Success", "Discord link copied to clipboard!")
    end
})

StartTab:Button({
    Title = "Copy YouTube Link",
    Callback = function()
        pcall(function() setclipboard("https://youtube.com/@scr1ptSp1ng") end)
        notify("Success", "YouTube link copied to clipboard!")
    end
})

StartTab:Button({
    Title = "Copy ScriptBlox Link",
    Callback = function()
        pcall(function() setclipboard("https://scriptblox.com/u/Sp1ng") end)
        notify("Success", "ScriptBlox link copied to clipboard!")
    end
})

StartTab:Button({
    Title = "Copy Rscripts Link",
    Callback = function()
        pcall(function() setclipboard("https://rscripts.net/@Sp1ng") end)
        notify("Success", "Rscripts link copied to clipboard!")
    end
})

local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(playerNames, p.Name)
    end
end

PlayerTab:Dropdown({
    Title = "TP Player",
    Values = playerNames,
    Value = "",
    Callback = function(v)
        local target = Players:FindFirstChild(v)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Core.getHRP()
            if hrp then
                hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

PlayerTab:Slider({
    Title = "Walk Speed",
    Value = {
        Min = 16,
        Max = 150,
        Default = 16,
    },
    Step = 1,
    Callback = function(v)
        Core.MovementSettings.WalkSpeed = v
        local hum = Core.getHumanoid()
        if hum then hum.WalkSpeed = v end
    end
})

PlayerTab:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v) Core.MovementSettings.InfJump = v end
})

UserInputService.JumpRequest:Connect(function()
    if Core.MovementSettings.InfJump then
        local hum = Core.getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

PlayerTab:Toggle({
    Title = "Anti Fling",
    Default = false,
    Callback = function(v)
        Core.MovementSettings.AntiFling = v
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CanCollide = not v end
            end
        end
    end
})

PlayerTab:Button({
    Title = "Fling Murderer",
    Callback = function()
        local murderer = Core.getMurderer()
        if murderer then
            task.spawn(function() Core.flingPlayer(murderer) end)
        else
            notify("Error", "No Murderer found!")
        end
    end
})

PlayerTab:Button({
    Title = "Fling Sheriff",
    Callback = function()
        local sheriff = Core.getSheriff()
        if sheriff then
            task.spawn(function() Core.flingPlayer(sheriff) end)
        else
            notify("Error", "No Sheriff found!")
        end
    end
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

ESPTab:Toggle({ Title = "Innocent ESP", Default = false, Callback = function(v) Core.VisualSettings.InnocentESP = v end })
ESPTab:Toggle({ Title = "Sheriff ESP", Default = false, Callback = function(v) Core.VisualSettings.SheriffESP = v end })
ESPTab:Toggle({ Title = "Murder ESP", Default = false, Callback = function(v) Core.VisualSettings.MurderESP = v end })

local gunEspHighlight = nil
ESPTab:Toggle({
    Title = "Gun ESP",
    Default = false,
    Callback = function(v)
        Core.VisualSettings.GunESP = v
        if not v and gunEspHighlight then
            gunEspHighlight:Destroy()
            gunEspHighlight = nil
        end
    end
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

AutomationsTab:Toggle({
    Title = "Auto TP Gun",
    Default = false,
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
    end
})

AutomationsTab:Toggle({
    Title = "Auto Shoot Murderer",
    Default = false,
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
    end
})

AutomationsTab:Toggle({
    Title = "Coins Farm",
    Default = false,
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
    end
})

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.S then
        Window:Toggle()
    end
end)

notify("Sp1ng Hub", "Successfully loaded!")
