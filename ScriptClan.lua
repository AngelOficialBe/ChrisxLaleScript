-- ==================== SERVICIOS Y VARIABLES ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Anti-AFK Automático
LP.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

repeat task.wait(0.3) until LP:FindFirstChild("muscleEvent") and LP:FindFirstChild("leaderstats")

local Strength = LP.leaderstats.Strength
local Rebirths = LP.leaderstats.Rebirths

-- Variables de Estado
local FastFarm500 = false
local FastFarm2k = false
local AutoRebirth = false
local FastRebirth = false

-- Referencias para control dinámico de los Toggles en la UI
local toggle500Ref, toggle2kRef

-- ==================== LÓGICA DE FARMING 1: (500 Rep/s) ====================
task.spawn(function()
    local cachedEvent = LP:FindFirstChild("muscleEvent")
    LP.ChildAdded:Connect(function(child)
        if child.Name == "muscleEvent" then cachedEvent = child end
    end)

    local RATE = 500
    local BURST = 50
    local INTERVAL = BURST / RATE

    while true do
        if FastFarm500 then
            if not cachedEvent or not cachedEvent.Parent then
                cachedEvent = LP:FindFirstChild("muscleEvent")
            end
            if cachedEvent then
                local start = os.clock()
                for i = 1, BURST do
                    if not FastFarm500 then break end
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

-- ==================== LÓGICA DE FARMING 2: (2k Rep/s) ====================
task.spawn(function()
    local cachedEvent = LP:FindFirstChild("muscleEvent")
    LP.ChildAdded:Connect(function(child)
        if child.Name == "muscleEvent" then cachedEvent = child end
    end)

    local RATE = 2000
    local BURST = 200
    local INTERVAL = BURST / RATE

    while true do
        if FastFarm2k then
            if not cachedEvent or not cachedEvent.Parent then
                cachedEvent = LP:FindFirstChild("muscleEvent")
            end
            if cachedEvent then
                local start = os.clock()
                for i = 1, BURST do
                    if not FastFarm2k then break end
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
    WindowObj = {}
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
        Size = UDim2.new(0, 560, 0, 340),
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

    local NavContainer = Create("Frame", {
        Name = "NavContainer",
        Size = UDim2.new(1, -10, 1, -64),
        Position = UDim2.new(0, 5, 0, 62),
        BackgroundTransparency = 1
    }, Sidebar)

    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, NavContainer)

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
        ["Jefes"] = "👹",
        ["Teletransporte"] = "🌀"
    }

    function WindowObj:CreateTab(name, iconChar, subTitleText)
        local finalIcon = iconChar or emojiMap[name] or name:sub(1, 1)

        local btn = Create("TextButton", {
            Name = name .. "TabBtn",
            Size = UDim2.new(1, 0, 0, 32),
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
local JefesTab = Window:CreateTab("Jefes", "👹", "Farming de jefes")
local TeletransporteTab = Window:CreateTab("Teletransporte", "🌀", "Viaja por el mapa")

-- ==================== AÑADIR ELEMENTOS A LAS PESTAÑAS ====================
PrincipalTab:AddSection("Información")
PrincipalTab:CreateToggle({
    Name = "Estado Anti-AFK",
    Description = "Activo por defecto (Protección contra inactividad)",
    Default = true
}, function(state)
    print("Anti-AFK state:", state)
end)

FarmingTab:AddSection("Farming OP")

toggle500Ref = FarmingTab:CreateToggle({
    Name = "OP Farm (500 Rep/s)",
    Description = "Velocidad estándar: 500 repeticiones por segundo",
    Default = false
}, function(state)
    FastFarm500 = state
    if state then 
        FastFarm2k = false 
    end
end)

toggle2kRef = FarmingTab:CreateToggle({
    Name = "OP Farm (2k Rep/s)",
    Description = "Velocidad rápida: 2,000 repeticiones por segundo",
    Default = false
}, function(state)
    FastFarm2k = state
    if state then 
        FastFarm500 = false 
    end
end)

RebirthTab:AddSection("Rebirth")

RebirthTab:CreateToggle({
    Name = "Auto Rebirth",
    Description = "Rebirth cuando alcanzas la fuerza requerida",
    Default = false
}, function(state)
    AutoRebirth = state
end)

RebirthTab:AddSection("Fast Rebirth")

RebirthTab:CreateToggle({
    Name = "Fast Rebirth",
    Description = "Speed -> Farm -> Packs -> Rebirth",
    Default = false
}, function(state)
    FastRebirth = state
    if state then 
        FastFarm2k = true 
        FastFarm500 = false
    end
end)
