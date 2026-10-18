-- 1. Cargas tu librería desde GitHub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Chrismon014/ERDN/refs/heads/main/LibraryERDN"))()

-- 2. LLAMAS A LA FUNCIÓN VISUAL (Esto es lo que hacía falta para que cargue la interfaz)
local Window = Library:CreateWindow({
    Title = "SLK PRIVATE",
    Icon = "rbxassetid://6031097225" -- Imagen para el cuadro minimizado
})

-- 3. Crear las Pestañas (Contenedores internos)
local EntrenamientoTab = Window:CreateTab("Entrenamiento")
local RebirthsTab = Window:CreateTab("Rebirths")

-- 4. Añadir contenido a la pestaña de Entrenamiento
EntrenamientoTab:CreateToggle({
    Name = "OP Strength",
    Default = false
}, function(state)
    getgenv()._AutoRepFarmEnabled = state
end)

EntrenamientoTab:CreateToggle({
    Name = "Eat Protein Egg (30 Min)",
    Default = false
}, function(state)
    getgenv()._AutoEatEnabled = state
end)

-- Contenido de ejemplo para Rebirths
RebirthsTab:CreateToggle({
    Name = "Auto Rebirth (Próximamente)",
    Default = false
}, function(state)
    print("Rebirth estado:", state)
end)
