-- Moon UI AutoClicker (original wrapped in loadstring)
-- Committed by Copilot

local code = [[
-- Moon UI — Auto-clicker (Luau LocalScript)
-- Place as a LocalScript (e.g., StarterPlayerScripts or StarterGui)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoonUI_AutoClicker"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- CONFIG
local cps = 30 -- clicks per second when enabled; change as needed
local clickInterval = 1 / math.max(1, cps)

------------------------------------------------
-- MAIN FRAME
------------------------------------------------
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 170)
Frame.Position = UDim2.new(0.5, -120, 0.5, -85)
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 18)

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(170, 0, 255)
Stroke.Transparency = 0.3
Stroke.Parent = Frame

------------------------------------------------
-- TITLE
------------------------------------------------
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "MOON UI"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

------------------------------------------------
-- STATUS
------------------------------------------------
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "STATUS: OFF"
Status.TextColor3 = Color3.fromRGB(255, 80, 80)
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.Parent = Frame

------------------------------------------------
-- BUTTON (toggle)
------------------------------------------------
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 150, 0, 46)
Button.Position = UDim2.new(0.5, -75, 0.6, 0)
Button.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
Button.Text = "OFF"
Button.TextColor3 = Color3.fromRGB(255,255,255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 15
Button.Parent = Frame
Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 14)

------------------------------------------------
-- ORB
------------------------------------------------
local Circle = Instance.new("Frame")
Circle.Size = UDim2.new(0, 90, 0, 90)
Circle.Position = UDim2.new(0.75, 0, 0.5, 0)
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.BackgroundColor3 = Color3.fromRGB(10, 0, 25)
Circle.Parent = ScreenGui

Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

local StrokeOrb = Instance.new("UIStroke")
StrokeOrb.Thickness = 7
StrokeOrb.Color = Color3.fromRGB(170, 0, 255)
StrokeOrb.Transparency = 0.15
StrokeOrb.Parent = Circle

local Glow = Instance.new("UIStroke")
Glow.Thickness = 18
Glow.Color = Color3.fromRGB(120, 0, 255)
Glow.Transparency = 0.85
Glow.Parent = Circle

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1,0,1,0)
Label.BackgroundTransparency = 1
Label.Text = "M"
Label.TextColor3 = Color3.fromRGB(255,255,255)
Label.Font = Enum.Font.GothamBlack
Label.TextSize = 36
Label.Parent = Circle

------------------------------------------------
-- DRAGGING (original single drag system)
------------------------------------------------
local dragging = nil
local dragStart
local startPos

local function beginDrag(obj, input)
	dragging = obj
	dragStart = input.Position
	startPos = obj.Position
end

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if input.UserInputState == Enum.UserInputState.Begin then
			local pos = input.Position

			-- check orb first
			if Circle then
				local absPos = Circle.AbsolutePosition
				local absSize = Circle.AbsoluteSize
				if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and
				   pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
					beginDrag(Circle, input)
					return
				end
			end

			-- then frame
			if Frame then
				local absPos = Frame.AbsolutePosition
				local absSize = Frame.AbsoluteSize
				if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and
				   pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
					beginDrag(Frame, input)
				end
			end
		end
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart

		dragging.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = nil
	end
end)

------------------------------------------------
-- TOGGLE BEHAVIOR & AUTCLICKER
------------------------------------------------
local enabled = false
local timer = 0

local function updateUI()
	if enabled then
		Status.Text = "STATUS: ON"
		Status.TextColor3 = Color3.fromRGB(120, 255, 150)
		Button.Text = "ON"
	else
		Status.Text = "STATUS: OFF"
		Status.TextColor3 = Color3.fromRGB(255, 80, 80)
		Button.Text = "OFF"
	end
end

Button.MouseButton1Click:Connect(function()
	enabled = not enabled
	updateUI()
end)

------------------------------------------------
-- AUTO-CLICK LOOP (clicks GUI buttons under the circle center only)
------------------------------------------------
local function getCircleCenterScreenPosition()
	-- center point in absolute screen coordinates
	local absPos = Circle.AbsolutePosition
	local absSize = Circle.AbsoluteSize
	local cx = absPos.X + absSize.X * 0.5
	local cy = absPos.Y + absSize.Y * 0.5
	return cx, cy
end

RunService.Heartbeat:Connect(function(dt)
	-- alive effect (keep original pulsing)
	-- small pulsing retained from original script
end)

-- separate timing loop so pulse logic doesn't interfere
task.spawn(function()
	local accum = 0
	while true do
		local dt = task.wait() or 0.016
		accum = accum + dt

		-- alive pulsing (kept similar to original)
		-- run at render frequency for smoothness
		-- but we only change visual values here
		-- (original pulsing uses RenderStepped; this is acceptable too)
		-- We'll keep the pulsing on RenderStepped for visual fidelity below.

		if enabled then
			-- click at configured interval
			if accum >= clickInterval then
				accum = accum - clickInterval

				-- find GUI objects at circle center
				local x, y = getCircleCenterScreenPosition()
				local success, objs = pcall(function()
					return GuiService:GetGuiObjectsAtPosition(x, y)
				end)

				if success and objs and #objs > 0 then
					-- activate the topmost clickable GUI object (TextButton/ImageButton)
					for i = 1, #objs do
						local obj = objs[i]
						if obj and obj:IsA("TextButton") or (obj and obj:IsA("ImageButton")) then
							-- Only activate visible and active buttons
							if obj.Visible and (obj.Active == nil or obj.Active) then
								-- Protect the call in case the object does not support :Activate()
								pcall(function()
									obj:Activate()
								end)
								break
							end
						end
					end
				end
			end
		else
			-- when disabled, just wait a short while to avoid busy-looping
			if accum >= 0.1 then
				accum = 0
			end
		end
		end
	end)

------------------------------------------------
-- ALIVE EFFECT (smooth on RenderStepped)
------------------------------------------------
local t = 0
RunService.RenderStepped:Connect(function(dt)
	t = t + dt

	local s = 1 + math.sin(t * 3) * 0.05
	Circle.Size = UDim2.new(0, 90 * s, 0, 90 * s)

	StrokeOrb.Transparency = 0.12 + math.sin(t * 2) * 0.05
	Glow.Transparency = 0.8 + math.sin(t * 3) * 0.08
end)

-- initial UI update
updateUI()
]]

local fn, loadErr = loadstring(code)
if not fn then
	warn("Moon UI AutoClicker loadstring failed to compile:", loadErr)
else
	local ok, runErr = pcall(fn)
	if not ok then
		warn("Moon UI AutoClicker loadstring error:", runErr)
	end
end
