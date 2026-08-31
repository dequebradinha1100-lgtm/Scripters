-- [[ FACADA HUB - VERSÃO TCS HITBOX OTIMIZADA ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- =====================================================
-- CORES
-- =====================================================

local GREEN = Color3.fromRGB(0, 255, 100)
local GREEN_DARK = Color3.fromRGB(0, 120, 50)
local BG = Color3.fromRGB(5, 25, 15)
local CARD = Color3.fromRGB(10, 50, 28)
local TEXT = Color3.fromRGB(200, 255, 220)

-- =====================================================
-- CONFIG
-- =====================================================

local cfg = {
    reach = 18, -- Aumentado levemente para melhor aproveitamento TCS
    sphere = true,
    touch = true,
    autoFollow = false,
    espEnabled = false,
    punAlert = false
}

local balls = {}
local esps = {}
local spherePart = nil
local targetBall = nil

local character
local humanoid
local hrp
local leftFoot, rightFoot

local function updateCharacter()
    character = Player.Character

    if character then
        humanoid = character:FindFirstChildOfClass("Humanoid")
        hrp = character:FindFirstChild("HumanoidRootPart")
        leftFoot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg")
        rightFoot = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg")
    else
        humanoid = nil
        hrp = nil
        leftFoot = nil
        rightFoot = nil
    end
end

updateCharacter()

Player.CharacterAdded:Connect(function(char)
    character = char
    task.wait(0.5)
    humanoid = char:FindFirstChildOfClass("Humanoid")
    hrp = char:FindFirstChild("HumanoidRootPart")
    leftFoot = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
    rightFoot = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")
end)

-- =====================================================
-- LIMPAR GUI ANTIGA
-- =====================================================

pcall(function()
    local old = PlayerGui:FindFirstChild("FacadaHub_Gui")
    if old then old:Destroy() end
end)

pcall(function()
    local old = PlayerGui:FindFirstChild("FacadaHub_FloatGui")
    if old then old:Destroy() end
end)

-- =====================================================
-- SCREEN GUI
-- =====================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FacadaHub_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- =====================================================
-- MAIN FRAME
-- =====================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 300)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
MainFrame.BackgroundColor3 = BG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = GREEN
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- =====================================================
-- TOP BAR
-- =====================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Color3.fromRGB(3, 15, 8)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 18)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "💚 FACADA HUB (TCS)"
Title.TextColor3 = GREEN
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 34, 0, 34)
Close.Position = UDim2.new(1, -42, 0, 7)
Close.BackgroundColor3 = GREEN_DARK
Close.Text = "✕"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- =====================================================
-- CONTEÚDO
-- =====================================================

local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -58)
Content.Position = UDim2.new(0, 10, 0, 53)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

-- =====================================================
-- TOGGLE
-- =====================================================

local function createToggle(text, default, callback)
    local state = default

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 42)
    Frame.BackgroundColor3 = CARD
    Frame.BorderSizePixel = 0
    Frame.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 11)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = GREEN_DARK
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -100, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = TEXT
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 78, 0, 28)
    Button.Position = UDim2.new(1, -86, 0.5, -14)
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 10
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Parent = Frame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 9)
    ButtonCorner.Parent = Button

    local function update()
        if state then
            Button.BackgroundColor3 = GREEN
            Button.Text = "LIGADO"
        else
            Button.BackgroundColor3 = GREEN_DARK
            Button.Text = "DESLIGADO"
        end
    end

    update()

    Button.MouseButton1Click:Connect(function()
        state = not state
        update()
        pcall(function() callback(state) end)
    end)

    return {
        Set = function(_, value)
            if state ~= value then
                state = value
                update()
                pcall(function() callback(state) end)
            end
        end
    }
end

-- =====================================================
-- SLIDER
-- =====================================================

local function createSlider(text, min, max, default, callback)
    local value = default

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 58)
    Frame.BackgroundColor3 = CARD
    Frame.BorderSizePixel = 0
    Frame.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 11)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = GREEN_DARK
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 22)
    Label.Position = UDim2.new(0, 14, 0, 4)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = TEXT
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -28, 0, 10)
    Bar.Position = UDim2.new(0, 14, 0, 36)
    Bar.BackgroundColor3 = Color3.fromRGB(3, 20, 10)
    Bar.BorderSizePixel = 0
    Bar.Parent = Frame

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 5)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = GREEN
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 5)
    FillCorner.Parent = Fill

    local dragging = false

    local function updateValue(input)
        local percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        value = math.floor(min + ((max - min) * percent))
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Label.Text = text .. ": " .. tostring(value)
        pcall(function() callback(value) end)
    end

    local initialPercent = (value - min) / (max - min)
    Fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    Label.Text = text .. ": " .. tostring(value)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateValue(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- =====================================================
-- BOLAS
-- =====================================================

local function updateBalls()
    balls = {}
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("BasePart") and (object.Name == "TPS" or object.Name == "TrainingBall" or object.Name == "Ball") then
            table.insert(balls, object)
        end
    end
end

local function getClosestBall()
    if not hrp then return nil end
    local closest
    local distance = math.huge

    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local d = (ball.Position - hrp.Position).Magnitude
            if d < distance then
                distance = d
                closest = ball
            end
        end
    end
    return closest
end

-- =====================================================
-- ESFERA (POSICIONADA COM FOCO NA FRENTE - TCS)
-- =====================================================

local function updateSphere()
    if not cfg.sphere then
        if spherePart then
            spherePart:Destroy()
            spherePart = nil
        end
        return
    end

    if not spherePart then
        spherePart = Instance.new("Part")
        spherePart.Name = "FacadaHub_TCSReach"
        spherePart.Shape = Enum.PartType.Ball
        spherePart.Anchored = true
        spherePart.CanCollide = false
        spherePart.CanTouch = false
        spherePart.CanQuery = false
        spherePart.Material = Enum.Material.ForceField
        spherePart.Transparency = 0.65
        spherePart.Color = GREEN
        spherePart.Parent = Workspace
    end

    spherePart.Size = Vector3.new(cfg.reach * 2, cfg.reach * 2, cfg.reach * 2)
end

-- =====================================================
-- ELEMENTOS DA INTERFACE
-- =====================================================

createToggle("💚 Esfera do Reach (TCS)", cfg.sphere, function(value)
    cfg.sphere = value
    updateSphere()
end)

createSlider("📏 Alcance TCS", 1, 40, cfg.reach, function(value)
    cfg.reach = value
    updateSphere()
end)

createToggle("🖐️ Hitbox TCS Ativa", cfg.touch, function(value)
    cfg.touch = value
end)

local autoToggle = createToggle("⚽ Auto Seguir Bola", cfg.autoFollow, function(value)
    cfg.autoFollow = value
    if value then
        targetBall = getClosestBall()
    else
        targetBall = nil
    end
end)

createToggle("💚 Alerta PUN", cfg.punAlert, function(value)
    cfg.punAlert = value
end)

createToggle("👁️ ESP de Bolas", cfg.espEnabled, function(value)
    cfg.espEnabled = value
end)

-- =====================================================
-- BOTÃO FLUTUANTE
-- =====================================================

local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "FacadaHub_FloatGui"
FloatGui.ResetOnSpawn = false
FloatGui.IgnoreGuiInset = true
FloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FloatGui.Parent = PlayerGui

local FollowButton = Instance.new("TextButton")
FollowButton.Name = "SeguirBola"
FollowButton.Size = UDim2.new(0, 180, 0, 48)
FollowButton.Position = UDim2.new(0.72, 0, 0.12, 0)
FollowButton.BackgroundColor3 = BG
FollowButton.Text = "💚 SEGUIR BOLA: OFF"
FollowButton.TextColor3 = Color3.new(1, 1, 1)
FollowButton.Font = Enum.Font.GothamBold
FollowButton.TextSize = 12
FollowButton.BorderSizePixel = 0
FollowButton.Active = true
FollowButton.Draggable = true
FollowButton.Parent = FloatGui

local FollowCorner = Instance.new("UICorner")
FollowCorner.CornerRadius = UDim.new(0, 24)
FollowCorner.Parent = FollowButton

local FollowStroke = Instance.new("UIStroke")
FollowStroke.Color = GREEN
FollowStroke.Thickness = 2
FollowStroke.Parent = FollowButton

local function updateFollowButton()
    if cfg.autoFollow then
        FollowButton.Text = "💚 SEGUIR BOLA: ON"
        FollowButton.TextColor3 = GREEN
    else
        FollowButton.Text = "💚 SEGUIR BOLA: OFF"
        FollowButton.TextColor3 = Color3.new(1, 1, 1)
    end
end

FollowButton.MouseButton1Click:Connect(function()
    cfg.autoFollow = not cfg.autoFollow
    if cfg.autoFollow then
        targetBall = getClosestBall()
    else
        targetBall = nil
    end
    autoToggle:Set(cfg.autoFollow)
    updateFollowButton()
end)

-- =====================================================
-- BOLHA PARA ABRIR/FECHAR
-- =====================================================

local Bubble = Instance.new("TextButton")
Bubble.Name = "FacadaHub_Bubble"
Bubble.Size = UDim2.new(0, 58, 0, 58)
Bubble.Position = UDim2.new(0.04, 0, 0.25, 0)
Bubble.BackgroundColor3 = BG
Bubble.Text = "💚\nFACADA"
Bubble.TextColor3 = GREEN
Bubble.Font = Enum.Font.GothamBold
Bubble.TextSize = 10
Bubble.BorderSizePixel = 0
Bubble.Active = true
Bubble.Draggable = true
Bubble.Parent = ScreenGui

local BubbleCorner = Instance.new("UICorner")
BubbleCorner.CornerRadius = UDim.new(1, 0)
BubbleCorner.Parent = Bubble

local BubbleStroke = Instance.new("UIStroke")
BubbleStroke.Color = GREEN
BubbleStroke.Thickness = 2
BubbleStroke.Parent = Bubble

Bubble.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- =====================================================
-- TECLA RIGHT CTRL / E
-- =====================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end

    if input.KeyCode == Enum.KeyCode.E then
        cfg.autoFollow = not cfg.autoFollow
        if cfg.autoFollow then
            targetBall = getClosestBall()
        else
            targetBall = nil
        end
        autoToggle:Set(cfg.autoFollow)
        updateFollowButton()
    end
end)

-- =====================================================
-- LOOP PRINCIPAL (LÓGICA TCS DE HITBOX AVANÇADA)
-- =====================================================

RunService.Heartbeat:Connect(function()
    updateCharacter()
    updateBalls()

    -- Posicionamento da Esfera com leve offset para frente (Estilo TCS)
    if spherePart and spherePart.Parent and hrp then
        local tcsPosition = hrp.Position + (hrp.CFrame.LookVector * 2)
        spherePart.Position = tcsPosition
    end

    -- Hitbox TCS de Toque de Alta Performance
    if cfg.touch and hrp then
        for _, ball in ipairs(balls) do
            if ball and ball.Parent then
                -- Checa a distância baseada na posição do corpo + pés
                local d = (ball.Position - hrp.Position).Magnitude
                if d <= cfg.reach then
                    pcall(function()
                        if firetouchinterest then
                            -- Dispara usando os pés (se existirem) ou a RootPart para simulação natural TCS
                            local touchPart = leftFoot or rightFoot or hrp
                            firetouchinterest(touchPart, ball, 0)
                            firetouchinterest(touchPart, ball, 1)
                        end
                    end)
                end
            end
        end
    end

    -- Auto Seguir Bola
    if cfg.autoFollow and humanoid and hrp then
        if not targetBall or not targetBall.Parent then
            targetBall = getClosestBall()
        end

        if targetBall and targetBall.Parent then
            humanoid:MoveTo(targetBall.Position)
        end
    end

    -- ESP de Bolas otimizado
    if cfg.espEnabled then
        for _, ball in ipairs(balls) do
            if ball and ball.Parent and not esps[ball] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "FacadaHub_ESP"
                highlight.Adornee = ball
                highlight.FillColor = GREEN
                highlight.FillTransparency = 0.45
                highlight.OutlineColor = GREEN_DARK
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = ball

                esps[ball] = highlight
            end
        end

        for ball, highlight in pairs(esps) do
            if not ball.Parent then
                pcall(function() highlight:Destroy() end)
                esps[ball] = nil
            end
        end
    else
        for ball, highlight in pairs(esps) do
            pcall(function() highlight:Destroy() end)
        end
        esps = {}
    end
end)

-- =====================================================
-- INICIALIZAÇÃO
-- =====================================================

updateBalls()
updateSphere()
updateFollowButton()

MainFrame.Visible = true

print("FACADA HUB (TCS HITBOX) carregado com sucesso!")
