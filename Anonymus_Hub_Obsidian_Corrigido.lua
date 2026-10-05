-- ============================================================
-- ANONYMUS HUB
-- Obsidian Edition
-- Smile 7 + Auto Follow atualizado
-- ============================================================

-- =========================
-- OBSIDIAN UI
-- =========================

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
    warn("Failed to load Obsidian UI")
    return
end

local Window = Library:CreateWindow({
    Title = "Anonymus Hub",
    Footer = "by anonymus lindo",
    Center = true,
    AutoShow = true,
    ShowMobileButtons = true
})

-- =========================
-- SERVICES
-- =========================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- =========================
-- CONFIG
-- =========================

local cfg = {
    reachEnabled = true,
    reach = 10,
    sphere = true,
    reachColor = Color3.fromRGB(0, 255, 255),

    bolaBrancaAtiva = false,
    textureInputText = "",
    meshInputText = "",

    autoFollow = false,
    followDistance = 1.8,
    teleportOffset = 3,

    kickOn = false,
    kick = 5,

    magneticEnabled = false,
    magneticStrength = 50,

    esp = true,
    espTrainingOnly = false,
    espPlayers = false,
    espLines = false,

    walkSpeedEnabled = false,
    walkSpeed = 16,
    infiniteJump = false,
    spin = false,
    spinSpeed = 3,
    autoReset = false,
    rgbPlayer = false
}

-- =========================
-- STATE
-- =========================

local char, humanoid, hrp
local balls = {}
local esps = {}
local playerEsps = {}
local dadosOriginais = {}

local sp = nil
local targetBall = nil
local savedGoalPosition = nil

local spinAngle = 0
local rgbHue = 0
local rgbConnection = nil

-- =========================
-- CHARACTER
-- =========================

local function atualizarChar()
    char = LocalPlayer.Character

    if char then
        humanoid = char:FindFirstChildOfClass("Humanoid")
        hrp = char:FindFirstChild("HumanoidRootPart")
    else
        humanoid = nil
        hrp = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    atualizarChar()
end)

atualizarChar()

-- =========================
-- BALL NAMES
-- =========================

local bolaNomes = {
    TPS = true,
    ESA = true,
    MRS = true,
    PRS = true,
    MPS = true,
    SSS = true,
    AIFA = true,
    RBZ = true,
    Football = true,
    Ball = true,
    SoccerBall = true,
    Hitbox = true,
    Bola = true,
    TrainingBall = true
}

-- =========================
-- BALL DETECTION
-- =========================

local TargetCenter = Vector3.new(0, -28.94, 0)
local CenterTolerance = 3.5

local function ObterBolas()
    local lista = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nome = obj.Name
            local lower = nome:lower()

            if bolaNomes[nome]
                or lower:find("ball")
                or lower:find("bola")
                or lower:find("tcs")
            then
                table.insert(lista, obj)
            end
        end
    end

    return lista
end

local function AcharBolaMaisProxima()
    if not hrp or not hrp.Parent then
        return nil
    end

    local maisProxima
    local menorDist = math.huge

    for _, obj in ipairs(ObterBolas()) do
        if obj and obj.Parent then
            local size = obj.Size

            local tamanhoValido =
                size.X >= 0.8 and
                size.X <= 5

            local noCentro =
                (obj.Position - TargetCenter).Magnitude <= CenterTolerance

            if tamanhoValido and not noCentro then
                local distancia =
                    (obj.Position - hrp.Position).Magnitude

                if distancia < menorDist then
                    menorDist = distancia
                    maisProxima = obj
                end
            end
        end
    end

    return maisProxima
end

-- =========================
-- MOVEMENT DETECTION
-- =========================

local function MovimentoManual()
    if UserInputService:IsKeyDown(Enum.KeyCode.W)
        or UserInputService:IsKeyDown(Enum.KeyCode.A)
        or UserInputService:IsKeyDown(Enum.KeyCode.S)
        or UserInputService:IsKeyDown(Enum.KeyCode.D)
    then
        return true
    end

    if humanoid and humanoid.MoveDirection.Magnitude > 0.05 then
        return true
    end

    return false
end

local function AnimacaoDeSkill()
    if not humanoid then
        return false
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        return false
    end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local nome = track.Name:lower()

        if nome:find("skill")
            or nome:find("dribble")
            or nome:find("fake")
            or nome:find("shoot")
            or nome:find("head")
            or nome:find("rainbow")
            or nome:find("lambreta")
        then
            return true
        end
    end

    return false
end

-- =========================
-- REACH SPHERE
-- =========================

local function AtualizarEsfera()
    if not cfg.sphere then
        if sp and sp.Parent then
            sp:Destroy()
        end
        sp = nil
        return
    end

    if not sp or not sp.Parent then
        sp = Instance.new("Part")
        sp.Name = "AnonymusReachSphere"
        sp.Shape = Enum.PartType.Ball
        sp.Anchored = true
        sp.CanCollide = false
        sp.CanTouch = false
        sp.CanQuery = false
        sp.Transparency = 0.7
        sp.Material = Enum.Material.ForceField
        sp.Parent = Workspace
    end

    sp.Size = Vector3.new(
        cfg.reach * 2,
        cfg.reach * 2,
        cfg.reach * 2
    )

    sp.Color = cfg.reachColor
end

-- =========================
-- IDS
-- =========================

local function FormatarID(id)
    if not id or id == "" then
        return ""
    end

    local num = string.match(id, "%d+")
    return num and ("rbxassetid://" .. num) or id
end

-- =========================
-- ORIGINAL BALL DATA
-- =========================

local function SalvarOriginal(b)
    if dadosOriginais[b] then
        return
    end

    local mesh = b:FindFirstChildOfClass("SpecialMesh")
    local decalMap = {}

    for _, c in ipairs(b:GetChildren()) do
        if c:IsA("Decal") or c:IsA("Texture") then
            decalMap[c] = {
                Texture = c.Texture,
                Transparency = c.Transparency
            }
        end
    end

    dadosOriginais[b] = {
        Color = b.Color,
        Material = b.Material,
        TextureID = b:IsA("MeshPart") and b.TextureID or "",
        MeshId = b:IsA("MeshPart") and b.MeshId or "",
        SpecialMeshId = mesh and mesh.MeshId or "",
        SpecialMeshTexture = mesh and mesh.TextureId or "",
        Decals = decalMap
    }
end

local function RestaurarTexture()
    cfg.textureInputText = ""

    for _, b in ipairs(ObterBolas()) do
        pcall(function()
            local original = dadosOriginais[b]
            if not original then
                return
            end

            if b:IsA("MeshPart") then
                b.TextureID = original.TextureID
            end

            local mesh = b:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                mesh.TextureId = original.SpecialMeshTexture
            end

            for _, c in ipairs(b:GetChildren()) do
                if c:IsA("Decal") or c:IsA("Texture") then
                    local data = original.Decals[c]
                    if data then
                        c.Texture = data.Texture
                        c.Transparency = data.Transparency
                    end
                end
            end
        end)
    end
end

local function RestaurarMesh()
    cfg.meshInputText = ""

    for _, b in ipairs(ObterBolas()) do
        pcall(function()
            local original = dadosOriginais[b]
            if not original then
                return
            end

            if b:IsA("MeshPart") and original.MeshId ~= "" then
                b.MeshId = original.MeshId
            end

            local mesh = b:FindFirstChildOfClass("SpecialMesh")
            if mesh and original.SpecialMeshId ~= "" then
                mesh.MeshId = original.SpecialMeshId
            end
        end)
    end
end

local function AplicarBola()
    local texture = FormatarID(cfg.textureInputText)
    local meshId = FormatarID(cfg.meshInputText)

    for _, b in ipairs(ObterBolas()) do
        pcall(function()
            SalvarOriginal(b)

            local mesh = b:FindFirstChildOfClass("SpecialMesh")

            if meshId ~= "" then
                if b:IsA("MeshPart") then
                    b.MeshId = meshId
                else
                    if not mesh then
                        mesh = Instance.new("SpecialMesh")
                        mesh.Parent = b
                    end

                    mesh.MeshType = Enum.MeshType.FileMesh
                    mesh.MeshId = meshId
                end
            end

            if texture ~= "" then
                if b:IsA("MeshPart") then
                    b.TextureID = texture
                end

                if mesh then
                    mesh.TextureId = texture
                end

                for _, c in ipairs(b:GetChildren()) do
                    if c:IsA("Decal") or c:IsA("Texture") then
                        c.Texture = texture
                    end
                end
            end

            if cfg.bolaBrancaAtiva then
                b.Color = Color3.fromRGB(255, 255, 255)
                b.Material = Enum.Material.SmoothPlastic

                for _, c in ipairs(b:GetChildren()) do
                    if c:IsA("SurfaceAppearance") then
                        c.Enabled = false
                    end
                end
            else
                local original = dadosOriginais[b]

                if original then
                    b.Color = original.Color
                    b.Material = original.Material
                end

                for _, c in ipairs(b:GetChildren()) do
                    if c:IsA("SurfaceAppearance") then
                        c.Enabled = true
                    end
                end
            end
        end)
    end
end

-- =========================
-- TELEPORT
-- =========================

local function TeleportarParaBola()
    if not hrp then
        return
    end

    local ball = AcharBolaMaisProxima()
    if not ball then
        return
    end

    hrp.CFrame =
        ball.CFrame * CFrame.new(0, cfg.teleportOffset, 0)
end

local function SalvarPosicaoGol()
    if hrp then
        savedGoalPosition = hrp.CFrame
    end
end

local function IrParaGol()
    if hrp and savedGoalPosition then
        hrp.CFrame = savedGoalPosition
    end
end

-- =========================
-- RGB
-- =========================

local function DefinirRGB(ativo)
    cfg.rgbPlayer = ativo

    if rgbConnection then
        rgbConnection:Disconnect()
        rgbConnection = nil
    end

    if not ativo then
        return
    end

    rgbConnection = RunService.RenderStepped:Connect(function()
        rgbHue = (rgbHue + 0.5) % 360

        local cor = Color3.fromHSV(
            rgbHue / 360,
            1,
            1
        )

        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Color = cor
                end
            end
        end
    end)
end

-- =========================
-- ESP
-- =========================

local function CriarESPBall(b)
    if esps[b] then
        return
    end

    local gui = Instance.new("BillboardGui")
    gui.Name = "AnonymusBallESP"
    gui.Adornee = b
    gui.Size = UDim2.new(0, 70, 0, 35)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui

    esps[b] = {
        gui = gui,
        text = label
    }
end

local function LimparESP()
    for b, data in pairs(esps) do
        pcall(function()
            data.gui:Destroy()
        end)
        esps[b] = nil
    end
end

-- =========================
-- OBSIDIAN TABS
-- =========================

local TabReach = Window:AddTab("Reach", "crosshair")
local TabCustom = Window:AddTab("Customizar Bola", "palette")
local TabGameplay = Window:AddTab("Teleports", "gamepad-2")
local TabBola = Window:AddTab("Bola", "circle")
local TabESP = Window:AddTab("ESP", "eye")
local TabPersonagem = Window:AddTab("Personagem", "user")

-- =========================
-- REACH
-- =========================

local ReachBox = TabReach:AddLeftGroupbox("Reach")

ReachBox:AddToggle("ReachEnabled", {
    Text = "Ativar Reach",
    Default = cfg.reachEnabled,
    Callback = function(v)
        cfg.reachEnabled = v
    end
})

local ReachSlider = ReachBox:AddSlider({
    Text = "Alcance",
    Min = 1,
    Max = 50,
    Default = cfg.reach,
    Rounding = 0,
    Callback = function(v)
        cfg.reach = tonumber(v) or cfg.reach
        AtualizarEsfera()
    end
})

ReachBox:AddToggle("ReachSphere", {
    Text = "Mostrar Esfera",
    Default = cfg.sphere,
    Callback = function(v)
        cfg.sphere = v
        AtualizarEsfera()
    end
})

ReachBox:AddInput("ReachColor", {
    Text = "Cor RGB",
    Default = "0,255,255",
    Placeholder = "R,G,B",
    Callback = function(text)
        local r, g, b = text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")

        if r and g and b then
            cfg.reachColor = Color3.fromRGB(
                math.clamp(tonumber(r), 0, 255),
                math.clamp(tonumber(g), 0, 255),
                math.clamp(tonumber(b), 0, 255)
            )
            AtualizarEsfera()
        end
    end
})

-- =========================
-- CUSTOMIZAR BOLA
-- =========================

local CustomLeft = TabCustom:AddLeftGroupbox("Customização")

CustomLeft:AddToggle("WhiteBall", {
    Text = "Bola Branca",
    Default = cfg.bolaBrancaAtiva,
    Callback = function(v)
        cfg.bolaBrancaAtiva = v
        AplicarBola()
    end
})

CustomLeft:AddInput("TextureID", {
    Text = "Texture ID",
    Default = "",
    Placeholder = "Cole a Texture ID...",
    Callback = function(text)
        cfg.textureInputText = text
        AplicarBola()
    end
})

CustomLeft:AddButton({
    Text = "Remover Texture",
    Callback = function()
        RestaurarTexture()
    end
})

CustomLeft:AddInput("MeshID", {
    Text = "Mesh ID",
    Default = "",
    Placeholder = "Cole a Mesh ID...",
    Callback = function(text)
        cfg.meshInputText = text
        AplicarBola()
    end
})

CustomLeft:AddButton({
    Text = "Remover Mesh",
    Callback = function()
        RestaurarMesh()
    end
})

local CustomRight = TabCustom:AddRightGroupbox("Bolas Prontas")

CustomRight:AddButton({
    Text = "Champions Laranja",
    Callback = function()
        cfg.textureInputText = "http://www.roblox.com/asset/?id=6631296730"
        cfg.meshInputText = "rbxassetid://4545270159"
        AplicarBola()
    end
})

CustomRight:AddButton({
    Text = "Champions Azul",
    Callback = function()
        cfg.textureInputText = "rbxassetid://8108082224"
        cfg.meshInputText = "rbxassetid://4454597214"
        AplicarBola()
    end
})

CustomRight:AddButton({
    Text = "Champions Branca",
    Callback = function()
        cfg.textureInputText = "http://www.roblox.com/asset/?id=7897839361"
        cfg.meshInputText = "rbxassetid://4761031195"
        AplicarBola()
    end
})

-- =========================
-- TELEPORT / AUTO FOLLOW
-- =========================

local FollowBox = TabGameplay:AddLeftGroupbox("Auto Follow")

FollowBox:AddToggle("AutoFollow", {
    Text = "Ativar Auto Follow",
    Default = cfg.autoFollow,
    Callback = function(v)
        cfg.autoFollow = v
        targetBall = v and AcharBolaMaisProxima() or nil
    end
})

for _, value in ipairs({1.5, 1.8, 2.2}) do
    FollowBox:AddButton({
        Text = "Definir distância: " .. tostring(value) .. "m",
        Callback = function()
            cfg.followDistance = value
        end
    })
end

local FollowInfo = TabGameplay:AddRightGroupbox("Teleport")

FollowInfo:AddButton({
    Text = "Teleport para Bola",
    Callback = function()
        TeleportarParaBola()
    end
})

FollowInfo:AddSlider({
    Text = "Altura do Teleport",
    Min = 0,
    Max = 10,
    Default = cfg.teleportOffset,
    Rounding = 1,
    Callback = function(v)
        cfg.teleportOffset = tonumber(v) or cfg.teleportOffset
    end
})

FollowInfo:AddButton({
    Text = "Salvar Posição do Gol",
    Callback = function()
        SalvarPosicaoGol()
    end
})

FollowInfo:AddButton({
    Text = "Ir para Gol Salvo",
    Callback = function()
        IrParaGol()
    end
})

-- =========================
-- BOLA
-- =========================

local BallBox = TabBola:AddLeftGroupbox("Bola")

BallBox:AddToggle("MagneticBall", {
    Text = "Magnetic Ball",
    Default = cfg.magneticEnabled,
    Callback = function(v)
        cfg.magneticEnabled = v
    end
})

BallBox:AddSlider({
    Text = "Força Magnética",
    Min = 10,
    Max = 200,
    Default = cfg.magneticStrength,
    Rounding = 0,
    Callback = function(v)
        cfg.magneticStrength = tonumber(v) or cfg.magneticStrength
    end
})

BallBox:AddToggle("PowerShoot", {
    Text = "Power Shoot",
    Default = cfg.kickOn,
    Callback = function(v)
        cfg.kickOn = v
    end
})

BallBox:AddSlider({
    Text = "Força Power Shoot",
    Min = 0,
    Max = 10,
    Default = cfg.kick,
    Rounding = 0,
    Callback = function(v)
        cfg.kick = tonumber(v) or cfg.kick
    end
})

-- =========================
-- ESP
-- =========================

local ESPBox = TabESP:AddLeftGroupbox("ESP")

ESPBox:AddToggle("BallESP", {
    Text = "ESP Ball",
    Default = cfg.esp,
    Callback = function(v)
        cfg.esp = v
        if not v then
            LimparESP()
        end
    end
})

ESPBox:AddToggle("TrainingESP", {
    Text = "Somente Bola de Treino",
    Default = cfg.espTrainingOnly,
    Callback = function(v)
        cfg.espTrainingOnly = v
    end
})

ESPBox:AddToggle("PlayerESP", {
    Text = "ESP Players",
    Default = cfg.espPlayers,
    Callback = function(v)
        cfg.espPlayers = v
    end
})

ESPBox:AddToggle("LineESP", {
    Text = "ESP Linhas",
    Default = cfg.espLines,
    Callback = function(v)
        cfg.espLines = v
    end
})

-- =========================
-- PERSONAGEM
-- =========================

local CharacterBox = TabPersonagem:AddLeftGroupbox("Personagem")

CharacterBox:AddToggle("WalkSpeedEnabled", {
    Text = "Ativar WalkSpeed",
    Default = cfg.walkSpeedEnabled,
    Callback = function(v)
        cfg.walkSpeedEnabled = v

        if humanoid and not v then
            humanoid.WalkSpeed = 16
        end
    end
})

CharacterBox:AddSlider({
    Text = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = cfg.walkSpeed,
    Rounding = 0,
    Callback = function(v)
        cfg.walkSpeed = tonumber(v) or cfg.walkSpeed

        if humanoid and cfg.walkSpeedEnabled then
            humanoid.WalkSpeed = cfg.walkSpeed
        end
    end
})

CharacterBox:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = cfg.infiniteJump,
    Callback = function(v)
        cfg.infiniteJump = v
    end
})

CharacterBox:AddToggle("SpinMode", {
    Text = "Spin Mode",
    Default = cfg.spin,
    Callback = function(v)
        cfg.spin = v
    end
})

CharacterBox:AddSlider({
    Text = "Spin Speed",
    Min = 1,
    Max = 20,
    Default = cfg.spinSpeed,
    Rounding = 0,
    Callback = function(v)
        cfg.spinSpeed = tonumber(v) or cfg.spinSpeed
    end
})

CharacterBox:AddToggle("RGBPlayer", {
    Text = "RGB Player",
    Default = cfg.rgbPlayer,
    Callback = function(v)
        DefinirRGB(v)
    end
})

CharacterBox:AddToggle("AutoReset", {
    Text = "Auto Reset",
    Default = cfg.autoReset,
    Callback = function(v)
        cfg.autoReset = v
    end
})

-- =========================
-- INFINITE JUMP
-- =========================

UserInputService.JumpRequest:Connect(function()
    if cfg.infiniteJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- =========================
-- MAIN LOOP
-- =========================

local lastBallScan = 0

RunService.Heartbeat:Connect(function(delta)
    if not char
        or not char.Parent
        or not humanoid
        or not humanoid.Parent
        or not hrp
        or not hrp.Parent
    then
        atualizarChar()
        return
    end

    -- Atualiza lista de bolas sem varrer o Workspace em excesso
    if os.clock() - lastBallScan >= 0.10 then
        balls = ObterBolas()
        lastBallScan = os.clock()
    end

    -- WalkSpeed
    if cfg.walkSpeedEnabled and humanoid.WalkSpeed ~= cfg.walkSpeed then
        humanoid.WalkSpeed = cfg.walkSpeed
    end

    -- Auto Follow
    if cfg.autoFollow then
        if not targetBall
            or not targetBall.Parent
        then
            targetBall = AcharBolaMaisProxima()
        end

        if targetBall and targetBall.Parent then
            local manual = MovimentoManual()
            local skill = AnimacaoDeSkill()

            if not manual and not skill then
                local ballPos = targetBall.Position
                local myPos = hrp.Position

                local targetPos = Vector3.new(
                    ballPos.X,
                    myPos.Y,
                    ballPos.Z
                )

                local offset = targetPos - myPos
                local distance = offset.Magnitude

                if distance > cfg.followDistance and distance > 0.05 then
                    humanoid:Move(offset.Unit, false)
                end
            end
        end
    end

    -- Reach
    if cfg.reachEnabled then
        for _, b in ipairs(balls) do
            if b
                and b.Parent
                and (b.Position - hrp.Position).Magnitude <= cfg.reach
            then
                pcall(function()
                    if firetouchinterest then
                        firetouchinterest(hrp, b, 0)
                        firetouchinterest(hrp, b, 1)
                    end
                end)
            end
        end
    end

    -- Spin
    if cfg.spin then
        spinAngle = spinAngle + delta * cfg.spinSpeed * 5

        hrp.CFrame =
            CFrame.new(hrp.Position)
            * CFrame.Angles(0, spinAngle, 0)
    end

    -- Esfera
    if sp and hrp then
        sp.Position = hrp.Position
    end

    -- Customização
    if #balls > 0
        and (cfg.bolaBrancaAtiva
        or cfg.textureInputText ~= ""
        or cfg.meshInputText ~= "")
    then
        AplicarBola()
    end

    -- ESP Ball
    if cfg.esp then
        for _, b in ipairs(balls) do
            local permitido = true

            if cfg.espTrainingOnly
                and b.Name ~= "TrainingBall"
            then
                permitido = false
            end

            if permitido then
                CriarESPBall(b)

                if esps[b]
                    and esps[b].text
                then
                    local distance =
                        (b.Position - hrp.Position).Magnitude

                    esps[b].text.Text =
                        math.floor(distance) .. "m"
                end
            elseif esps[b] then
                pcall(function()
                    esps[b].gui:Destroy()
                end)

                esps[b] = nil
            end
        end
    else
        LimparESP()
    end

    -- Auto Reset
    if cfg.autoReset then
        if humanoid.Health <= 0 then
            task.defer(function()
                if LocalPlayer.Character == char then
                    LocalPlayer:LoadCharacter()
                end
            end)
        end
    end
end)

-- =========================
-- INITIALIZE
-- =========================

AtualizarEsfera()

print("Anonymus Hub carregado com Obsidian.")
