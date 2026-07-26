local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/main/Source.lua"))()
local Window = redzlib:MakeWindow({
    Title = "Admin-X Beta",
    SubTitle = "Dont expect it to be perfect ",
    SaveFolder = "Admin-x 1 Config"
})

local Tab = Window:MakeTab({"Ui"})
local Tab = Window:MakeTab({"Npc"})
local Tab = Window:MakeTab({"Tools"})

local Section = Tab:AddSection({ Name = "Client Side" })
Tab:AddButton({
    Name = "Teleoport tool",
    Callback = function()
        local plr = game:GetService("Players").LocalPlayer
        local mouse = plr:GetMouse()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "[Teleport Tool]"
        tool.Activated:Connect(function()
            local root = plr.Character.HumanoidRootPart
            local pos = mouse.Hit.Position+Vector3.new(0,2.5,0)
            local offset = pos-root.Position
            root.CFrame = root.CFrame+offset
        end)
        tool.Parent = plr.Backpack
    end
})

local Section = Tab:AddSection({ Name = "Server Side" })
local dropdownOptions = {"None"}
local autoUpdateEnabled = false

local function updateTools()
    if not autoUpdateEnabled then return end
    for _, tool in pairs(game:GetDescendants()) do
        if tool:IsA("Tool") and not table.find(dropdownOptions, tool.Name) then
            table.insert(dropdownOptions, tool.Name)
            Tab:SetDropdownOptions("ToolSelector", dropdownOptions)
        end
    end
end

local Section = Tab:AddSection({ Name = "Select a Tool" })
Tab:AddDropdown({
    Name = "ToolSelector",
    Default = "None",
    Options = dropdownOptions,
    Callback = function(Value)
        if Value ~= "None" then
            local player = game.Players.LocalPlayer
            local tool = game:FindFirstChild(Value, true)
            if tool and player.Backpack then
                local clonedTool = tool:Clone()
                clonedTool.Parent = player.Backpack
            end
        end
    end
})

game:GetService("RunService").Heartbeat:Connect(updateTools)

local Section = Tab:AddSection({ Name = "Auto Update" })
Tab:AddToggle({
    Name = "Auto Update",
    Default = false,
    Callback = function(Value) autoUpdateEnabled = Value end
})

local Section = Tab:AddSection({ Name = "Update" })
Tab:AddButton({
    Name = "Update DropDown",
    Callback = function()
        for _, tool in pairs(game:GetDescendants()) do
            if tool:IsA("Tool") and not table.find(dropdownOptions, tool.Name) then
                table.insert(dropdownOptions, tool.Name)
            end
        end
        Tab:SetDropdownOptions("ToolSelector", dropdownOptions)
    end
})

local Tab = Window:MakeTab({"Esp"})
local Section = Tab:AddSection({ Name = "Player Esp" })
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESPColor = {
    ["Red"] = Color3.fromRGB(255, 0, 0),
    ["Blue"] = Color3.fromRGB(0, 0, 255)
}

local function getTeamColor(player)
    if player.Team then
        return ESPColor[player.Team.Name] or Color3.fromRGB(255, 255, 255)
    else
        return Color3.fromRGB(255, 255, 255)
    end
end

local ESPEnabled = false
local ESPFrames = {}

local function createESP(player)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local box = Drawing.new("Square")
        box.Color = getTeamColor(player)
        box.Thickness = 1
        box.Transparency = 0.5
        local text = Drawing.new("Text")
        text.Size = 16
        text.Color = Color3.fromRGB(255, 255, 255)
        text.Outline = true
        local runService = game:GetService("RunService")
        local connection
        connection = runService.RenderStepped:Connect(function()
            if ESPEnabled and character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                local rootPartPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    box.Size = Vector2.new(2000 / rootPartPosition.Z, 2000 / rootPartPosition.Z)
                    box.Position = Vector2.new(rootPartPosition.X - box.Size.X / 2, rootPartPosition.Y - box.Size.Y / 2)
                    box.Visible = true
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    text.Text = string.format("%s\nHP: %d\nDist: %d", player.Name, math.floor(player.Character.Humanoid.Health), math.floor(distance))
                    text.Position = Vector2.new(rootPartPosition.X, rootPartPosition.Y - box.Size.Y / 2 - 20)
                    text.Visible = true
                else
                    box.Visible = false
                    text.Visible = false
                end
            else
                box.Visible = false
                text.Visible = false
                connection:Disconnect()
                box:Remove()
                text:Remove()
            end
        end)
        table.insert(ESPFrames, {box = box, text = text, connection = connection})
    end
end

local function addESPToAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then createESP(player) end
    end
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(character) createESP(player) end)
        end
    end)
end

local function removeESPFrames()
    for _, frame in ipairs(ESPFrames) do
        frame.connection:Disconnect()
        frame.box:Remove()
        frame.text:Remove()
    end
    ESPFrames = {}
end

local Toggle = Tab:AddToggle({
    Name = "Turn On Player ESP",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then addESPToAllPlayers() else removeESPFrames() end
    end
})

local Tab = Window:MakeTab({"testing"})
Tab:AddButton({
    Name = "Death Counter",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local function onTouch(otherPart)
            local otherCharacter = otherPart.Parent
            if otherCharacter and otherCharacter:IsA("Model") and otherCharacter:FindFirstChild("Humanoid") then
                local otherHumanoidRootPart = otherCharacter:FindFirstChild("HumanoidRootPart")
                if otherHumanoidRootPart then
                    local direction = otherHumanoidRootPart.CFrame.LookVector
                    local newPosition = otherHumanoidRootPart.CFrame * CFrame.new(-direction.X * 5, 0, -direction.Z * 5)
                    humanoidRootPart.CFrame = newPosition
                end
            end
        end
        humanoidRootPart.Touched:Connect(onTouch)
    end
})

Tab:AddButton({Name = "Arceus x", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3"))() end})
Tab:AddButton({Name = "Arceus x", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3"))() end})
Tab:AddButton({Name = "Arceus x", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3"))() end})
Tab:AddButton({Name = "Arceus x", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3"))() end})
Tab:AddButton({Name = "Update DropDown", Callback = function() end})

Tab:AddButton({
    Name = "The Diffrentce",
    Callback = function()
        local TweenService = game:GetService("TweenService")
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local function createTween(part, properties, duration, easingStyle, easingDirection)
            local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
            local tween = TweenService:Create(part, tweenInfo, properties)
            return tween
        end
        local function tweenCharacter()
            local tween1 = createTween(humanoidRootPart, {CFrame = humanoidRootPart.CFrame * CFrame.new(5, 0, 0)}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
            local tween2 = createTween(humanoidRootPart, {CFrame = humanoidRootPart.CFrame * CFrame.new(-10, 0, 0)}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
            local tween3 = createTween(humanoidRootPart, {CFrame = humanoidRootPart.CFrame * CFrame.new(5, 0, 0)}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
            local tween4 = createTween(humanoidRootPart, {CFrame = humanoidRootPart.CFrame * CFrame.new(0, 50, 0)}, 1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
            tween1:Play()
            tween1.Completed:Connect(function() tween2:Play() end)
            tween2.Completed:Connect(function() tween3:Play() end)
            tween3.Completed:Connect(function() tween4:Play() end)
        end
        tweenCharacter()
    end
})

local Toggle = Tab:AddToggle({
    Name = "Move Mining Pads",
    Default = false,
    Callback = function(Value)
        toggle = Value
        if toggle then moveMiningPadsToPlayer() end
    end
})

local player = game.Players.LocalPlayer
local toggle = false

local function moveMiningPadsToPlayer()
    local miningPadsFolder = workspace:FindFirstChild("MiningPads")
    if not miningPadsFolder then print("MiningPads folder not found") return end
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then print("HumanoidRootPart not found") return end
    for _, part in pairs(miningPadsFolder:GetChildren()) do
        if part:IsA("BasePart") then
            part.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

local Tab = Window:MakeTab({"Local Player"})
local Section = Tab:AddSection({ Name = "Local Player" })
local Section = Tab:AddSection({ Name = "Set Speed" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local lastSpeed = 16

local CoolSlider = Tab:AddSlider({
    Name = "Player Walk Speed",
    Min = 0,
    Max = 759,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        lastSpeed = value
        if Toggle.Enabled then LocalPlayer.Character.Humanoid.WalkSpeed = value end
    end,
})

local Toggle = Tab:AddToggle({
    Name = "Set Speed",
    Default = false,
    Callback = function(Value)
        Toggle.Enabled = Value
        if Value then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = lastSpeed
            end
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").WalkSpeed = Toggle.Enabled and lastSpeed or 16
end)

LocalPlayer.Character:WaitForChild("Humanoid").AncestryChanged:Connect(function(child, parent)
    if parent and child:IsA("Humanoid") then
        child.WalkSpeed = Toggle.Enabled and lastSpeed or 16
    end
end)

local Section = Tab:AddSection({ Name = "Set jump" })
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local lastJumpHeight = 7.2

local JumpSlider = Tab:AddSlider({
    Name = "Player Jump Height",
    Min = 0,
    Max = 100,
    Default = 7.2,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Jump",
    Callback = function(value)
        lastJumpHeight = value
        if JumpToggle.Enabled then LocalPlayer.Character.Humanoid.JumpHeight = value end
    end,
})

local JumpToggle = Tab:AddToggle({
    Name = "Set Jump Height",
    Default = false,
    Callback = function(Value)
        JumpToggle.Enabled = Value
        if Value then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpHeight = lastJumpHeight
            end
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpHeight = 7.2
            end
        end
    end
})

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").JumpHeight = JumpToggle.Enabled and lastJumpHeight or 7.2
end)

LocalPlayer.Character:WaitForChild("Humanoid").AncestryChanged:Connect(function(child, parent)
    if parent and child:IsA("Humanoid") then
        child.JumpHeight = JumpToggle.Enabled and lastJumpHeight or 7.2
    end
end)

local Section = Tab:AddSection({ Name = "Set Gravity" })
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local lastGravity = 54

local GravitySlider = Tab:AddSlider({
    Name = "Player Gravity",
    Min = 0,
    Max = 100,
    Default = 54,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Gravity",
    Callback = function(value)
        lastGravity = value
        if GravityToggle.Enabled then game.Workspace.Gravity = value end
    end,
})

local GravityToggle = Tab:AddToggle({
    Name = "Set Player Gravity",
    Default = false,
    Callback = function(Value)
        GravityToggle.Enabled = Value
        if Value then game.Workspace.Gravity = lastGravity else game.Workspace.Gravity = 54 end
    end
})

LocalPlayer.CharacterAdded:Connect(function(character)
    if GravityToggle.Enabled then game.Workspace.Gravity = lastGravity else game.Workspace.Gravity = 54 end
end)

LocalPlayer.Character:WaitForChild("Humanoid").AncestryChanged:Connect(function(child, parent)
    if parent and child:IsA("Humanoid") then
        if GravityToggle.Enabled then game.Workspace.Gravity = lastGravity else game.Workspace.Gravity = 54 end
    end
end)

local Section = Tab:AddSection({ Name = "Pet Simulator Games" })
local autoCollectOrbs = false
local autoCollectLootbags = false

local ToggleOrbs = Tab:AddToggle({
    Name = "Auto Collect Orbs",
    Default = false,
    Callback = function(Value)
        autoCollectOrbs = Value
        if autoCollectOrbs then collectOrbs() end
    end
})

local function collectOrbs()
    while autoCollectOrbs do
        local fororbs = workspace.__THINGS.Orbs:GetChildren()
        local MyOrbs = {}
        if #fororbs > 0 then
            for i, v in next, fororbs do
                MyOrbs[i] = tonumber(v.Name)
                v:Destroy()
            end
        end
        RE("Orbs: Collect"):FireServer(MyOrbs)
        wait(1)
    end
end

local ToggleLootbags = Tab:AddToggle({
    Name = "Auto Collect Lootbags",
    Default = false,
    Callback = function(Value)
        autoCollectLootbags = Value
        if autoCollectLootbags then collectLootbags() end
    end
})

local function collectLootbags()
    while autoCollectLootbags do
        local forlootbags = workspace.__THINGS.Lootbags:GetChildren()
        local MyLootbags = {}
        if #forlootbags > 0 then
            for i, v in next, forlootbags do
                MyLootbags[i] = tonumber(v.Name)
                v:Destroy()
            end
        end
        RE("Lootbags: Collect"):FireServer(MyLootbags)
        wait(1)
    end
end

spawn(function() while true do if autoCollectOrbs then collectOrbs() end wait(1) end end)
spawn(function() while true do if autoCollectLootbags then collectLootbags() end wait(1) end end)

local Toggle = Tab:AddToggle({
    Name = "Auto Collect Ranked Rewards",
    Default = false,
    Callback = function(Value)
        local ClaimRanks = Value
        for _,v in Player.PlayerGui.Rank.Frame.Rewards.Items.Unlocks:GetChildren() do
            if v.Name == "ClaimSlot" then
                RE("Ranks_ClaimReward"):FireServer(tonumber(v.Title.Text))
            end
        end
    end
})

local Section = Tab:AddSection({ Name = "Afk Section" })
local Toggle = Tab:AddToggle({
    Name = "Anti-Afk",
    Default = false,
    Callback = function(Value)
        if Value then
            getconnections(game:GetService("Players").LocalPlayer.Idled):Disable()
        else
            print('Anti-AfK Script Not Active')
        end
    end
})

local Section = Tab:AddSection({ Name = "Tools" })
Tab:AddButton({Name = "Arceus x", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3"))() end})
Tab:AddButton({Name = "aim lock", Callback = function() loadstring(game:HttpGet("https://rentry.co/n55gmtpi/raw", true))() end})
Tab:AddButton({Name = "Remote spy", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/SimpleSpy/main/Mobile.lua"))() end})
Tab:AddButton({Name = "Dex Explorer", Callback = function() loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/Dex%20Explorer.txt"))() end})
Tab:AddButton({Name = "Dex explorer keyless", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/DEX-Explorer/main/Mobile.lua"))() end})
Tab:AddButton({Name = "Inf Yeld", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})
Tab:AddButton({Name = "stream sniper", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/FFJ1/Roblox-Exploits/main/scripts/Sniper.lua"))() end})
Tab:AddButton({Name = "Player Hub", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/JustAP1ayer/PlayerHubOther/main/PlayerHubLoader.lua"))() end})
Tab:AddButton({Name = "Name less Admin", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))() end})
Tab:AddButton({Name = "Eclipse hub", Callback = function() getgenv().mainKey = "nil" loadstring(game:HttpGet("https://api.eclipsehub.xyz/auth"))() end})

Tab:AddButton({
    Name = "vector position finder",
    Callback = function()
        local ScreenGui = Instance.new("ScreenGui")
        local Frame = Instance.new("Frame")
        local title = Instance.new("TextLabel")
        local copy = Instance.new("TextButton")
        local pos = Instance.new("TextBox")
        local find = Instance.new("TextButton")
        ScreenGui.Parent = game.CoreGui
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        Frame.Parent = ScreenGui
        Frame.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
        Frame.BorderSizePixel = 0
        Frame.Position = UDim2.new(0.639646292, 0, 0.399008662, 0)
        Frame.Size = UDim2.new(0, 387, 0, 206)
        Frame.Active = true
        title.Name = "title"
        title.Parent = Frame
        title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        title.BorderSizePixel = 0
        title.Size = UDim2.new(0, 387, 0, 50)
        title.Font = Enum.Font.GothamBold
        title.Text = "Position Finder"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 30.000
        title.TextWrapped = true
        copy.Name = "copy"
        copy.Parent = Frame
        copy.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        copy.BorderSizePixel = 0
        copy.Position = UDim2.new(0.527131796, 0, 0.635922313, 0)
        copy.Size = UDim2.new(0, 148, 0, 50)
        copy.Font = Enum.Font.GothamSemibold
        copy.Text = "Copy"
   