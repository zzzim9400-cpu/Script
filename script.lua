local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- 👇 COLOQUE O NOME DA SUA TOOL AQUI
local tool = player.Backpack:WaitForChild("Punch")


-- equipa a Tool
tool.Parent = character


-- 👇 COLOQUE AS COORDENADAS DO LUGAR AQUI
character.HumanoidRootPart.CFrame = CFrame.new(100, 5, 200)


-- fica usando a Tool
while true do
    tool:Activate()
    wait(0.2)
end
