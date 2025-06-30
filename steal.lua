local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = Workspace.CurrentCamera

local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
local Window = ReGui:Window({
    Title = "",
    Size = UDim2.fromOffset(430, 195)
})

--//---------------------------------------------------------------------------------------------------------------
-- Alertas para nomes específicos

local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local nomesAlvos = {
    "Los Tralaleritos",
    "La Vacca Saturno Saturnita",
    "La Grande Combinasion",
    "Graipuss Medussi",
    "Tralalero Tralala",
    "Odin Din Din Dun"
}

local function verificarETeleportar()
    local encontrados = {}
    for _, nome in ipairs(nomesAlvos) do
        if Workspace:FindFirstChild(nome) then
            table.insert(encontrados, nome)
        end
    end

    if #encontrados > 0 then
        local alertas = {}
        local startY = 100
        for i, nome in ipairs(encontrados) do
            local alerta = Drawing.new("Text")
            alerta.Text = nome
            alerta.Size = 28
            alerta.Center = true
            alerta.Outline = true
            alerta.Font = 2
            alerta.Color = Color3.new(1, 0.2, 0.2)
            alerta.Position = Vector2.new(Camera.ViewportSize.X / 2, startY + (i - 1) * 35)
            alerta.Visible = true
            table.insert(alertas, alerta)
        end

        task.delay(10, function()
            for _, alerta in ipairs(alertas) do
                if alerta then
                    alerta:Remove()
                end
            end
        end)
    elseif _G.serverHopAtivo then
        local player = game.Players.LocalPlayer
        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end
end

verificarETeleportar()

--//---------------------------------------------------------------------------------------------------------------
-- Compra e equipagem de itens

local items = {"Speed Coil", "Invisibility Cloak", "Quantum Cloner"}

local function comprarItens()
    local net = ReplicatedStorage.Packages.Net["RF/CoinsShopService/RequestBuy"]
    for _, itemName in ipairs(items) do
        net:InvokeServer(itemName)
        task.wait(0.5)
    end
end

local function equipItemFromBackpack(itemName)
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local item = backpack:FindFirstChild(itemName)
    if item then
        item.Parent = character
    end
end

comprarItens()
equipItemFromBackpack("Speed Coil")

--//---------------------------------------------------------------------------------------------------------------
-- Controle de velocidade

local velocidadeAtiva = true
local velocidadeDesejada = 80
local coilName = "coil"

Window:Checkbox({
    Value = true,
    Label = "Velocidade",
    Callback = function(self, Value)
        velocidadeAtiva = Value
    end
})

Window:SliderInt({
    Label = "Mola de velocidade",
    Minimum = 0,
    Maximum = 80,
    Value = velocidadeDesejada,
    Callback = function(self, value)
        velocidadeDesejada = value
    end
})

local function aplicaSpeed(hum)
    if hum and hum:IsA("Humanoid") then
        hum.WalkSpeed = velocidadeDesejada
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if velocidadeAtiva and hum.WalkSpeed ~= velocidadeDesejada then
                hum.WalkSpeed = velocidadeDesejada
            end
        end)
    end
end

local function monitorarVelocidade()
    while true do
        task.wait(0.3)
        if not velocidadeAtiva then continue end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool and tool.Name:lower():find(coilName) then
            aplicaSpeed(hum)
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    monitorarVelocidade()
end)
task.spawn(monitorarVelocidade)

--//---------------------------------------------------------------------------------------------------------------
-- Controle de pulo

local jumpEnabled = true
local jumpPower = 80

Window:Checkbox({
    Value = true,
    Label = "Pulo",
    Callback = function(self, Value)
        jumpEnabled = Value
        if Humanoid then
            Humanoid.UseJumpPower = Value
        end
    end
})

Window:SliderInt({
    Label = "",
    Minimum = 0,
    Maximum = 150,
    Value = jumpPower,
    Callback = function(self, value)
        jumpPower = value
    end
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if Humanoid and jumpEnabled then
            Humanoid.JumpPower = jumpPower
        end
    end
end)

--//---------------------------------------------------------------------------------------------------------------
-- Detecção de invisibilidade

local invisStatus = {}
local checkInvisivelAtivo = true

local function tornarVisivel(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not part:IsDescendantOf(character:FindFirstChildOfClass("Accessory")) then
            part.Transparency = 0
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 0
        end
    end
end

local function adicionarNomeFlutuante(character, playerName)
    if character:FindFirstChild("InvisibleNameGui") then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "InvisibleNameGui"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = playerName .. " (Invisível)"
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    billboard.Parent = character
end

local function removerNomeFlutuante(character)
    local gui = character:FindFirstChild("InvisibleNameGui")
    if gui then gui:Destroy() end
end

local function estaInvisivel(character)
    local total = 0
    local invisiveis = 0
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not part:IsDescendantOf(character:FindFirstChildOfClass("Accessory")) then
            total += 1
            if part.Transparency >= 1 then
                invisiveis += 1
            end
        end
    end
    return total > 0 and invisiveis == total
end

local function iniciarLoopInvisibilidade()
    task.spawn(function()
        while checkInvisivelAtivo do
            task.wait(0.3)
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                local character = player.Character
                if not character then continue end
                local estaInvi = estaInvisivel(character)
                local estavaInvi = invisStatus[player] or false
                if estaInvi and not estavaInvi then
                    adicionarNomeFlutuante(character, player.Name)
                    invisStatus[player] = true
                elseif not estaInvi and estavaInvi then
                    removerNomeFlutuante(character)
                    invisStatus[player] = false
                end
            end
        end
        for player, status in pairs(invisStatus) do
            if status and player.Character then
                removerNomeFlutuante(player.Character)
                invisStatus[player] = false
            end
        end
    end)
end

--//---------------------------------------------------------------------------------------------------------------
-- ESP para alvos

local esps = {}

local function getTargetPart(model)
    if model:IsA("Model") then
        if model.PrimaryPart then return model.PrimaryPart end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then return part end
        end
    end
    return nil
end

local function criarESPs()
    for _, esp in ipairs(esps) do
        if esp.Line then esp.Line:Remove() end
        if esp.Text then esp.Text:Remove() end
    end
    esps = {}

    for _, nomeAlvo in ipairs(nomesAlvos) do
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == nomeAlvo then
                local part = getTargetPart(obj)
                if part then
                    local line = Drawing.new("Line")
                    line.Thickness = 2
                    line.Color = Color3.new(1, 1, 1)
                    line.Transparency = 1

                    local nameTag = Drawing.new("Text")
                    nameTag.Size = 32
                    nameTag.Center = true
                    nameTag.Outline = true
                    nameTag.Text = obj.Name
                    nameTag.Color = Color3.new(1, 1, 1)
                    nameTag.Transparency = 1

                    table.insert(esps, {
                        Model = obj,
                        Part = part,
                        Line = line,
                        Text = nameTag
                    })
                end
            end
        end
    end
end

local atualizar = true
RunService.RenderStepped:Connect(function()
    if not atualizar then
        for _, esp in ipairs(esps) do
            esp.Line.Visible = false
            esp.Text.Visible = false
        end
        return
    end

    for _, esp in ipairs(esps) do
        local screenPos = Camera:WorldToScreenPoint(esp.Part.Position)
        if screenPos.Z > 0 then
            esp.Line.Visible = true
            esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
            esp.Line.To = Vector2.new(screenPos.X, screenPos.Y)
            esp.Text.Visible = true
            esp.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
        else
            esp.Line.Visible = false
            esp.Text.Visible = false
        end
    end
end)

Window:Checkbox({
    Value = true,
    Label = "ESP Brainrots",
    Callback = function(_, Value)
        atualizar = Value
        if Value then
            criarESPs()
        else
            for _, esp in ipairs(esps) do
                if esp.Line then esp.Line:Remove() end
                if esp.Text then esp.Text:Remove() end
            end
            esps = {}
        end
    end
})

Window:Checkbox({
    Value = true,
    Label = "Ver invisíveis",
    Callback = function(self, Value)
        checkInvisivelAtivo = Value
        if Value then
            iniciarLoopInvisibilidade()
        end
    end
})

--//---------------------------------------------------------------------------------------------------------------
-- Visualização de tempo nas bases

local plots = Workspace:WaitForChild("Plots")
local clones = {}

Window:Checkbox({
    Value = true,
    Label = "Ver segundos das bases",
    Callback = function(self, Value)
        if Value then
            for _, plot in ipairs(plots:GetChildren()) do
                local successMain, mainPart = pcall(function()
                    return plot.Purchases.PlotBlock.Main
                end)

                if successMain and mainPart and mainPart:IsA("BasePart") then
                    local billboardGui = mainPart:FindFirstChild("BillboardGui")
                    local remainingTime = billboardGui and billboardGui:FindFirstChild("RemainingTime")

                    if remainingTime and remainingTime:IsA("TextLabel") then
                        local newBillboard = Instance.new("BillboardGui")
                        newBillboard.Name = "RemainingTime_Clone"
                        newBillboard.Adornee = mainPart
                        newBillboard.Size = UDim2.new(0, 200, 0, 50)
                        newBillboard.StudsOffset = Vector3.new(0, 5, 0)
                        newBillboard.AlwaysOnTop = true
                        newBillboard.Parent = mainPart

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.new(1, 1, 0)
                        textLabel.TextStrokeTransparency = 0.5
                        textLabel.TextScaled = true
                        textLabel.Font = Enum.Font.SourceSansBold
                        textLabel.Text = remainingTime.Text
                        textLabel.Parent = newBillboard

                        table.insert(clones, newBillboard)

                        task.spawn(function()
                            while textLabel.Parent and remainingTime.Parent do
                                textLabel.Text = remainingTime.Text
                                task.wait(0.2)
                            end
                        end)
                    end
                end

                local successBase, yourBase = pcall(function()
                    return plot.PlotSign:FindFirstChild("YourBase")
                end)

                if successBase and yourBase and yourBase:IsA("BillboardGui") then
                    yourBase.AlwaysOnTop = true
                end
            end
        else
            for _, clone in ipairs(clones) do
                if clone and clone.Parent then
                    clone:Destroy()
                end
            end
            clones = {}

            for _, plot in ipairs(plots:GetChildren()) do
                local successBase, yourBase = pcall(function()
                    return plot.PlotSign:FindFirstChild("YourBase")
                end)

                if successBase and yourBase and yourBase:IsA("BillboardGui") then
                    yourBase.AlwaysOnTop = false
                end
            end
        end
    end
})

--//---------------------------------------------------------------------------------------------------------------
