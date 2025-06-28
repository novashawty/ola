local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
local Window = ReGui:Window({
	Title = "",
	Size = UDim2.fromOffset(300, 200)
})
--//---------------------------------------------------------------------------------------------------------------

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local backpack = plr:WaitForChild("Backpack")

local coilName = "coil"
local velocidadeAtiva = false
local velocidadeDesejada = 80

Window:Checkbox({
	Value = false,
	Label = "Velocidade",
	Callback = function(self, Value: boolean)
		velocidadeAtiva = Value
	end
})

Window:SliderInt({
	Label = "",
	Minimum = 0,
	Maximum = 80,
	Value = velocidadeDesejada,
	Callback = function(self, value)
		velocidadeDesejada = value
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

local jumpEnabled = false
local jumpPower = 50
Window:Checkbox({
	Value = false,
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
local plr = game.Players.LocalPlayer
local backpack = plr:WaitForChild("Backpack")
local itemsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Items")

Window:Button({
	Text = "Pegar todos os itens",
	Callback = function()
		for _, item in ipairs(itemsFolder:GetChildren()) do
			if item:IsA("Tool") then
				-- Clona o item e coloca no backpack
				local clone = item:Clone()
				clone.Parent = backpack
			end
		end
	end,
})
