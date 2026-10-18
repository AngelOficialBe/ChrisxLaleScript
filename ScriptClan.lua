-- ==================== SERVICIOS Y VARIABLES ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

-- Anti-AFK Automático
LP.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

repeat task.wait(0.3) until LP:FindFirstChild("muscleEvent") and LP:FindFirstChild("leaderstats")

local Strength = LP.leaderstats.Strength
local Rebirths = LP.leaderstats.Rebirths

local FastFarm = false
local AutoRebirth = false
local FastRebirth = false

-- ==================== LÓGICA DE FARMING (OP FARM) ====================
task.spawn(function()
    local cachedEvent = LP:FindFirstChild("muscleEvent")
    LP.ChildAdded:Connect(function(child)
        if child.Name == "muscleEvent" then cachedEvent = child end
    end)

    local RATE = 10000
    local BURST = 1000
    local INTERVAL = BURST / RATE

    while true do
        if FastFarm then
            if not cachedEvent or not cachedEvent.Parent then
                cachedEvent = LP:FindFirstChild("muscleEvent")
            end
            if cachedEvent then
                local start = os.clock()
                for i = 1, BURST do
                    if not FastFarm then break end
                    pcall(function() cachedEvent:FireServer("rep") end)
                end
                local remaining = INTERVAL - (os.clock() - start)
                if remaining > 0 then task.wait(remaining) else task.wait() end
            else
                task.wait(0.05)
            end
        else
            task.wait(0.1)
        end
    end
end)

-- ==================== AUTO REBIRTH ====================
task.spawn(function()
	local lastRequest = 0
	local minCooldown = 0.1

	local function getRemote()
		local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
		return rEvents and rEvents:FindFirstChild("rebirthRemote")
	end

	local function tryRebirth()
		if not AutoRebirth then return end
		local now = os.clock()
		if now - lastRequest < minCooldown then return end

		local remote = getRemote()
		if not remote then return end

		lastRequest = now
		pcall(function()
			if remote:IsA("RemoteFunction") then
				remote:InvokeServer("rebirthRequest")
			elseif remote:IsA("RemoteEvent") then
				remote:FireServer("rebirthRequest")
			end
		end)
	end

	Strength:GetPropertyChangedSignal("Value"):Connect(tryRebirth)
	while task.wait(0.10) do
		tryRebirth()
	end
end)

-- ==================== CARGAR LA INTERFAZ (LIBRERÍA) ====================
local LibraryURL = "https://raw.githubusercontent.com/Chrismon014/ERDN/refs/heads/main/LibraryERDN"
local Library = loadstring(game:HttpGet(LibraryURL))()

local Window = Library:CreateWindow({
    Title = "SLK Paid Hub",
    Icon = "rbxassetid://6031097225"
})

-- Crear Pestañas
local FarmingTab = Window:CreateTab("Farming", "F")
local BossTab = Window:CreateTab("Boss", "B")
local InfoTab = Window:CreateTab("Info", "I")
local SettingsTab = Window:CreateTab("Settings", "S")

-- Añadir Elementos a la Pestaña Farming
FarmingTab:AddSection("Farming OP")
FarmingTab:CreateToggle({
    Name = "OP Farm",
    Description = "Target: OP FARM (Fast Strength)",
    Default = false
}, function(state)
    FastFarm = state
end)

FarmingTab:AddSection("Rebirth")
FarmingTab:CreateToggle({
    Name = "Auto Rebirth",
    Description = "Rebirth when strength reaches threshold",
    Default = false
}, function(state)
    AutoRebirth = state
end)

FarmingTab:AddSection("Fast Rebirth")
FarmingTab:CreateToggle({
    Name = "Fast Rebirth",
    Description = "Speed -> Farm -> Packs -> Rebirth",
    Default = false
}, function(state)
    FastRebirth = state
    if state then FastFarm = true end
end)
