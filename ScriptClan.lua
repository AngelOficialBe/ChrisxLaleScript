-- ==================== SERVICIOS Y VARIABLES ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer

-- Anti-AFK Automático con Notificación Nativa de Roblox
LP.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "SLK Paid Hub",
        Text = "Anti-AFK Activo 🛡️",
        Duration = 4
    })
end)

repeat task.wait(0.3) until LP:FindFirstChild("muscleEvent") and LP:FindFirstChild("leaderstats")

local Strength = LP.leaderstats:WaitForChild("Strength")
local Rebirths = LP.leaderstats:WaitForChild("Rebirths")

-- Variables de Estado de Farming
local FastFarm500 = false
local FastFarm2k = false
local FastFarm10k = false
local FastFarm20k = false

-- Variables de Estado de Rebirth
local AutoRebirth = false
local RebirthsCombination = false
local RebirthChaos = false
local RebirthsTitans = false

-- Variables de Configuración y Autoreconectador
local AutoRejoinActive = false
local AutoExecuteActive = false
local ConfigFileName = "ChrisxLale_Config.json"

-- ==================== SISTEMA DE CONFIGURACIÓN Y AUTO-EXECUTE ====================
local function SaveConfig()
    if type(writefile) == "function" then
        pcall(function()
            local configData = {
                AutoExecute = AutoExecuteActive,
                AutoRejoin = AutoRejoinActive
            }
            writefile(ConfigFileName, HttpService:JSONEncode(configData))
        end)
    end
end

local function LoadConfig()
    if type(readfile) == "function" and type(isfile) == "function" then
        pcall(function()
            if isfile(ConfigFileName) then
                local savedData = HttpService:JSONEncode(readfile(ConfigFileName))
                if type(savedData) == "table" then
                    AutoExecuteActive = savedData.AutoExecute == true
                    AutoRejoinActive = savedData.AutoRejoin == true
                end
            end
        end)
    end
end

LoadConfig()

-- Lógica de Auto Rejoin
CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if AutoRejoinActive and (child.Name == "ErrorPrompt" or child:FindFirstChild("ErrorTitle")) then
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "SLK Paid Hub",
                Text = "Reconectando al servidor... 🔄",
                Duration = 5
            })
        end)
        task.wait(1)
        TeleportService:Teleport(game.PlaceId, LP)
    end
end)

-- ==================== DICCIONARIO Y SISTEMA DE MASCOTAS ====================
local PETS = {
    ["Omega Overlord"] = { repSpeed = 20, strength = 0, durability = 0, rebirth = 0 },
    ["Swift Samurai"] = { repSpeed = 15, strength = 0, durability = 0, rebirth = 0 },
    ["Titanium Hydra"] = { repSpeed = 0, strength = 0, durability = 0, rebirth = 2 },
    ["Tribal Overlord"] = { repSpeed = 0, strength = 0, durability = 0, rebirth = 2 },
    ["Common Boss Pet"] = { repSpeed = 5, strength = 0, durability = 0, rebirth = 0 },
    ["Rare Boss Pet"] = { repSpeed = 7, strength = 0, durability = 0, rebirth = 0 },
    ["Epic Boss Pet"] = { repSpeed = 10, strength = 0, durability = 0, rebirth = 0 },
    ["Rainbow Boss Pet"] = { repSpeed = 10, strength = 7, durability = 0, rebirth = 0 },
    ["Legendary Boss Pet"] = { repSpeed = 10, strength = 10, durability = 0, rebirth = 0 },
    ["Mythic Boss Pet"] = { repSpeed = 10, strength = 20, durability = 0, rebirth = 0 },
    ["Inferno Drake"] = { repSpeed = 40, strength = 0, durability = 0, rebirth = 0 },
}

local MAX_PET_SLOTS = 12
local TARGET_REP_SPEED = 100

local function applyPetLoadout(selected, isCurrent)
    local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
    local remote = rEvents and rEvents:FindFirstChild("equipPetEvent")
    if not remote then return false end

    local petsFolder = LP:FindFirstChild("petsFolder")
    if petsFolder then
        for _, folder in ipairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, pet in ipairs(folder:GetChildren()) do
                    if isCurrent and not isCurrent() then return false end
                    remote:FireServer("unequipPet", pet)
                end
            end
        end
    end
    task.wait(0.05)
    for _, pet in ipairs(selected) do
        if isCurrent and not isCurrent() then return false end
        remote:FireServer("equipPet", pet)
    end
    return not isCurrent or isCurrent()
end

local function getOwnedConfiguredPets()
    local ownedPets = {}
    local petsFolder = LP:FindFirstChild("petsFolder")
    if not petsFolder then return ownedPets end

    for _, folder in ipairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                local config = PETS[pet.Name]
                if config then
                    table.insert(ownedPets, {
                        instance = pet,
                        name = pet.Name,
                        repSpeed = config.repSpeed or 0,
                        strength = config.strength or 0,
                        durability = config.durability or 0,
                        rebirth = config.rebirth or 0,
                    })
                end
            end
        end
    end
    return ownedPets
end

local function equipBestFarmingPets(isCurrent)
    if isCurrent and not isCurrent() then return end
    local pets = getOwnedConfiguredPets()
    local selected = {}
    local equipped = {}
    local equippedCount = 0
    local currentRepSpeed = 0

    table.sort(pets, function(a, b) return a.repSpeed > b.repSpeed end)

    for _, pet in ipairs(pets) do
        if equippedCount >= MAX_PET_SLOTS or currentRepSpeed >= TARGET_REP_SPEED then break end
        if pet.repSpeed > 0 then
            table.insert(selected, pet.instance)
            equipped[pet.instance] = true
            equippedCount = equippedCount + 1
            currentRepSpeed = currentRepSpeed + pet.repSpeed
        end
    end

    local remainingPets = {}
    for _, pet in ipairs(pets) do
        if not equipped[pet.instance] then
            table.insert(remainingPets, pet)
        end
    end

    table.sort(remainingPets, function(a, b)
        return (a.strength + a.durability) > (b.strength + b.durability)
    end)

    for _, pet in ipairs(remainingPets) do
        if equippedCount >= MAX_PET_SLOTS then break end
        if pet.strength > 0 or pet.durability > 0 then
            table.insert(selected, pet.instance)
            equipped[pet.instance] = true
            equippedCount = equippedCount + 1
        end
    end

    applyPetLoadout(selected, isCurrent)
end

local function equipSpecificPets(targetRepName, isCurrent)
    if isCurrent and not isCurrent() then return end
    local pets = getOwnedConfiguredPets()
    local selected = {}
    local equippedCount = 0

    for _, pet in ipairs(pets) do
        if equippedCount >= MAX_PET_SLOTS then break end
        if pet.name == targetRepName then
            table.insert(selected, pet.instance)
            equippedCount = equippedCount + 1
        end
    end

    if equippedCount == 0 then
        for _, pet in ipairs(pets) do
            if equippedCount >= MAX_PET_SLOTS then break end
            table.insert(selected, pet.instance)
            equippedCount = equippedCount + 1
        end
    end

    applyPetLoadout(selected, isCurrent)
end

local function equipStrictRebirthPets(targetRebirthName, isCurrent)
    if isCurrent and not isCurrent() then return end
    local pets = getOwnedConfiguredPets()
    local selected = {}
    local equippedCount = 0

    for _, pet in ipairs(pets) do
        if equippedCount >= MAX_PET_SLOTS then break end
        if pet.name == targetRebirthName then
            table.insert(selected, pet.instance)
            equippedCount = equippedCount + 1
        end
    end

    if equippedCount == 0 then
        for _, pet in ipairs(pets) do
            if equippedCount >= MAX_PET_SLOTS then break end
            table.insert(selected, pet.instance)
            equippedCount = equippedCount + 1
        end
    end

    applyPetLoadout(selected, isCurrent)
end

local function equipBestRebirthPets(isCurrent)
    if isCurrent and not isCurrent() then return end
    local pets = getOwnedConfiguredPets()
    local selected = {}

    table.sort(pets, function(a, b) return a.rebirth > b.rebirth end)

    local equippedCount = 0
    for _, pet in ipairs(pets) do
        if equippedCount >= MAX_PET_SLOTS then break end
        if pet.rebirth > 0 then
            table.insert(selected, pet.instance)
            equippedCount = equippedCount + 1
        end
    end

    applyPetLoadout(selected, isCurrent)
end

local function sendTrainingReps(state, rate, maxBurst, canSend)
    local now = os.clock()
    local elapsed = math.clamp(now - (state.LastAt or now), 0, 0.1)
    state.LastAt = now
    state.Tokens = math.min(maxBurst, (state.Tokens or 0) + rate * elapsed)
    local sent = 0
    local muscleEvent = LP:FindFirstChild("muscleEvent")
    while state.Tokens >= 1 and canSend() and muscleEvent do
        muscleEvent:FireServer("rep")
        state.Tokens = state.Tokens - 1
        sent = sent + 1
    end
    return sent
end

-- ==================== MOTOR DE FARMING OP ====================
local function createFarmLoop(getState, rate, burst)
    task.spawn(function()
        local cachedEvent = LP:FindFirstChild("muscleEvent")
        LP.ChildAdded:Connect(function(child)
            if child.Name == "muscleEvent" then cachedEvent = child end
        end)

        local INTERVAL = burst / rate

        while true do
            if getState() then
                if not cachedEvent or not cachedEvent.Parent then
                    cachedEvent = LP:FindFirstChild("muscleEvent")
                end
                if cachedEvent then
                    local start = os.clock()
                    for i = 1, burst do
                        if not getState() then break end
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
end

createFarmLoop(function() return FastFarm500 end, 500, 50)
createFarmLoop(function() return FastFarm2k end, 2000, 200)
createFarmLoop(function() return FastFarm10k end, 10000, 500)
createFarmLoop(function() return FastFarm20k end, 20000, 1000)

-- ==================== AUTO REBIRTH NORMAL ====================
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

-- ==================== MOTOR GENERALIZADO DE FAST REBIRTH ====================
local function runFastRebirthWorker(getStateRef, getGenRef, setGenRef, equipRepFunc, equipRebFunc)
    local adaptiveData = { TargetSeconds = 3, MaxRate = 50, SendRate = 50, StrengthPerRep = nil }

    local function isCurrent(gen)
        return getStateRef() and getGenRef() == gen
    end

    local function updateAdaptiveSpeed(cycle)
        local now = os.clock()
        if now - cycle.SampleAt < 0.25 then return end
        local gain = Strength.Value - cycle.StartStrength
        if gain > 0 and cycle.Sent > 0 then
            adaptiveData.StrengthPerRep = gain / cycle.Sent
            local remaining = math.max(0, cycle.Target - Strength.Value)
            local seconds = math.max(0.1, adaptiveData.TargetSeconds - cycle.TrainingSeconds)
            adaptiveData.SendRate = math.clamp(remaining / adaptiveData.StrengthPerRep / seconds, 1, adaptiveData.MaxRate)
        elseif cycle.TrainingSeconds >= adaptiveData.TargetSeconds then
            adaptiveData.SendRate = adaptiveData.MaxRate
        end
        cycle.SampleAt = now
    end

    local function performCycle(gen)
        local cycle = {
            Target = 5000 + Rebirths.Value * 2550,
            Rebirths = Rebirths.Value,
            SampleAt = os.clock(),
            StartStrength = Strength.Value,
            Sent = 0,
            Tokens = 0,
            LastAt = os.clock(),
            TrainingSeconds = 0
        }
        adaptiveData.SendRate = adaptiveData.StrengthPerRep and math.clamp(math.max(0, cycle.Target - cycle.StartStrength) / adaptiveData.StrengthPerRep / adaptiveData.TargetSeconds, 1, adaptiveData.MaxRate) or adaptiveData.MaxRate

        local lastTrainingAt = os.clock()
        local function needsTraining()
            return isCurrent(gen) and Rebirths.Value == cycle.Rebirths and Strength.Value < cycle.Target
        end

        while needsTraining() do
            local now = os.clock()
            local character = LP.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                cycle.TrainingSeconds = cycle.TrainingSeconds + math.max(0, now - lastTrainingAt)
                updateAdaptiveSpeed(cycle)
                cycle.Sent = cycle.Sent + sendTrainingReps(cycle, adaptiveData.SendRate, 5, needsTraining)
            else
                cycle.Tokens = 0
                cycle.LastAt = now
            end
            lastTrainingAt = now
            RunService.Heartbeat:Wait()
        end

        if not isCurrent(gen) or Rebirths.Value ~= cycle.Rebirths then return end

        equipRebFunc(function() return isCurrent(gen) end)

        local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
        local remote = rEvents and rEvents:FindFirstChild("rebirthRemote")

        while isCurrent(gen) and Rebirths.Value == cycle.Rebirths do
            if remote then
                pcall(function()
                    if remote:IsA("RemoteFunction") then
                        remote:InvokeServer("rebirthRequest")
                    elseif remote:IsA("RemoteEvent") then
                        remote:FireServer("rebirthRequest")
                    end
                end)
            end
            task.wait(0.05)
        end
    end

    setGenRef(getGenRef() + 1)
    local currentGen = getGenRef()

    task.spawn(function()
        pcall(function()
            while isCurrent(currentGen) do
                equipRepFunc(function() return isCurrent(currentGen) end)
                if not isCurrent(currentGen) then break end
                
                performCycle(currentGen)
                task.wait()
            end
        end)
    end)
end

local combGen, chaosGen, titansGen = 0, 0, 0

local function triggerCombination()
    if RebirthsCombination then
        runFastRebirthWorker(
            function() return RebirthsCombination end,
            function() return combGen end,
            function(v) combGen = v end,
            function(cb) equipBestFarmingPets(cb) end,
            function(cb) equipBestRebirthPets(cb) end
        )
    end
end

local function triggerChaos()
    if RebirthChaos then
        runFastRebirthWorker(
            function() return RebirthChaos end,
            function() return chaosGen end,
            function(v) chaosGen = v end,
            function(cb) equipSpecificPets("Swift Samurai", cb) end,
            function(cb) equipStrictRebirthPets("Tribal Overlord", cb) end
        )
    end
end

local function triggerTitans()
    if RebirthsTitans then
        runFastRebirthWorker(
            function() return RebirthsTitans end,
            function() return titansGen end,
            function(v) titansGen = v end,
            function(cb) equipSpecificPets("Omega Overlord", cb) end,
            function(cb) equipStrictRebirthPets("Titanium Hydra", cb) end
        )
    end
end

-- ==================== LIBRERÍA DE INTERFAZ GRÁFICA ====================
local Library = {}

local function Create(className, properties, parent)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

local function MakeDraggable(dragBar, object)
    local dragging, dragStart, startPos
    
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)
end

function Library:CreateWindow(config)
    local WindowObj = {}
    local windowTitle = config.Title or "👑 ChrisxLale Script"
    
    local parentUI = (gethui and gethui()) or CoreGui or LP:WaitForChild("PlayerGui")
    if parentUI:FindFirstChild("ChrisxLale_AestheticUI") then
        parentUI.ChrisxLale_AestheticUI:Destroy()
    end

    local ScreenGui = Create("ScreenGui", {
        Name = "ChrisxLale_AestheticUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    }, parentUI)

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Color3.fromRGB(18, 18, 22),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 580, 0, 360),
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, ScreenGui)

    Create("UICorner", {CornerRadius = UDim.new(0, 12)}, MainFrame)
    Create("UIStroke", {Color = Color3.fromRGB(120, 80, 255), Thickness = 1.5}, MainFrame)

    local MiniButton = Create("TextButton", {
        Name = "ChrisxLale_Mini",
        Size = UDim2.new(0, 140, 0, 38),
        Position = UDim2.new(1, -155, 0, 15),
        BackgroundColor3 = Color3.fromRGB(22, 22, 30),
        BorderSizePixel = 0,
        Text = windowTitle,
        TextColor3 = Color3.fromRGB(235, 235, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Visible = false,
        AutoButtonColor = false
    }, ScreenGui)

    Create("UICorner", {CornerRadius = UDim.new(0, 10)}, MiniButton)
    Create("UIStroke", {Color = Color3.fromRGB(120, 80, 255), Thickness = 1.5}, MiniButton)

    local TopBar = Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Color3.fromRGB(12, 12, 16),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32)
    }, MainFrame)

    Create("UICorner", {CornerRadius = UDim.new(0, 12)}, TopBar)
    Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(12, 12, 16),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -5),
        Size = UDim2.new(1, 0, 0, 5)
    }, TopBar)

    MakeDraggable(TopBar, MainFrame)

    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0, 4),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        Text = "×",
        TextColor3 = Color3.fromRGB(180, 180, 200),
        Font = Enum.Font.GothamBold,
        TextSize = 16
    }, TopBar)
    Create("UICorner", {CornerRadius = UDim.new(0, 6)}, CloseBtn)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local MinimizeBtn = Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -60, 0, 4),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        Text = "-",
        TextColor3 = Color3.fromRGB(210, 210, 225),
        Font = Enum.Font.GothamBold,
        TextSize = 16
    }, TopBar)
    Create("UICorner", {CornerRadius = UDim.new(0, 6)}, MinimizeBtn)

    MinimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MiniButton.Visible = true
    end)

    MiniButton.MouseButton1Click:Connect(function()
        MiniButton.Visible = false
        MainFrame.Visible = true
    end)

    local Container = Create("Frame", {
        Name = "Container",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(1, 0, 1, -32)
    }, MainFrame)

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Color3.fromRGB(12, 12, 16),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 140, 1, 0)
    }, Container)
    Create("UICorner", {CornerRadius = UDim.new(0, 12)}, Sidebar)

    local AvatarImage = Create("ImageLabel", {
        Name = "AvatarImage",
        BackgroundColor3 = Color3.fromRGB(25, 24, 32),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 12),
        Size = UDim2.new(0, 36, 0, 36),
        Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    }, Sidebar)
    Create("UICorner", {CornerRadius = UDim.new(1, 0)}, AvatarImage)

    Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = LP.Name,
        TextColor3 = Color3.fromRGB(235, 235, 240),
        TextSize = 11,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 13),
        Size = UDim2.new(0, 78, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    }, Sidebar)

    Create("TextLabel", {
        Font = Enum.Font.Gotham,
        Text = "VIP User",
        TextColor3 = Color3.fromRGB(130, 130, 140),
        TextSize = 10,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 29),
        Size = UDim2.new(0, 78, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left
    }, Sidebar)

    Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 36),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 56),
        Size = UDim2.new(1, -24, 0, 1)
    }, Sidebar)

    -- ==================== CORRECCIÓN: SCROLLINGFRAME PARA EL MENÚ LATERAL ====================
    local NavContainer = Create("ScrollingFrame", {
        Name = "NavContainer",
        Size = UDim2.new(1, -6, 1, -64),
        Position = UDim2.new(0, 3, 0, 62),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(120, 80, 255),
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }, Sidebar)

    local navLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, NavContainer)

    navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        NavContainer.CanvasSize = UDim2.new(0, 0, 0, navLayout.AbsoluteContentSize.Y + 10)
    end)

    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -145, 1, 0),
        Position = UDim2.new(0, 145, 0, 0),
        BackgroundTransparency = 1
    }, Container)

    local pages = {}
    local navButtons = {}
    local firstTab = true

    local emojiMap = {
        ["Principal"] = "🏠",
        ["Farming"] = "🏋️",
        ["Rebirth"] = "🌌",
        ["Auto Rocks"] = "⛰️",
        ["Stats"] = "📊",
        ["Gift"] = "🎁",
        ["Teleport"] = "🌀",
        ["Settings"] = "⚙️"
    }

    function WindowObj:CreateTab(name, iconChar, subTitleText)
        local finalIcon = iconChar or emojiMap[name] or name:sub(1, 1)

        local btn = Create("TextButton", {
            Name = name .. "TabBtn",
            Size = UDim2.new(1, -6, 0, 32),
            BackgroundColor3 = Color3.fromRGB(12, 12, 16),
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        }, NavContainer)
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}, btn)

        local iconLabel = Create("TextLabel", {
            Name = "IconLabel",
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = finalIcon,
            TextColor3 = Color3.fromRGB(160, 160, 180),
            Font = Enum.Font.GothamBold,
            TextSize = 11
        }, btn)

        local textLabel = Create("TextLabel", {
            Name = "TextLabel",
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 28, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Color3.fromRGB(180, 180, 200),
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, btn)

        local indicator = Create("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0, 18),
            Position = UDim2.new(0, 0, 0.5, -9),
            BackgroundColor3 = Color3.fromRGB(120, 80, 255),
            BorderSizePixel = 0,
            Visible = false
        }, btn)
        Create("UICorner", {CornerRadius = UDim.new(0, 2)}, indicator)

        local page = Create("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.new(1, -16, 1, -12),
            Position = UDim2.new(0, 8, 0, 6),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(120, 80, 255),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        }, ContentContainer)

        local pageLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, page)

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 15)
        end)

        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = finalIcon .. "  " .. name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = -2
        }, page)

        if subTitleText then
            Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text = subTitleText,
                TextColor3 = Color3.fromRGB(140, 140, 160),
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = -1
            }, page)
        end

        table.insert(navButtons, {
            Button = btn,
            Indicator = indicator,
            Icon = iconLabel,
            Text = textLabel
        })

        if firstTab then
            firstTab = false
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(28, 24, 45)
            indicator.Visible = true
            iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(pages) do p.Visible = false end
            page.Visible = true

            for _, navItem in ipairs(navButtons) do
                navItem.Button.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
                navItem.Indicator.Visible = false
                navItem.Icon.TextColor3 = Color3.fromRGB(160, 160, 180)
                navItem.Text.TextColor3 = Color3.fromRGB(180, 180, 200)
            end

            btn.BackgroundColor3 = Color3.fromRGB(28, 24, 45)
            indicator.Visible = true
            iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        pages[name] = page

        local TabMethods = {}

        function TabMethods:AddSection(secText)
            return Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Text = string.upper(secText),
                TextColor3 = Color3.fromRGB(130, 100, 200),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            }, page)
        end

        function TabMethods:CreateToggle(config, callback)
            local titleText = config.Name or "Toggle"
            local descText = config.Description or ""
            local defaultState = config.Default or false
            local currentState = defaultState

            local row = Create("Frame", {
                Size = UDim2.new(1, -6, 0, descText ~= "" and 52 or 40),
                BackgroundColor3 = Color3.fromRGB(24, 24, 30),
                BorderSizePixel = 0
            }, page)
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}, row)

            Create("TextLabel", {
                Size = UDim2.new(1, -75, 0, 20),
                Position = UDim2.new(0, 12, 0, descText ~= "" and 8 or 10),
                BackgroundTransparency = 1,
                Text = titleText,
                TextColor3 = Color3.fromRGB(240, 240, 250),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }, row)

            if descText ~= "" then
                Create("TextLabel", {
                    Size = UDim2.new(1, -75, 0, 16),
                    Position = UDim2.new(0, 12, 0, 28),
                    BackgroundTransparency = 1,
                    Text = descText,
                    TextColor3 = Color3.fromRGB(130, 130, 150),
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, row)
            end

            local switchBg = Create("Frame", {
                Size = UDim2.new(0, 42, 0, 24),
                Position = UDim2.new(1, -52, 0.5, -12),
                BackgroundColor3 = currentState and Color3.fromRGB(100, 70, 220) or Color3.fromRGB(50, 50, 60),
                BorderSizePixel = 0
            }, row)
            Create("UICorner", {CornerRadius = UDim.new(1, 0)}, switchBg)

            local knob = Create("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = currentState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0
            }, switchBg)
            Create("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)

            local clickBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = ""
            }, row)

            clickBtn.MouseButton1Click:Connect(function()
                currentState = not currentState
                local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                if currentState then
                    TweenService:Create(switchBg, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 70, 220)}):Play()
                    TweenService:Create(knob, tweenInfo, {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
                else
                    TweenService:Create(switchBg, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
                    TweenService:Create(knob, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
                end
                pcall(callback, currentState)
            end)

            if defaultState then pcall(callback, true) end

            return row
        end

        function TabMethods:AddButton(text, callback)
            local btn = Create("TextButton", {
                Size = UDim2.new(1, -6, 0, 36),
                BackgroundColor3 = Color3.fromRGB(28, 24, 45),
                BorderSizePixel = 0,
                Text = text,
                TextColor3 = Color3.fromRGB(235, 235, 255),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                AutoButtonColor = true
            }, page)
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}, btn)

            btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            return btn
        end

        function TabMethods:AddTextBox(placeholder, callback)
            local row = Create("Frame", {
                Size = UDim2.new(1, -6, 0, 38),
                BackgroundColor3 = Color3.fromRGB(24, 24, 30),
                BorderSizePixel = 0
            }, page)
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}, row)

            local box = Create("TextBox", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                PlaceholderText = placeholder or "Escribe aquí...",
                Text = "",
                TextColor3 = Color3.fromRGB(240, 240, 250),
                PlaceholderColor3 = Color3.fromRGB(120, 120, 140),
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            }, row)

            box.FocusLost:Connect(function(enterPressed)
                pcall(callback, box.Text)
            end)

            return box
        end

        return TabMethods
    end

    return WindowObj
end

-- ==================== INICIALIZACIÓN DE LA UI ====================
local Window = Library:CreateWindow({
    Title = "👑 ChrisxLale Script",
    Icon = "rbxassetid://6031097225"
})

-- Crear Pestañas
local PrincipalTab = Window:CreateTab("Principal", "🏠", "Bienvenido al script, " .. LP.Name)
local FarmingTab = Window:CreateTab("Farming", "🏋️", "Automatización de recursos")
local RebirthTab = Window:CreateTab("Rebirth", "🌌", "Sistema de reencarnaciones")
local RocksTab = Window:CreateTab("Auto Rocks", "⛰️", "Farming automático de rocas")
local StatsTab = Window:CreateTab("Stats", "📊", "Calculadoras y monitoreo en tiempo real")
local GiftTab = Window:CreateTab("Gift", "🎁", "Regalar consumibles a otros jugadores")
local TeleportTab = Window:CreateTab("Teleport", "🌀", "Viaja por el mapa")
local SettingsTab = Window:CreateTab("Settings", "⚙️", "Configuración y automatización")

-- ==================== PESTAÑA PRINCIPAL ====================
PrincipalTab:AddSection("Utilidades")
PrincipalTab:CreateToggle({
    Name = "Anti-AFK",
    Description = "Protección automática contra inactividad",
    Default = true
}, function(state)
    if state then
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "SLK Paid Hub",
                Text = "Anti-AFK Activo 🛡️",
                Duration = 3
            })
        end)
    end
end)

PrincipalTab:CreateToggle({
    Name = "Anti Lag Ligero",
    Description = "Baja gráficos y sombras sin alterar los colores del mapa",
    Default = false
}, function(state)
    pcall(function()
        if state then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.Technology = Enum.LightingTechnology.Compatibility
            StarterGui:SetCore("SendNotification", {
                Title = "SLK Paid Hub",
                Text = "Anti Lag Activado ⚡",
                Duration = 3
            })
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
            Lighting.Technology = Enum.LightingTechnology.Future
        end
    end)
end)

-- ==================== PESTAÑA FARMING ====================
FarmingTab:AddSection("Activar para Rebirths+Fuerza")

FarmingTab:CreateToggle({
    Name = "OP Farm (500 Rep/s)",
    Description = "Velocidad recomendada para combinar con Fast Rebirth",
    Default = false
}, function(state)
    FastFarm500 = state
    if state then 
        FastFarm2k = false 
        FastFarm10k = false 
        FastFarm20k = false 
    end
end)

FarmingTab:AddSection("Solo fuerza")

FarmingTab:CreateToggle({
    Name = "OP Farm (2k Rep/s)",
    Description = "Velocidad rápida: 2,000 repeticiones por segundo",
    Default = false
}, function(state)
    FastFarm2k = state
    if state then 
        FastFarm500 = false 
        FastFarm10k = false 
        FastFarm20k = false 
    end
end)

FarmingTab:CreateToggle({
    Name = "OP Farm (10k Rep/s)",
    Description = "Velocidad alta: 10,000 repeticiones por segundo",
    Default = false
}, function(state)
    FastFarm10k = state
    if state then 
        FastFarm500 = false 
        FastFarm2k = false 
        FastFarm20k = false 
    end
end)

FarmingTab:CreateToggle({
    Name = "OP Farm (20k Rep/s)",
    Description = "Velocidad máxima: 20,000 repeticiones por segundo",
    Default = false
}, function(state)
    FastFarm20k = state
    if state then 
        FastFarm500 = false 
        FastFarm2k = false 
        FastFarm10k = false 
    end
end)

-- ==================== PESTAÑA REBIRTH ====================
RebirthTab:AddSection("Rebirth")

RebirthTab:CreateToggle({
    Name = "Auto Rebirth",
    Description = "Rebirth automático básico por fuerza",
    Default = false
}, function(state)
    AutoRebirth = state
    if state then
        RebirthsCombination = false
        RebirthChaos = false
        RebirthsTitans = false
    end
end)

RebirthTab:AddSection("Fast Rebirth")

RebirthTab:CreateToggle({
    Name = "Auto Rebirths combination",
    Description = "Sirven Golems/Packs",
    Default = false
}, function(state)
    RebirthsCombination = state
    if state then
        AutoRebirth = false
        RebirthChaos = false
        RebirthsTitans = false
        FastFarm2k = false
        FastFarm10k = false
        FastFarm20k = false
        FastFarm500 = true
        triggerCombination()
    end
end)

RebirthTab:CreateToggle({
    Name = "Rebirth chaos",
    Description = "Renace Pack Chaos",
    Default = false
}, function(state)
    RebirthChaos = state
    if state then
        AutoRebirth = false
        RebirthsCombination = false
        RebirthsTitans = false
        FastFarm2k = false
        FastFarm10k = false
        FastFarm20k = false
        FastFarm500 = true
        triggerChaos()
    end
end)

RebirthTab:CreateToggle({
    Name = "Rebirths titans",
    Description = "Renace Pack Titans",
    Default = false
}, function(state)
    RebirthsTitans = state
    if state then
        AutoRebirth = false
        RebirthsCombination = false
        RebirthChaos = false
        FastFarm2k = false
        FastFarm10k = false
        FastFarm20k = false
        FastFarm500 = true
        triggerTitans()
    end
end)

-- ==================== PESTAÑA AUTO ROCKS ====================
RocksTab:AddSection("Farming de Rocas")

local activeRock = nil

local function getrocktool()
    local backpack = LP:FindFirstChild("Backpack")
    local char = LP.Character
    if backpack and char and char:FindFirstChild("Humanoid") then
        local punch = backpack:FindFirstChild("Punch") or char:FindFirstChild("Punch")
        if punch and punch.Parent == backpack then
            char.Humanoid:EquipTool(punch)
        end
    end
    pcall(function()
        if LP:FindFirstChild("muscleEvent") then
            LP.muscleEvent:FireServer("punch", "leftHand")
            LP.muscleEvent:FireServer("punch", "rightHand")
        end
    end)
end

local rockList = {
    { Name = "Farm Tiny Island Rock", MinDur = 0, DurVal = 0 },
    { Name = "Farm Starter Island Rock", MinDur = 100, DurVal = 100 },
    { Name = "Farm Legend Beach Rock", MinDur = 5000, DurVal = 5000 },
    { Name = "Farm Frost Gym Rock", MinDur = 150000, DurVal = 150000 },
    { Name = "Farm Mythical Gym Rock", MinDur = 400000, DurVal = 400000 },
    { Name = "Farm Eternal Gym Rock", MinDur = 750000, DurVal = 750000 },
    { Name = "Farm Legend Gym Rock", MinDur = 1000000, DurVal = 1000000 },
    { Name = "Farm Muscle King Gym Rock", MinDur = 5000000, DurVal = 5000000 },
    { Name = "Farm Ancient Jungle Rock", MinDur = 10000000, DurVal = 10000000 },
	{ Name = "Farm Industrial Jungle Rock", MinDur = 25000000, DurVal = 25000000 },
	{ Name = "Farm Hallowed Rock", MinDur = 0, DurVal = 0 },
}

for _, rockInfo in ipairs(rockList) do
    RocksTab:CreateToggle({
        Name = rockInfo.Name,
        Description = "Requiere " .. rockInfo.MinDur .. " de Durabilidad",
        Default = false
    }, function(bool)
        if bool then
            activeRock = rockInfo.Name
            task.spawn(function()
                while activeRock == rockInfo.Name do
                    task.wait(0.01)
                    pcall(function()
                        local durabilityObj = LP:FindFirstChild("Durability")
                        if durabilityObj and durabilityObj.Value >= rockInfo.MinDur then
                            getrocktool()
                            local machinesFolder = workspace:FindFirstChild("machinesFolder")
                            if machinesFolder then
                                for _, v in pairs(machinesFolder:GetDescendants()) do
                                    if v.Name == "neededDurability" and v.Value == rockInfo.DurVal then
                                        local rockPart = v.Parent and v.Parent:FindFirstChild("Rock")
                                        local char = LP.Character
                                        if rockPart and char then
                                            local rightHand = char:FindFirstChild("RightHand")
                                            local leftHand = char:FindFirstChild("LeftHand")
                                            if rightHand and leftHand then
                                                firetouchinterest(rockPart, rightHand, 0)
                                                firetouchinterest(rockPart, rightHand, 1)
                                                firetouchinterest(rockPart, leftHand, 0)
                                                firetouchinterest(rockPart, leftHand, 1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        else
            if activeRock == rockInfo.Name then
                activeRock = nil
            end
        end
    end)
end

-- ==================== PESTAÑA STATS & CALCULATOR ====================
StatsTab:AddSection("Monitoreo en Tiempo Real")

local stopwatchLabel = StatsTab:AddButton("Fast Rep Time: 0d 0h 0m 0s", function() end)
local projectedStrengthLabel = StatsTab:AddButton("Strength Rate: 0 /Hour", function() end)
local projectedDurabilityLabel = StatsTab:AddButton("Durability Rate: 0 /Hour", function() end)

StatsTab:AddSection("Progreso de Estadísticas")
local strengthLabel = StatsTab:AddButton("Strength: 0 | Gained: 0", function() end)
local durabilityLabel = StatsTab:AddButton("Durability: 0 | Gained: 0", function() end)

local leaderstats = LP:WaitForChild("leaderstats")
local strengthStat = leaderstats:WaitForChild("Strength")
local durabilityStat = LP:WaitForChild("Durability")

local function formatNumber(number)
    local isNegative = number < 0
    number = math.abs(number)
    if number >= 1e15 then return (isNegative and "-" or "") .. string.format("%.2fQa", number / 1e15)
    elseif number >= 1e12 then return (isNegative and "-" or "") .. string.format("%.2fT", number / 1e12)
    elseif number >= 1e9 then return (isNegative and "-" or "") .. string.format("%.2fB", number / 1e9)
    elseif number >= 1e6 then return (isNegative and "-" or "") .. string.format("%.2fM", number / 1e6)
    elseif number >= 1e3 then return (isNegative and "-" or "") .. string.format("%.2fK", number / 1e3)
    else return (isNegative and "-" or "") .. string.format("%.2f", number) end
end

local startTime = tick()
local initialStrength = strengthStat.Value
local initialDurability = durabilityStat.Value
local trackingStarted = false
local strengthHistory = {}
local durabilityHistory = {}
local calculationInterval = 10

task.spawn(function()
    local lastCalcTime = tick()
    while true do
        local currentTime = tick()
        local currentStrength = strengthStat.Value
        local currentDurability = durabilityStat.Value
        if not trackingStarted and (currentStrength - initialStrength) >= 100e9 then
            trackingStarted = true
            startTime = tick()
            strengthHistory = {}
            durabilityHistory = {}
        end
        if trackingStarted then
            local elapsedTime = currentTime - startTime
            local days = math.floor(elapsedTime / (24 * 3600))
            local hours = math.floor((elapsedTime % (24 * 3600)) / 3600)
            local minutes = math.floor((elapsedTime % 3600) / 60)
            local seconds = math.floor(elapsedTime % 60)
            stopwatchLabel.Text = string.format("Fast Rep Time: %dd %dh %dm %ds", days, hours, minutes, seconds)
            
            local sessionStrengthDelta = currentStrength - initialStrength
            local sessionDurabilityDelta = currentDurability - initialDurability
            strengthLabel.Text = "Strength: " .. formatNumber(currentStrength) .. " | Gained: " .. formatNumber(sessionStrengthDelta)
            durabilityLabel.Text = "Durability: " .. formatNumber(currentDurability) .. " | Gained: " .. formatNumber(sessionDurabilityDelta)
            
            table.insert(strengthHistory, {time = currentTime, value = currentStrength})
            table.insert(durabilityHistory, {time = currentTime, value = currentDurability})
            while #strengthHistory > 0 and currentTime - strengthHistory[1].time > calculationInterval do table.remove(strengthHistory, 1) end
            while #durabilityHistory > 0 and currentTime - durabilityHistory[1].time > calculationInterval do table.remove(durabilityHistory, 1) end
            
            if currentTime - lastCalcTime >= calculationInterval then
                lastCalcTime = currentTime
                if #strengthHistory >= 2 then
                    local strengthDelta = strengthHistory[#strengthHistory].value - strengthHistory[1].value
                    local strengthPerSecond = strengthDelta / calculationInterval
                    local strengthPerHour = math.floor(strengthPerSecond * 3600)
                    local strengthPerDay = math.floor(strengthPerSecond * 86400)
                    projectedStrengthLabel.Text = "Strength: " .. formatNumber(strengthPerHour) .. "/H | " .. formatNumber(strengthPerDay) .. "/D"
                end
                if #durabilityHistory >= 2 then
                    local durabilityDelta = durabilityHistory[#durabilityHistory].value - durabilityHistory[1].value
                    local durabilityPerSecond = durabilityDelta / calculationInterval
                    local durabilityPerHour = math.floor(durabilityPerSecond * 3600)
                    local durabilityPerDay = math.floor(durabilityPerSecond * 86400)
                    projectedDurabilityLabel.Text = "Durability: " .. formatNumber(durabilityPerHour) .. "/H | " .. formatNumber(durabilityPerDay) .. "/D"
                end
            end
        end
        task.wait(0.05)
    end
end)

-- ==================== PESTAÑA GIFT ====================
GiftTab:AddSection("Monitoreo de Consumibles")

local proteinEggBtn = GiftTab:AddButton("Protein Eggs: 0", function() end)

local function updateItemCounts()
    local proteinEggCount = 0
    
    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name == "Protein Egg" then
                proteinEggCount = proteinEggCount + 1
            end
        end
    end
    
    local consumablesFolder = LP:FindFirstChild("consumablesFolder")
    if consumablesFolder then
        for _, item in ipairs(consumablesFolder:GetChildren()) do
            if item.Name == "Protein Egg" then
                proteinEggCount = proteinEggCount + 1
            end
        end
    end

    proteinEggBtn.Text = "Protein Eggs: " .. proteinEggCount
end

task.spawn(function()
    while true do
        updateItemCounts()
        task.wait(1)
    end
end)

GiftTab:AddSection("Actualizar Lista")

GiftTab:AddButton("🔄 Refresh Players / Items", function()
    updateItemCounts()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "SLK Paid Hub",
            Text = "Lista de jugadores y consumibles actualizada! 🔄",
            Duration = 3
        })
    end)
end)

GiftTab:AddSection("Regalar Protein Eggs")

local targetEggPlayerName = ""
local giftEggAmount = 0

GiftTab:AddTextBox("Nombre del jugador (Username)", function(text)
    targetEggPlayerName = text
end)

GiftTab:AddTextBox("Cantidad de Eggs", function(text)
    giftEggAmount = tonumber(text) or 0
end)

GiftTab:AddButton("Gift Protein Eggs", function()
    if targetEggPlayerName == "" or giftEggAmount <= 0 then
        StarterGui:SetCore("SendNotification", { Title = "Gift Error", Text = "Escribe un jugador y cantidad válida.", Duration = 3 })
        return
    end

    local targetPlayer = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower() == targetEggPlayerName:lower() or plr.DisplayName:lower() == targetEggPlayerName:lower() then
            targetPlayer = plr
            break
        end
    end

    if not targetPlayer then
        StarterGui:SetCore("SendNotification", { Title = "Gift Error", Text = "Jugador no encontrado.", Duration = 3 })
        return
    end

    task.spawn(function()
        local countSent = 0
        local giftRemote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("giftRemote")
        local consumablesFolder = LP:FindFirstChild("consumablesFolder")
        
        if giftRemote and consumablesFolder then
            for i = 1, giftEggAmount do
                local egg = consumablesFolder:FindFirstChild("Protein Egg")
                if egg then
                    pcall(function()
                        if giftRemote:IsA("RemoteFunction") then
                            giftRemote:InvokeServer("giftRequest", targetPlayer, egg)
                        else
                            giftRemote:FireServer("giftRequest", targetPlayer, egg)
                        end
                    end)
                    countSent = countSent + 1
                    task.wait(0.15)
                else
                    break
                end
            end
        end
        updateItemCounts()
        StarterGui:SetCore("SendNotification", { Title = "Gift Finalizado", Text = "Se regalaron " .. countSent .. " Protein Eggs a " .. targetPlayer.DisplayName, Duration = 4 })
    end)
end)

GiftTab:AddSection("Auto Consumir")

local itemList = {
    "Tropical Shake", "Energy Shake", "Protein Bar", "TOUGH Bar", "Protein Shake", "ULTRA Shake", "Energy Bar"
}

local function formatEventName(itemName)
    local parts = {}
    for word in itemName:gmatch("%S+") do table.insert(parts, word:lower()) end
    for i = 2, #parts do parts[i] = parts[i]:sub(1, 1):upper() .. parts[i]:sub(2) end
    return table.concat(parts)
end

local function activateRandomItems(count)
    local shuffledItems = {}
    for _, item in ipairs(itemList) do table.insert(shuffledItems, item) end
    for i = #shuffledItems, 2, -1 do
        local j = math.random(i)
        shuffledItems[i], shuffledItems[j] = shuffledItems[j], shuffledItems[i]
    end
    for i = 1, math.min(count, #shuffledItems) do
        local char = LP.Character
        local backpack = LP:FindFirstChild("Backpack")
        local tool = (char and char:FindFirstChild(shuffledItems[i])) or (backpack and backpack:FindFirstChild(shuffledItems[i]))
        if tool and LP:FindFirstChild("muscleEvent") then
            local eventName = formatEventName(shuffledItems[i])
            pcall(function() LP.muscleEvent:FireServer(eventName, tool) end)
        end
    end
end

GiftTab:CreateToggle({
    Name = "Eat Everything",
    Description = "Consume consumibles aleatorios automáticamente",
    Default = false
}, function(state)
    getgenv().autoEatRunning = state
    if state then
        task.spawn(function()
            while getgenv().autoEatRunning do
                activateRandomItems(4)
                task.wait(0.5)
            end
        end)
    end
end)

-- ==================== PESTAÑA TELETRANSPORTE ====================
TeleportTab:AddSection("Zonas del Mapa")

local function tpTo(cf, name)
    pcall(function()
        local character = LP.Character or LP.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = cf
        StarterGui:SetCore("SendNotification", {
            Title = "Teletransporte",
            Text = "Teleported to " .. name,
            Duration = 3
        })
    end)
end

TeleportTab:AddButton("Spawn", function()
    tpTo(CFrame.new(2, 8, 115), "Spawn")
end)

TeleportTab:AddButton("Secret Area", function()
    tpTo(CFrame.new(1947, 2, 6191), "Secret Area")
end)

TeleportTab:AddButton("Tiny Island", function()
    tpTo(CFrame.new(-34, 7, 1903), "Tiny Island")
end)

TeleportTab:AddButton("Frozen Island", function()
    tpTo(CFrame.new(-2600.00244, 3.67686558, -403.884369, 0.0873617008, 1.0482899e-09, 0.99617666, 3.07204253e-08, 1, -3.7464023e-09, -0.99617666, 3.09302628e-08, 0.0873617008), "Frozen Island")
end)

TeleportTab:AddButton("Mythical Island", function()
    tpTo(CFrame.new(2255, 7, 1071), "Mythical Island")
end)

TeleportTab:AddButton("Eternal Island", function()
    tpTo(CFrame.new(-6768, 7, -1287), "***** Island")
end)

TeleportTab:AddButton("Legend Island", function()
    tpTo(CFrame.new(4604, 991, -3887), "Legend Island")
end)

TeleportTab:AddButton("Muscle King Island", function()
    tpTo(CFrame.new(-8646, 17, -5738), "Muscle King")
end)

TeleportTab:AddButton("Jungle Island", function()
    tpTo(CFrame.new(-8659, 6, 2384), "Jungle Island")
end)

TeleportTab:AddButton("Industrial Gym", function()
    tpTo(CFrame.new(-5563.23388671875, 60.47392654418945, 4942.44482421875), "Industrial Gym")
end)

TeleportTab:AddButton("Halloween Gym", function()
    tpTo(CFrame.new(5558, 86, 5838), "Halloween Gym")
end)

-- ==================== PESTAÑA SETTINGS / CONFIG ====================
SettingsTab:AddSection("Auto Execute")

SettingsTab:CreateToggle({
    Name = "Auto Execute",
    Description = "Guarda el estado del script para autoejecutarse al ingresar",
    Default = AutoExecuteActive
}, function(state)
    AutoExecuteActive = state
    SaveConfig()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "SLK Paid Hub",
            Text = state and "Auto Execute Activado ⚙️" or "Auto Execute Desactivado ❌",
            Duration = 3
        })
    end)
end)

SettingsTab:AddSection("Auto Rejoin")

SettingsTab:CreateToggle({
    Name = "Auto Rejoin",
    Description = "Reconecta automáticamente al servidor si sufres una desconexión",
    Default = AutoRejoinActive
}, function(state)
    AutoRejoinActive = state
    SaveConfig()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "SLK Paid Hub",
            Text = state and "Auto Rejoin Activado 🔄" or "Auto Rejoin Desactivado ❌",
            Duration = 3
        })
    end)
end)
