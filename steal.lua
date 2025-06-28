local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
local Window = ReGui:Window({
	Title = "",
	Size = UDim2.fromOffset(430, 195)
})

--//---------------------------------------------------------------------------------------------------------------

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local backpack = plr:WaitForChild("Backpack")

local coilName = "coil"
local velocidadeAtiva = true
local velocidadeDesejada = 80

Window:Checkbox({
	Value = true,
	Label = "Velocidade",
	Callback = function(self, Value: boolean)
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

Window:Button({
	Text = "Pegar kit",
	Callback = function()
		local items = {"Speed Coil", "Invisibility Cloak", "Quantum Cloner"}

		for _, itemName in ipairs(items) do
    		game:GetService("ReplicatedStorage").Packages.Net["RF/CoinsShopService/RequestBuy"]:InvokeServer(itemName)
    		task.wait(0.5)
		end
		local Players = game:GetService("Players")
		local localPlayer = Players.LocalPlayer

		local function equipItemFromBackpack(itemName)
			local backpack = localPlayer:WaitForChild("Backpack")
			local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

			local item = backpack:FindFirstChild(itemName)
		if item then
			item.Parent = character
		end
		end

	equipItemFromBackpack("Speed Coil")

	end
})

function aplicaSpeed(hum)
	if hum and hum:IsA("Humanoid") then
		hum.WalkSpeed = velocidadeDesejada
		hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if velocidadeAtiva and hum.WalkSpeed ~= velocidadeDesejada then
				hum.WalkSpeed = velocidadeDesejada
			end
		end)
	end
end

function monitorar()
	while true do
		task.wait(0.3)
		if not velocidadeAtiva then continue end

		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local tool = char and char:FindFirstChildOfClass("Tool")

		if tool and tool.Name:lower():find(coilName) then
			aplicaSpeed(hum)
		end
	end
end

plr.CharacterAdded:Connect(function()
	task.wait(0.5)
	monitorar()
end)

task.spawn(monitorar)


--//---------------------------------------------------------------------------------------------------------------

local jumpEnabled = true
local jumpPower = 150
Window:Checkbox({
	Value = true,
	Label = "Pulo",
	Callback = function(self, Value: boolean)
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

local Players = game:GetService("Players")
local invisStatus = {}

local localPlayer = Players.LocalPlayer

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

local function iniciarLoop()
	spawn(function()
		while checkInvisivelAtivo do
			task.wait(0.3)

			for _, player in ipairs(Players:GetPlayers()) do
				if player == localPlayer then
					continue
				end

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

Window:Checkbox({
	Value = true,
	Label = "Ver invisíveis",
	Callback = function(self, Value)
		checkInvisivelAtivo = Value
		if Value then
			iniciarLoop()
		end
	end
})

--//---------------------------------------------------------------------------------------------------------------

local plots = game:GetService("Workspace"):WaitForChild("Plots")

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

						coroutine.wrap(function()
							while textLabel.Parent and remainingTime.Parent do
								textLabel.Text = remainingTime.Text
								task.wait(0.2)
							end
						end)()
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
