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
local Stats = game:GetService("Stats")

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

-- ==================== PING PROTECTION ====================
local PingProtection = true
local PING_PAUSE = 15000
local PING_RESUME = 350
local PING_CHECK = 0.5
local pingPaused = false
local farm500BeforePing, farm2kBeforePing, farm10kBeforePing, farm20kBeforePing = false, false, false, false

local function getPing()
    local success, ping = pcall(function()
        local network = Stats:FindFirstChild("Network")
        local serverStats = network and network:FindFirstChild("ServerStatsItem")
        local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
        if dataPing then
            return tonumber(string.match(dataPing:GetValueString(), "%d+"))
        end
        return nil
    end)
    return success and ping or nil
end

task.spawn(function()
    while true do
        task.wait(PING_CHECK)
        if PingProtection then
            local ping = getPing()
            if ping then
                if not pingPaused and ping >= PING_PAUSE then
                    pingPaused = true
                    farm500BeforePing = FastFarm500
                    farm2kBeforePing = FastFarm2k
                    farm10kBeforePing = FastFarm10k
                    farm20kBeforePing = FastFarm20k
                    FastFarm500 = false
                    FastFarm2k = false
                    FastFarm10k = false
                    FastFarm20k = false
                elseif pingPaused and ping <= PING_RESUME then
                    pingPaused = false
                    if farm500BeforePing then FastFarm500 = true end
                    if farm2kBeforePing then FastFarm2k = true end
                    if farm10kBeforePing then FastFarm10k = true end
                    if farm20kBeforePing then FastFarm20k = true end
                    farm500BeforePing, farm2kBeforePing, farm10kBeforePing, farm20kBeforePing = false, false, false, false
                end
            end
        end
    end
end)

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
