local player = game.Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MinhaUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = screenGui

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 50)
titulo.Text = "Minha UI"
titulo.TextSize = 25
titulo.TextColor3 = Color3.new(1, 1, 1)
titulo.BackgroundTransparency = 1
titulo.Parent = frame

local botao = Instance.new("TextButton")
botao.Size = UDim2.new(0, 200, 0, 50)
botao.Position = UDim2.new(0.5, -100, 0.5, -10)
botao.Text = "Clique aqui"
botao.TextSize = 20
botao.Parent = frame

botao.MouseButton1Click:Connect(function()
	print("Botão clicado!")
end)
