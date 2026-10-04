--[[
	========================================================================
	NOVA // SINGLE-FILE BUILD  (v3.1.0 + Interaction Upgrade Patch)
	========================================================================
	นำไฟล์นี้ไปวางเป็น **LocalScript** ใน StarterPlayer > StarterPlayerScripts
	(หรือใช้กับ executor ได้เลย — รันได้ทันที ไม่ต้องสร้าง ModuleScript ใดๆ)

	สิ่งที่รวมอยู่ในไฟล์นี้:
	  Core:      Cleanup / Theme / Engine / UI / Effects / Window / Library
	  Components: Controls
	  Systems:    Console
	  + NOVA Demo (ส่วนท้าย แก้ไขได้ตามใจ)
	  + NOVA Upgrade Patch (ลากหน้าต่าง, ยุบ/คลี่หน้าต่าง, toggle แบบใหม่,
	    layout มือถือ, modal กระดาษแป้นพิมพ์)

	* Patch ต้องการ API เพิ่มเติมจากตัว Library เดิม จึงมีส่วนเชื่อม (glue) เล็กน้อย:
	  Library.Options / Library.Palette / Library:Motion() / Library:Watch() /
	  Library:Refresh() / Library:StopDrag() / Library:Tween(token) /
	  Library:After(sec, cb, scope) / Window.CloseButton / Window.Booting
	========================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")


-- ============================================================
-- CORE // CLEANUP (ModuleScript -> inline)
-- ============================================================

type Scope = {
	Alive: boolean,
	_items: {[number]: () -> ()},
	_next: number,
	_parent: Scope?,
	_parentKey: number?,
	Add: (self: Scope, item: any) -> number,
	Remove: (self: Scope, key: number) -> (),
	Forget: (self: Scope, key: number) -> (),
	Child: (self: Scope) -> Scope,
	Destroy: (self: Scope) -> (),
}

local Cleanup = {}
Cleanup.__index = Cleanup

local function disposer(item: any): () -> ()
	if typeof(item) == "RBXScriptConnection" then
		return function()
			item:Disconnect()
		end
	elseif typeof(item) == "Instance" then
		return function()
			item:Destroy()
		end
	elseif type(item) == "function" then
		return item
	elseif type(item) == "table" and type(item.Destroy) == "function" then
		return function()
			item:Destroy()
		end
	end

	error("Unsupported cleanup item")
end

function Cleanup.new(): Scope
	return setmetatable({
		Alive = true,
		_items = {},
		_next = 0,
	}, Cleanup) :: any
end

function Cleanup:Add(item: any): number
	local dispose = disposer(item)

	if not self.Alive then
		dispose()
		return 0
	end

	self._next += 1
	self._items[self._next] = dispose
	return self._next
end

function Cleanup:Forget(key: number)
	self._items[key] = nil
end

function Cleanup:Remove(key: number)
	local dispose = self._items[key]
	self._items[key] = nil

	if dispose then
		local ok, err = pcall(dispose)
		if not ok then
			warn("[NOVA cleanup]", err)
		end
	end
end

function Cleanup:Child(): Scope
	local child = Cleanup.new()
	child._parent = self
	child._parentKey = self:Add(child)
	return child
end

function Cleanup:Destroy()
	if not self.Alive then
		return
	end

	self.Alive = false

	if self._parent and self._parentKey then
		self._parent:Forget(self._parentKey)
	end

	self._parent = nil
	self._parentKey = nil

	local keys = {}
	for key in self._items do
		table.insert(keys, key)
	end
	table.sort(keys, function(a, b)
		return a > b
	end)

	for _, key in keys do
		self:Remove(key)
	end
end


-- ============================================================
-- CORE // THEME
-- ============================================================

type Palette = {[string]: Color3}

local function rgb(hex: number): Color3
	return Color3.fromHex(string.format("%06x", hex))
end

local function palette(
	background: number,
	panel: number,
	panel2: number,
	accent: number,
	secondary: number,
	text: number,
	muted: number
): Palette
	return {
		Background = rgb(background),
		Panel = rgb(panel),
		Panel2 = rgb(panel2),
		Accent = rgb(accent),
		Secondary = rgb(secondary),
		Text = rgb(text),
		Muted = rgb(muted),
		Border = rgb(accent):Lerp(rgb(background), 0.52),
		Glow = rgb(accent),
		Particle = rgb(secondary),

		System = rgb(0x53E8FF),
		Success = rgb(0x68FBB2),
		Warning = rgb(0xFFD66E),
		Error = rgb(0xFF557B),
		Executor = rgb(0xB179FF),
		Console = rgb(0x66B8FF),
		Settings = rgb(0xFF7CCE),
	}
end

local themes: {[string]: Palette} = {
	NeonPurple = palette(
		0x080A17, 0x141329, 0x201A3B,
		0xA774FF, 0x48DFFF, 0xF1F0FF, 0x929DBD
	),
	CyberBlue = palette(
		0x040D19, 0x0B1C30, 0x0D2A40,
		0x438AFF, 0x42F2FF, 0xEAF8FF, 0x85A6C6
	),
	BloodMoon = palette(
		0x13070D, 0x25101A, 0x3A1624,
		0xFF426B, 0xFF946C, 0xFFF0F3, 0xBD8B9B
	),
	Toxic = palette(
		0x07110B, 0x102119, 0x1C3020,
		0xACFF42, 0x37E9A6, 0xF2FFE8, 0x91B49A
	),
	Void = palette(
		0x05050C, 0x10101D, 0x1A1530,
		0x865CFF, 0xDD6CFF, 0xECE7FF, 0x8D88AD
	),
	Amethyst = palette(
		0x10091B, 0x221232, 0x371845,
		0xC887FF, 0xFF70D8, 0xFCEDFF, 0xB395C5
	),
	Arctic = palette(
		0xDCE9F4, 0xF3F9FF, 0xD6E8F5,
		0x3966DA, 0x008AA5, 0x142744, 0x526D88
	),
}

local Theme = {}

Theme.Names = {
	"NeonPurple",
	"CyberBlue",
	"BloodMoon",
	"Toxic",
	"Void",
	"Amethyst",
	"Arctic",
}

function Theme.Get(name: string): Palette
	local selected = themes[name]
	assert(selected, "Unknown NOVA theme: " .. name)
	return table.clone(selected)
end


-- ============================================================
-- CORE // ENGINE
-- ============================================================

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")


local Engine = {}
Engine.__index = Engine

local DEFAULTS = {
	Animated = true,
	Effects = true,
	Particles = true,
	Glow = true,
	ReducedMotion = false,
	PerformanceMode = false,
	TerminalTyping = true,

	UIScale = 1,
	Transparency = 0,
	MaxParticles = 36,
	ParticleLifetime = 12,
	ParticleSpeed = 0.045,
	ParticleOpacity = 0.55,
}

function Engine.new(options)
	local self = setmetatable({}, Engine)

	self.Scope = Cleanup.new()
	self.Options = table.clone(DEFAULTS)

	for key, value in options or {} do
		self.Options[key] = value
	end

	self.ThemeName = self.Options.Theme or "NeonPurple"
	self.Palette = Theme.Get(self.ThemeName)

	self.Time = 0
	self.FPS = 60
	self.Jobs = {}
	self.Bindings = {}
	self.Listeners = {}
	self.Keys = {}
	self.DragState = nil
	self.Capture = nil
	self.OnKey = nil

	local accumulated = 0

	self.Scope:Add(RunService.Heartbeat:Connect(function(dt)
		self.Time += dt
		self.FPS += ((1 / math.max(dt, 0.001)) - self.FPS) * 0.08

		accumulated += dt

		local interval = self.Options.PerformanceMode and 0.1 or 1 / 30
		if accumulated < interval then
			return
		end

		local step = accumulated
		accumulated = 0

		local snapshot = {}
		for token, job in self.Jobs do
			table.insert(snapshot, {token, job})
		end

		for _, entry in snapshot do
			local token, job = entry[1], entry[2]

			if self.Jobs[token] and job.Scope.Alive then
				local ok, err = xpcall(function()
					job.Fn(step, self.Time)
				end, debug.traceback)

				if not ok then
					warn("[NOVA scheduler]", err)
					job.Scope:Remove(job.Key)
				end
			end
		end
	end))

	self.Scope:Add(UserInputService.InputChanged:Connect(function(input)
		local drag = self.DragState
		if not drag then
			return
		end

		local mouse = drag.Input.UserInputType == Enum.UserInputType.MouseButton1

		if input == drag.Input
			or (mouse and input.UserInputType == Enum.UserInputType.MouseMovement)
		then
			drag.Move(Vector2.new(input.Position.X, input.Position.Y))
		end
	end))

	self.Scope:Add(UserInputService.InputEnded:Connect(function(input)
		local drag = self.DragState
		if not drag then
			return
		end

		if input == drag.Input
			or (
				drag.Input.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseButton1
			)
		then
			self:StopDrag()
		end
	end))

	self.Scope:Add(UserInputService.WindowFocusReleased:Connect(function()
		self:StopDrag()
	end))

	self.Scope:Add(UserInputService.InputBegan:Connect(function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if self.Capture then
			local capture = self.Capture
			self.Capture = nil
			capture(input.KeyCode == Enum.KeyCode.Escape and nil or input.KeyCode)
			return
		end

		if self.OnKey and self.OnKey(input, processed) then
			return
		end

		if processed or UserInputService:GetFocusedTextBox() then
			return
		end

		for _, binding in self.Keys do
			if binding.Key == input.KeyCode then
				self:Call(binding.Callback)
			end
		end
	end))

	self.Scope:Add(function()
		self:StopDrag()
		self.Capture = nil
		self.OnKey = nil
		table.clear(self.Keys)
		table.clear(self.Jobs)
		table.clear(self.Bindings)
		table.clear(self.Listeners)
	end)

	return self
end

-- Callbacks should not yield. Schedule staged work with After().
function Engine:Call(callback, ...)
	if not callback then
		return
	end

	local args = table.pack(...)
	local ok, err = xpcall(function()
		callback(table.unpack(args, 1, args.n))
	end, debug.traceback)

	if not ok then
		warn("[NOVA callback]", err)
	end
end

function Engine:Job(scope, callback)
	local token = {}
	local key

	key = scope:Add(function()
		self.Jobs[token] = nil
	end)

	if scope.Alive then
		self.Jobs[token] = {
			Fn = callback,
			Scope = scope,
			Key = key,
		}
	end

	return function()
		scope:Remove(key)
	end
end

function Engine:After(scope, seconds, callback)
	local deadline = self.Time + math.max(seconds, 0)
	local cancel

	cancel = self:Job(scope, function()
		if self.Time >= deadline then
			cancel()
			if scope.Alive then
				self:Call(callback)
			end
		end
	end)

	return cancel
end

function Engine:Motion()
	return self.Options.Animated
		and not self.Options.ReducedMotion
		and not self.Options.PerformanceMode
end

function Engine:Tween(scope, object, duration, properties)
	if not scope.Alive then
		return
	end

	if not self:Motion() then
		for key, value in properties do
			object[key] = value
		end
		return
	end

	local tween = TweenService:Create(
		object,
		TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		properties
	)

	local connection
	local key

	key = scope:Add(function()
		if connection then
			connection:Disconnect()
		end
		tween:Cancel()
		tween:Destroy()
	end)

	connection = tween.Completed:Connect(function()
		scope:Remove(key)
	end)

	tween:Play()
	return tween
end

function Engine:Resolve(role)
	if type(role) == "table" then
		return ColorSequence.new(
			self.Palette[role[1]],
			self.Palette[role[2]]
		)
	end

	return assert(self.Palette[role], "Unknown theme role: " .. tostring(role))
end

function Engine:Bind(scope, object, property, role)
	local token = {}

	self.Bindings[token] = {
		Object = object,
		Property = property,
		Role = role,
	}

	object[property] = self:Resolve(role)

	scope:Add(function()
		self.Bindings[token] = nil
	end)
end

function Engine:Watch(scope, callback)
	local token = {}
	self.Listeners[token] = callback

	scope:Add(function()
		self.Listeners[token] = nil
	end)

	callback()
end

function Engine:Refresh()
	for _, binding in self.Bindings do
		binding.Object[binding.Property] = self:Resolve(binding.Role)
	end

	for _, callback in self.Listeners do
		self:Call(callback)
	end
end

function Engine:SetTheme(name)
	self.ThemeName = name
	self.Palette = Theme.Get(name)

	if self.Options.Accent then
		self.Palette.Accent = self.Options.Accent
		self.Palette.Glow = self.Options.Accent
	end

	self:Refresh()
end

function Engine:SetOption(name, value)
	assert(self.Options[name] ~= nil or name == "Accent", "Unknown option: " .. name)

	self.Options[name] = value

	if name == "Accent" then
		self:SetTheme(self.ThemeName)
	else
		self:Refresh()
	end
end

function Engine:StopDrag()
	local drag = self.DragState
	self.DragState = nil

	if drag and drag.Scroll and drag.Scroll.Parent then
		drag.Scroll.ScrollingEnabled = drag.WasScrolling
	end

	if drag and drag.Finish then
		self:Call(drag.Finish)
	end
end

function Engine:Drag(scope, target, move, finish)
	target.Active = true

	scope:Add(target.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		self:StopDrag()

		local scroll = target:FindFirstAncestorWhichIsA("ScrollingFrame")

		self.DragState = {
			Owner = scope,
			Input = input,
			Move = move,
			Finish = finish,
			Scroll = scroll,
			WasScrolling = scroll and scroll.ScrollingEnabled,
		}

		if scroll then
			scroll.ScrollingEnabled = false
		end

		move(Vector2.new(input.Position.X, input.Position.Y))
	end))

	scope:Add(function()
		if self.DragState and self.DragState.Owner == scope then
			self:StopDrag()
		end
	end)
end

function Engine:Destroy()
	self.Scope:Destroy()
end


-- ============================================================
-- CORE // UI
-- ============================================================

local UI = {}
UI.__index = UI

function UI.new(engine)
	return setmetatable({E = engine}, UI)
end

function UI:New(scope, className, parent, properties, bindings)
	local object = Instance.new(className)

	if object:IsA("GuiObject") then
		object.BorderSizePixel = 0
	end

	if object:IsA("TextLabel")
		or object:IsA("TextButton")
		or object:IsA("TextBox")
	then
		object.Font = Enum.Font.GothamMedium
		object.TextSize = 13
		object.TextColor3 = self.E.Palette.Text
	end

	if object:IsA("TextButton") then
		object.AutoButtonColor = false
	end

	if object:IsA("TextBox") then
		object.ClearTextOnFocus = false
	end

	for key, value in properties or {} do
		object[key] = value
	end

	object.Parent = parent
	scope:Add(object)

	for property, role in bindings or {} do
		self.E:Bind(scope, object, property, role)
	end

	return object
end

function UI:Text(scope, parent, text, properties, role)
	local props = {
		BackgroundTransparency = 1,
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 20),
	}

	for key, value in properties or {} do
		props[key] = value
	end

	return self:New(scope, "TextLabel", parent, props, {
		TextColor3 = role or "Text",
	})
end

function UI:Round(scope, object, radius)
	return self:New(scope, "UICorner", object, {
		CornerRadius = UDim.new(0, radius or 10),
	})
end

function UI:Stroke(scope, object, role, thickness, transparency)
	return self:New(scope, "UIStroke", object, {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
	}, {
		Color = role or "Border",
	})
end

function UI:Gradient(scope, object, a, b, rotation)
	return self:New(scope, "UIGradient", object, {
		Rotation = rotation or 25,
	}, {
		Color = {a or "Panel", b or "Panel2"},
	})
end

function UI:Panel(scope, parent, properties, accent, className)
	local props = {
		BackgroundTransparency = self.E.Options.Transparency,
	}

	for key, value in properties or {} do
		props[key] = value
	end

	local panel = self:New(scope, className or "Frame", parent, props, {
		BackgroundColor3 = "Panel",
	})

	self:Round(scope, panel, 10)
	local stroke = self:Stroke(scope, panel, accent or "Border", 1, 0.15)
	local gradient = self:Gradient(scope, panel, "Panel", "Panel2", 25)

	self.E:Watch(scope, function()
		panel.BackgroundTransparency = self.E.Options.Transparency
	end)

	return panel, stroke, gradient
end

function UI:Padding(scope, parent, amount)
	return self:New(scope, "UIPadding", parent, {
		PaddingLeft = UDim.new(0, amount),
		PaddingRight = UDim.new(0, amount),
		PaddingTop = UDim.new(0, amount),
		PaddingBottom = UDim.new(0, amount),
	})
end

function UI:List(scope, parent, gap)
	return self:New(scope, "UIListLayout", parent, {
		Padding = UDim.new(0, gap or 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

function UI:Button(scope, parent, text, properties, callback, accent)
	local props = {
		Text = "",
		Size = UDim2.fromOffset(140, 48),
		Active = true,
	}

	for key, value in properties or {} do
		props[key] = value
	end

	local button, stroke = self:Panel(
		scope, parent, props, accent or "Accent", "TextButton"
	)

	local label = self:Text(scope, button, text, {
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local scale = self:New(scope, "UIScale", button, {Scale = 1})

	local function animateScale(value)
		self.E:Tween(scope, scale, 0.16, {Scale = value})
	end

	scope:Add(button.MouseEnter:Connect(function()
		if self.E.Options.Effects then
			animateScale(1.025)
			self.E:Tween(scope, stroke, 0.15, {Transparency = 0})
		end

		if self.E.Options.HoverSound then
			self.E:Call(self.E.Options.HoverSound, button)
		end
	end))

	scope:Add(button.MouseLeave:Connect(function()
		animateScale(1)
		self.E:Tween(scope, stroke, 0.15, {Transparency = 0.15})
	end))

	scope:Add(button.Activated:Connect(function()
		if self.E.Options.Effects then
			scale.Scale = 0.97
			animateScale(1)

			if self.E.FX then
				self.E.FX:Ripple(button, scope)
			end
		end

		self.E:Call(callback)
	end))

	return button, label
end

function UI:Field(scope, parent, text, properties)
	local props = {
		Text = text or "",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 0.15,
		TextXAlignment = Enum.TextXAlignment.Left,
	}

	for key, value in properties or {} do
		props[key] = value
	end

	local field = self:New(scope, "TextBox", parent, props, {
		BackgroundColor3 = "Background",
		TextColor3 = "Text",
		PlaceholderColor3 = "Muted",
	})

	self:Round(scope, field, 7)
	self:Stroke(scope, field, "Border", 1, 0.1)
	self:Padding(scope, field, 10)

	return field
end

function UI:Brackets(scope, parent, role)
	for _, info in {
		{0, 0, 0, 0},
		{1, 0, 1, 0},
		{0, 1, 0, 1},
		{1, 1, 1, 1},
	} do
		local horizontal = self:New(scope, "Frame", parent, {
			AnchorPoint = Vector2.new(info[3], info[4]),
			Position = UDim2.fromScale(info[1], info[2]),
			Size = UDim2.fromOffset(25, 2),
		}, {BackgroundColor3 = role or "Accent"})

		self:New(scope, "Frame", parent, {
			AnchorPoint = horizontal.AnchorPoint,
			Position = horizontal.Position,
			Size = UDim2.fromOffset(2, 25),
		}, {BackgroundColor3 = role or "Accent"})
	end
end


-- ============================================================
-- CORE // EFFECTS
-- ============================================================

local Effects = {}
Effects.__index = Effects

function Effects.new(engine, ui)
	return setmetatable({E = engine, U = ui}, Effects)
end

function Effects:Background(parent, owner, options)
	options = options or {}

	local E, U = self.E, self.U
	local scope = owner:Child()

	local layer = U:New(scope, "Frame", parent, {
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
	}, {BackgroundColor3 = "Background"})

	U:Gradient(scope, layer, "Background", "Panel2", 30)

	local grid = U:New(scope, "Frame", layer, {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 80, 1, 80),
		Position = UDim2.fromOffset(-40, -40),
	})

	for i = 0, 28 do
		U:New(scope, "Frame", grid, {
			Position = UDim2.fromOffset(i * 52, 0),
			Size = UDim2.new(0, 1, 1, 0),
			BackgroundTransparency = 0.93,
		}, {BackgroundColor3 = "Secondary"})
	end

	for i = 0, 20 do
		U:New(scope, "Frame", grid, {
			Position = UDim2.fromOffset(0, i * 52),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundTransparency = 0.94,
		}, {BackgroundColor3 = "Accent"})
	end

	local beams = {}
	for i = 1, 3 do
		local beam = U:New(scope, "Frame", layer, {
			Size = UDim2.new(0, 130, 1.8, 0),
			Rotation = 25,
			BackgroundTransparency = 0.93,
		}, {BackgroundColor3 = i % 2 == 0 and "Accent" or "Secondary"})

		local gradient = U:New(scope, "UIGradient", beam, {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
		})

		table.insert(beams, beam)
	end

	local scan = U:New(scope, "Frame", layer, {
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundTransparency = 0.65,
	}, {BackgroundColor3 = "System"})

	local ring = U:New(scope, "Frame", layer, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.83, 0.45),
		Size = UDim2.fromOffset(260, 260),
		BackgroundTransparency = 1,
		Rotation = 45,
	})

	U:Stroke(scope, ring, "Accent", 1, 0.72)
	U:Round(scope, ring, 75)

	local innerRing = U:New(scope, "Frame", ring, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.76, 0.76),
		BackgroundTransparency = 1,
		Rotation = 30,
	})

	U:Stroke(scope, innerRing, "Secondary", 1, 0.72)
	U:Round(scope, innerRing, 100)
	U:Brackets(scope, ring, "Secondary")

	local random = Random.new(701)
	local particles = {}

	local count = math.clamp(
		options.Count or E.Options.MaxParticles,
		0,
		100
	)

	for i = 1, count do
		local kind = i % 4
		local node

		if kind == 0 then
			node = U:Text(scope, layer, "0x" .. string.format("%02X", i * 3), {
				Size = UDim2.fromOffset(38, 16),
				TextSize = 9,
				Font = Enum.Font.Code,
				TextTransparency = 0.65,
			}, "Particle")
		elseif kind == 1 then
			node = U:Text(scope, layer, "+", {
				Size = UDim2.fromOffset(12, 12),
				TextSize = 13,
				TextTransparency = 0.5,
			}, "Particle")
		else
			node = U:New(scope, "Frame", layer, {
				Size = UDim2.fromOffset(kind == 2 and 2 or 6, 2),
				Rotation = kind == 2 and 0 or -35,
				BackgroundTransparency = 0.5,
			}, {BackgroundColor3 = "Particle"})
		end

		table.insert(particles, {
			Node = node,
			X = random:NextNumber(),
			Y = random:NextNumber(),
			Phase = random:NextNumber(),
			Speed = random:NextNumber(0.55, 1.4),
		})
	end

	-- GUI vignette: dark edge layers, not a Lighting blur.
	for _, side in {"Left", "Right"} do
		local edge = U:New(scope, "Frame", layer, {
			AnchorPoint = Vector2.new(side == "Right" and 1 or 0, 0),
			Position = UDim2.fromScale(side == "Right" and 1 or 0, 0),
			Size = UDim2.new(0.12, 0, 1, 0),
			BackgroundTransparency = 0.3,
		}, {BackgroundColor3 = "Background"})

		U:New(scope, "UIGradient", edge, {
			Rotation = side == "Right" and 180 or 0,
			Transparency = NumberSequence.new(0, 1),
		})
	end

	E:Watch(scope, function()
		local rich = E.Options.Effects and not E.Options.PerformanceMode

		grid.Visible = rich
		scan.Visible = rich
		ring.Visible = rich and E.Options.Glow

		for _, beam in beams do
			beam.Visible = rich and E.Options.Glow
		end

		for _, particle in particles do
			particle.Node.Visible = rich and E.Options.Particles
		end
	end)

	local clock = 0

	E:Job(scope, function(dt)
		if not E:Motion() or not E.Options.Effects then
			return
		end

		clock += dt
		grid.Position = UDim2.fromOffset(-52 + (clock * 3) % 52, -40)

		scan.Position = UDim2.fromScale(0, (clock * 0.055) % 1)

		ring.Rotation = 45 + clock * 5
		innerRing.Rotation = 30 - clock * 8

		for i, beam in beams do
			beam.Position = UDim2.fromScale(
				((clock * 0.027 + i / 3) % 1.6) - 0.3,
				-0.4
			)
		end

		if E.Options.Particles then
			local lifetime = math.max(E.Options.ParticleLifetime, 0.1)
			local speed = E.Options.ParticleSpeed

			for _, particle in particles do
				local age = (clock / lifetime + particle.Phase) % 1
				local opacity = math.sin(age * math.pi)
					* E.Options.ParticleOpacity

				particle.Node.Position = UDim2.fromScale(
					(particle.X + math.sin(clock * 0.2 + particle.Phase) * 0.018) % 1,
					(particle.Y - clock * speed * particle.Speed) % 1
				)

				if particle.Node:IsA("TextLabel") then
					particle.Node.TextTransparency = 1 - opacity
				else
					particle.Node.BackgroundTransparency = 1 - opacity
				end
			end
		end
	end)

	return scope
end

function Effects:Play(name, target, owner, options)
	options = options or {}

	local E, U = self.E, self.U
	local scope = owner:Child()
	local duration = options.Duration or 0.55

	if not E.Options.Effects or not E:Motion() then
		scope:Destroy()
		return scope
	end

	local function overlay(properties)
		properties = properties or {}
		properties.ZIndex = math.max(target.ZIndex + 1, 5)

		return U:New(scope, "Frame", target, properties, {
			BackgroundColor3 = options.Role or "Glow",
		})
	end

	if name == "Fade" then
		local property = target:IsA("CanvasGroup")
			and "GroupTransparency"
			or "BackgroundTransparency"

		E:Tween(scope, target, duration, {
			[property] = options.Transparency or 0,
		})

	elseif name == "Slide" then
		local original = target.Position
		target.Position = original + UDim2.fromOffset(options.X or 24, options.Y or 0)
		E:Tween(scope, target, duration, {Position = original})

	elseif name == "Scale" then
		local scale = U:New(scope, "UIScale", target, {
			Scale = options.From or 0.97,
		})
		E:Tween(scope, scale, duration, {Scale = 1})

	elseif name == "Glitch" then
		for i = 1, 5 do
			local band = overlay({
				Position = UDim2.fromScale(0, i / 6),
				Size = UDim2.new(1, 0, 0, i % 2 == 0 and 3 or 1),
				BackgroundTransparency = 0.35,
			})

			E:Tween(scope, band, duration, {
				Position = band.Position + UDim2.fromOffset(i % 2 == 0 and 35 or -35, 0),
				BackgroundTransparency = 1,
			})
		end

	elseif name == "ParticleBurst" or name == "EnergyBurst" then
		local count = math.min(options.Count or 12, 32)

		for i = 1, count do
			local angle = i / count * math.pi * 2
			local dot = overlay({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(4, 2),
				Rotation = math.deg(angle),
				BackgroundTransparency = 0.1,
			})

			E:Tween(scope, dot, duration, {
				Position = UDim2.new(
					0.5, math.cos(angle) * 75,
					0.5, math.sin(angle) * 40
				),
				BackgroundTransparency = 1,
			})
		end

	elseif name == "Ripple" then
		local circle = overlay({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(4, 4),
			BackgroundTransparency = 0.82,
		})

		U:Round(scope, circle, 1000)

		local size = math.min(math.max(target.AbsoluteSize.X, 60), 220)
		E:Tween(scope, circle, duration, {
			Size = UDim2.fromOffset(size, size),
			BackgroundTransparency = 1,
		})

	elseif name == "Glow" or name == "Pulse" then
		local frame = overlay({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		})

		U:Round(scope, frame, 10)
		local stroke = U:Stroke(scope, frame, "Glow", 5, 0.25)

		E:Tween(scope, stroke, duration, {
			Thickness = 1,
			Transparency = 1,
		})

	elseif name == "Scanline" then
		local line = overlay({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.new(1, 0, 0, 2),
			BackgroundTransparency = 0.2,
		})

		E:Tween(scope, line, duration, {
			Position = UDim2.fromScale(0, 1),
			BackgroundTransparency = 1,
		})

	elseif name == "Shimmer" or name == "EnergySweep" then
		local beam = overlay({
			Position = UDim2.fromScale(-0.2, 0),
			Size = UDim2.new(0.18, 0, 1, 0),
			BackgroundTransparency = 0.78,
		})

		U:New(scope, "UIGradient", beam, {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
		})

		E:Tween(scope, beam, duration, {
			Position = UDim2.fromScale(1, 0),
			BackgroundTransparency = 1,
		})

	else
		scope:Destroy()
		error("Unknown effect: " .. tostring(name))
	end

	E:After(scope, duration + 0.05, function()
		scope:Destroy()
	end)

	return scope
end

for _, name in {
	"Glow", "Pulse", "Ripple", "Shimmer", "Scanline",
	"ParticleBurst", "EnergySweep", "EnergyBurst",
	"Glitch", "Fade", "Slide", "Scale",
} do
	local effectName = name

	Effects[effectName] = function(self, target, owner, options)
		return self:Play(effectName, target, owner, options)
	end
end


-- ============================================================
-- COMPONENTS // CONTROLS
-- ============================================================

local Controls = {}

local function finite(value)
	return type(value) == "number"
		and value == value
		and value > -math.huge
		and value < math.huge
end

local function numerical(options)
	local min = options.Min or 0
	local max = options.Max or 100
	local step = options.Step or 1

	assert(finite(min) and finite(max) and max > min, "Invalid numeric range")
	assert(finite(step) and step > 0, "Step must be positive")

	local decimals = 0
	while decimals < 6
		and math.abs(step * 10 ^ decimals - math.round(step * 10 ^ decimals)) > 0.000001
	do
		decimals += 1
	end

	local function validate(value)
		local number = tonumber(value)
		assert(finite(number), "Expected a finite number")

		number = min + math.round((number - min) / step) * step
		number = math.clamp(number, min, max)

		return tonumber(string.format("%." .. decimals .. "f", number))
	end

	local function format(value)
		return string.format("%." .. decimals .. "f", value)
	end

	return validate, format, min, max, step
end

local function row(tab, options, height)
	local scope = tab.Scope:Child()
	local U = tab.Window.U

	tab.Order += 1

	local frame = U:Panel(scope, tab.Container, {
		Size = UDim2.new(1, -2, 0, height),
		LayoutOrder = tab.Order,
		ClipsDescendants = true,
	}, options.Accent or "Border")

	U:New(scope, "Frame", frame, {
		Position = UDim2.fromOffset(0, 14),
		Size = UDim2.fromOffset(3, 26),
	}, {BackgroundColor3 = options.Accent or "Accent"})

	U:Text(scope, frame, string.upper(options.Name or "CONTROL"), {
		Position = UDim2.fromOffset(16, 12),
		Size = UDim2.new(1, -32, 0, 20),
		TextSize = 12,
	})

	if options.Description then
		U:Text(scope, frame, options.Description, {
			Position = UDim2.fromOffset(16, 34),
			Size = UDim2.new(1, -32, 0, 32),
			TextSize = 11,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, "Muted")
	end

	local control = {
		Scope = scope,
		Frame = frame,
		Window = tab.Window,
		Callback = options.Callback,
	}

	function control:Destroy()
		self.Scope:Destroy()
	end

	return control
end

local function state(control, options, validator, render, default)
	control.Validate = function(_, value)
		return validator(value)
	end

	function control:Set(value, silent)
		if not self.Scope.Alive then
			return
		end

		self.Value = validator(value)
		render(self.Value)

		if not silent then
			self.Window.E:Call(self.Callback, self.Value)
		end
	end

	control:Set(default, true)

	if options.Id then
		local registry = control.Window.Library.Registry

		assert(not registry[options.Id], "Duplicate control Id: " .. options.Id)
		registry[options.Id] = control

		control.Scope:Add(function()
			if registry[options.Id] == control then
				registry[options.Id] = nil
			end
		end)
	end

	return control
end

function Controls.CreateSection(tab, name)
	tab.Order += 1

	return tab.Window.U:Text(tab.Scope, tab.Container, "// " .. string.upper(name), {
		LayoutOrder = tab.Order,
		Size = UDim2.new(1, 0, 0, 30),
		TextSize = 11,
		Font = Enum.Font.Code,
	}, "Secondary")
end

function Controls.CreateButton(tab, options)
	local control = row(tab, options, 124)
	local W, U, E = tab.Window, tab.Window.U, tab.Window.E

	local button = U:Button(control.Scope, control.Frame,
		(options.Icon and ("[ " .. options.Icon .. " ]  ") or "") .. (options.Name or "COMMAND"),
		{
			Position = UDim2.fromOffset(16, 68),
			Size = UDim2.new(1, -32, 0, 44),
		},
		function()
			W.FX:EnergySweep(control.Frame, control.Scope)
			E:Call(options.Callback)
		end,
		options.Accent or "Accent"
	)

	control.Button = button
	return control
end

function Controls.CreateToggle(tab, options)
	local control = row(tab, options, 124)
	local U, E = tab.Window.U, tab.Window.E

	local switch, label = U:Button(control.Scope, control.Frame, "", {
		Position = UDim2.fromOffset(16, 68),
		Size = UDim2.new(1, -32, 0, 44),
	}, function()
		control:Set(not control.Value)
	end)

	local beam = U:New(control.Scope, "Frame", switch, {
		Position = UDim2.new(0, 12, 1, -6),
		Size = UDim2.new(0.2, 0, 0, 2),
	}, {BackgroundColor3 = "Success"})

	return state(control, options, function(value)
		assert(type(value) == "boolean", "Toggle expects boolean")
		return value
	end, function(value)
		label.Text = value and "POWER  [ ========● ]  ACTIVE" or "POWER  [ ●-------- ]  STANDBY"

		E:Tween(control.Scope, beam, 0.25, {
			Size = UDim2.new(value and 0.9 or 0.15, 0, 0, 2),
			BackgroundTransparency = value and 0 or 0.65,
		})

		if value then
			tab.Window.FX:Pulse(switch, control.Scope)
		end
	end, options.Default == true)
end

function Controls.CreateSlider(tab, options)
	local control = row(tab, options, 160)
	local U, E = tab.Window.U, tab.Window.E
	local validate, format, min, max = numerical(options)

	local valueText = U:Text(control.Scope, control.Frame, "", {
		Position = UDim2.fromOffset(16, 66),
		Size = UDim2.new(1, -32, 0, 22),
		Font = Enum.Font.Code,
	}, options.Accent or "System")

	local hitbox = U:New(control.Scope, "TextButton", control.Frame, {
		Text = "",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 88),
		Size = UDim2.new(1, -32, 0, 46),
		AutoButtonColor = false,
	})

	local track = U:New(control.Scope, "Frame", hitbox, {
		Position = UDim2.new(0, 0, 0.5, -3),
		Size = UDim2.new(1, 0, 0, 6),
	}, {BackgroundColor3 = "Background"})

	U:Round(control.Scope, track, 8)

	local fill = U:New(control.Scope, "Frame", track, {
		Size = UDim2.fromScale(0, 1),
	}, {BackgroundColor3 = "Accent"})

	U:Round(control.Scope, fill, 8)
	U:Gradient(control.Scope, fill, "Accent", "Secondary", 0)

	for i = 0, 10 do
		U:New(control.Scope, "Frame", hitbox, {
			Position = UDim2.new(i / 10, 0, 0.5, 11),
			Size = UDim2.fromOffset(1, i % 5 == 0 and 7 or 4),
			BackgroundTransparency = 0.4,
		}, {BackgroundColor3 = "Muted"})
	end

	local thumb = U:New(control.Scope, "Frame", hitbox, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(22, 22),
	}, {BackgroundColor3 = "Text"})

	U:Round(control.Scope, thumb, 12)
	U:Stroke(control.Scope, thumb, "Accent", 3, 0.1)

	U:Text(control.Scope, control.Frame, tostring(min), {
		Position = UDim2.fromOffset(16, 138),
		Size = UDim2.fromOffset(90, 16),
		TextSize = 10,
	}, "Muted")

	U:Text(control.Scope, control.Frame, tostring(max), {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 138),
		Size = UDim2.fromOffset(90, 16),
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, "Muted")

	state(control, options, validate, function(value)
		local alpha = (value - min) / (max - min)

		fill.Size = UDim2.fromScale(alpha, 1)
		thumb.Position = UDim2.fromScale(alpha, 0.5)

		valueText.Text = "VALUE // " .. format(value)
			.. (options.Percentage and ("  |  " .. math.round(alpha * 100) .. "%") or "")
	end, options.Default or min)

	local lastBurst = -1

	E:Drag(control.Scope, hitbox, function(position)
		local alpha = math.clamp(
			(position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1),
			0,
			1
		)

		local value = validate(min + (max - min) * alpha)

		if value ~= control.Value then
			control:Set(value)
		end

		if E.Time - lastBurst > 0.18 then
			lastBurst = E.Time
			tab.Window.FX:ParticleBurst(thumb, control.Scope, {Count = 5, Duration = 0.3})
		end
	end)

	return control
end

function Controls.CreateInput(tab, options)
	local control = row(tab, options, 124)
	local U, E = tab.Window.U, tab.Window.E

	local numeric = options.Numeric == true
	local validate, format, _, _, step

	if numeric then
		validate, format, _, _, step = numerical(options)
	else
		validate = function(value)
			assert(type(value) == "string", "Input expects string")
			return string.sub(value, 1, options.MaxLength or 4096)
		end

		format = tostring
	end

	local field = U:Field(control.Scope, control.Frame, "", {
		Position = UDim2.fromOffset(numeric and 70 or 16, 68),
		Size = UDim2.new(1, numeric and -140 or -32, 0, 44),
		TextXAlignment = numeric and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
		PlaceholderText = options.Placeholder or "ENTER VALUE",
	})

	state(control, options, validate, function(value)
		field.Text = format(value)
	end, options.Default or (numeric and (options.Min or 0) or ""))

	control.Field = field

	control.Scope:Add(field.FocusLost:Connect(function()
		local ok, value = pcall(validate, field.Text)

		if ok then
			control:Set(value)
		else
			field.Text = format(control.Value)
			tab.Window.FX:Glitch(control.Frame, control.Scope)
		end
	end))

	if numeric then
		U:Button(control.Scope, control.Frame, "−", {
			Position = UDim2.fromOffset(16, 68),
			Size = UDim2.fromOffset(44, 44),
		}, function()
			control:Set(control.Value - step)
		end)

		U:Button(control.Scope, control.Frame, "+", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -16, 0, 68),
			Size = UDim2.fromOffset(44, 44),
		}, function()
			control:Set(control.Value + step)
		end)
	end

	return control
end

function Controls.CreateDropdown(tab, options)
	local control = row(tab, options, 124)
	local U, W = tab.Window.U, tab.Window
	local values = options.Values or {}

	assert(#values > 0, "Dropdown requires Values")

	local _, label = U:Button(control.Scope, control.Frame, "", {
		Position = UDim2.fromOffset(16, 68),
		Size = UDim2.new(1, -32, 0, 44),
	}, function()
		local items = {}

		for _, value in values do
			table.insert(items, {
				Name = tostring(value),
				Value = value,
				Selected = value == control.Value,
			})
		end

		W:OpenPicker(options.Name or "SELECT MODE", items, function(item)
			if control.Scope.Alive then
				control:Set(item.Value)
			end
		end)
	end)

	return state(control, options, function(value)
		assert(table.find(values, value), "Invalid dropdown value")
		return value
	end, function(value)
		label.Text = "[ " .. tostring(value) .. " ]     ▾"
	end, options.Default or values[1])
end

function Controls.CreateKeybind(tab, options)
	local control = row(tab, options, 124)
	local E, U = tab.Window.E, tab.Window.U
	local token = {}

	local _, label = U:Button(control.Scope, control.Frame, "", {
		Position = UDim2.fromOffset(16, 68),
		Size = UDim2.new(1, -32, 0, 44),
	}, function()
		if E.Capture then
			return
		end

		label.Text = "PRESS A KEY // ESC TO CANCEL"

		local capture
		capture = function(key)
			if not control.Scope.Alive then
				return
			end

			if key then
				control:Set(key.Name)
			else
				label.Text = "[ " .. control.Value .. " ]"
			end
		end

		E.Capture = capture

		control.Scope:Add(function()
			if E.Capture == capture then
				E.Capture = nil
			end
		end)
	end)

	control.Scope:Add(function()
		E.Keys[token] = nil
	end)

	return state(control, options, function(value)
		if typeof(value) == "EnumItem" then
			value = value.Name
		end

		assert(type(value) == "string", "Keybind expects a KeyCode name")

		local ok, key = pcall(function()
			return Enum.KeyCode[value]
		end)

		assert(ok and key and key ~= Enum.KeyCode.Unknown, "Invalid key")
		return value
	end, function(value)
		label.Text = "[ " .. value .. " ]"

		E.Keys[token] = {
			Key = Enum.KeyCode[value],
			Callback = options.OnPressed,
		}
	end, options.Default or "RightShift")
end

function Controls.CreateColorPicker(tab, options)
	local control = row(tab, options, 320)
	local U = tab.Window.U

	local swatch = U:New(control.Scope, "Frame", control.Frame, {
		Position = UDim2.fromOffset(16, 68),
		Size = UDim2.new(1, -32, 0, 36),
	})

	U:Round(control.Scope, swatch, 7)
	U:Stroke(control.Scope, swatch, "Border", 1, 0)

	local axes = {}
	local hsv = {0, 1, 1}

	for index, name in {"HUE", "SATURATION", "VALUE"} do
		local y = 118 + (index - 1) * 64

		local label = U:Text(control.Scope, control.Frame, name, {
			Position = UDim2.fromOffset(16, y),
			Size = UDim2.new(1, -32, 0, 16),
			TextSize = 10,
			Font = Enum.Font.Code,
		}, "Muted")

		local hit = U:New(control.Scope, "TextButton", control.Frame, {
			Position = UDim2.fromOffset(16, y + 16),
			Size = UDim2.new(1, -32, 0, 44),
			Text = "",
			BackgroundTransparency = 1,
			AutoButtonColor = false,
		})

		local track = U:New(control.Scope, "Frame", hit, {
			Position = UDim2.new(0, 0, 0.5, -3),
			Size = UDim2.new(1, 0, 0, 6),
		}, {BackgroundColor3 = "Background"})

		local fill = U:New(control.Scope, "Frame", track, {
			Size = UDim2.fromScale(1, 1),
		}, {BackgroundColor3 = "Accent"})

		U:Round(control.Scope, track, 5)
		U:Round(control.Scope, fill, 5)

		axes[index] = {Fill = fill, Label = label, Name = name}

		tab.Window.E:Drag(control.Scope, hit, function(position)
			hsv[index] = math.clamp(
				(position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1),
				0,
				1
			)

			control:Set(Color3.fromHSV(hsv[1], hsv[2], hsv[3]))
		end)
	end

	return state(control, options, function(value)
		assert(typeof(value) == "Color3", "ColorPicker expects Color3")
		return value
	end, function(value)
		hsv[1], hsv[2], hsv[3] = value:ToHSV()
		swatch.BackgroundColor3 = value

		for index, axis in axes do
			axis.Fill.Size = UDim2.fromScale(hsv[index], 1)
			axis.Label.Text = axis.Name .. " // " .. math.round(hsv[index] * 100) .. "%"
		end
	end, options.Default or Color3.fromRGB(167, 116, 255))
end

function Controls.Install(tabClass)
	for _, name in {
		"CreateSection",
		"CreateButton",
		"CreateToggle",
		"CreateSlider",
		"CreateInput",
		"CreateDropdown",
		"CreateKeybind",
		"CreateColorPicker",
	} do
		tabClass[name] = Controls[name]
	end
end


-- ============================================================
-- SYSTEMS // CONSOLE
-- ============================================================

local Console = {}
Console.__index = Console

local ROLES = {
	INFO = "System",
	SUCCESS = "Success",
	WARNING = "Warning",
	ERROR = "Error",
	DEBUG = "Muted",
}

function Console.new(window, tab)
	local self = setmetatable({}, Console)

	self.Window = window
	self.Scope = tab.Scope:Child()
	self.Logs = {}
	self.Query = ""
	self.Level = "ALL"
	self.AutoScroll = true
	self.MaxLogs = 160
	self.RenderScope = nil
	self.RenderPending = false

	local E, U = window.E, window.U

	tab:CreateSection("LIVE DEVELOPER TERMINAL")

	local tools = U:Panel(self.Scope, tab.Container, {
		LayoutOrder = 10,
		Size = UDim2.new(1, -2, 0, 176),
	}, "Console")

	local search = U:Field(self.Scope, tools, "", {
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.new(1, -24, 0, 44),
		PlaceholderText = "SEARCH LOGS...",
	})

	self.Scope:Add(search:GetPropertyChangedSignal("Text"):Connect(function()
		self.Query = string.lower(search.Text)
		self:Refresh()
	end))

	U:Button(self.Scope, tools, "FILTER", {
		Position = UDim2.fromOffset(12, 66),
		Size = UDim2.new(0.5, -18, 0, 44),
	}, function()
		local items = {}

		for _, level in {"ALL", "INFO", "SUCCESS", "WARNING", "ERROR", "DEBUG"} do
			table.insert(items, {Name = level})
		end

		window:OpenPicker("LOG LEVEL", items, function(item)
			self.Level = item.Name
			self:Refresh()
		end)
	end, "Console")

	U:Button(self.Scope, tools, "COPY", {
		Position = UDim2.new(0.5, 6, 0, 66),
		Size = UDim2.new(0.5, -18, 0, 44),
	}, function()
		window:TextDialog("COPY CONSOLE // SELECT TEXT", self:Export(), true)
	end, "Console")

	U:Button(self.Scope, tools, "CLEAR", {
		Position = UDim2.fromOffset(12, 120),
		Size = UDim2.new(0.5, -18, 0, 44),
	}, function()
		table.clear(self.Logs)
		self:Refresh()
	end, "Warning")

	local _, autoLabel

	_, autoLabel = U:Button(self.Scope, tools, "AUTO SCROLL: ON", {
		Position = UDim2.new(0.5, 6, 0, 120),
		Size = UDim2.new(0.5, -18, 0, 44),
	}, function()
		self.AutoScroll = not self.AutoScroll
		autoLabel.Text = "AUTO SCROLL: " .. (self.AutoScroll and "ON" or "OFF")
	end, "Console")

	local terminal = U:Panel(self.Scope, tab.Container, {
		LayoutOrder = 11,
		Size = UDim2.new(1, -2, 0, 360),
		ClipsDescendants = true,
	}, "Console")

	U:Brackets(self.Scope, terminal, "Console")

	self.List = U:New(self.Scope, "ScrollingFrame", terminal, {
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.new(1, -24, 1, -54),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {ScrollBarImageColor3 = "Console"})

	U:List(self.Scope, self.List, 7)

	local cursor = U:Text(self.Scope, terminal, "", {
		Position = UDim2.new(0, 14, 1, -30),
		Size = UDim2.new(1, -28, 0, 20),
		TextSize = 11,
		Font = Enum.Font.Code,
	}, "Success")

	local started = E.Time
	local message = "> INTERFACE CONNECTED // SYSTEM READY"

	E:Job(self.Scope, function(_, now)
		local typing = E.Options.TerminalTyping and E:Motion()
		local count = typing and math.floor((now - started) * 26) or #message
		local blink = E:Motion() and math.floor(now * 2) % 2 == 0

		cursor.Text = string.sub(message, 1, math.min(count, #message))
			.. (blink and "_" or " ")
	end)

	self.Scope:Add(self.List:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
		if self.AutoScroll then
			self.List.CanvasPosition = Vector2.new(
				0,
				math.max(0, self.List.AbsoluteCanvasSize.Y - self.List.AbsoluteSize.Y)
			)
		end
	end))

	self:Log("SUCCESS", "NOVA console attached.")
	return self
end

function Console:Log(level, message)
	if not self.Scope.Alive then
		return
	end

	level = string.upper(level or "INFO")

	if not ROLES[level] then
		level = "INFO"
	end

	table.insert(self.Logs, {
		Time = os.date("%H:%M:%S"),
		Level = level,
		Message = string.sub(tostring(message), 1, 3000),
	})

	while #self.Logs > self.MaxLogs do
		table.remove(self.Logs, 1)
	end

	self:Refresh()
end

function Console:Export()
	local result = {}

	for _, log in self.Logs do
		table.insert(result, string.format(
			"[%s] [%s] %s",
			log.Time,
			log.Level,
			log.Message
		))
	end

	return table.concat(result, "\n")
end

function Console:Refresh()
	if self.RenderPending or not self.Scope.Alive then
		return
	end

	self.RenderPending = true

	self.Window.E:After(self.Scope, 0, function()
		self.RenderPending = false

		if self.RenderScope then
			self.RenderScope:Destroy()
		end

		self.RenderScope = self.Scope:Child()

		for index, log in self.Logs do
			local matchesLevel = self.Level == "ALL" or self.Level == log.Level
			local matchesQuery = self.Query == ""
				or string.find(string.lower(log.Message), self.Query, 1, true)

			if matchesLevel and matchesQuery then
				self.Window.U:Text(self.RenderScope, self.List,
					string.format("[%s] [%s] %s", log.Time, log.Level, log.Message),
					{
						LayoutOrder = index,
						Size = UDim2.new(1, -10, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						TextWrapped = true,
						TextSize = 11,
						TextYAlignment = Enum.TextYAlignment.Top,
						Font = Enum.Font.Code,
					},
					ROLES[log.Level]
				)
			end
		end
	end)
end

function Console:Destroy()
	self.Scope:Destroy()
end


-- ============================================================
-- CORE // WINDOW (+ TAB)
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")


local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

Controls.Install(Tab)

function Window.new(library, options)
	local self = setmetatable({}, Window)

	self.Library = library
	self.E = library.Engine
	self.U = library.UI
	self.FX = library.Effects
	self.Scope = self.E.Scope:Child()
	self.Tabs = {}
	self.Commands = {}
	self.Notices = {}
	self.CurrentTab = nil
	self.Popup = nil
	self.Mobile = false
	self.DrawerOpen = false
	self.Minimized = false
	self.Booting = false
	self.Status = {
		Name = "READY",
		Message = "All interface systems operational.",
		Progress = 0,
		Started = self.E.Time,
	}

	local E, U, S = self.E, self.U, self.Scope

	self.Gui = U:New(S, "ScreenGui",
		Players.LocalPlayer:WaitForChild("PlayerGui"),
		{
			Name = "NOVA_CommandCenter",
			ResetOnSpawn = false,
			IgnoreGuiInset = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = options.DisplayOrder or 50,
		}
	)

	self.Root = U:New(S, "Frame", self.Gui, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})

	self.Shell = U:Panel(S, self.Root, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(1180, 760),
		ClipsDescendants = true,
	}, "Accent")

	self.Scale = U:New(S, "UIScale", self.Shell, {Scale = 1})

	self.FX:Background(self.Shell, S)

	-- Layered outer neon shell.
	for index = 1, 3 do
		local frame = U:New(S, "Frame", self.Shell, {
			Position = UDim2.fromOffset(index * 3, index * 3),
			Size = UDim2.new(1, -index * 6, 1, -index * 6),
			BackgroundTransparency = 1,
			ZIndex = 2,
		})

		U:Round(S, frame, 12)

		local stroke = U:Stroke(
			S, frame, index % 2 == 0 and "Secondary" or "Glow",
			index == 1 and 2 or 1,
			0.35 + index * 0.12
		)

		E:Watch(S, function()
			stroke.Enabled = index == 1
				or (E.Options.Glow and not E.Options.PerformanceMode)
		end)
	end

	local border = U:Stroke(S, self.Shell, "Accent", 2, 0.1)
	local borderGradient = U:Gradient(S, border, "Accent", "Secondary", 0)

	E:Job(S, function(_, now)
		if E:Motion() and E.Options.Effects then
			borderGradient.Rotation = (now * 25) % 360
		end
	end)

	self.Header = U:Panel(S, self.Shell, {
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.new(1, -24, 0, 86),
		ZIndex = 10,
	}, "Border")

	self.Menu = U:Button(S, self.Header, "☰", {
		Position = UDim2.fromOffset(10, 20),
		Size = UDim2.fromOffset(46, 46),
	}, function()
		self:ToggleDrawer()
	end)

	local logo = U:Panel(S, self.Header, {
		Position = UDim2.fromOffset(16, 16),
		Size = UDim2.fromOffset(54, 54),
		Rotation = 0,
	}, "Accent")

	U:Text(S, logo, "N", {
		Size = UDim2.fromScale(1, 1),
		TextSize = 32,
		TextXAlignment = Enum.TextXAlignment.Center,
		Font = Enum.Font.GothamBlack,
	}, "Secondary")

	self.Logo = logo

	self.Title = U:Text(S, self.Header, options.Title or "N O V A", {
		Position = UDim2.fromOffset(86, 16),
		Size = UDim2.fromOffset(230, 30),
		TextSize = 26,
		Font = Enum.Font.GothamBlack,
	})

	self.Subtitle = U:Text(S, self.Header, options.Subtitle or "ADVANCED INTERFACE", {
		Position = UDim2.fromOffset(88, 48),
		Size = UDim2.fromOffset(280, 18),
		TextSize = 9,
		Font = Enum.Font.Code,
	}, "Muted")

	self.Telemetry = U:Text(S, self.Header, "● SYSTEM ONLINE", {
		Position = UDim2.new(0.42, 0, 0, 22),
		Size = UDim2.new(0.34, -20, 0, 44),
		TextSize = 11,
		Font = Enum.Font.Code,
		TextWrapped = true,
	}, "System")

	self.SearchButton = U:Button(S, self.Header, "⌕", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -172, 0, 20),
		Size = UDim2.fromOffset(44, 46),
	}, function()
		self:OpenCommands()
	end)

	self.SettingsButton = U:Button(S, self.Header, "CFG", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -120, 0, 20),
		Size = UDim2.fromOffset(44, 46),
	}, function()
		for _, tab in self.Tabs do
			if tab.Name == "Settings" then
				self:SelectTab(tab)
				break
			end
		end
	end, "Settings")

	self.MinButton = U:Button(S, self.Header, "—", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -68, 0, 20),
		Size = UDim2.fromOffset(44, 46),
	}, function()
		self.Minimized = not self.Minimized
		self:Layout()
	end)

	self.CloseButton = U:Button(S, self.Header, "×", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 20),
		Size = UDim2.fromOffset(44, 46),
	}, function()
		library:Destroy()
	end, "Error")

	self.Sidebar = U:Panel(S, self.Shell, {
		Position = UDim2.fromOffset(14, 110),
		Size = UDim2.new(0, 196, 1, -154),
		ZIndex = 30,
	}, "Border")

	U:Text(S, self.Sidebar, "COMMAND DIRECTORY", {
		Position = UDim2.fromOffset(14, 12),
		Size = UDim2.new(1, -28, 0, 24),
		TextSize = 10,
		Font = Enum.Font.Code,
	}, "Muted")

	self.Nav = U:New(S, "ScrollingFrame", self.Sidebar, {
		Position = UDim2.fromOffset(10, 44),
		Size = UDim2.new(1, -20, 1, -56),
		BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 2,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {ScrollBarImageColor3 = "Accent"})

	U:List(S, self.Nav, 10)
	U:Padding(S, self.Nav, 3)

	self.Content = U:New(S, "Frame", self.Shell, {
		Position = UDim2.fromOffset(226, 110),
		Size = UDim2.new(1, -242, 1, -154),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 10,
	})

	self.DrawerOverlay = U:New(S, "TextButton", self.Shell, {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.4,
		Visible = false,
		Active = true,
		ZIndex = 25,
		AutoButtonColor = false,
	})

	S:Add(self.DrawerOverlay.Activated:Connect(function()
		self:ToggleDrawer(false)
	end))

	-- A dedicated drawer grip avoids fighting vertical list scrolling.
	local grip = U:New(S, "Frame", self.Sidebar, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 16, 1, 0),
		BackgroundTransparency = 0.85,
	}, {BackgroundColor3 = "Accent"})

	local swipeStart

	E:Drag(S, grip, function(position)
		if not self.Mobile then
			return
		end

		swipeStart = swipeStart or position.X

		if swipeStart - position.X > 60 then
			self:ToggleDrawer(false)
			E:StopDrag()
		end
	end, function()
		swipeStart = nil
	end)

	self.Footer = U:Text(S, self.Shell,
		"SYS // 07     CORE ONLINE     |     NOVA " .. (options.Version or "3.0.0"),
		{
			Position = UDim2.new(0, 18, 1, -31),
			Size = UDim2.new(1, -36, 0, 18),
			TextSize = 10,
			Font = Enum.Font.Code,
			ZIndex = 10,
		},
		"Muted"
	)

	U:Brackets(S, self.Shell, "Secondary")

	S:Add(self.Root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:Layout()
	end))

	E:Watch(S, function()
		self:Layout()
	end)

	E.OnKey = function(input, processed)
		if self.Popup and input.KeyCode == Enum.KeyCode.Escape then
			self:ClosePopup()
			return true
		end

		if self.Popup and self.Popup.HandleKey then
			if self.Popup.HandleKey(input.KeyCode) then
				return true
			end
		end

		if processed or UserInputService:GetFocusedTextBox() then
			return false
		end

		local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

		if ctrl and input.KeyCode == Enum.KeyCode.K then
			self:OpenCommands()
			return true
		end

		if input.KeyCode == Enum.KeyCode.Escape and self.DrawerOpen then
			self:ToggleDrawer(false)
			return true
		end

		return false
	end

	S:Add(function()
		E.OnKey = nil
	end)

	local nextTelemetry = 0

	E:Job(S, function(_, now)
		if now < nextTelemetry then
			return
		end

		nextTelemetry = now + 1

		local ok, memory = pcall(function()
			return Stats:GetTotalMemoryUsageMb()
		end)

		self.Telemetry.Text = string.format(
			"● SYSTEM ONLINE\nFPS %d  MEM %s MB  NET --",
			math.round(E.FPS),
			ok and tostring(math.round(memory)) or "--"
		)

		self.Telemetry.TextTransparency = E:Motion()
			and (math.floor(now) % 2 == 0 and 0 or 0.15)
			or 0
	end)

	self:AddCommand("Change Theme", function()
		local items = {}

		for _, name in Theme.Names do
			table.insert(items, {Name = name})
		end

		self:OpenPicker("THEME ENGINE", items, function(item)
			library:SetTheme(item.Name)
		end)
	end)

	self:AddCommand("Toggle Performance Mode", function()
		library:SetPerformanceMode(not E.Options.PerformanceMode)
	end)

	self:Layout()
	return self
end

function Window:Layout()
	if not self.Scope.Alive then
		return
	end

	local viewport = self.Root.AbsoluteSize

	if viewport.X < 10 or viewport.Y < 10 then
		return
	end

	local scale = math.clamp(self.E.Options.UIScale, 0.75, 1.5)
	local width = math.min(1180, math.max(180, (viewport.X - 16) / scale))
	local height = math.min(800, math.max(180, (viewport.Y - 16) / scale))

	self.Scale.Scale = scale
	self.LogicalWidth = width
	self.LogicalHeight = height

	self.Mobile = viewport.X < 760 or width < 760

	self.Shell.Size = UDim2.fromOffset(width, self.Minimized and 110 or height)
	self.Header.Size = UDim2.new(1, -24, 0, self.Mobile and 96 or 86)

	self.Menu.Visible = self.Mobile
	self.Logo.Visible = not self.Mobile
	self.Subtitle.Visible = not self.Mobile
	self.Telemetry.Visible = not self.Mobile and width >= 1000
	self.SettingsButton.Visible = not self.Mobile

	self.Title.Position = UDim2.fromOffset(self.Mobile and 68 or 86, 16)
	self.Title.TextSize = self.Mobile and 20 or 26
	self.Title.Size = UDim2.new(1, self.Mobile and -140 or -330, 0, 30)
	self.Title.TextTruncate = Enum.TextTruncate.AtEnd

	self.Menu.Position = UDim2.fromOffset(10, 12)
	self.Menu.Size = UDim2.fromOffset(46, 44)

	self.SearchButton.Position = UDim2.new(1, self.Mobile and -120 or -172, 0, self.Mobile and 46 or 20)
	self.MinButton.Position = UDim2.new(1, -68, 0, self.Mobile and 46 or 20)

	for _, child in self.Header:GetChildren() do
		if child:IsA("TextButton") and child ~= self.Menu
			and child ~= self.SearchButton
			and child ~= self.SettingsButton
			and child ~= self.MinButton
		then
			child.Position = UDim2.new(1, -16, 0, self.Mobile and 46 or 20)
		end
	end

	local top = self.Mobile and 120 or 110
	local left = self.Mobile and 14 or 226

	self.Content.Position = UDim2.fromOffset(left, top)
	self.Content.Size = UDim2.new(1, -(left + 16), 1, -(top + 44))
	self.Content.Visible = not self.Minimized
	self.Footer.Visible = not self.Minimized

	local drawerWidth = math.min(252, width - 28)

	self.Sidebar.Size = UDim2.new(
		0, self.Mobile and drawerWidth or 196,
		1, -(top + 44)
	)

	self.Sidebar.Position = UDim2.fromOffset(
		self.Mobile and (self.DrawerOpen and 14 or -drawerWidth - 20) or 14,
		top
	)

	self.Sidebar.Visible = not self.Minimized
	self.DrawerOverlay.Visible = self.Mobile and self.DrawerOpen and not self.Minimized

	if self.Popup then
		self.Popup.Panel.Size = UDim2.new(1, -28, 0, math.min(440, height - 44))
	end

	self:LayoutNotices()
end

function Window:ToggleDrawer(force)
	if not self.Mobile then
		return
	end

	self.DrawerOpen = force == nil and not self.DrawerOpen or force
	self.DrawerOverlay.Visible = self.DrawerOpen

	local width = self.Sidebar.Size.X.Offset

	self.E:Tween(self.Scope, self.Sidebar, 0.28, {
		Position = UDim2.fromOffset(
			self.DrawerOpen and 14 or -width - 20,
			self.Mobile and 120 or 110
		),
	})

	if self.DrawerOpen then
		self.FX:EnergySweep(self.Sidebar, self.Scope)
	end
end

function Window:Toggle()
	self.Shell.Visible = not self.Shell.Visible

	if not self.Shell.Visible then
		self.E:StopDrag()
	end
end

function Window:CreateTab(options)
	local tab = setmetatable({
		Window = self,
		Scope = self.Scope:Child(),
		Name = options.Name or "Page",
		Order = 0,
	}, Tab)

	local U, S = self.U, tab.Scope

	tab.Page = U:New(S, "CanvasGroup", self.Content, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = 0,
		Visible = false,
	})

	tab.Container = U:New(S, "ScrollingFrame", tab.Page, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {ScrollBarImageColor3 = "Accent"})

	U:Padding(S, tab.Container, 7)
	U:List(S, tab.Container, 12)

	local button = U:Button(S, self.Nav, "", {
		Size = UDim2.new(1, -2, 0, 82),
		LayoutOrder = #self.Tabs + 1,
		ClipsDescendants = true,
	}, function()
		self:SelectTab(tab)
	end)

	tab.Nav = button

	U:Text(S, button, "[ " .. string.upper(options.Icon or "SYS") .. " ]", {
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 18),
		TextSize = 10,
		Font = Enum.Font.Code,
	}, options.Accent or "Secondary")

	U:Text(S, button, string.upper(tab.Name), {
		Position = UDim2.fromOffset(12, 29),
		Size = UDim2.new(1, -24, 0, 21),
		TextSize = 12,
	})

	U:Text(S, button, options.Description or "COMMAND MODULE", {
		Position = UDim2.fromOffset(12, 53),
		Size = UDim2.new(1, -24, 0, 16),
		TextSize = 8,
		Font = Enum.Font.Code,
	}, "Muted")

	tab.ActiveBeam = U:New(S, "Frame", button, {
		Position = UDim2.fromOffset(0, 8),
		Size = UDim2.new(0, 3, 1, -16),
		Visible = false,
	}, {BackgroundColor3 = options.Accent or "Accent"})

	table.insert(self.Tabs, tab)

	self:AddCommand("Open " .. tab.Name, function()
		self:SelectTab(tab)
	end)

	if not self.CurrentTab then
		self:SelectTab(tab)
	end

	return tab
end

function Window:SelectTab(tab)
	if not tab.Scope.Alive then
		return
	end

	if self.TransitionScope then
		self.TransitionScope:Destroy()
	end

	self.TransitionScope = self.Scope:Child()
	local transition = self.TransitionScope

	local previous = self.CurrentTab
	self.CurrentTab = tab

	for _, page in self.Tabs do
		page.ActiveBeam.Visible = page == tab
		if page ~= previous then
			page.Page.Visible = false
		end
	end

	local function reveal()
		if not transition.Alive then
			return
		end

		if previous and previous ~= tab then
			previous.Page.Visible = false
		end

		tab.Page.Visible = true
		tab.Page.GroupTransparency = self.E:Motion() and 1 or 0
		tab.Page.Position = UDim2.fromOffset(self.E:Motion() and 26 or 0, 0)

		self.E:Tween(transition, tab.Page, 0.3, {
			GroupTransparency = 0,
			Position = UDim2.fromOffset(0, 0),
		})

		local cards = {}

		for _, child in tab.Container:GetChildren() do
			if child:IsA("Frame") then
				table.insert(cards, child)
			end
		end

		table.sort(cards, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)

		for index, card in cards do
			if index > 10 then
				break
			end

			self.E:After(transition, (index - 1) * 0.04, function()
				if card.Parent then
					self.FX:Scale(card, transition, {
						From = 0.97,
						Duration = 0.3,
					})
					self.FX:Shimmer(card, transition, {Duration = 0.35})
				end
			end)
		end

		self.FX:EnergySweep(tab.Nav, transition)
	end

	if previous and previous ~= tab and self.E:Motion() then
		self.E:Tween(transition, previous.Page, 0.12, {
			GroupTransparency = 1,
			Position = UDim2.fromOffset(-18, 0),
		})

		self.E:After(transition, 0.13, reveal)
	else
		reveal()
	end

	self:ToggleDrawer(false)
end

function Window:AddCommand(name, callback)
	table.insert(self.Commands, {Name = name, Callback = callback})
end

function Window:ClosePopup()
	if self.Popup then
		local popup = self.Popup
		self.Popup = nil
		popup.Scope:Destroy()
	end
end

function Window:Modal(title)
	self:ClosePopup()

	local scope = self.Scope:Child()
	local U = self.U

	local overlay = U:New(scope, "TextButton", self.Shell, {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.25,
		Active = true,
		AutoButtonColor = false,
		ZIndex = 80,
	})

	local panel = U:Panel(scope, overlay, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -28, 0, math.min(440, (self.LogicalHeight or 700) - 44)),
		Active = true,
		ClipsDescendants = true,
	}, "Accent")

	U:New(scope, "UISizeConstraint", panel, {
		MaxSize = Vector2.new(620, 480),
	})

	U:Brackets(scope, panel, "Secondary")

	U:Text(scope, panel, title, {
		Position = UDim2.fromOffset(16, 12),
		Size = UDim2.new(1, -78, 0, 32),
		TextSize = 12,
		Font = Enum.Font.Code,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, "Secondary")

	U:Button(scope, panel, "×", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 8),
		Size = UDim2.fromOffset(44, 44),
	}, function()
		self:ClosePopup()
	end, "Error")

	scope:Add(overlay.Activated:Connect(function()
		-- Only close if the pointer is outside the modal.
		local p = UserInputService:GetMouseLocation()
		local a, b = panel.AbsolutePosition, panel.AbsoluteSize

		if p.X < a.X or p.X > a.X + b.X or p.Y < a.Y or p.Y > a.Y + b.Y then
			self:ClosePopup()
		end
	end))

	self.Popup = {Scope = scope, Panel = panel}
	self.FX:Scale(panel, scope, {From = 0.92, Duration = 0.3})
	self.FX:Scanline(panel, scope)

	return self.Popup
end

function Window:OpenPicker(title, items, callback)
	local popup = self:Modal(title)
	local S, U = popup.Scope, self.U

	local query = U:Field(S, popup.Panel, "", {
		Position = UDim2.fromOffset(14, 58),
		Size = UDim2.new(1, -28, 0, 46),
		PlaceholderText = "SEARCH COMMANDS / OPTIONS...",
	})

	local list = U:New(S, "ScrollingFrame", popup.Panel, {
		Position = UDim2.fromOffset(14, 116),
		Size = UDim2.new(1, -28, 1, -130),
		BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 3,
	}, {ScrollBarImageColor3 = "Accent"})

	U:List(S, list, 8)
	U:Padding(S, list, 3)

	local renderScope
	local shown = {}
	local labels = {}
	local selected = 1

	local function highlight()
		for index, label in labels do
			local item = shown[index]
			label.Text = (index == selected and "> " or "  ")
				.. (item.Selected and "● " or "")
				.. item.Name
		end
	end

	local function choose(index)
		local item = shown[index]
		if not item then
			return
		end

		self:ClosePopup()
		self.E:Call(callback, item)
	end

	local function render()
		if renderScope then
			renderScope:Destroy()
		end

		renderScope = S:Child()
		table.clear(shown)
		table.clear(labels)
		selected = 1

		local filter = string.lower(query.Text)

		for _, item in items do
			if filter == "" or string.find(string.lower(item.Name), filter, 1, true) then
				table.insert(shown, item)
			end
		end

		for index, item in shown do
			local button, label = U:Button(renderScope, list, item.Name, {
				LayoutOrder = index,
				Size = UDim2.new(1, -4, 0, 48),
				ClipsDescendants = true,
			}, function()
				choose(index)
			end)

			labels[index] = label

			if index <= 8 then
				self.E:After(renderScope, index * 0.025, function()
					self.FX:Shimmer(button, renderScope, {Duration = 0.3})
				end)
			end
		end

		if #shown == 0 then
			U:Text(renderScope, list, "NO MATCHING COMMANDS", {
				Size = UDim2.new(1, 0, 0, 48),
				TextXAlignment = Enum.TextXAlignment.Center,
			}, "Muted")
		end

		highlight()
	end

	popup.HandleKey = function(key)
		if key == Enum.KeyCode.Down then
			selected = math.min(selected + 1, math.max(#shown, 1))
		elseif key == Enum.KeyCode.Up then
			selected = math.max(selected - 1, 1)
		elseif key == Enum.KeyCode.Return or key == Enum.KeyCode.KeypadEnter then
			choose(selected)
			return true
		else
			return false
		end

		highlight()

		local top = (selected - 1) * 56
		local bottom = top + 56
		local current = list.CanvasPosition.Y

		if top < current then
			list.CanvasPosition = Vector2.new(0, top)
		elseif bottom > current + list.AbsoluteSize.Y then
			list.CanvasPosition = Vector2.new(0, bottom - list.AbsoluteSize.Y)
		end

		return true
	end

	S:Add(query:GetPropertyChangedSignal("Text"):Connect(render))
	render()

	-- Avoid forcing the mobile keyboard open.
	if not UserInputService.TouchEnabled then
		query:CaptureFocus()
	end
end

function Window:OpenCommands()
	self:OpenPicker("NOVA // COMMAND PALETTE", self.Commands, function(command)
		self.E:Call(command.Callback)
	end)
end

function Window:TextDialog(title, text, readOnly, onApply)
	local popup = self:Modal(title)
	local U, S = self.U, popup.Scope

	local field = U:Field(S, popup.Panel, text, {
		Position = UDim2.fromOffset(14, 58),
		Size = UDim2.new(1, -28, 1, -126),
		MultiLine = true,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextSize = 11,
		Font = Enum.Font.Code,
		TextEditable = not readOnly,
	})

	U:Button(S, popup.Panel, readOnly and "SELECT ALL // COPY MANUALLY" or "APPLY JSON", {
		Position = UDim2.new(0, 14, 1, -56),
		Size = UDim2.new(1, -28, 0, 44),
	}, function()
		if readOnly then
			field:CaptureFocus()
			field.SelectionStart = 1
			field.CursorPosition = #field.Text + 1
		else
			local value = field.Text
			self:ClosePopup()
			self.E:Call(onApply, value)
		end
	end)

	return field
end

function Window:CreateConsole(options)
	local tab = self:CreateTab(options or {
		Name = "Console",
		Icon = ">_",
		Accent = "Console",
	})

	self.Console = Console.new(self, tab)
	return self.Console, tab
end

function Tab:CreateHero(options)
	options = options or {}
	self.Order += 1

	local W, U, S = self.Window, self.Window.U, self.Scope:Child()

	local hero = U:Panel(S, self.Container, {
		LayoutOrder = self.Order,
		Size = UDim2.new(1, -2, 0, 258),
		ClipsDescendants = true,
	}, "Accent")

	W.FX:Background(hero, S, {Count = 14})
	U:Brackets(S, hero, "Secondary")

	U:Text(S, hero, "●  SYSTEM ONLINE  //  OPERATOR AUTHORIZED", {
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.new(1, -40, 0, 30),
		TextSize = 10,
		TextWrapped = true,
		Font = Enum.Font.Code,
	}, "System")

	U:Text(S, hero, options.Title or "Welcome back,\nOperator.", {
		Position = UDim2.fromOffset(20, 62),
		Size = UDim2.new(1, -40, 0, 86),
		TextSize = 30,
		TextWrapped = true,
		Font = Enum.Font.GothamBlack,
	})

	U:Text(S, hero, options.Description or "ALL SYSTEMS OPERATIONAL", {
		Position = UDim2.fromOffset(20, 151),
		Size = UDim2.new(1, -40, 0, 28),
		TextSize = 10,
		TextWrapped = true,
		Font = Enum.Font.Code,
	}, "Secondary")

	U:Button(S, hero, "EXECUTE", {
		Position = UDim2.fromOffset(20, 194),
		Size = UDim2.new(0.5, -26, 0, 46),
	}, options.OnExecute, "Executor")

	U:Button(S, hero, "CONSOLE", {
		Position = UDim2.new(0.5, 6, 0, 194),
		Size = UDim2.new(0.5, -26, 0, 46),
	}, options.OnConsole, "Console")

	return hero
end

function Tab:CreateStats(entries)
	self.Order += 1

	local W, U, S = self.Window, self.Window.U, self.Scope:Child()

	local holder = U:New(S, "Frame", self.Container, {
		LayoutOrder = self.Order,
		Size = UDim2.new(1, -2, 0, 300),
		BackgroundTransparency = 1,
	})

	local grid = U:New(S, "UIGridLayout", holder, {
		CellPadding = UDim2.fromOffset(12, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local labels = {}

	for index, entry in entries do
		local card = U:Panel(S, holder, {
			LayoutOrder = index,
			ClipsDescendants = true,
		}, entry.Accent or "Accent")

		U:Text(S, card, "[ " .. string.upper(entry.Name) .. " ]", {
			Position = UDim2.fromOffset(14, 12),
			Size = UDim2.new(1, -28, 0, 18),
			TextSize = 10,
			Font = Enum.Font.Code,
		}, entry.Accent or "Secondary")

		labels[index] = U:Text(S, card, tostring(entry.Value), {
			Position = UDim2.fromOffset(14, 38),
			Size = UDim2.new(1, -28, 0, 34),
			TextSize = 26,
			Font = Enum.Font.GothamBlack,
		})

		U:Text(S, card, entry.Description or "SYSTEM NOMINAL", {
			Position = UDim2.fromOffset(14, 78),
			Size = UDim2.new(1, -28, 0, 26),
			TextSize = 9,
			TextWrapped = true,
			Font = Enum.Font.Code,
		}, "Muted")

		-- Decorative signal bars, explicitly not telemetry.
		for barIndex = 1, 14 do
			local height = 4 + ((barIndex * 7 + index * 3) % 13)

			U:New(S, "Frame", card, {
				Position = UDim2.new(
					(barIndex - 1) / 16, 14,
					1, -12 - height
				),
				Size = UDim2.new(1 / 22, 0, 0, height),
				BackgroundTransparency = 0.35,
			}, {BackgroundColor3 = entry.Accent or "Accent"})
		end
	end

	local function layout()
		local width = holder.AbsoluteSize.X / W.Scale.Scale
		local columns = width >= 690 and 3 or (width >= 470 and 2 or 1)

		grid.CellSize = UDim2.new(
			1 / columns,
			-12 * (columns - 1) / columns,
			0,
			142
		)

		holder.Size = UDim2.new(
			1, -2, 0,
			math.ceil(#entries / columns) * 154 - 12
		)
	end

	S:Add(holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout))
	layout()

	return {
		Set = function(_, index, value)
			if labels[index] then
				labels[index].Text = tostring(value)
			end
		end,
	}
end

function Tab:CreateMonitor()
	self.Order += 1

	local W, U, E = self.Window, self.Window.U, self.Window.E
	local S = self.Scope:Child()

	local panel = U:Panel(S, self.Container, {
		LayoutOrder = self.Order,
		Size = UDim2.new(1, -2, 0, 244),
		ClipsDescendants = true,
	}, "Executor")

	U:Brackets(S, panel, "Executor")

	U:Text(S, panel, "LIVE EXECUTION MONITOR", {
		Position = UDim2.fromOffset(18, 16),
		Size = UDim2.new(1, -36, 0, 24),
		TextSize = 11,
		Font = Enum.Font.Code,
	}, "Executor")

	local stateLabel = U:Text(S, panel, "", {
		Position = UDim2.fromOffset(18, 56),
		Size = UDim2.new(1, -36, 0, 30),
		TextSize = 22,
		Font = Enum.Font.GothamBold,
	})

	local message = U:Text(S, panel, "", {
		Position = UDim2.fromOffset(18, 96),
		Size = UDim2.new(1, -36, 0, 36),
		TextWrapped = true,
		TextSize = 12,
	}, "Muted")

	local track = U:New(S, "Frame", panel, {
		Position = UDim2.fromOffset(18, 146),
		Size = UDim2.new(1, -36, 0, 10),
	}, {BackgroundColor3 = "Background"})

	U:Round(S, track, 6)

	local fill = U:New(S, "Frame", track, {
		Size = UDim2.fromScale(0, 1),
	}, {BackgroundColor3 = "Executor"})

	U:Round(S, fill, 6)
	U:Gradient(S, fill, "Executor", "Secondary", 0)

	local meta = U:Text(S, panel, "", {
		Position = UDim2.fromOffset(18, 174),
		Size = UDim2.new(1, -36, 0, 50),
		TextSize = 11,
		TextWrapped = true,
		Font = Enum.Font.Code,
	}, "System")

	E:Job(S, function(_, now)
		local status = W.Status
		local ended = status.Ended or now
		local elapsed = math.max(0, ended - status.Started)

		stateLabel.Text = "● " .. status.Name
		message.Text = status.Message
		fill.Size = UDim2.fromScale(status.Progress, 1)

		meta.Text = string.format(
			"PROGRESS  %03d%%\nELAPSED   %02d:%05.2f",
			math.round(status.Progress * 100),
			math.floor(elapsed / 60),
			elapsed % 60
		)

		stateLabel.TextTransparency = E:Motion()
			and not status.Ended
			and (0.08 + math.sin(now * 4) * 0.07)
			or 0
	end)

	return panel
end

function Window:LayoutNotices()
	if not self.Root then
		return
	end

	local width = math.min(370, math.max(160, self.Root.AbsoluteSize.X - 24))

	for index, notice in self.Notices do
		if notice.Scope.Alive then
			notice.Panel.Size = UDim2.fromOffset(width, 112)
			self.E:Tween(notice.Scope, notice.Panel, 0.22, {
				Position = UDim2.new(1, -12, 1, -12 - (index - 1) * 124),
			})
		end
	end
end

function Window:Notify(options)
	local U, E = self.U, self.E

	while #self.Notices >= 4 do
		local oldest = table.remove(self.Notices, 1)
		oldest.Scope:Destroy()
	end

	local scope = self.Scope:Child()
	local role = ({
		Success = "Success",
		Warning = "Warning",
		Error = "Error",
		System = "System",
	})[options.Type or "System"] or "System"

	local panel = U:Panel(scope, self.Root, {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 400, 1, -12),
		Size = UDim2.fromOffset(370, 112),
		ZIndex = 100,
		ClipsDescendants = true,
	}, role)

	U:Brackets(scope, panel, role)

	U:Text(scope, panel, options.Title or "SYSTEM ALERT", {
		Position = UDim2.fromOffset(14, 12),
		Size = UDim2.new(1, -28, 0, 22),
		TextSize = 12,
	}, role)

	U:Text(scope, panel, options.Description or "", {
		Position = UDim2.fromOffset(14, 40),
		Size = UDim2.new(1, -28, 0, 46),
		TextSize = 11,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, "Text")

	local progress = U:New(scope, "Frame", panel, {
		Position = UDim2.new(0, 10, 1, -8),
		Size = UDim2.new(1, -20, 0, 2),
	}, {BackgroundColor3 = role})

	local notice = {Scope = scope, Panel = panel}
	table.insert(self.Notices, notice)

	local function dismiss()
		if not scope.Alive then
			return
		end

		local index = table.find(self.Notices, notice)
		if index then
			table.remove(self.Notices, index)
		end

		self:LayoutNotices()

		E:Tween(scope, panel, 0.2, {
			Position = UDim2.new(1, 400, 1, panel.Position.Y.Offset),
		})

		E:After(scope, 0.22, function()
			scope:Destroy()
		end)
	end

	local started = E.Time
	local duration = math.max(0.5, options.Duration or 4)

	E:Job(scope, function(_, now)
		local alpha = math.clamp((now - started) / duration, 0, 1)
		progress.Size = UDim2.new(1 - alpha, -20 * (1 - alpha), 0, 2)
	end)

	E:After(scope, duration, dismiss)

	self:LayoutNotices()
	self.FX:Glow(panel, scope)

	return {Dismiss = dismiss}
end

function Window:Boot(options)
	options = options or {}

	if self.BootScope then
		self.BootScope:Destroy()
	end

	self:ClosePopup()

	local S = self.Scope:Child()
	self.BootScope = S
	self.Booting = true

	local U, E = self.U, self.E
	local duration = math.max(0.5, options.Duration or 3)
	local started = E.Time

	local cover = U:New(S, "TextButton", self.Shell, {
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Active = true,
		AutoButtonColor = false,
		ZIndex = 120,
	}, {BackgroundColor3 = "Background"})

	self.FX:Background(cover, S, {Count = 28})

	local content = U:New(S, "Frame", cover, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -40, 0, 370),
		BackgroundTransparency = 1,
	})

	U:New(S, "UISizeConstraint", content, {
		MaxSize = Vector2.new(560, 370),
	})

	-- Fit the boot composition on short landscape displays.
	local bootScale = U:New(S, "UIScale", content, {Scale = 1})

	local function fitBoot()
		bootScale.Scale = math.min(
			1,
			math.max(0.25, (self.Shell.AbsoluteSize.Y / self.Scale.Scale - 24) / 370)
		)
	end

	S:Add(self.Shell:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitBoot))
	fitBoot()

	U:Brackets(S, content, "System")

	local logo = U:Text(S, content, options.Logo or "N O V A", {
		Position = UDim2.fromOffset(12, 22),
		Size = UDim2.new(1, -24, 0, 70),
		TextSize = 50,
		TextXAlignment = Enum.TextXAlignment.Center,
		Font = Enum.Font.GothamBlack,
	}, "Text")

	U:Text(S, content, "ADVANCED INTERFACE // " .. (options.Version or "3.0.0"), {
		Position = UDim2.fromOffset(12, 98),
		Size = UDim2.new(1, -24, 0, 30),
		TextSize = 10,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Font = Enum.Font.Code,
	}, "Secondary")

	local stages = {
		"CORE INITIALIZATION",
		"INTERFACE COMPOSITION",
		"COMPONENT REGISTRY",
		"THEME ENGINE",
		"ANIMATION ENGINE",
		"HUD LOCK / SYSTEM ONLINE",
	}

	local labels = {}

	for index, stage in stages do
		labels[index] = U:Text(S, content, "○ " .. stage, {
			Position = UDim2.fromOffset(24, 136 + (index - 1) * 25),
			Size = UDim2.new(1, -48, 0, 20),
			TextSize = 11,
			Font = Enum.Font.Code,
		}, "Muted")
	end

	local track = U:New(S, "Frame", content, {
		Position = UDim2.new(0, 24, 1, -52),
		Size = UDim2.new(1, -48, 0, 8),
	}, {BackgroundColor3 = "Panel2"})

	local fill = U:New(S, "Frame", track, {
		Size = UDim2.fromScale(0, 1),
	}, {BackgroundColor3 = "Accent"})

	U:Gradient(S, fill, "Accent", "Secondary", 0)

	local percent = U:Text(S, content, "0%", {
		Position = UDim2.new(0, 24, 1, -32),
		Size = UDim2.new(1, -48, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.Code,
	}, "System")

	self.FX:Scale(logo, S, {From = 0.8, Duration = 0.7})
	self.FX:EnergySweep(content, S, {Duration = 1})

	E:Job(S, function(_, now)
		local alpha = math.clamp((now - started) / duration, 0, 1)
		local stageIndex = math.clamp(math.ceil(alpha * #stages), 1, #stages)

		fill.Size = UDim2.fromScale(alpha, 1)
		percent.Text = string.format("%03d%% // BOOT SEQUENCE", math.floor(alpha * 100))

		for index, label in labels do
			label.Text = (index <= stageIndex and "● " or "○ ") .. stages[index]
			label.TextTransparency = index <= stageIndex and 0 or 0.5
		end

		if E:Motion() then
			logo.TextTransparency = math.floor(now * 18) % 31 == 0 and 0.3 or 0
		end
	end)

	E:After(S, duration, function()
		self.Booting = false

		self.FX:Glitch(cover, S, {Duration = 0.22})
		self.FX:Glow(content, S, {Duration = 0.3})

		E:After(S, 0.25, function()
			S:Destroy()

			self.FX:Slide(self.Header, self.Scope, {Y = -35, Duration = 0.4})

			if not self.Mobile then
				self.FX:Slide(self.Sidebar, self.Scope, {X = -60, Duration = 0.45})
			end

			self.FX:Scale(self.Content, self.Scope, {From = 0.94, Duration = 0.45})
			self.FX:EnergySweep(self.Shell, self.Scope, {Duration = 0.8})

			if self.CurrentTab then
				self:SelectTab(self.CurrentTab)
			end

			self:Notify({
				Title = "SYSTEM ONLINE",
				Description = "Command center ready. Operator controls unlocked.",
				Type = "Success",
				Duration = 4,
			})
		end)
	end)
end

function Window:Destroy()
	self:ClosePopup()
	self.Scope:Destroy()
end


-- ============================================================
-- CORE // LIBRARY
-- ============================================================

local HttpService = game:GetService("HttpService")


local Library = {}

local LibraryMeta = {}
LibraryMeta.__index = function(self, key)
	local value = rawget(Library, key)
	if value ~= nil then
		return value
	end

	local engine = rawget(self, "Engine")
	if engine then
		return engine[key]
	end

	return nil
end
LibraryMeta.__newindex = function(self, key, value)
	rawset(self, key, value)
end

local VALID_STATES = {
	IDLE = true,
	READY = true,
	LOADING = true,
	INITIALIZING = true,
	EXECUTING = true,
	PROCESSING = true,
	FINALIZING = true,
	SUCCESS = true,
	WARNING = true,
	ERROR = true,
	COMPLETED = true,
}

local TERMINAL_STATES = {
	IDLE = true,
	READY = true,
	SUCCESS = true,
	WARNING = true,
	ERROR = true,
	COMPLETED = true,
}

local BOOLEAN_OPTIONS = {
	Animated = true,
	Effects = true,
	Particles = true,
	Glow = true,
	ReducedMotion = true,
	PerformanceMode = true,
	TerminalTyping = true,
}

function Library.new()
	return setmetatable({
		Registry = {},
	}, LibraryMeta)
end

Library.TweenSlots = setmetatable({}, {__mode = "k"})

function Library:Tween(scope, object, duration, properties, token)
	if not scope or not scope.Alive then
		return nil
	end

	local engine = rawget(self, "Engine")
	local slots = Library.TweenSlots

	if token then
		local objectSlots = rawget(slots, object)

		if objectSlots then
			local cancel = rawget(objectSlots, token)

			if cancel then
				cancel()
			end
		end
	end

	if engine and not engine:Motion() then
		for key, value in properties do
			object[key] = value
		end

		return nil
	end

	local tween = TweenService:Create(
		object,
		TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		properties
	)

	local connection
	local key

	local function cancel()
		if connection then
			connection:Disconnect()
			connection = nil
		end

		if tween then
			tween:Cancel()
			tween = nil
		end

		if token then
			local objectSlots = rawget(slots, object)

			if objectSlots and rawget(objectSlots, token) == cancel then
				objectSlots[token] = nil
			end
		end
	end

	key = scope:Add(cancel)

	if token then
		local objectSlots = rawget(slots, object)

		if not objectSlots then
			objectSlots = setmetatable({}, {__mode = "k"})
			slots[object] = objectSlots
		end

		objectSlots[token] = cancel
	end

	connection = tween.Completed:Connect(function()
		scope:Remove(key)
	end)

	tween:Play()
	return tween
end

function Library:CreateWindow(options)
	assert(not self.Window, "This Library instance already has a window")

	self.Registry = self.Registry or {}
	self.Engine = Engine.new(options or {})
	self.UI = UI.new(self.Engine)
	self.Effects = Effects.new(self.Engine, self.UI)
	self.Engine.FX = self.Effects

	self.Window = Window.new(self, options or {})
	return self.Window
end

function Library:RequireWindow()
	assert(self.Window and self.Window.Scope.Alive, "Create a NOVA window first")
	return self.Window
end

function Library:SetTheme(name)
	self:RequireWindow()
	self.Engine:SetTheme(name)
end

function Library:SetOption(name, value)
	self:RequireWindow()

	if BOOLEAN_OPTIONS[name] then
		assert(type(value) == "boolean", name .. " expects boolean")
	elseif name == "UIScale" then
		assert(type(value) == "number" and value == value, "Invalid scale")
		value = math.clamp(value, 0.75, 1.5)
	elseif name == "Transparency" then
		assert(type(value) == "number" and value == value, "Invalid transparency")
		value = math.clamp(value, 0, 0.65)
	elseif name == "Accent" then
		assert(typeof(value) == "Color3", "Accent expects Color3")
	else
		error("Option is not publicly mutable: " .. tostring(name))
	end

	self.Engine:SetOption(name, value)
end

function Library:SetPerformanceMode(enabled)
	self:SetOption("PerformanceMode", enabled)
end

function Library:SetStatus(name, message, progress)
	local window = self:RequireWindow()
	assert(VALID_STATES[name], "Unknown status: " .. tostring(name))

	local previous = window.Status

	local starting = TERMINAL_STATES[previous.Name]
		and not TERMINAL_STATES[name]

	local status = {
		Name = name,
		Message = message or "",
		Progress = progress == nil and previous.Progress
			or math.clamp(progress, 0, 1),
		Started = starting and self.Engine.Time or previous.Started,
		Ended = TERMINAL_STATES[name] and self.Engine.Time or nil,
	}

	if name == "COMPLETED" or name == "SUCCESS" then
		status.Progress = 1
	end

	window.Status = status

	if window.Console then
		local level = name == "ERROR" and "ERROR"
			or name == "WARNING" and "WARNING"
			or (name == "COMPLETED" or name == "SUCCESS") and "SUCCESS"
			or "INFO"

		window.Console:Log(level, name .. " // " .. (message or ""))
	end
end

function Library:SetProgress(progress, message)
	local window = self:RequireWindow()

	assert(
		type(progress) == "number"
			and progress == progress
			and progress > -math.huge
			and progress < math.huge,
		"Progress must be finite"
	)

	window.Status.Progress = math.clamp(progress, 0, 1)

	if message then
		window.Status.Message = message
	end
end

function Library:Notify(options)
	return self:RequireWindow():Notify(options)
end

function Library:Boot(options)
	self:RequireWindow():Boot(options)
end

function Library:PlayEffect(name, options)
	local window = self:RequireWindow()

	if name == "SystemBoot" then
		return window:Boot(options)
	end

	return self.Effects:Play(name, window.Shell, window.Scope, options)
end

function Library:After(seconds, callback, scope)
	local window = self:RequireWindow()
	return self.Engine:After(scope or window.Scope, seconds, callback)
end

function Library:ExportConfig()
	self:RequireWindow()

	local values = {}

	for id, control in self.Registry do
		local value = control.Value

		if typeof(value) == "Color3" then
			values[id] = {
				Type = "Color3",
				R = value.R,
				G = value.G,
				B = value.B,
			}
		else
			values[id] = value
		end
	end

	return HttpService:JSONEncode({
		Schema = 1,
		Theme = self.Engine.ThemeName,
		Values = values,
	})
end

function Library:ImportConfig(json, fireCallbacks)
	self:RequireWindow()
	assert(type(json) == "string" and #json <= 100000, "Invalid config payload")

	local data = HttpService:JSONDecode(json)

	assert(type(data) == "table" and data.Schema == 1, "Unsupported config schema")
	assert(type(data.Values) == "table", "Missing config values")
	assert(type(data.Theme) == "string", "Missing theme")

	-- Validate all recognized values before changing any control.
	Theme.Get(data.Theme)

	local staged = {}

	for id, value in data.Values do
		local control = self.Registry[id]

		if control then
			if type(value) == "table" and value.Type == "Color3" then
				for _, channel in {"R", "G", "B"} do
					local number = value[channel]

					assert(
						type(number) == "number"
							and number == number
							and number >= 0
							and number <= 1,
						"Invalid color channel"
					)
				end

				value = Color3.new(value.R, value.G, value.B)
			end

			table.insert(staged, {
				Control = control,
				Value = control:Validate(value),
			})
		end
	end

	self:SetTheme(data.Theme)

	for _, entry in staged do
		entry.Control:Set(entry.Value, true)
	end

	-- Opt-in because arbitrary feature callbacks may perform game actions.
	if fireCallbacks then
		for _, entry in staged do
			self.Engine:Call(entry.Control.Callback, entry.Value)
		end
	end

	return true
end

function Library:CreateSettings()
	local window = self:RequireWindow()
	local engine = self.Engine

	local tab = window:CreateTab({
		Name = "Settings",
		Icon = "CFG",
		Description = "INTERFACE CONTROL CENTER",
		Accent = "Settings",
	})

	tab:CreateSection("INTERFACE / DISPLAY")

	tab:CreateDropdown({
		Name = "UI Scale",
		Values = {"75%", "80%", "90%", "100%", "110%", "125%", "150%"},
		Default = "100%",
		Callback = function(value)
			self:SetOption("UIScale", tonumber(string.match(value, "%d+")) / 100)
		end,
	})

	tab:CreateSlider({
		Name = "Glass Transparency",
		Min = 0,
		Max = 0.65,
		Step = 0.01,
		Default = engine.Options.Transparency,
		Percentage = true,
		Callback = function(value)
			self:SetOption("Transparency", value)
		end,
	})

	tab:CreateSection("ANIMATION / EFFECTS / PERFORMANCE")

	for _, option in {
		"Animated",
		"Effects",
		"Particles",
		"Glow",
		"ReducedMotion",
		"PerformanceMode",
		"TerminalTyping",
	} do
		local optionName = option

		tab:CreateToggle({
			Name = optionName,
			Default = engine.Options[optionName],
			Callback = function(value)
				self:SetOption(optionName, value)
			end,
		})
	end

	tab:CreateSection("THEME ENGINE")

	tab:CreateDropdown({
		Name = "Theme",
		Values = Theme.Names,
		Default = engine.ThemeName,
		Callback = function(value)
			self:SetTheme(value)
		end,
	})

	tab:CreateColorPicker({
		Name = "Accent Override",
		Default = engine.Palette.Accent,
		Callback = function(value)
			self:SetOption("Accent", value)
		end,
	})

	tab:CreateButton({
		Name = "Reset Theme Accent",
		Description = "Remove the custom accent override.",
		Callback = function()
			engine.Options.Accent = nil
			engine:SetTheme(engine.ThemeName)
		end,
	})

	tab:CreateSection("CONTROLS")

	tab:CreateKeybind({
		Name = "Toggle Interface",
		Default = "RightShift",
		OnPressed = function()
			window:Toggle()
		end,
	})

	tab:CreateSection("CONFIGURATION")

	tab:CreateButton({
		Name = "Export Configuration",
		Description = "Exports controls that have an explicit Id.",
		Callback = function()
			window:TextDialog("EXPORT CONFIG // JSON", self:ExportConfig(), true)
		end,
	})

	tab:CreateButton({
		Name = "Import Configuration",
		Description = "Validates JSON first; feature callbacks remain disabled.",
		Callback = function()
			window:TextDialog("IMPORT CONFIG // JSON", "", false, function(text)
				local ok, err = pcall(function()
					self:ImportConfig(text, false)
				end)

				self:Notify({
					Title = ok and "CONFIGURATION LOADED" or "CONFIGURATION ERROR",
					Description = ok
						and "Control values restored without executing feature callbacks."
						or tostring(err),
					Type = ok and "Success" or "Error",
				})
			end)
		end,
	})

	return tab
end

function Library:Destroy()
	if self.Window then
		self.Window:Destroy()
		self.Window = nil
	end

	if self.Engine then
		self.Engine:Destroy()
		self.Engine = nil
	end

	self.UI = nil
	self.Effects = nil
	self.Registry = {}
end


local WindowClass = Window
local TabClass = Tab


-- ============================================================
-- NOVA DEMO // ตัวอย่างการใช้งาน (แก้ไขส่วนนี้ได้ตามต้องการ)
-- ============================================================

local Window = Library:CreateWindow({
	Title = "N O V A",
	Subtitle = "ADVANCED INTERFACE",
	Version = "3.1.0",
	DisplayOrder = 50,
})

local UI = Library.UI
local Effects = Library.Effects

-- ------------------------------------------------------------------
-- HOME
-- ------------------------------------------------------------------

local home = Window:CreateTab({
	Name = "Home",
	Icon = "SYS",
	Description = "COMMAND MODULE",
	Accent = "Accent",
})

home:CreateHero({
	Title = "Welcome back,\nOperator.",
	Description = "ALL SYSTEMS OPERATIONAL",
	OnExecute = function()
		Library:SetStatus("EXECUTING", "Running demo task...", 0.35)
		Library:Notify({
			Title = "EXECUTE",
			Description = "Primary command executed.",
			Type = "Success",
		})
	end,
	OnConsole = function()
		for _, tab in Window.Tabs do
			if tab.Name == "Console" then
				Window:SelectTab(tab)
				break
			end
		end
	end,
})

home:CreateStats({
	{Name = "UPTIME", Value = "99.9%", Description = "SYSTEM NOMINAL", Accent = "Success"},
	{Name = "LATENCY", Value = "24ms", Description = "NETWORK STABLE", Accent = "System"},
	{Name = "MODULES", Value = "12", Description = "ACTIVE SCRIPTS", Accent = "Executor"},
})

home:CreateMonitor()

-- ------------------------------------------------------------------
-- CONTROLS
-- ------------------------------------------------------------------

local controlsTab = Window:CreateTab({
	Name = "Controls",
	Icon = "CTL",
	Description = "INPUT MODULES",
	Accent = "Secondary",
})

controlsTab:CreateSection("CORE SWITCHES")

controlsTab:CreateToggle({
	Name = "Auto Execute",
	Default = true,
	Callback = function(value)
		if Window.Console then
			Window.Console:Log("INFO", "Auto Execute -> " .. tostring(value))
		end
	end,
})

controlsTab:CreateToggle({
	Name = "Silent Mode",
	Default = false,
	Callback = function(value)
		if Window.Console then
			Window.Console:Log("INFO", "Silent Mode -> " .. tostring(value))
		end
	end,
})

controlsTab:CreateSection("NUMERIC CONTROL")

controlsTab:CreateSlider({
	Name = "Field of View",
	Min = 70,
	Max = 120,
	Step = 1,
	Default = 70,
	Percentage = true,
	Callback = function(value)
		pcall(function()
			workspace.CurrentCamera.FieldOfView = value
		end)
	end,
})

controlsTab:CreateInput({
	Name = "Display Name",
	Placeholder = "ENTER NAME",
	Default = "",
	Callback = function(value)
		if Window.Console then
			Window.Console:Log("INFO", "Display Name -> " .. value)
		end
	end,
})

controlsTab:CreateInput({
	Name = "Jump Power",
	Numeric = true,
	Min = 50,
	Max = 200,
	Step = 5,
	Default = 50,
	Callback = function(value)
		if Window.Console then
			Window.Console:Log("INFO", "Jump Power -> " .. tostring(value))
		end
	end,
})

controlsTab:CreateDropdown({
	Name = "Team Select",
	Values = {"Alpha", "Bravo", "Charlie"},
	Default = "Alpha",
	Callback = function(value)
		if Window.Console then
			Window.Console:Log("INFO", "Team -> " .. tostring(value))
		end
	end,
})

controlsTab:CreateKeybind({
	Name = "Panic Key",
	Default = "RightControl",
	OnPressed = function()
		Library:Notify({
			Title = "PANIC KEY",
			Description = "Keybind triggered.",
			Type = "Warning",
		})
	end,
})

controlsTab:CreateColorPicker({
	Name = "Highlight Color",
	Default = Color3.fromRGB(167, 116, 255),
	Callback = function(value)
		if Window.Console then
			Window.Console:Log("INFO", "Color picked.")
		end
	end,
})

controlsTab:CreateButton({
	Name = "Run Demo Task",
	Description = "Simulates a multi-stage execution on the monitor.",
	Callback = function()
		Library:SetStatus("LOADING", "Staging resources...", 0.1)
		Library:After(0.8, function()
			Library:SetStatus("EXECUTING", "Executing payload...", 0.45)
		end)
		Library:After(1.8, function()
			Library:SetStatus("FINALIZING", "Cleaning up...", 0.8)
		end)
		Library:After(2.6, function()
			Library:SetStatus("SUCCESS", "Demo task completed.", 1)
		end)
	end,
})

-- ------------------------------------------------------------------
-- CONSOLE + SETTINGS + BOOT
-- ------------------------------------------------------------------

Window:CreateConsole()
Library:CreateSettings()

Window:Boot({
	Duration = 3,
	Version = "3.1.0",
})


---------------------------------------------------------------------
-- NOVA UPGRADE PATCH
-- Paste at the VERY BOTTOM of the previous single-file LocalScript.
--
-- Adds:
--   Mouse / touch window dragging
--   Animated collapse into a compact command bar
--   Angular segmented toggles
--   Improved mobile / landscape layout
--   Wider drawer swipe grip
--   Keyboard-aware modal positioning
--
-- Uses existing variables:
-- Library, Window, WindowClass, TabClass, UI, Effects,
-- UserInputService, PlayerGui
---------------------------------------------------------------------

do
	assert(
		Library and Library.Window and Window,
		"NOVA patch must be placed below the existing single-file script."
	)

	local W = Window
	local PatchScope = W.Scope:Child()

	local State = {
		Center = nil,
		Drag = nil,
		LastCollapsed = W.Minimized,
		CollapseScope = nil,
		Mobile = false,
		Landscape = false,
		DrawerTop = 122,
		FullWidth = 1180,
		FullHeight = 760,
		CollapsedHeight = 122,
		Destroyed = false,
	}

	-----------------------------------------------------------------
	-- UTILITIES
	-----------------------------------------------------------------

	local function clampAxis(value, extent, minimum, maximum)
		if maximum - minimum <= extent then
			return (minimum + maximum) * 0.5
		end

		return math.clamp(
			value,
			minimum + extent * 0.5,
			maximum - extent * 0.5
		)
	end

	local function findButtonLabel(button)
		for _, child in button:GetChildren() do
			if child:IsA("TextLabel") then
				return child
			end
		end

		return nil
	end

	local function setButtonText(button, text)
		local label = findButtonLabel(button)

		if label then
			label.Text = text
		end
	end

	local function getPhysicalShellSize()
		return Vector2.new(
			W.Shell.Size.X.Offset * W.Scale.Scale,
			W.Shell.Size.Y.Offset * W.Scale.Scale
		)
	end

	local function clampCenter(center, physicalSize)
		local viewport = W.Root.AbsoluteSize
		local margin = 8

		return Vector2.new(
			clampAxis(
				center.X,
				physicalSize.X,
				margin,
				viewport.X - margin
			),
			clampAxis(
				center.Y,
				physicalSize.Y,
				margin,
				viewport.Y - margin
			)
		)
	end

	local function applyCenter(center, physicalSize)
		if not W.Scope.Alive then
			return
		end

		center = clampCenter(
			center,
			physicalSize or getPhysicalShellSize()
		)

		State.Center = center

		W.Shell.AnchorPoint = Vector2.new(0.5, 0.5)
		W.Shell.Position = UDim2.fromOffset(center.X, center.Y)
	end

	local function cancelShellSizeTween()
		local slots = Library.TweenSlots[W.Shell]

		if slots and slots["nova-collapse"] then
			slots["nova-collapse"]()
		end
	end

	-----------------------------------------------------------------
	-- KEYBOARD-AWARE MODAL POSITIONING
	-----------------------------------------------------------------

	local function fitPopup()
		local popup = W.Popup

		if not popup or not popup.Scope.Alive then
			return
		end

		local scale = math.max(W.Scale.Scale, 0.01)
		local logicalHeight = W.Shell.AbsoluteSize.Y / scale
		local availableHeight = logicalHeight - 28

		if UserInputService.OnScreenKeyboardVisible then
			local keyboardTop = UserInputService.OnScreenKeyboardPosition.Y

			if keyboardTop > 0 then
				local aboveKeyboard = (
					keyboardTop - W.Shell.AbsolutePosition.Y
				) / scale

				availableHeight = math.min(
					availableHeight,
					aboveKeyboard - 16
				)
			end
		end

		-- Extremely small visible areas cannot contain the whole modal.
		-- Keep the input/header usable; the results area remains scrollable.
		local height = math.clamp(availableHeight, 170, 440)

		popup.Panel.AnchorPoint = Vector2.new(0.5, 0)
		popup.Panel.Size = UDim2.new(1, -28, 0, height)

		local top = math.max(12, (logicalHeight - height) * 0.5)

		if UserInputService.OnScreenKeyboardVisible then
			top = 12
		end

		popup.Panel.Position = UDim2.new(0.5, 0, 0, top)
	end

	local OriginalModal = WindowClass.Modal

	function WindowClass:Modal(title)
		local popup = OriginalModal(self, title)

		if self == W then
			fitPopup()

			Library:After(0, function()
				if self.Popup == popup then
					fitPopup()
				end
			end, popup.Scope)
		end

		return popup
	end

	for _, property in {
		"OnScreenKeyboardVisible",
		"OnScreenKeyboardPosition",
		"OnScreenKeyboardSize",
	} do
		PatchScope:Add(
			UserInputService:GetPropertyChangedSignal(property):Connect(function()
				fitPopup()
			end)
		)
	end

	-----------------------------------------------------------------
	-- RESPONSIVE LAYOUT + ANIMATED COLLAPSE
	-----------------------------------------------------------------

	local OriginalLayout = WindowClass.Layout

	function WindowClass:Layout()
		if self ~= W then
			return OriginalLayout(self)
		end

		if not self.Scope.Alive or State.Destroyed then
			return
		end

		local viewport = self.Root.AbsoluteSize

		if viewport.X < 10 or viewport.Y < 10 then
			return
		end

		local previousSize = self.Shell.Size
		local previousContentVisible = self.Content.Visible
		local previousSidebarVisible = self.Sidebar.Visible
		local collapsedChanged = State.LastCollapsed ~= self.Minimized

		-- Touch laptops keep the desktop layout at normal desktop sizes.
		-- Short touch screens receive the compact landscape layout.
		local mobile = viewport.X < 760
			or (
				UserInputService.TouchEnabled
				and viewport.Y < 600
			)

		local landscape = mobile and viewport.X > viewport.Y

		State.Mobile = mobile
		State.Landscape = landscape

		-- Preserve 44+ physical-pixel touch targets on mobile.
		-- The user's desktop scale preference is retained.
		local requestedScale = Library.Options.UIScale

		if mobile then
			Library.Options.UIScale = 1
		end

		OriginalLayout(self)

		Library.Options.UIScale = requestedScale

		self.Mobile = mobile

		local scale = self.Scale.Scale
		local fullWidth = math.min(
			1180,
			math.max(160, (viewport.X - 16) / scale)
		)

		local fullHeight = math.min(
			800,
			math.max(140, (viewport.Y - 16) / scale)
		)

		State.FullWidth = fullWidth
		State.FullHeight = fullHeight

		local collapsed = self.Minimized

		-- Collapsed HUD uses two rows so the title and 44px buttons
		-- do not overlap on narrow phones.
		local headerHeight

		if collapsed then
			headerHeight = 98
		elseif landscape then
			headerHeight = 62
		elseif mobile then
			headerHeight = 98
		else
			headerHeight = 86
		end

		local top = headerHeight + 24
		local footerHeight = landscape and 26 or 42

		State.DrawerTop = top
		State.CollapsedHeight = headerHeight + 24

		local targetWidth = collapsed
			and math.min(fullWidth, 370)
			or fullWidth

		local targetHeight = collapsed
			and State.CollapsedHeight
			or fullHeight

		local targetSize = UDim2.fromOffset(
			targetWidth,
			targetHeight
		)

		self.Header.Size = UDim2.new(
			1, -24,
			0, headerHeight
		)

		-------------------------------------------------------------
		-- HEADER
		-------------------------------------------------------------

		local compact = mobile or collapsed

		self.Logo.Visible = not compact
		self.Subtitle.Visible = not compact
		self.Telemetry.Visible = not compact and fullWidth >= 1000

		self.Menu.Visible = mobile and not collapsed
		self.SettingsButton.Visible = not compact

		self.Title.TextSize = compact and 19 or 26

		self.Menu.Position = UDim2.fromOffset(
			10,
			landscape and not collapsed and 9 or 12
		)

		self.Menu.Size = UDim2.fromOffset(44, 44)

		self.SearchButton.Size = UDim2.fromOffset(44, 44)
		self.SettingsButton.Size = UDim2.fromOffset(44, 44)
		self.MinButton.Size = UDim2.fromOffset(44, 44)
		self.CloseButton.Size = UDim2.fromOffset(44, 44)

		if collapsed then
			self.Title.Position = UDim2.fromOffset(16, 10)
			self.Title.Size = UDim2.new(1, -32, 0, 28)

			self.SearchButton.Position = UDim2.new(1, -120, 0, 48)
			self.MinButton.Position = UDim2.new(1, -68, 0, 48)
			self.CloseButton.Position = UDim2.new(1, -16, 0, 48)

		elseif landscape then
			self.Title.Position = UDim2.fromOffset(66, 16)
			self.Title.Size = UDim2.new(1, -242, 0, 28)

			self.SearchButton.Position = UDim2.new(1, -120, 0, 9)
			self.MinButton.Position = UDim2.new(1, -68, 0, 9)
			self.CloseButton.Position = UDim2.new(1, -16, 0, 9)

		elseif mobile then
			self.Title.Position = UDim2.fromOffset(66, 15)
			self.Title.Size = UDim2.new(1, -80, 0, 28)

			self.SearchButton.Position = UDim2.new(1, -120, 0, 48)
			self.MinButton.Position = UDim2.new(1, -68, 0, 48)
			self.CloseButton.Position = UDim2.new(1, -16, 0, 48)

		else
			self.Title.Position = UDim2.fromOffset(86, 16)
			self.Title.Size = UDim2.new(1, -330, 0, 30)

			self.SearchButton.Position = UDim2.new(1, -172, 0, 20)
			self.SettingsButton.Position = UDim2.new(1, -120, 0, 20)
			self.MinButton.Position = UDim2.new(1, -68, 0, 20)
			self.CloseButton.Position = UDim2.new(1, -16, 0, 20)
		end

		setButtonText(self.MinButton, collapsed and "+" or "—")

		-------------------------------------------------------------
		-- CONTENT / DRAWER
		-------------------------------------------------------------

		local left = mobile and 14 or 226

		-- Keep expanded content dimensions during collapse.
		-- The shell clips it as the window contracts.
		self.Content.Position = UDim2.fromOffset(left, top)
		self.Content.Size = UDim2.fromOffset(
			math.max(80, fullWidth - left - 16),
			math.max(44, fullHeight - top - footerHeight)
		)

		local drawerWidth = mobile
			and math.min(280, fullWidth - 28)
			or 196

		self.Sidebar.Size = UDim2.fromOffset(
			drawerWidth,
			math.max(44, fullHeight - top - footerHeight)
		)

		self.Sidebar.Position = UDim2.fromOffset(
			mobile
				and (self.DrawerOpen and 14 or -drawerWidth - 20)
				or 14,
			top
		)

		-- Expand the existing swipe grip rather than adding another
		-- input listener or overlay on top of the navigation cards.
		for _, child in self.Sidebar:GetChildren() do
			if child:IsA("Frame")
				and child.AnchorPoint == Vector2.new(1, 0)
				and child.Size.Y.Scale == 1
				and child.Size.X.Scale == 0
			then
				child.Size = UDim2.new(
					0, mobile and 44 or 18,
					1, 0
				)
			end
		end

		self.Nav.Size = UDim2.new(
			1, mobile and -58 or -26,
			1, -56
		)

		self.Footer.Visible = not collapsed and not landscape

		self.DrawerOverlay.Visible = mobile
			and self.DrawerOpen
			and not collapsed

		-------------------------------------------------------------
		-- COLLAPSE TRANSITION
		-------------------------------------------------------------

		if State.CollapseScope then
			State.CollapseScope:Destroy()
			State.CollapseScope = nil
		end

		cancelShellSizeTween()

		local targetPhysicalSize = Vector2.new(
			targetWidth * scale,
			targetHeight * scale
		)

		local center = State.Center or viewport * 0.5
		applyCenter(center, targetPhysicalSize)

		local animate = collapsedChanged
			and Library:Motion()
			and not self.Booting

		if animate then
			local transition = PatchScope:Child()
			State.CollapseScope = transition

			self.Shell.Size = previousSize

			if collapsed then
				self.Content.Visible = previousContentVisible
				self.Sidebar.Visible = previousSidebarVisible
				self.DrawerOverlay.Visible = false
			else
				self.Content.Visible = true
				self.Sidebar.Visible = true
			end

			Library:Tween(
				transition,
				self.Shell,
				0.32,
				{Size = targetSize},
				"nova-collapse"
			)

			Library:After(0.34, function()
				self.Content.Visible = not self.Minimized
				self.Sidebar.Visible = not self.Minimized

				applyCenter(
					State.Center or viewport * 0.5,
					getPhysicalShellSize()
				)

				if not self.Minimized then
					Effects:EnergySweep(
						self.Header,
						transition,
						{Duration = 0.4}
					)
				end
			end, transition)

		else
			self.Shell.Size = targetSize
			self.Content.Visible = not collapsed
			self.Sidebar.Visible = not collapsed
		end

		State.LastCollapsed = collapsed

		fitPopup()
		self:LayoutNotices()
	end

	-----------------------------------------------------------------
	-- DRAWER: FOLLOW THE CURRENT HEADER HEIGHT
	-----------------------------------------------------------------

	local OriginalToggleDrawer = WindowClass.ToggleDrawer

	function WindowClass:ToggleDrawer(force)
		if self ~= W then
			return OriginalToggleDrawer(self, force)
		end

		if not self.Mobile or self.Minimized then
			return
		end

		if force == nil then
			self.DrawerOpen = not self.DrawerOpen
		else
			self.DrawerOpen = force
		end

		self.DrawerOverlay.Visible = self.DrawerOpen

		Library:Tween(self.Scope, self.Sidebar, 0.28, {
			Position = UDim2.fromOffset(
				self.DrawerOpen
					and 14
					or -self.Sidebar.Size.X.Offset - 20,
				State.DrawerTop
			),
		}, "position")

		if self.DrawerOpen then
			Effects:EnergySweep(self.Sidebar, self.Scope)
		end
	end

	-----------------------------------------------------------------
	-- PUBLIC COLLAPSE API
	-----------------------------------------------------------------

	function WindowClass:SetCollapsed(collapsed)
		assert(type(collapsed) == "boolean", "Expected boolean")

		if self.Booting then
			return
		end

		if self.Minimized == collapsed then
			return
		end

		if collapsed then
			self:ClosePopup()
			self.DrawerOpen = false
		end

		self.Minimized = collapsed
		self:Layout()
	end

	function WindowClass:ToggleCollapsed()
		self:SetCollapsed(not self.Minimized)
	end

	-----------------------------------------------------------------
	-- DRAGGING: MOUSE + TOUCH
	-----------------------------------------------------------------

	local function pointInside(object, point)
		local position = object.AbsolutePosition
		local size = object.AbsoluteSize

		return point.X >= position.X
			and point.Y >= position.Y
			and point.X <= position.X + size.X
			and point.Y <= position.Y + size.Y
	end

	local function isInteractiveHeaderTarget(point)
		local hits = PlayerGui:GetGuiObjectsAtPosition(
			math.floor(point.X),
			math.floor(point.Y)
		)

		for _, hit in hits do
			if hit:IsDescendantOf(W.Header) then
				local ancestor = hit

				while ancestor and ancestor ~= W.Header do
					if ancestor:IsA("GuiButton")
						or ancestor:IsA("TextBox")
					then
						return true
					end

					ancestor = ancestor.Parent
				end
			end
		end

		return false
	end

	local function stopWindowDrag()
		State.Drag = nil
	end

	PatchScope:Add(UserInputService.InputBegan:Connect(function(input)
		local inputType = input.UserInputType

		if inputType ~= Enum.UserInputType.MouseButton1
			and inputType ~= Enum.UserInputType.Touch
		then
			return
		end

		if State.Drag
			or W.Booting
			or W.Popup
			or W.DrawerOpen
			or not W.Shell.Visible
		then
			return
		end

		local point = Vector2.new(input.Position.X, input.Position.Y)

		if not pointInside(W.Header, point) then
			return
		end

		if isInteractiveHeaderTarget(point) then
			return
		end

		-- Do not let a slider capture and header drag coexist.
		Library:StopDrag()

		local rootPosition = W.Root.AbsolutePosition
		local shellPosition = W.Shell.AbsolutePosition
		local shellSize = W.Shell.AbsoluteSize

		local center = shellPosition
			- rootPosition
			+ shellSize * 0.5

		State.Center = center

		State.Drag = {
			Input = input,
			StartPointer = point,
			StartCenter = center,
		}
	end))

	PatchScope:Add(UserInputService.InputChanged:Connect(function(input)
		local drag = State.Drag

		if not drag then
			return
		end

		local mouseDrag = drag.Input.UserInputType
			== Enum.UserInputType.MouseButton1

		if input ~= drag.Input
			and not (
				mouseDrag
				and input.UserInputType == Enum.UserInputType.MouseMovement
			)
		then
			return
		end

		local point = Vector2.new(input.Position.X, input.Position.Y)
		local delta = point - drag.StartPointer

		-- Direct movement avoids lag between finger and window.
		applyCenter(
			drag.StartCenter + delta,
			getPhysicalShellSize()
		)
	end))

	PatchScope:Add(UserInputService.InputEnded:Connect(function(input)
		local drag = State.Drag

		if not drag then
			return
		end

		if input == drag.Input
			or (
				drag.Input.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseButton1
			)
		then
			stopWindowDrag()
		end
	end))

	PatchScope:Add(
		UserInputService.WindowFocusReleased:Connect(stopWindowDrag)
	)

	PatchScope:Add(W.Root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		stopWindowDrag()
	end))

	PatchScope:Add(W.Shell:GetPropertyChangedSignal("Visible"):Connect(function()
		if not W.Shell.Visible then
			stopWindowDrag()
		end
	end))

	-----------------------------------------------------------------
	-- ANGULAR SEGMENTED TOGGLES
	--
	-- Keeps the original toggle's callback and state behavior.
	-- Replaces only its visible presentation.
	-----------------------------------------------------------------

	local Skinned = setmetatable({}, {__mode = "k"})

	local function skinToggle(button, sourceLabel, owner)
		if Skinned[button] then
			return
		end

		Skinned[button] = true

		local S = owner:Child()

		S:Add(button.Destroying:Connect(function()
			S:Destroy()
		end))

		button.ClipsDescendants = true

		-- The original renderer still updates this label.
		-- Its text becomes the state signal for the new visuals.
		sourceLabel.Visible = false

		for _, child in button:GetChildren() do
			if child:IsA("UICorner") then
				child.CornerRadius = UDim.new(0, 5)
			elseif child:IsA("Frame") then
				-- Hide the old thin power beam.
				child.Visible = false
			end
		end

		local face = UI.New(S, "Frame", button, {
			Name = "NOVA_AngularToggle",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Active = false,
			ZIndex = 3,
		})

		local caption = UI.Text(S, face, "POWER", {
			Position = UDim2.fromOffset(12, 5),
			Size = UDim2.new(0.36, -12, 0, 15),
			TextSize = 9,
			Font = Enum.Font.Code,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, "Muted")

		local status = UI.Text(S, face, "OFFLINE", {
			Position = UDim2.fromOffset(12, 21),
			Size = UDim2.new(0.36, -12, 0, 16),
			TextSize = 10,
			Font = Enum.Font.GothamBold,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, "Muted")

		local rail = UI.New(S, "Frame", face, {
			Position = UDim2.new(0.39, 0, 0.5, -12),
			Size = UDim2.new(0.61, -12, 0, 24),
		}, {BackgroundColor3 = "Background"})

		UI.Round(S, rail, 3)

		local railStroke = UI.Stroke(
			S, rail, "Border", 1, 0.15
		)

		local fill = UI.New(S, "Frame", rail, {
			Position = UDim2.fromOffset(3, 3),
			Size = UDim2.new(0.2, 0, 1, -6),
			BackgroundTransparency = 0.75,
		}, {BackgroundColor3 = "Accent"})

		UI.Round(S, fill, 2)
		UI.Gradient(S, fill, "Accent", "Secondary", 0)

		local segments = {}

		for index = 1, 8 do
			local segment = UI.New(S, "Frame", rail, {
				Position = UDim2.new(
					(index - 1) / 8,
					4,
					0,
					5
				),
				Size = UDim2.new(1 / 8, -7, 1, -10),
				BackgroundTransparency = 0.75,
				ZIndex = 2,
			}, {BackgroundColor3 = "Secondary"})

			table.insert(segments, segment)
		end

		-- Angular rectangular shuttle: deliberately no circular knob.
		local shuttle = UI.New(S, "Frame", rail, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(24, 18),
			ZIndex = 4,
		}, {BackgroundColor3 = "Muted"})

		UI.Round(S, shuttle, 2)

		local shuttleStroke = UI.Stroke(
			S, shuttle, "Text", 1, 0.5
		)

		UI.Text(S, shuttle, "//", {
			Size = UDim2.fromScale(1, 1),
			TextSize = 13,
			Font = Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, "Background")

		local on = false
		local initialized = false

		local function render()
			local nextOn = string.find(
				sourceLabel.Text,
				"ACTIVE",
				1,
				true
			) ~= nil

			local changed = initialized and nextOn ~= on

			on = nextOn
			initialized = true

			caption.Text = "POWER"
			status.Text = on and "ENGAGED" or "STANDBY"
			status.TextColor3 = on
				and Library.Palette.Secondary
				or Library.Palette.Muted

			shuttle.BackgroundColor3 = on
				and Library.Palette.Secondary
				or Library.Palette.Muted

			railStroke.Color = on
				and Library.Palette.Accent
				or Library.Palette.Border

			shuttleStroke.Transparency = on and 0.15 or 0.6

			Library:Tween(S, shuttle, 0.23, {
				Position = on
					and UDim2.new(1, -27, 0.5, 0)
					or UDim2.new(0, 3, 0.5, 0),
			}, "toggle-shuttle")

			Library:Tween(S, fill, 0.23, {
				Size = on
					and UDim2.new(1, -6, 1, -6)
					or UDim2.new(0.2, 0, 1, -6),
				BackgroundTransparency = on and 0.55 or 0.9,
			}, "toggle-fill")

			for index, segment in segments do
				local transparency = on
					and (index % 2 == 0 and 0.2 or 0.4)
					or 0.88

				Library:Tween(S, segment, 0.2, {
					BackgroundTransparency = transparency,
				}, "toggle-segment")
			end

			if changed and on then
				Effects:EnergySweep(
					button,
					S,
					{Duration = 0.35}
				)
			end
		end

		S:Add(sourceLabel:GetPropertyChangedSignal("Text"):Connect(render))
		Library:Watch(S, render)
	end

	-- Upgrade the toggles that were already created by the Demo.
	for _, object in W.Shell:GetDescendants() do
		if object:IsA("TextButton") then
			local label = findButtonLabel(object)

			if label and string.sub(label.Text, 1, 5) == "POWER" then
				skinToggle(object, label, PatchScope)
			end
		end
	end

	-- Also upgrade toggles created after this patch.
	local OriginalCreateToggle = TabClass.CreateToggle

	function TabClass:CreateToggle(options)
		local control = OriginalCreateToggle(self, options)

		for _, child in control.Frame:GetChildren() do
			if child:IsA("TextButton") then
				local label = findButtonLabel(child)

				if label and string.sub(label.Text, 1, 5) == "POWER" then
					skinToggle(child, label, control.Scope)
					break
				end
			end
		end

		return control
	end

	-----------------------------------------------------------------
	-- MOBILE CARD GRIDS
	--
	-- Single column on phones, including landscape.
	-- Desktop retains its adaptive 1 / 2 / 3-column arrangement.
	-----------------------------------------------------------------

	local AdaptedGrids = setmetatable({}, {__mode = "k"})

	local function adaptGrid(grid, owner)
		if AdaptedGrids[grid] then
			return
		end

		AdaptedGrids[grid] = true

		local holder = grid.Parent

		if not holder or not holder:IsA("GuiObject") then
			return
		end

		local S = owner:Child()
		local updating = false

		S:Add(holder.Destroying:Connect(function()
			S:Destroy()
		end))

		local function update()
			if updating or not S.Alive then
				return
			end

			updating = true

			local count = 0

			for _, child in holder:GetChildren() do
				if child:IsA("GuiObject") then
					count += 1
				end
			end

			local width = holder.AbsoluteSize.X
				/ math.max(W.Scale.Scale, 0.01)

			local columns

			if State.Mobile then
				columns = 1
			elseif width >= 690 then
				columns = 3
			elseif width >= 470 then
				columns = 2
			else
				columns = 1
			end

			local desiredCell = UDim2.new(
				1 / columns,
				-12 * (columns - 1) / columns,
				0,
				142
			)

			local desiredHeight = math.max(
				0,
				math.ceil(count / columns) * 154 - 12
			)

			if grid.CellSize ~= desiredCell then
				grid.CellSize = desiredCell
			end

			local desiredSize = UDim2.new(1, -2, 0, desiredHeight)

			if holder.Size ~= desiredSize then
				holder.Size = desiredSize
			end

			updating = false
		end

		S:Add(grid:GetPropertyChangedSignal("CellSize"):Connect(update))
		S:Add(holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))
		S:Add(holder.ChildAdded:Connect(update))
		S:Add(holder.ChildRemoved:Connect(update))

		Library:Watch(S, update)
		update()
	end

	for _, object in W.Content:GetDescendants() do
		if object:IsA("UIGridLayout") then
			adaptGrid(object, PatchScope)
		end
	end

	PatchScope:Add(W.Content.DescendantAdded:Connect(function(object)
		if object:IsA("UIGridLayout") then
			Library:After(0, function()
				if object.Parent then
					adaptGrid(object, PatchScope)
				end
			end, PatchScope)
		end
	end))

	-----------------------------------------------------------------
	-- MOBILE NOTIFICATIONS
	--
	-- Avoid stacking four large alerts over an entire phone screen.
	-----------------------------------------------------------------

	local OriginalNotify = Library.Notify

	function Library:Notify(options)
		if State.Mobile and self.Window then
			while #self.Window.Notices >= 2 do
				local oldest = table.remove(self.Window.Notices, 1)
				oldest.Scope:Destroy()
			end
		end

		return OriginalNotify(self, options)
	end

	-----------------------------------------------------------------
	-- COMMANDS
	-----------------------------------------------------------------

	W:AddCommand("Collapse / Expand Interface", function()
		W:ToggleCollapsed()
	end)

	W:AddCommand("Center Interface", function()
		stopWindowDrag()

		applyCenter(
			W.Root.AbsoluteSize * 0.5,
			getPhysicalShellSize()
		)
	end)

	-----------------------------------------------------------------
	-- INITIALIZE / CLEANUP
	-----------------------------------------------------------------

	PatchScope:Add(function()
		State.Destroyed = true
		State.Drag = nil

		-- Restore patched class functions if the library is destroyed.
		WindowClass.Layout = OriginalLayout
		WindowClass.Modal = OriginalModal
		WindowClass.ToggleDrawer = OriginalToggleDrawer
		TabClass.CreateToggle = OriginalCreateToggle
		Library.Notify = OriginalNotify
	end)

	W:Layout()

	-- Refresh grids after the new mobile state and scale are applied.
	for _, object in W.Content:GetDescendants() do
		if object:IsA("UIGridLayout") then
			local holder = object.Parent

			if holder and holder:IsA("GuiObject") then
				-- Its existing responsive listener will run on the next
				-- geometry update; schedule a settings refresh as well.
				Library:After(0, function()
					if PatchScope.Alive then
						Library:Refresh()
					end
				end, PatchScope)

				break
			end
		end
	end

	if W.Console then
		W.Console:Log(
			"SUCCESS",
			"Interaction upgrade loaded: drag, animated collapse, angular toggles, mobile layout."
		)
	end
end

---------------------------------------------------------------------
-- NEW API EXAMPLES
---------------------------------------------------------------------

-- Window:SetCollapsed(true)
-- Window:SetCollapsed(false)
-- Window:ToggleCollapsed()

-- Existing APIs still work:
-- Window:Toggle()
-- Library:SetPerformanceMode(true)
-- Library:SetOption("ReducedMotion", true)
-- Library:Destroy()