-- NOX HUB - Obsidian UI
-- Footer: Anonymus7

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local function UpdateCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

local AutoFollowEnabled = false
local FollowDistance = 1.8
local ReachEnabled = false
local ReachDistance = 3.5
local BringBallEnabled = false
local AutoGoalEnabled = false
local GoalInstantTP = false
local GoalBallSpeed = 200
local SavedGoalPosition = nil
local BallFireEnabled = false

local TargetCenter = Vector3.new(0, -28.94, 0)
local CenterTolerance = 3.5

local function GetClosestBall()
    if not RootPart then return nil end
    local closest, shortest = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if obj.Name == "TPS" or n:find("ball") or n:find("bola") then
                local s = obj.Size
                if s.X >= 0.8 and s.X <= 5 and (obj.Position - TargetCenter).Magnitude > CenterTolerance then
                    local d = (obj.Position - RootPart.Position).Magnitude
                    if d < shortest then
                        shortest = d
                        closest = obj
                    end
                end
            end
        end
    end
    return closest
end

local function IsManualMoving()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A)
        or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D) then
        return true
    end
    return Humanoid and Humanoid.MoveDirection.Magnitude > 0.05
end

local function IsSkillPlaying()
    if not Humanoid then return false end
    local animator = Humanoid:FindFirstChildOfClass("Animator")
    if not animator then return false end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local n = track.Name:lower()
        if n:find("skill") or n:find("dribble") or n:find("shoot") or n:find("head") or n:find("rainbow") or n:find("lambreta") then
            return true
        end
    end
    return false
end

local function TouchBall(ball)
    if not RootPart or not ball then return end
    pcall(function()
        firetouchinterest(RootPart, ball, 0)
        firetouchinterest(RootPart, ball, 1)
    end)
end

-- Ball follow / Reach
RunService.RenderStepped:Connect(function()
    if not Character or not Humanoid or not RootPart then return end
    local ball = GetClosestBall()
    if not ball then return end

    if AutoFollowEnabled and not IsManualMoving() and not IsSkillPlaying() then
        local target = Vector3.new(ball.Position.X, RootPart.Position.Y, ball.Position.Z)
        local offset = target - RootPart.Position
        if offset.Magnitude > FollowDistance then
            Humanoid:Move(offset.Unit, false)
        end
    end

    if ReachEnabled and (ball.Position - RootPart.Position).Magnitude <= ReachDistance * 5 then
        TouchBall(ball)
        for _, part in ipairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                pcall(function()
                    firetouchinterest(part, ball, 0)
                    firetouchinterest(part, ball, 1)
                end)
            end
        end
    end
end)

-- Bring Ball / Auto Goal
RunService.Heartbeat:Connect(function()
    local ball = GetClosestBall()
    if not ball or not RootPart then return end

    if BringBallEnabled then
        local destination = RootPart.Position
        local distance = (destination - ball.Position).Magnitude
        if distance > 4 then
            pcall(function()
                ball.AssemblyLinearVelocity = (destination - ball.Position).Unit * 180
            end)
        else
            pcall(function() ball.AssemblyLinearVelocity = Vector3.zero end)
        end
    end

    if AutoGoalEnabled and SavedGoalPosition then
        local distance = (SavedGoalPosition - ball.Position).Magnitude
        if GoalInstantTP and (ball.Position - RootPart.Position).Magnitude <= 5 then
            pcall(function()
                ball.CFrame = CFrame.new(SavedGoalPosition)
                ball.AssemblyLinearVelocity = Vector3.zero
            end)
        elseif distance > 3 then
            pcall(function()
                ball.AssemblyLinearVelocity = (SavedGoalPosition - ball.Position).Unit * GoalBallSpeed
            end)
        else
            pcall(function() ball.AssemblyLinearVelocity = Vector3.zero end)
        end
    end
end)

-- Load Obsidian UI only after core logic is ready
local Library
local ok, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
end)
if not ok or not result then
    warn("Nox Hub: Failed to load Obsidian UI")
    return
end
Library = result

local Window = Library:CreateWindow({
    Title = "Nox Hub",
    Footer = "Anonymus7",
    Center = true,
    AutoShow = true,
    ShowMobileButtons = true
})

local function Safe(fn)
    return function(...)
        local success, err = pcall(fn, ...)
        if not success then warn("Nox Hub: " .. tostring(err)) end
    end
end

local BallTab = Window:AddTab("Ball", "circle-dot")
local ReachTab = Window:AddTab("Reach", "maximize")
local PlayerTab = Window:AddTab("Player", "user")
local GrassTab = Window:AddTab("Gramado", "trees")
local AntiLagTab = Window:AddTab("Anti-Lag", "gauge")

-- BALL
local BallBox = BallTab:AddLeftGroupbox("Ball")
BallBox:AddToggle("BallFollow", {
    Text = "Ball Follow",
    Default = false,
    Callback = Safe(function(v) AutoFollowEnabled = v end)
})

BallBox:AddButton({
    Text = "Bring Ball",
    Func = Safe(function()
        BringBallEnabled = not BringBallEnabled
    end)
})

BallBox:AddButton({
    Text = "Salvar Posição do Gol",
    Func = Safe(function()
        if RootPart then
            SavedGoalPosition = RootPart.Position
        end
    end)
})

BallBox:AddToggle("AutoGoal", {
    Text = "Auto Goal",
    Default = false,
    Callback = Safe(function(v)
        if v and not SavedGoalPosition then
            warn("Nox Hub: salve a posição do gol primeiro.")
            AutoGoalEnabled = false
            return
        end
        AutoGoalEnabled = v
    end)
})

BallBox:AddSlider("GoalSpeed", {
    Text = "Velocidade da Bola",
    Min = 1,
    Max = 10,
    Default = 4,
    Rounding = 0,
    Callback = Safe(function(v) GoalBallSpeed = tonumber(v) * 50 end)
})

BallBox:AddToggle("InstantGoal", {
    Text = "Teleporte Instantâneo",
    Default = false,
    Callback = Safe(function(v) GoalInstantTP = v end)
})

BallBox:AddToggle("BallFire", {
    Text = "Efeito de Fogo",
    Default = false,
    Callback = Safe(function(v)
        BallFireEnabled = v
        local ball = GetClosestBall()
        if not ball then return end
        local fire = ball:FindFirstChildOfClass("Fire")
        if v and not fire then
            fire = Instance.new("Fire")
            fire.Size = 6
            fire.Parent = ball
        elseif not v and fire then
            fire:Destroy()
        end
    end)
})

local BallInfo = BallTab:AddRightGroupbox("Configuração")
BallInfo:AddSlider("FollowDistance", {
    Text = "Distância do Ball Follow",
    Min = 1,
    Max = 4,
    Default = FollowDistance,
    Rounding = 1,
    Callback = Safe(function(v) FollowDistance = tonumber(v) or FollowDistance end)
})
BallInfo:AddLabel("Bring Ball e Auto Goal ficam nesta aba.", true)

-- REACH
local ReachBox = ReachTab:AddLeftGroupbox("Reach")
ReachBox:AddToggle("ReachToggle", {
    Text = "Ativar Reach",
    Default = false,
    Callback = Safe(function(v) ReachEnabled = v end)
})
ReachBox:AddSlider("ReachSize", {
    Text = "Tamanho do Reach",
    Min = 2,
    Max = 10,
    Default = ReachDistance,
    Rounding = 1,
    Callback = Safe(function(v) ReachDistance = tonumber(v) or ReachDistance end)
})

-- PLAYER
local PlayerBox = PlayerTab:AddLeftGroupbox("Player")
local PlayerWalkSpeed = 16
local PlayerJumpPower = 50
local Noclip = false
local InfiniteJump = false

PlayerBox:AddSlider("WalkSpeed", {
    Text = "WalkSpeed", Min = 8, Max = 100, Default = 16, Rounding = 0,
    Callback = Safe(function(v) PlayerWalkSpeed = tonumber(v) or 16; if Humanoid then Humanoid.WalkSpeed = PlayerWalkSpeed end end)
})
PlayerBox:AddSlider("JumpPower", {
    Text = "JumpPower", Min = 20, Max = 150, Default = 50, Rounding = 0,
    Callback = Safe(function(v) PlayerJumpPower = tonumber(v) or 50; if Humanoid then Humanoid.JumpPower = PlayerJumpPower end end)
})
PlayerBox:AddToggle("Noclip", { Text = "Noclip", Default = false, Callback = Safe(function(v) Noclip = v end) })
PlayerBox:AddToggle("InfiniteJump", { Text = "Pulo Infinito", Default = false, Callback = Safe(function(v) InfiniteJump = v end) })
PlayerBox:AddButton({ Text = "Resetar valores", Func = Safe(function() PlayerWalkSpeed = 16; PlayerJumpPower = 50; if Humanoid then Humanoid.WalkSpeed = 16; Humanoid.JumpPower = 50 end end) })

UserInputService.JumpRequest:Connect(function()
    if InfiniteJump and Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
RunService.Stepped:Connect(function()
    if Noclip and Character then
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- GRAMADO
local GrassBox = GrassTab:AddLeftGroupbox("Gramado")
local GrassEnabled = false
local OldGrass = {}
GrassBox:AddToggle("Grass", {
    Text = "Remover detalhes do gramado",
    Default = false,
    Callback = Safe(function(v)
        GrassEnabled = v
        if v then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
                    OldGrass[obj] = obj.Enabled
                    obj.Enabled = false
                end
            end
        else
            for obj, state in pairs(OldGrass) do
                if obj and obj.Parent then obj.Enabled = state end
            end
            table.clear(OldGrass)
        end
    end)
})

-- ANTI-LAG
local AntiBox = AntiLagTab:AddLeftGroupbox("Performance")
local Shadows = Lighting.GlobalShadows
local Fog = Lighting.FogEnd
AntiBox:AddToggle("Optimize", {
    Text = "Otimizar sombras",
    Default = false,
    Callback = Safe(function(v)
        if v then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
        else
            Lighting.GlobalShadows = Shadows
            Lighting.FogEnd = Fog
        end
    end)
})
AntiBox:AddLabel("Configurações reversíveis de iluminação/performance.", true)

print("Nox Hub carregado com Obsidian UI - Anonymus7")
