============================================================
--  PAINEL DE CÓDIGO - por Replit Agent
--
--  Como usar:
--  1. Execute ESTE script primeiro (Command Bar ou executor)
--  2. Execute QUALQUER outro script depois
--  3. O código do outro script aparece no painel preto
-- ============================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== INTERFACE =====

-- Remove painel antigo se existir
local oldGui = playerGui:FindFirstChild("PainelCodigoGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PainelCodigoGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Painel principal preto
local painel = Instance.new("Frame")
painel.Name = "Painel"
painel.Size = UDim2.new(0, 520, 0, 360)
painel.Position = UDim2.new(0.5, -260, 0.5, -180)
painel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
painel.BorderSizePixel = 0
painel.Active = true
painel.Draggable = true
painel.Parent = screenGui

Instance.new("UICorner", painel).CornerRadius = UDim.new(0, 7)

local borda = Instance.new("UIStroke")
borda.Color = Color3.fromRGB(50, 50, 50)
borda.Thickness = 1
borda.Parent = painel

-- Barra de título
local titulo = Instance.new("Frame")
titulo.Size = UDim2.new(1, 0, 0, 32)
titulo.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
titulo.BorderSizePixel = 0
titulo.Parent = painel
Instance.new("UICorner", titulo).CornerRadius = UDim.new(0, 7)

local tituloLabel = Instance.new("TextLabel")
tituloLabel.Size = UDim2.new(1, -80, 1, 0)
tituloLabel.Position = UDim2.new(0, 12, 0, 0)
tituloLabel.BackgroundTransparency = 1
tituloLabel.Text = "● Painel de Código"
tituloLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
tituloLabel.TextSize = 13
tituloLabel.Font = Enum.Font.Code
tituloLabel.TextXAlignment = Enum.TextXAlignment.Left
tituloLabel.Parent = titulo

-- Botão fechar
local btnFechar = Instance.new("TextButton")
btnFechar.Size = UDim2.new(0, 26, 0, 20)
btnFechar.Position = UDim2.new(1, -30, 0.5, -10)
btnFechar.BackgroundColor3 = Color3.fromRGB(190, 50, 50)
btnFechar.Text = "✕"
btnFechar.TextColor3 = Color3.fromRGB(255,255,255)
btnFechar.TextSize = 11
btnFechar.Font = Enum.Font.GothamBold
btnFechar.BorderSizePixel = 0
btnFechar.Parent = titulo
Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 4)

btnFechar.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Scroll para o código
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -48)
scroll.Position = UDim2.new(0, 5, 0, 38)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = painel

-- Label de código dentro do scroll
local codeText = Instance.new("TextLabel")
codeText.Size = UDim2.new(1, -10, 0, 0)
codeText.Position = UDim2.new(0, 8, 0, 6)
codeText.AutomaticSize = Enum.AutomaticSize.Y
codeText.BackgroundTransparency = 1
codeText.Text = "-- Aguardando código ser executado...\n-- Execute qualquer script depois deste."
codeText.TextColor3 = Color3.fromRGB(170, 210, 170)
codeText.TextSize = 13
codeText.Font = Enum.Font.Code
codeText.TextXAlignment = Enum.TextXAlignment.Left
codeText.TextYAlignment = Enum.TextYAlignment.Top
codeText.TextWrapped = false
codeText.RichText = false
codeText.Parent = scroll

-- Barra inferior
local rodape = Instance.new("Frame")
rodape.Size = UDim2.new(1, 0, 0, 10)
rodape.Position = UDim2.new(0, 0, 1, -10)
rodape.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
rodape.BorderSizePixel = 0
rodape.Parent = painel

-- ===== LÓGICA DE CAPTURA =====

-- Função que exibe o código no painel com efeito de escrita linha por linha
local function exibirCodigo(codigo)
    if typeof(codigo) ~= "string" or #codigo == 0 then return end

    codeText.Text = ""
    tituloLabel.Text = "● Capturando código..."
    tituloLabel.TextColor3 = Color3.fromRGB(220, 180, 50)

    local linhas = {}
    for linha in (codigo .. "\n"):gmatch("([^\n]*)\n") do
        table.insert(linhas, linha)
    end

    -- Efeito de escrita: adiciona linha por linha
    local textoAtual = ""
    for i, linha in ipairs(linhas) do
        textoAtual = textoAtual .. linha
        if i < #linhas then
            textoAtual = textoAtual .. "\n"
        end
        codeText.Text = textoAtual

        -- Scroll automático para baixo
        task.defer(function()
            scroll.CanvasPosition = Vector2.new(0, math.huge)
        end)

        task.wait(0.012) -- velocidade da escrita (ajuste se quiser mais rápido/lento)
    end

    tituloLabel.Text = "● Código Capturado ✓ (" .. #linhas .. " linhas)"
    tituloLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
end

-- ===== INTERCEPTA LOADSTRING =====
-- Quando você executar outro script depois deste,
-- o loadstring vai ser chamado com o código desse script.

local loadstringOriginal = loadstring

loadstring = function(codigo, fonte, ...)
    -- Exibe o código no painel (em thread separada pra não travar a execução)
    task.spawn(exibirCodigo, codigo)
    -- Executa o código normalmente
    return loadstringOriginal(codigo, fonte, ...)
end

print("[PainelCodigo] ✅ Ativo! Execute qualquer script agora e o código aparecerá no painel.")
