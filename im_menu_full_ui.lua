--[[
    I'M MENU • UI COMPLETA (somente interface)
    Todas as abas, seções e controles estão prontos.
    A lógica fica nos callbacks marcados com "-- TODO".

    API rápida:
      Window:AddCategory("Nome")
      local Tab = Window:AddTab("Nome", "ícone")
      local Sec = Tab:AddSection("Nome")              -- alterna entre coluna esquerda/direita
      Sec:AddToggle{Text, Default, Keybind, Flag, Callback}
      Sec:AddSlider{Text, Min, Max, Default, Suffix, Flag, Callback}
      Sec:AddDropdown{Text, Options, Default, Flag, Callback}  -- :SetOptions(t) :Set(v) :Get()
      Sec:AddKeybind{Text, Default, Flag, Callback}
      Sec:AddButton{Text, Callback}
      Sec:AddInput{Text, Placeholder, Flag, Callback}
      Sec:AddLabel("texto")                           -- :Set("novo texto")
      Sec:AddGroup("Título")                          -- grupo expansível (mesmos métodos)
      Lib:Notify{Title, Text, Duration}
      Lib.Flags["NomeDoFlag"]                         -- valor atual de cada controle
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local __ok, __err = xpcall(function()

--------------------------------------------------------------------
-- TEMA
--------------------------------------------------------------------
local C = {
	Window   = Color3.fromRGB(8, 8, 10),
	Sidebar  = Color3.fromRGB(10, 10, 12),
	Card     = Color3.fromRGB(18, 18, 20),
	Item     = Color3.fromRGB(28, 28, 32),
	Selected = Color3.fromRGB(26, 26, 30),
	Stroke   = Color3.fromRGB(34, 34, 38),
	Text     = Color3.fromRGB(235, 235, 235),
	SubText  = Color3.fromRGB(150, 150, 155),
	Accent   = Color3.fromRGB(160, 90, 255),
	Off      = Color3.fromRGB(110, 110, 115),
}
local FONT, FONT_B, FONT_X = Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold

--------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function corner(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, o) end
local function stroke(o, col)
	return new("UIStroke", {Color = col or C.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end
local function pad(o, t, b, l, r)
	return new("UIPadding", {
		PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
	}, o)
end
local function list(o, p)
	return new("UIListLayout", {Padding = UDim.new(0, p or 6), SortOrder = Enum.SortOrder.LayoutOrder}, o)
end
local function label(parent, text, size, color, font, xalign)
	return new("TextLabel", {
		BackgroundTransparency = 1, Text = text, TextSize = size or 12, TextColor3 = color or C.Text,
		Font = font or FONT, TextXAlignment = xalign or Enum.TextXAlignment.Left,
	}, parent)
end
local function safe(cb, ...)
	if cb then task.spawn(cb, ...) end
end

--------------------------------------------------------------------
-- BIBLIOTECA
--------------------------------------------------------------------
local Lib = {Flags = {}}

local USE_HIDDEN_UI = false -- mude para true se quiser usar gethui() (alguns executores não renderizam)

local function getGuiParent()
	if USE_HIDDEN_UI and gethui then
		local ok, res = pcall(gethui)
		if ok and res then return res end
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local parentGui = getGuiParent()
for _, p in ipairs({parentGui, LocalPlayer:FindFirstChildOfClass("PlayerGui")}) do
	local old = p and p:FindFirstChild("IM_MENU_FULL")
	if old then old:Destroy() end
end
local Gui = new("ScreenGui", {
	Name = "IM_MENU_FULL", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100,
}, parentGui)

-- Teclas (keybinds globais)
local binds, listening = {}, nil
UIS.InputBegan:Connect(function(i, gp)
	if listening then
		if i.UserInputType == Enum.UserInputType.Keyboard then
			listening.set(i.KeyCode ~= Enum.KeyCode.Escape and i.KeyCode or nil)
			listening = nil
		end
		return
	end
	if gp then return end
	for _, b in ipairs(binds) do
		if b.key and i.KeyCode == b.key then b.fire() end
	end
end)

local function keyName(k) return k and k.Name or "—" end

local function makeKeyButton(parent, default, onFire, onChange)
	local bind = {key = default, fire = onFire}
	table.insert(binds, bind)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(46, 18), BackgroundColor3 = C.Item, Text = keyName(default),
		TextSize = 10, TextColor3 = C.SubText, Font = FONT, AutoButtonColor = false,
	}, parent)
	corner(b, 4)
	local function set(k)
		bind.key = k; b.Text = keyName(k); b.TextColor3 = C.SubText
		if onChange then onChange(k) end
	end
	b.MouseButton1Click:Connect(function()
		b.Text = "..."; b.TextColor3 = C.Accent
		listening = {set = set}
	end)
	return b, set, bind
end

-- Notificações
local NotifyHolder = new("Frame", {
	Size = UDim2.new(0, 260, 1, -20), Position = UDim2.new(1, -270, 0, 10), BackgroundTransparency = 1,
}, Gui)
new("UIListLayout", {
	Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Bottom,
	SortOrder = Enum.SortOrder.LayoutOrder,
}, NotifyHolder)

function Lib:Notify(o)
	local f = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.Card, BorderSizePixel = 0,
	}, NotifyHolder)
	corner(f, 8); stroke(f); pad(f, 8, 8, 12, 12); list(f, 2)
	local t = label(f, o.Title or "", 12, C.Text, FONT_X); t.Size = UDim2.new(1, 0, 0, 16)
	local d = label(f, o.Text or "", 11, C.SubText, FONT)
	d.Size = UDim2.new(1, 0, 0, 14); d.TextWrapped = true; d.AutomaticSize = Enum.AutomaticSize.Y
	task.delay(o.Duration or 3, function()
		if f.Parent then f:Destroy() end
	end)
end

--------------------------------------------------------------------
-- CONTAINER (métodos de controles)
--------------------------------------------------------------------
local Container = {}
Container.__index = Container

local function flagSet(o, v)
	local f = o.Flag or o.Text
	if f then Lib.Flags[f] = v end
end

function Container:AddLabel(text)
	local l = label(self.Body, text, 12, C.SubText); l.Size = UDim2.new(1, 0, 0, 18)
	l.TextWrapped = true; l.AutomaticSize = Enum.AutomaticSize.Y
	return {Instance = l, Set = function(_, t) l.Text = t end}
end

function Container:AddButton(o)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.Item, Text = o.Text or "Botão",
		TextSize = 12, TextColor3 = C.Text, Font = FONT, AutoButtonColor = true,
	}, self.Body)
	corner(b, 6)
	b.MouseButton1Click:Connect(function() safe(o.Callback) end)
	return {Instance = b, SetText = function(_, t) b.Text = t end}
end

function Container:AddToggle(o)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1}, self.Body)
	local l = label(row, o.Text or "Toggle", 12, C.Text); l.Size = UDim2.new(1, -90, 1, 0)
	local track = new("TextButton", {
		Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -34, 0.5, -9),
		BackgroundColor3 = C.Off, Text = "", AutoButtonColor = false,
	}, row)
	corner(track, 9)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
	}, track)
	corner(knob, 7)
	local state = o.Default or false
	local obj = {}
	local function render()
		TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = state and C.Accent or C.Off}):Play()
		TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)}):Play()
	end
	local function set(v, silent)
		state = v; render(); flagSet(o, state)
		if not silent then safe(o.Callback, state) end
	end
	function obj:Set(v) set(v) end
	function obj:Get() return state end
	track.MouseButton1Click:Connect(function() set(not state) end)
	if o.Keybind ~= nil then
		local default = typeof(o.Keybind) == "EnumItem" and o.Keybind or nil
		local kb = makeKeyButton(row, default, function() set(not state) end)
		kb.Position = UDim2.new(1, -86, 0.5, -9)
	end
	render(); flagSet(o, state)
	return obj
end

function Container:AddKeybind(o)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1}, self.Body)
	local l = label(row, o.Text or "Tecla", 12, C.Text); l.Size = UDim2.new(1, -60, 1, 0)
	local kb = makeKeyButton(row, o.Default, function() safe(o.Callback) end, function(k)
		flagSet(o, k)
	end)
	kb.Position = UDim2.new(1, -46, 0.5, -9)
	flagSet(o, o.Default)
end

function Container:AddSlider(o)
	local min, max = o.Min or 0, o.Max or 100
	local value = math.clamp(o.Default or min, min, max)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1}, self.Body)
	local l = label(row, o.Text or "Slider", 12, C.Text); l.Size = UDim2.new(1, -60, 0, 18)
	local v = label(row, "", 11, C.SubText, FONT, Enum.TextXAlignment.Right)
	v.Size = UDim2.new(0, 60, 0, 18); v.Position = UDim2.new(1, -60, 0, 0)
	local bar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 6), Position = UDim2.fromOffset(0, 24), BackgroundColor3 = C.Item, BorderSizePixel = 0,
	}, row)
	corner(bar, 3)
	local fill = new("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.Accent, BorderSizePixel = 0}, bar)
	corner(fill, 3)
	local hit = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 16), BackgroundTransparency = 1, Text = "",
	}, row)
	local function render()
		local a = (value - min) / math.max(max - min, 1e-9)
		fill.Size = UDim2.new(a, 0, 1, 0)
		v.Text = tostring(value) .. (o.Suffix or "")
	end
	local function set(n, silent)
		local step = o.Step or 1
		value = math.clamp(math.floor(n / step + 0.5) * step, min, max)
		render(); flagSet(o, value)
		if not silent then safe(o.Callback, value) end
	end
	local dragging = false
	local function fromInput(x)
		local a = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		set(min + (max - min) * a)
	end
	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true; fromInput(i.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			fromInput(i.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	render(); flagSet(o, value)
	return {Set = function(_, n) set(n) end, Get = function() return value end}
end

function Container:AddDropdown(o)
	local options = o.Options or {}
	local selected = o.Default
	local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, self.Body)
	list(wrap, 4)
	local head = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.Item, Text = "", AutoButtonColor = false,
	}, wrap)
	corner(head, 6)
	local txt = label(head, "", 12, C.Text); txt.Size = UDim2.new(1, -30, 1, 0); txt.Position = UDim2.fromOffset(10, 0)
	local arrow = label(head, "▾", 12, C.SubText, FONT_B, Enum.TextXAlignment.Center)
	arrow.Size = UDim2.fromOffset(24, 28); arrow.Position = UDim2.new(1, -26, 0, 0)
	local listFrame = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.Item, Visible = false, BorderSizePixel = 0,
	}, wrap)
	corner(listFrame, 6); list(listFrame, 0)
	local obj = {}
	local function renderText()
		txt.Text = (o.Text or "Dropdown") .. ": " .. tostring(selected or "—")
	end
	local function set(v, silent)
		selected = v; renderText(); flagSet(o, v)
		listFrame.Visible = false; arrow.Text = "▾"
		if not silent then safe(o.Callback, v) end
	end
	local function rebuild()
		for _, c in ipairs(listFrame:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		for _, opt in ipairs(options) do
			local b = new("TextButton", {
				Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = tostring(opt),
				TextSize = 12, TextColor3 = C.SubText, Font = FONT, AutoButtonColor = false,
			}, listFrame)
			b.MouseButton1Click:Connect(function() set(opt) end)
		end
	end
	function obj:SetOptions(t) options = t; rebuild() end
	function obj:Set(v) set(v) end
	function obj:Get() return selected end
	head.MouseButton1Click:Connect(function()
		listFrame.Visible = not listFrame.Visible
		arrow.Text = listFrame.Visible and "▴" or "▾"
	end)
	rebuild(); renderText(); flagSet(o, selected)
	return obj
end

function Container:AddInput(o)
	local box = new("TextBox", {
		Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.Item, Text = "",
		PlaceholderText = o.Placeholder or o.Text or "", PlaceholderColor3 = C.SubText,
		TextColor3 = C.Text, TextSize = 12, Font = FONT, ClearTextOnFocus = false,
	}, self.Body)
	corner(box, 6); pad(box, 0, 0, 10, 10)
	box.FocusLost:Connect(function()
		flagSet(o, box.Text); safe(o.Callback, box.Text)
	end)
	return {Instance = box, Get = function() return box.Text end, Set = function(_, t) box.Text = t end}
end

-- Grupo expansível
function Container:AddGroup(titleText)
	local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, self.Body)
	list(wrap, 6)
	local head = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = C.Item, Text = "",
		AutoButtonColor = false,
	}, wrap)
	corner(head, 6)
	local t = label(head, "▸  " .. titleText, 12, C.Text, FONT_B); t.Size = UDim2.new(1, -10, 1, 0); t.Position = UDim2.fromOffset(10, 0)
	local body = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Visible = false,
	}, wrap)
	list(body, 6); pad(body, 2, 2, 6, 0)
	head.MouseButton1Click:Connect(function()
		body.Visible = not body.Visible
		t.Text = (body.Visible and "▾  " or "▸  ") .. titleText
	end)
	return setmetatable({Body = body}, Container)
end

--------------------------------------------------------------------
-- JANELA
--------------------------------------------------------------------
function Lib:CreateWindow(cfg)
	cfg = cfg or {}
	local Window = {Tabs = {}, Order = 0}

	local Frame = new("Frame", {
		Size = UDim2.fromOffset(820, 510), Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = C.Window,
		BackgroundTransparency = 0.05, BorderSizePixel = 0, ClipsDescendants = true,
	}, Gui)
	corner(Frame, 10); stroke(Frame)
	local scale = new("UIScale", {}, Frame)
	local cam = workspace.CurrentCamera or workspace:WaitForChild("Camera", 5)
	local function updateScale()
		local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
		scale.Scale = math.clamp(math.min(vp.X / 880, vp.Y / 560), 0.45, 1)
	end
	updateScale()
	if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end
	Window.Frame = Frame

	-- Sidebar
	local Sidebar = new("Frame", {Size = UDim2.new(0, 172, 1, 0), BackgroundColor3 = C.Sidebar, BorderSizePixel = 0}, Frame)
	new("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = C.Stroke, BorderSizePixel = 0}, Sidebar)
	local st = label(Sidebar, cfg.SidebarTitle or "Painel I'M MENU · Versão Beta", 12, C.SubText, FONT_B, Enum.TextXAlignment.Center)
	st.Size = UDim2.new(1, -16, 0, 34); st.Position = UDim2.fromOffset(8, 4); st.TextWrapped = true

	local TabList = new("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -100), Position = UDim2.fromOffset(0, 44), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, Sidebar)
	list(TabList, 4); pad(TabList, 0, 0, 6, 6)

	local Profile = new("Frame", {Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 1, -50), BackgroundTransparency = 1}, Sidebar)
	new("Frame", {Size = UDim2.new(1, -16, 0, 1), Position = UDim2.fromOffset(8, 0), BackgroundColor3 = C.Stroke, BorderSizePixel = 0}, Profile)
	local av = new("ImageLabel", {
		Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(12, 10), BackgroundColor3 = C.Card, BorderSizePixel = 0,
		Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(LocalPlayer.UserId),
	}, Profile)
	corner(av, 15)
	local nm = label(Profile, LocalPlayer.DisplayName, 11, C.SubText, FONT); nm.Size = UDim2.new(1, -90, 0, 30); nm.Position = UDim2.fromOffset(48, 10)
	nm.TextTruncate = Enum.TextTruncate.AtEnd
	local ar = label(Profile, "›", 22, C.SubText, FONT_B, Enum.TextXAlignment.Center)
	ar.Size = UDim2.fromOffset(24, 30); ar.Position = UDim2.new(1, -34, 0, 10)

	-- Conteúdo
	local Content = new("Frame", {Size = UDim2.new(1, -172, 1, 0), Position = UDim2.fromOffset(172, 0), BackgroundTransparency = 1}, Frame)
	local Header = new("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1}, Content)
	local ht = label(Header, cfg.Title or "I'M MENU", 12, C.Text, FONT_X, Enum.TextXAlignment.Center)
	ht.Size = UDim2.new(1, 0, 0, 28); ht.Position = UDim2.fromOffset(0, 4)
	new("Frame", {Size = UDim2.new(1, -20, 0, 1), Position = UDim2.new(0, 10, 1, -1), BackgroundColor3 = C.Stroke, BorderSizePixel = 0}, Header)

	local searchBtn = new("TextButton", {
		Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -40, 0, 14), BackgroundTransparency = 1,
		Text = "⌕", TextSize = 20, TextColor3 = C.Text, Font = FONT_B,
	}, Header)
	local searchBox = new("TextBox", {
		Size = UDim2.fromOffset(150, 24), Position = UDim2.new(1, -198, 0, 16), BackgroundColor3 = C.Item, Visible = false,
		Text = "", PlaceholderText = "Pesquisar aba...", PlaceholderColor3 = C.SubText,
		TextColor3 = C.Text, TextSize = 11, Font = FONT, ClearTextOnFocus = false,
	}, Header)
	corner(searchBox, 6); pad(searchBox, 0, 0, 8, 8)

	local Pages = new("Frame", {Size = UDim2.new(1, 0, 1, -50), Position = UDim2.fromOffset(0, 50), BackgroundTransparency = 1}, Content)

	-- Abas
	local current
	function Window:SelectTab(name)
		for n, t in pairs(self.Tabs) do
			local on = n == name
			t.page.Visible = on
			TweenService:Create(t.btn, TweenInfo.new(0.12), {BackgroundTransparency = on and 0 or 1}):Play()
			t.text.TextColor3 = on and C.Text or C.SubText
			t.icon.TextColor3 = on and C.Accent or C.SubText
		end
		current = name
	end

	function Window:AddCategory(text)
		self.Order += 1
		local l = label(TabList, text, 11, C.SubText, FONT)
		l.Size = UDim2.new(1, 0, 0, 22); l.LayoutOrder = self.Order
		pad(l, 6, 0, 4, 0)
	end

	function Window:AddTab(name, icon)
		self.Order += 1
		local btn = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.Selected, BackgroundTransparency = 1,
			Text = "", AutoButtonColor = false, LayoutOrder = self.Order,
		}, TabList)
		corner(btn, 6)
		local ic = label(btn, icon or "•", 14, C.SubText, FONT_B, Enum.TextXAlignment.Center)
		ic.Size = UDim2.fromOffset(26, 30); ic.Position = UDim2.fromOffset(4, 0)
		local tx = label(btn, name, 12, C.SubText, FONT); tx.Size = UDim2.new(1, -36, 1, 0); tx.Position = UDim2.fromOffset(34, 0)

		local page = new("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
			ScrollBarThickness = 2, ScrollBarImageColor3 = C.Stroke,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, Pages)
		pad(page, 8, 12, 12, 12)
		local holder = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, page)
		new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, holder)
		local cols = {}
		for i = 1, 2 do
			local col = new("Frame", {
				Size = UDim2.new(0.5, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1, LayoutOrder = i,
			}, holder)
			list(col, 10)
			cols[i] = col
		end

		local Tab = {Name = name, btn = btn, page = page, text = tx, icon = ic, count = 0}
		function Tab:AddSection(title, column)
			self.count += 1
			local col = cols[column or ((self.count - 1) % 2 + 1)]
			local card = new("Frame", {
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = C.Card, BorderSizePixel = 0,
			}, col)
			corner(card, 8); pad(card, 10, 10, 12, 12); list(card, 8)
			local h = label(card, title, 11, C.SubText, FONT_B); h.Size = UDim2.new(1, 0, 0, 14)
			return setmetatable({Body = card}, Container)
		end
		self.Tabs[name] = Tab
		btn.MouseButton1Click:Connect(function() self:SelectTab(name) end)
		if not current then self:SelectTab(name) end
		return Tab
	end

	-- Busca
	searchBtn.MouseButton1Click:Connect(function()
		searchBox.Visible = not searchBox.Visible
		if searchBox.Visible then searchBox:CaptureFocus() end
	end)
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = searchBox.Text:lower()
		for n, t in pairs(Window.Tabs) do
			t.btn.Visible = q == "" or n:lower():find(q, 1, true) ~= nil
		end
	end)

	-- Arrastar + abrir/fechar
	do
		local dragging, startPos, startInput
		Header.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging, startInput, startPos = true, i.Position, Frame.Position
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - startInput
				Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end

	function Window:SetVisible(v)
		Frame.Visible = v
	end

	-- Botão flutuante
	local fb = new("TextButton", {
		Size = UDim2.fromOffset(42, 42), Position = UDim2.new(0, 14, 0.5, -21), BackgroundColor3 = C.Window,
		Text = "☰", TextSize = 18, TextColor3 = C.Text, Font = FONT_B, AutoButtonColor = false, Visible = false,
	}, Gui)
	corner(fb, 21); stroke(fb, C.Stroke)
	fb.MouseButton1Click:Connect(function() Frame.Visible = not Frame.Visible end)
	Window.ToggleButton = fb
	do
		local d, sp, si, moved
		fb.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				d, si, sp, moved = true, i.Position, fb.Position, false
				i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end)
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local delta = i.Position - si
				fb.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
			end
		end)
	end

	return Window
end

--------------------------------------------------------------------
-- LOADER (tela inicial)
--------------------------------------------------------------------
function Lib:CreateLoader(o)
	local overlay = new("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4,
		BorderSizePixel = 0, ZIndex = 50, Active = true,
	}, Gui)
	local f = new("Frame", {
		Size = UDim2.fromOffset(360, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = C.Window, BorderSizePixel = 0, ZIndex = 51,
	}, overlay)
	corner(f, 10); stroke(f); pad(f, 16, 16, 18, 18); list(f, 8)
	new("UIScale", {Scale = 1}, f)

	local function row(text, size, color, font)
		local l = label(f, text, size, color, font); l.Size = UDim2.new(1, 0, 0, size + 6)
		l.TextWrapped = true; l.AutomaticSize = Enum.AutomaticSize.Y; l.ZIndex = 52
		return l
	end
	row(o.Title or "Hub", 18, C.Text, FONT_X)
	row(("v%s  •  %s  •  %s"):format(o.Version or "1.0.0", o.Role or "", o.Date or ""), 11, C.SubText, FONT)
	row("Changelog", 12, C.Text, FONT_B)
	for _, line in ipairs(o.Changelog or {}) do row("• " .. line, 11, C.SubText, FONT) end
	row(o.Terms or "", 10, C.SubText, FONT)

	local go = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = C.Accent, Text = "Injetar",
		TextSize = 13, TextColor3 = Color3.new(1, 1, 1), Font = FONT_X, AutoButtonColor = true, ZIndex = 52,
	}, f)
	corner(go, 6)
	go.MouseButton1Click:Connect(function()
		overlay:Destroy()
		safe(o.OnLoad)
	end)
	return {Overlay = overlay}
end

--------------------------------------------------------------------
-- MENU: ABAS E SEÇÕES (todas vazias de lógica)
--------------------------------------------------------------------
local W = Lib:CreateWindow({Title = "I'M MENU", SidebarTitle = "Painel I'M MENU · Versão Beta"})
W:SetVisible(false)

-- ============ SEU JOGADOR ============
W:AddCategory("Seu Jogador")

do
	local Tab = W:AddTab("Geral", "👤")

	local s = Tab:AddSection("Walkspeed")
	s:AddToggle({Text = "WalkSpeed", Callback = function(v) --[[ TODO ]] end})
	s:AddSlider({Text = "Velocidade", Min = 16, Max = 200, Default = 16, Callback = function(v) --[[ TODO ]] end})
	s:AddKeybind({Text = "Tecla", Flag = "WalkSpeedKey", Callback = function() --[[ TODO ]] end})

	local j = Tab:AddSection("Jumppower")
	j:AddToggle({Text = "JumpPower", Callback = function(v) --[[ TODO ]] end})
	j:AddSlider({Text = "Forca", Min = 50, Max = 300, Default = 50, Callback = function(v) --[[ TODO ]] end})

	local b = Tab:AddSection("Seu Boneco")
	b:AddToggle({Text = "Noclip", Keybind = true, Callback = function(v) --[[ TODO ]] end})
	b:AddToggle({Text = "Fly", Keybind = true, Callback = function(v) --[[ TODO ]] end})
	b:AddSlider({Text = "Vel. Fly", Min = 10, Max = 300, Default = 50, Callback = function(v) --[[ TODO ]] end})
	b:AddToggle({Text = "Rolar", Callback = function(v) --[[ TODO ]] end})
	b:AddToggle({Text = "Anti Ragdoll", Callback = function(v) --[[ TODO ]] end})
end

do
	local Tab = W:AddTab("Cosméticos", "✨")
	local s = Tab:AddSection("Curar")
	s:AddButton({Text = "Curar", Callback = function() --[[ TODO ]] end})
	s:AddButton({Text = "Preencher fome", Callback = function() --[[ TODO ]] end})
	s:AddButton({Text = "Preencher Sede", Callback = function() --[[ TODO ]] end})
end

-- ============ AUTO FARM ============
W:AddCategory("Auto Farm")

do
	local Tab = W:AddTab("Lixeiro", "🗑")
	local s = Tab:AddSection("Farm Lixo")
	s:AddToggle({Text = "Auto Farm Lixeiro", Callback = function(v) --[[ TODO ]] end})
	s:AddSlider({Text = "Lixos por entrega", Min = 1, Max = 20, Default = 5, Callback = function(v) --[[ TODO ]] end})
end

do
	local Tab = W:AddTab("Partes de Arma", "🔧")
	local s = Tab:AddSection("Farm Partes")
	s:AddToggle({Text = "Auto Farm Partes de Arma", Callback = function(v) --[[ TODO ]] end})
end

-- ============ COMBAT ============
W:AddCategory("Combat")

do
	local Tab = W:AddTab("ESP", "◉")
	local s = Tab:AddSection("ESP")
	s:AddToggle({Text = "Ativar ESP", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Caixa 2D", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Caixa 3D", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Nome", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Distancia", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Item na mao", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Esqueleto", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Highlight", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Tracer", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Seta fora da tela", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Times", Callback = function(v) --[[ TODO ]] end})
	s:AddSlider({Text = "Distancia maxima", Min = 100, Max = 5000, Default = 1000, Step = 50, Suffix = " studs", Callback = function(v) --[[ TODO ]] end})
end

do
	local Tab = W:AddTab("Silent Aim", "⌖")
	local s = Tab:AddSection("Silent Aim")
	s:AddToggle({Text = "Silent Aim (cabeca)", Callback = function(v) --[[ TODO ]] end})

	local adv = s:AddGroup("Silent Aim Avançado")
	adv:AddSlider({Text = "Taxa de acerto (%)", Min = 0, Max = 100, Default = 100, Suffix = "%", Callback = function(v) --[[ TODO ]] end})
	adv:AddDropdown({Text = "Parte do corpo", Options = {"Head", "HumanoidRootPart", "Torso", "Aleatório"}, Default = "Head", Callback = function(v) --[[ TODO ]] end})

	s:AddToggle({Text = "Visibility Check", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Friend Check", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Admin / Staff Check", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Mostrar FOV", Callback = function(v) --[[ TODO ]] end})
	s:AddSlider({Text = "FOV", Min = 10, Max = 500, Default = 120, Callback = function(v) --[[ TODO ]] end})
	s:AddSlider({Text = "Distancia do alvo", Min = 50, Max = 2000, Default = 500, Step = 10, Callback = function(v) --[[ TODO ]] end})
end

local ArmaEquipada -- label atualizável
do
	local Tab = W:AddTab("Armas", "🔫")
	local eq = Tab:AddSection("Arma equipada")
	ArmaEquipada = eq:AddLabel("Nenhuma arma equipada.") -- ArmaEquipada:Set("Nome da arma")

	local s = Tab:AddSection("Modificações")
	s:AddToggle({Text = "Sem recuo", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Municao infinita", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Recarga instantanea", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Sem lentidao com arma", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Cadencia custom", Callback = function(v) --[[ TODO ]] end})
	s:AddSlider({Text = "Tiros por segundo", Min = 1, Max = 30, Default = 10, Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Tracer neon", Callback = function(v) --[[ TODO ]] end})
	s:AddDropdown({Text = "Cor do tracer", Options = {"Roxo", "Vermelho", "Azul", "Verde", "Branco", "Arco-íris"}, Default = "Roxo", Callback = function(v) --[[ TODO ]] end})
end

-- ============ DIVERSOS ============
W:AddCategory("Diversos")

local ItensDropdown, PoliciaisLabel, LocaisDropdown, PlayersDropdown
do
	local Tab = W:AddTab("Diversos", "🧰")

	local d = Tab:AddSection("Diversos")
	d:AddToggle({Text = "Perfect Lock Pick", Callback = function(v) --[[ TODO ]] end})
	d:AddToggle({Text = "Equipar melhor arma.", Callback = function(v) --[[ TODO ]] end})

	local c = Tab:AddSection("Coletar Itens")
	c:AddToggle({Text = "Mostrar HUD de itens", Callback = function(v) --[[ TODO ]] end})
	ItensDropdown = c:AddDropdown({Text = "Item mais proximo", Options = {}, Callback = function(v) --[[ TODO ]] end}) -- ItensDropdown:SetOptions({...})
	c:AddButton({Text = "Tp", Callback = function() --[[ TODO ]] end})
	c:AddSlider({Text = "Velocidade do TP (studs/s)", Min = 10, Max = 500, Default = 100, Step = 5, Callback = function(v) --[[ TODO ]] end})

	local r = Tab:AddSection("Roubos")
	r:AddToggle({Text = "Mostrar HUD de roubos", Callback = function(v) --[[ TODO ]] end})
	PoliciaisLabel = r:AddLabel("Policiais: 0") -- PoliciaisLabel:Set("Policiais: 3")
end

do
	local Tab = W:AddTab("Teleport", "📍")
	local s = Tab:AddSection("Locais")
	s:AddToggle({Text = "Mostrar HUD de teleports", Callback = function(v) --[[ TODO ]] end})
	LocaisDropdown = s:AddDropdown({Text = "Local", Options = {}, Callback = function(v) --[[ TODO ]] end}) -- :SetOptions({...})
	s:AddButton({Text = "TP", Callback = function() --[[ TODO ]] end})
	s:AddLabel("Nenhum local do GPS encontrado.")
end

do
	local Tab = W:AddTab("Tp Players", "🧍")
	local s = Tab:AddSection("Players")
	s:AddLabel("Nenhum outro jogador no servidor.")
	PlayersDropdown = s:AddDropdown({Text = "Jogador", Options = {}, Callback = function(v) --[[ TODO ]] end}) -- :SetOptions({...})
	s:AddButton({Text = "TP", Callback = function() --[[ TODO ]] end})
end

-- ============ SERVIÇOS ============
W:AddCategory("Serviços")

local EmpregoLabel, SaldoLabel
do
	local Tab = W:AddTab("Trabalho e compras", "🔨")

	local e = Tab:AddSection("Empregos")
	EmpregoLabel = e:AddLabel("Emprego atual: nenhum") -- :Set("Emprego atual: X")
	e:AddDropdown({Text = "Emprego", Options = {}, Callback = function(v) --[[ TODO ]] end})
	e:AddButton({Text = "Trocar emprego", Callback = function() --[[ TODO ]] end})

	local g = Tab:AddSection("GCM")
	g:AddButton({Text = "Equipar farda de GCM", Callback = function() --[[ TODO ]] end})

	local c = Tab:AddSection("Comprar Itens")
	SaldoLabel = c:AddLabel("Saldo: $0") -- :Set("Saldo: $1000")
	c:AddDropdown({Text = "Item", Options = {}, Callback = function(v) --[[ TODO ]] end})
	c:AddButton({Text = "Comprar", Callback = function() --[[ TODO ]] end})
end

-- ============ VEÍCULO ============
W:AddCategory("Veículo")

do
	local Tab = W:AddTab("Veículo", "🚗")
	local s = Tab:AddSection("Veículo")
	s:AddToggle({Text = "Durabilidade (HUD)", Callback = function(v) --[[ TODO ]] end})
	s:AddButton({Text = "Reparar carro", Callback = function() --[[ TODO ]] end})
	s:AddToggle({Text = "Botão flutuante de reparar", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Botão flutuante roubar", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Cinto automático", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Noclip Car", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "VFly", Keybind = true, Callback = function(v) --[[ TODO ]] end})
	s:AddSlider({Text = "Vel. horizontal VFly", Min = 10, Max = 300, Default = 60, Callback = function(v) --[[ TODO ]] end})
	s:AddSlider({Text = "Vel. vertical VFly", Min = 10, Max = 300, Default = 60, Callback = function(v) --[[ TODO ]] end})
	s:AddSlider({Text = "Boost aceleração (%)", Min = 0, Max = 300, Default = 0, Suffix = "%", Callback = function(v) --[[ TODO ]] end})
	s:AddToggle({Text = "Mostrar melhores carros", Callback = function(v) --[[ TODO ]] end})
end

do
	local Tab = W:AddTab("Universal", "🌍")
	local s = Tab:AddSection("Mundo")
	s:AddLabel("Adicione aqui as opções de mundo.")
	-- s:AddToggle({Text = "...", Callback = function(v) end})
end

-- ============ CONFIG ============
W:AddCategory("Config")

do
	local Tab = W:AddTab("Config", "⚙")

	local m = Tab:AddSection("Menu")
	m:AddKeybind({Text = "Tecla abrir/fechar", Default = Enum.KeyCode.RightShift, Flag = "MenuKey", Callback = function()
		W.Frame.Visible = not W.Frame.Visible
	end})

	local a = Tab:AddSection("Anticheat")
	local acStatus = a:AddLabel("Aplicando...") -- acStatus:Set("Ativo")
	a:AddButton({Text = "Reaplicar silenciador", Callback = function() --[[ TODO ]] end})

	local c = Tab:AddSection("Configs")
	c:AddLabel("Salve, carregue e edite suas configurações.")
	local nome = c:AddInput({Text = "Nome", Placeholder = "Nome", Flag = "ConfigName"})
	local lista = c:AddDropdown({Text = "Configs salvas", Options = {}, Flag = "ConfigSelected"})
	c:AddButton({Text = "Criar nova config", Callback = function() --[[ TODO: salvar Lib.Flags ]] end})
	c:AddButton({Text = "Carregar config", Callback = function() --[[ TODO ]] end})
	c:AddButton({Text = "Editar config selecionada", Callback = function() --[[ TODO ]] end})
	c:AddButton({Text = "Excluir config selecionada", Callback = function() --[[ TODO ]] end})
end

W:SelectTab("Geral")

--------------------------------------------------------------------
-- LOADER
--------------------------------------------------------------------
Lib:CreateLoader({
	Title = "I'M MENU",
	Version = "1.0.0",
	Role = "Cliente",
	Date = os.date("%d/%m/%Y"),
	Changelog = {
		"Nova interface",
		"Todas as abas e seções",
		"Correções gerais",
	},
	Terms = "Use com responsabilidade.",
	OnLoad = function()
		W:SetVisible(true)
		W.ToggleButton.Visible = true
		Lib:Notify({Title = "I'M MENU", Text = "Interface carregada.", Duration = 3})
	end,
})

getgenv = getgenv or function() return _G end
getgenv().IM_MENU_LIB = Lib

end, debug.traceback)

-- Se der erro, mostra no console E na tela (dá para copiar o texto)
if not __ok then
	warn("[I'M MENU] ERRO:\n" .. tostring(__err))
	pcall(function()
		local g = Instance.new("ScreenGui")
		g.Name = "IM_MENU_ERRO"; g.ResetOnSpawn = false; g.DisplayOrder = 999
		g.Parent = LocalPlayer:WaitForChild("PlayerGui")
		local f = Instance.new("Frame")
		f.Size = UDim2.new(0.9, 0, 0, 220); f.Position = UDim2.new(0.05, 0, 0.05, 0)
		f.BackgroundColor3 = Color3.fromRGB(30, 0, 0); f.BorderSizePixel = 0; f.Parent = g
		local t = Instance.new("TextBox")
		t.Size = UDim2.new(1, -16, 1, -16); t.Position = UDim2.fromOffset(8, 8)
		t.BackgroundTransparency = 1; t.TextColor3 = Color3.new(1, 1, 1)
		t.TextSize = 12; t.Font = Enum.Font.Code; t.TextWrapped = true
		t.TextXAlignment = Enum.TextXAlignment.Left; t.TextYAlignment = Enum.TextYAlignment.Top
		t.ClearTextOnFocus = false; t.TextEditable = false
		t.Text = "[I'M MENU] ERRO:\n" .. tostring(__err)
		t.Parent = f
	end)
end
