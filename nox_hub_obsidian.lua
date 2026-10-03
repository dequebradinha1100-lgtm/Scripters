-- ====================================================================
-- SERVICES & VARIÁVEIS PRINCIPAIS
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local parentContainer = gethui and gethui() or LocalPlayer:WaitForChild("PlayerGui")
if parentContainer:FindFirstChild("NoxHubGui") then
    parentContainer.NoxHubGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoxHubGui"
ScreenGui.Parent = parentContainer
ScreenGui.ResetOnSpawn = false

-- ====================================================================
-- TELA DE CARREGAMENTO (LOADING SCREEN)
-- ====================================================================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Parent = ScreenGui
LoadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
LoadingFrame.Position = UDim2.new(0.5, -175, 0.5, -105)
LoadingFrame.Size = UDim2.new(0, 350, 0, 210)
LoadingFrame.ClipsDescendants = true

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 12)
LoadingCorner.Parent = LoadingFrame

local LoadingStroke = Instance.new("UIStroke")
LoadingStroke.Color = Color3.fromRGB(40, 40, 50)
LoadingStroke.Thickness = 1.5
LoadingStroke.Parent = LoadingFrame

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Parent = LoadingFrame
LoadTitle.BackgroundTransparency = 1
LoadTitle.Position = UDim2.new(0, 0, 0, 15)
LoadTitle.Size = UDim2.new(1, 0, 0, 25)
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.Text = "NOX HUB"
LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadTitle.TextSize = 18

local LoadDev = Instance.new("TextLabel")
LoadDev.Parent = LoadingFrame
LoadDev.BackgroundTransparency = 1
LoadDev.Position = UDim2.new(0, 0, 0, 42)
LoadDev.Size = UDim2.new(1, 0, 0, 18)
LoadDev.Font = Enum.Font.GothamMedium
LoadDev.Text = "Obsidian UI"
LoadDev.TextColor3 = Color3.fromRGB(120, 120, 140)
LoadDev.TextSize = 12

local LoadWarn = Instance.new("TextLabel")
LoadWarn.Parent = LoadingFrame
LoadWarn.BackgroundTransparency = 1
LoadWarn.Position = UDim2.new(0, 15, 0, 68)
LoadWarn.Size = UDim2.new(1, -30, 0, 85)
LoadWarn.Font = Enum.Font.Gotham
LoadWarn.Text = "Esse script é único e totalmente original!\nAdquira somente com o usuário: 7zhc (Não compre de ninguém).\n\n⚠️ 67 HUB e Dio Brando HUB são cópias que não sabem fazer seu trabalho sozinho."
LoadWarn.TextColor3 = Color3.fromRGB(240, 80, 80)
LoadWarn.TextSize = 10
LoadWarn.TextWrapped = true

local BarBackground = Instance.new("Frame")
BarBackground.Parent = LoadingFrame
BarBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
BarBackground.Position = UDim2.new(0.1, 0, 0.86, 0)
BarBackground.Size = UDim2.new(0.8, 0, 0, 8)

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = BarBackground

local BarFill = Instance.new("Frame")
BarFill.Parent = BarBackground
BarFill.BackgroundColor3 = Color3.fromRGB(60, 220, 100)
BarFill.Size = UDim2.new(0, 0, 1, 0)

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = BarFill

-- Animação de Carregamento
TweenService:Create(BarFill, TweenInfo.new(3.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()

task.delay(3.2, function()
    TweenService:Create(LoadingFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    for _, child in ipairs(LoadingFrame:GetDescendants()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        elseif child:IsA("Frame") then
            TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        end
    end
    task.wait(0.4)
    LoadingFrame:Destroy()
end)

-- ====================================================================
-- CONFIGURAÇÕES DE ESTADO
-- ====================================================================
local AutoFollowEnabled = false
local ReachEnabled = false
local ReachDistance = 3.5
local FollowDistance = 1.8

local TargetCenter = Vector3.new(0, -28.94, 0)
local CenterTolerance = 3.5

local function UpdateCharacter(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- ====================================================================
-- 1. SISTEMA DE DRAG
-- ====================================================================
local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ====================================================================
-- 2. DETECTOR DA BOLA MAIS PRÓXIMA
-- ====================================================================
local function GetClosestBall()
    if not RootPart then return nil end

    local closestBall = nil
    local shortestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "TPS" or obj.Name:lower():find("ball") or obj.Name:lower():find("bola")) then
            local size = obj.Size
            local isCorrectSize = (size.X >= 0.8 and size.X <= 5.0)
            local isAtCenter = (obj.Position - TargetCenter).Magnitude <= CenterTolerance

            if isCorrectSize and not isAtCenter then
                local dist = (obj.Position - RootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestBall = obj
                end
            end
        end
    end

    return closestBall
end

-- ====================================================================
-- 3. DETECTOR DE INPUT MANUAL
-- ====================================================================
local function IsManualMoving()
    local keyMovement = UserInputService:IsKeyDown(Enum.KeyCode.W) or 
                        UserInputService:IsKeyDown(Enum.KeyCode.A) or 
                        UserInputService:IsKeyDown(Enum.KeyCode.S) or 
                        UserInputService:IsKeyDown(Enum.KeyCode.D)
    
    if keyMovement then return true end

    if Humanoid then
        local moveVec = Humanoid.MoveDirection
        if moveVec.Magnitude > 0.05 then
            return true
        end
    end

    return false
end

local function IsSkillPlaying()
    if Humanoid then
        local animator = Humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local name = track.Name:lower()
                if name:find("skill") or name:find("dribble") or name:find("fake") or name:find("shoot") or name:find("head") or name:find("rainbow") or name:find("lambreta") then
                    return true
                end
            end
        end
    end
    return false
end

-- ====================================================================
-- 4. INTERCEPTADOR ANTI-BUG
-- ====================================================================
local rawnamecall
rawnamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and self == Humanoid and (method == "MoveTo" or method == "moveTo") then
        local targetPos = args[1]
        if typeof(targetPos) == "Vector3" then
            if (targetPos - TargetCenter).Magnitude <= CenterTolerance or targetPos == Vector3.zero then
                return nil
            end
        end
    end

    return rawnamecall(self, ...)
end)

-- ====================================================================
-- 5. LOOPS PRINCIPAIS
-- ====================================================================
RunService.RenderStepped:Connect(function()
    if not RootPart or not RootPart.Parent or not Humanoid then return end
    local ball = GetClosestBall()

    if AutoFollowEnabled and ball then
        local manualMove = IsManualMoving()
        local doingSkill = IsSkillPlaying()

        if not manualMove and not doingSkill then
            local ballPos = ball.Position
            local myPos = RootPart.Position
            local targetVector = Vector3.new(ballPos.X, myPos.Y, ballPos.Z)
            local distance = (targetVector - myPos).Magnitude

            if distance > FollowDistance then
                local moveDirection = (targetVector - myPos).Unit
                Humanoid:Move(moveDirection, false)
            end
        end
    end

    if ReachEnabled and ball then
        local distance = (ball.Position - RootPart.Position).Magnitude
        local reachStuds = ReachDistance * 5.0

        if distance <= reachStuds then
            firetouchinterest(RootPart, ball, 0)
            firetouchinterest(RootPart, ball, 1)

            for _, part in ipairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    firetouchinterest(part, ball, 0)
                    firetouchinterest(part, ball, 1)
                end
            end

            for _, child in ipairs(ball:GetChildren()) do
                if child:IsA("TouchTransmitter") then
                    firetouchinterest(RootPart, ball, 0)
                    firetouchinterest(RootPart, ball, 1)
                end
            end
        end
    end
end)

if getgenv().Nousigi then 
	if game.CoreGui:FindFirstChild("Night Mystic GUI") then
		for i, v in ipairs(game.CoreGui:GetChildren()) do
			if string.find(v.Name,  "Night Mystic") then
				v:Destroy()
			end
		end
	end
end
getgenv().Nousigi = true

local DisableAnimation = game.Players.LocalPlayer.PlayerGui:FindFirstChild('TouchGui')

local T1UIColor = {
    ["Border Color"] = Color3.fromRGB(50, 50, 50),
    ["Click Effect Color"] = Color3.fromRGB(200, 40, 40),
    ["Setting Icon Color"] = Color3.fromRGB(200, 200, 200),
    ["Logo Image"] = "rbxassetid://105245380363493",
    ["Search Icon Color"] = Color3.fromRGB(200, 40, 40),
    ["Search Icon Highlight Color"] = Color3.fromRGB(255, 60, 60),
    ["GUI Text Color"] = Color3.fromRGB(240, 240, 240),
    ["Text Color"] = Color3.fromRGB(240, 240, 240),
    ["Placeholder Text Color"] = Color3.fromRGB(100, 100, 100),
    ["Title Text Color"] = Color3.fromRGB(255, 255, 255),
    
    ["Background Main Color"] = Color3.fromRGB(15, 15, 15), 
    ["Background 1 Color"] = Color3.fromRGB(22, 22, 22),
    ["Background 1 Transparency"] = 0.05,
    ["Background 2 Color"] = Color3.fromRGB(30, 30, 30),
    ["Background 3 Color"] = Color3.fromRGB(25, 25, 25),
    ["Background Image"] = "",
    
    ["Page Selected Color"] = Color3.fromRGB(200, 40, 40),
    ["Section Text Color"] = Color3.fromRGB(255, 255, 255),
    ["Section Underline Color"] = Color3.fromRGB(200, 40, 40),
    ["Toggle Border Color"] = Color3.fromRGB(70, 70, 70),
    ["Toggle Checked Color"] = Color3.fromRGB(200, 40, 40),
    ["Toggle Desc Color"] = Color3.fromRGB(180, 180, 180),
    
    ["Button Color"] = Color3.fromRGB(35, 35, 35),
    ["Label Color"] = Color3.fromRGB(28, 28, 28),
    ["Dropdown Icon Color"] = Color3.fromRGB(200, 40, 40),
    ["Dropdown Selected Color"] = Color3.fromRGB(200, 40, 40),
    ["Dropdown Selected Check Color"] = Color3.fromRGB(255, 255, 255),
    
    ["Textbox Highlight Color"] = Color3.fromRGB(200, 40, 40),
    ["Box Highlight Color"] = Color3.fromRGB(200, 40, 40),
    ["Slider Line Color"] = Color3.fromRGB(45, 45, 45),
    ["Slider Highlight Color"] = Color3.fromRGB(200, 40, 40),
    
    ["Tween Animation 1 Speed"] = DisableAnimation and 0 or 0.25,
    ["Tween Animation 2 Speed"] = DisableAnimation and 0 or 0.5,
    ["Tween Animation 3 Speed"] = DisableAnimation and 0 or 0.1,
    ["Text Stroke Transparency"] = .8 
}



getgenv().UIColor = T1UIColor
getgenv().AllControls = {}
getgenv().UIToggled = false


local currcolor = {}
local djtmemay = false
local cac = false
-- ====================================================================
-- NOX HUB + OBSIDIAN UI INTEGRATION
-- Versão separada usando a Obsidian UI.
-- ====================================================================

local Library

local libSuccess, libResult = pcall(function()
    return loadstring(
        game:HttpGet(
            "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"
        )
    )()
end)

if libSuccess and libResult then
    Library = libResult
else
    warn("Failed to load UI Library")
    return
end

local Window = Library:CreateWindow({
    Title = "Nox Hub",
    Footer = "Steal an Egg",
    Center = true,
    AutoShow = true,
    ShowMobileButtons = true
})

local function SafeCallback(fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            warn("Nox Hub: " .. tostring(err))
        end
    end
end

local FollowTab = Window:AddTab("Auto Follow", "rbxassetid://7072725342")
local ReachTab = Window:AddTab("Reach", "rbxassetid://7072725342")
local BallTab = Window:AddTab("Bola", "rbxassetid://7072725342")
local GrassTab = Window:AddTab("Gramado", "rbxassetid://7072725342")
local AntiLagTab = Window:AddTab("Anti-Lag", "rbxassetid://7072725342")

-- AUTO FOLLOW
local FollowSection = FollowTab:AddLeftGroupbox("Auto Follow")
FollowSection:AddToggle("AutoFollow", {
    Text = "Ativar Auto Follow",
    Default = AutoFollowEnabled,
    Description = "Interruptor principal do Auto Follow.",
    Callback = SafeCallback(function(Value)
        AutoFollowEnabled = Value
    end),
})

for _, value in ipairs({1.5, 1.8, 2.2}) do
    FollowSection:AddButton({
        Text = "Definir distância: " .. tostring(value) .. "m",
        Func = SafeCallback(function()
            FollowDistance = value
        end),
        Callback = SafeCallback(function()
            FollowDistance = value
        end),
    })
end

local FollowInfo = FollowTab:AddRightGroupbox("Status")
FollowInfo:AddLabel("O interruptor liga/desliga o Auto Follow.", true)
FollowInfo:AddLabel("WASD/analógico interrompe o acompanhamento durante o movimento manual.", true)

-- REACH
local ReachSection = ReachTab:AddLeftGroupbox("Reach")
ReachSection:AddToggle("Reach", {
    Text = "Ativar Reach",
    Default = ReachEnabled,
    Description = "Interruptor principal do Reach.",
    Callback = SafeCallback(function(Value)
        ReachEnabled = Value
    end),
})

local ReachSlider = ReachSection:AddSlider({
    Text = "Tamanho do Reach",
    Min = 2.0,
    Max = 10.0,
    Default = ReachDistance,
    Rounding = 1,
    Compact = false,
    Callback = SafeCallback(function(Value)
        ReachDistance = tonumber(Value) or ReachDistance
    end),
})

for _, value in ipairs({2.0, 3.5, 5.0, 7.5, 10.0}) do
    ReachSection:AddButton({
        Text = "Definir Reach: " .. tostring(value) .. "m",
        Callback = SafeCallback(function()
            ReachDistance = value
            if ReachSlider and ReachSlider.SetValue then
                ReachSlider:SetValue(value)
            end
        end),
    })
end

local ReachInfo = ReachTab:AddRightGroupbox("Configuração")
ReachInfo:AddLabel("Use o regulador para escolher o tamanho do Reach.", true)
ReachInfo:AddLabel("O interruptor controla se a função fica ativa.", true)

-- BOLA
local BallSection = BallTab:AddLeftGroupbox("Bola")
BallSection:AddToggle("BallFire", {
    Text = "Efeito de Fogo",
    Default = false,
    Description = "Liga/desliga o efeito visual da bola.",
    Callback = SafeCallback(function(Value)
        local ball = GetClosestBall()
        if not ball then return end
        local fire = ball:FindFirstChildOfClass("Fire")
        if Value and not fire then
            local newFire = Instance.new("Fire")
            newFire.Size = 6
            newFire.Parent = ball
        elseif not Value and fire then
            fire:Destroy()
        end
    end),
})

BallSection:AddButton({
    Text = "Cor: Vermelho Neon",
    Callback = SafeCallback(function()
        local ball = GetClosestBall()
        if ball then
            ball.Color = Color3.fromRGB(255, 40, 40)
            ball.Material = Enum.Material.Neon
        end
    end),
})

BallSection:AddButton({
    Text = "Cor: Azul Cyan",
    Callback = SafeCallback(function()
        local ball = GetClosestBall()
        if ball then
            ball.Color = Color3.fromRGB(0, 230, 255)
            ball.Material = Enum.Material.Neon
        end
    end),
})

-- GRAMADO
local ModifiedGrassParts, GrassOriginals = {}, {}
local GrassEnabled = false
local SelectedGrassColor = Color3.fromRGB(15, 75, 30)

local function ApplyGrassColor(color)
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            local isCharacter = part:IsDescendantOf(Players) or (part.Parent and part.Parent:FindFirstChildOfClass("Humanoid"))
            if not isCharacter then
                local n = part.Name:lower()
                local isLine = n:find("line") or n:find("linha") or n:find("white") or part.Transparency > 0.4
                if not isLine and (ModifiedGrassParts[part] or n:find("grass") or n:find("pitch") or n:find("campo") or n:find("field") or n:find("out") or n:find("wedge") or n:find("stadium") or n:find("floor") or (part.Position.Y < 5 and part.Size.X > 8)) then
                    if not GrassOriginals[part] then
                        GrassOriginals[part] = {Color = part.Color, Material = part.Material}
                    end
                    part.Color = color
                    part.Material = Enum.Material.SmoothPlastic
                    ModifiedGrassParts[part] = true
                end
            end
        end
    end
end

local function RestoreGrass()
    for part, original in pairs(GrassOriginals) do
        if part and part.Parent then
            part.Color = original.Color
            part.Material = original.Material
        end
    end
    table.clear(ModifiedGrassParts)
    table.clear(GrassOriginals)
end

local GrassSection = GrassTab:AddLeftGroupbox("Gramado")
GrassSection:AddToggle("GrassEnabled", {
    Text = "Ativar gramado personalizado",
    Default = false,
    Description = "Interruptor para aplicar/remover a cor escolhida.",
    Callback = SafeCallback(function(Value)
        GrassEnabled = Value
        if Value then
            ApplyGrassColor(SelectedGrassColor)
        else
            RestoreGrass()
        end
    end),
})

local function SetGrassColor(color)
    SelectedGrassColor = color
    if GrassEnabled then
        ApplyGrassColor(color)
    end
end

for name, color in pairs({
    ["Verde Dark"] = Color3.fromRGB(15, 75, 30),
    ["Preto Total"] = Color3.fromRGB(18, 18, 22),
    ["Roxo Cyber"] = Color3.fromRGB(80, 20, 120),
    ["Azul Midnight"] = Color3.fromRGB(15, 35, 85),
}) do
    GrassSection:AddButton({
        Text = "Selecionar: " .. name,
        Callback = SafeCallback(function()
            SetGrassColor(color)
        end),
    })
end

-- ANTI-LAG
local AntiLagSection = AntiLagTab:AddLeftGroupbox("Performance")
local OriginalGlobalShadows, OriginalFogEnd = Lighting.GlobalShadows, Lighting.FogEnd

AntiLagSection:AddToggle("ShadowOptimization", {
    Text = "Otimizar sombras",
    Default = false,
    Description = "Interruptor reversível para sombras e neblina.",
    Callback = SafeCallback(function(Value)
        if Value then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
        else
            Lighting.GlobalShadows = OriginalGlobalShadows
            Lighting.FogEnd = OriginalFogEnd
        end
    end),
})

local OriginalMaterials = {}
AntiLagSection:AddToggle("TextureOptimization", {
    Text = "Texturas lisas (FPS)",
    Default = false,
    Description = "Aplica SmoothPlastic e restaura ao desligar.",
    Callback = SafeCallback(function(Value)
        if Value then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(Players) and OriginalMaterials[v] == nil then
                    OriginalMaterials[v] = v.Material
                    v.Material = Enum.Material.SmoothPlastic
                end
            end
        else
            for v, material in pairs(OriginalMaterials) do
                if v and v.Parent then
                    v.Material = material
                end
            end
            table.clear(OriginalMaterials)
        end
    end),
})

AntiLagSection:AddLabel("Os recursos com interruptor podem ser ligados e desligados pelo menu.", true)

return Library
