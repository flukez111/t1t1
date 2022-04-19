local tweenService = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")
local ability = game:GetService("ReplicatedStorage"):FindFirstChild("Ability")
local createLair = game:GetService("ReplicatedStorage").CreateDungeon
local buyItem = game:GetService("ReplicatedStorage").BuyItem
local storeStand = game:GetService("ReplicatedStorage").StoreStand

local spawn, wait = task.spawn, task.wait 
local cam = workspace.Camera

local player = game:GetService("Players").LocalPlayer
local chr = player.Character

clipping = false
function noClip()
	clipping = not clipping
	spawn(function()
		while clipping do
			game:GetService("RunService").Stepped:Wait()
			for _, v in next, chr:GetDescendants() do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end
	end)
end

local function ScaleToOffset(x, y)
	x *= cam.ViewportSize.X
	y *= cam.ViewportSize.Y
	return x, y
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/flukez111/t1t1/main/gui.lua", true))()

local npcFarm = library:CreateWindow("NPC Farm")
local itemFarm = library:CreateWindow("Item Farm")
local standFarm = library:CreateWindow("Stand Farm")
local miscUI = library:CreateWindow("Misc")

local options = {
	npcFarm = {
		abilities = {}
	},
	itemFarm = {},
	standFarm = {}
}

do --update stuff
	local bVelocity = Instance.new("BodyVelocity")
	bVelocity.MaxForce = Vector3.new()
	bVelocity.Velocity = Vector3.new()
	bVelocity.Name = "bV"
	local bAngularVelocity = Instance.new("BodyAngularVelocity")
	bAngularVelocity.AngularVelocity = Vector3.new()
	bAngularVelocity.MaxTorque = Vector3.new()
	bAngularVelocity.Name = "bAV"

	bVelocity:Clone().Parent = chr.HumanoidRootPart
	bAngularVelocity:Clone().Parent = chr.HumanoidRootPart
	player.CharacterAdded:Connect(function(v)
		chr = v
		bVelocity:Clone().Parent = v:WaitForChild("HumanoidRootPart", 9e99)
		bAngularVelocity:Clone().Parent = v:WaitForChild("HumanoidRootPart", 9e99)
	end)
	for _, v in next, game:GetService("Workspace"):GetDescendants() do
		if v:IsA("Seat") then
			v:Destroy()
		end
	end
end
do --npc Farm
	enemies = {
		unpack(game:GetService("Workspace").Alive:GetChildren())
	}
	do--update enemies
		table.remove(enemies, table.find(enemies, chr))
		game:GetService("Workspace").Alive.ChildAdded:connect(function(v)
			table.insert(enemies, v)
		end)
		game:GetService("Workspace").Alive.ChildRemoved:connect(function(v)
			table.remove(enemies, table.find(enemies, v))
		end)
	end
	npcFarm:Section("")
	toggleNPCFarm = npcFarm:Toggle("NPC Farm", {
		location = options.npcFarm,
		flag = "enabled"
	}, function()
		task.spawn(startNpcFarm)
		if options.npcFarm.enabled then
			chr:FindFirstChild("HumanoidRootPart").bV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
			chr:FindFirstChild("HumanoidRootPart").bAV.MaxTorque = Vector3.new(1 / 0, 1 / 0, 1 / 0)
		else
			chr:FindFirstChild("HumanoidRootPart").bV.MaxForce = Vector3.new()
			chr:FindFirstChild("HumanoidRootPart").bAV.MaxTorque = Vector3.new()
		end
	end)
	toggleDungeonFarm = npcFarm:Toggle("Dungeon Farm", {
		location = options.npcFarm,
		flag = "enabledDungeonFarm"
	}, function()
		if options.npcFarm.enabledDungeonFarm then
			task.spawn(startDungeonFarm)
			oldpos = chr:FindFirstChild("HumanoidRootPart").CFrame
			chr:FindFirstChild("HumanoidRootPart").bV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
			chr:FindFirstChild("HumanoidRootPart").bAV.MaxTorque = Vector3.new(1 / 0, 1 / 0, 1 / 0)
		else
			spawn(function()
				wait(3)
				chr:FindFirstChild("HumanoidRootPart").CFrame = oldpos
			end)
			if clipping then
				noClip()
			end
			chr:FindFirstChild("HumanoidRootPart").bV.MaxForce = Vector3.new()
			chr:FindFirstChild("HumanoidRootPart").bAV.MaxTorque = Vector3.new()
		end
		if options.npcFarm.enabled then
			toggleNPCFarm:Set(false)
		end
		if options.itemFarm.enabled then
			toggleItemFarm:Set(false)
		end
	end)
	npcFarm:Section("Options").Self:FindFirstChild("section_lbl").TextColor3 = Color3.new(1, 0.435294, 0)
	local distance = npcFarm:Slider("Distance", {
		location = options.npcFarm,
		flag = "selectedDistance",
		min = 1,
		default = 8,
		max = 20,
	})
	npcFarm:Section("Select NPC/Dungeon").Self:FindFirstChild("section_lbl").TextColor3 = Color3.new(1, 0.435294, 0)
	npcFarm:Dropdown("Enemy", {
		location = options.npcFarm,
		flag = "selectedEnemy",
		list = enemies,
	})
	npcFarm:Dropdown("Dungeon", {
		location = options.npcFarm,
		flag = "selectedDungeon",
		list = {
			unpack(game:GetService("ReplicatedFirst").preloader.Assets:GetChildren())
		}
	})
	npcFarm:Section("Abilities").Self:FindFirstChild("section_lbl").TextColor3 = Color3.new(1, 0.435294, 0)
	npcFarm:Toggle("MB1", {
		location = options.npcFarm.abilities,
		flag = "punch"
	}):Set(true)
	npcFarm:Toggle("E", {
		location = options.npcFarm.abilities,
		flag = "barrage"
	}):Set(true)
	npcFarm:Toggle("R", {
		location = options.npcFarm.abilities,
		flag = "R"
	}):Set(true)
	npcFarm:Toggle("T", {
		location = options.npcFarm.abilities,
		flag = "T"
	}):Set(true)
	npcFarm:Toggle("Y", {
		location = options.npcFarm.abilities,
		flag = "Y"
	})
	npcFarm:Toggle("F", {
		location = options.npcFarm.abilities,
		flag = "F"
	})
	npcFarm:Toggle("H", {
		location = options.npcFarm.abilities,
		flag = "H"
	})
	npcFarm:Toggle("J", {
		location = options.npcFarm.abilities,
		flag = "J"
	})
	npcFarm:Toggle("Z", {
		location = options.npcFarm.abilities,
		flag = "Z"
	})
	npcFarm:Toggle("X", {
		location = options.npcFarm.abilities,
		flag = "X"
	})
	npcFarm:Section("")
end
do --item Farm
	itemFarm:Section("")
	toggleItemFarm = itemFarm:Toggle("Enabled", {
		location = options.itemFarm,
		flag = "enabled"
	}, function()
		spawn(function()
			while options.itemFarm.enabled do
				wait()
				if game:GetService("Workspace"):FindFirstChild("Unusual Arrow") ~= nil or game:GetService("Workspace"):FindFirstChild("Stand Arrow") ~= nil or game:GetService("Workspace"):FindFirstChild("Rokakaka") ~= nil then
					getItems()
				end
			end
		end)
	end)
	itemFarm:Section("Options").Self:FindFirstChild("section_lbl").TextColor3 = Color3.new(1, 0.435294, 0)
	itemFarm:Slider("Speed", {
		location = options.itemFarm,
		flag = "selectedSpeed",
		precise = true,
		min = 0,
		max = 0.5,
		default = 0.05
	})
	itemFarm:Section("")
end
do --stand Farm
	local stands = {}
	local attributes = {}
	configs = {
		{
			"DIO's The World", 
			"Legendary",
		},
		{
			"Jotaro's Star Platinum",
			"Legendary"
		},
		{
			"Star Platinum OVA",
			"Legendary"
		},
		{
			"The World OVA",
			"Legendary"
		},
		{
			"The World",
			"Legendary"
		},
		{
			"Star Platinum",
			"Legendary"
		},
		{
			"Tusk Act 1",
			"Legendary"
		},
	}
	do--add stands & attributes
		local blacklist = {
			[1] = "King Crimson Requiem",
			[2] = "DIO's The World Over Heaven",
			[3] = "Jotaro's Star Platinum Over Heaven",
			[4] = "Silver Chariot Requiem",
			[5] = "Made In Heaven",
			[6] = "Golden Experience Requiem",
			[7] = "The World OVA Over Heaven",
			[8] = "Star Platinum Over Heaven",
			[9] = "The Hand Requiem",
			[10] = "Star Platinum OVA Over Heaven",
			[11] = "The World Over Heaven",
			[12] = "C-Moon",
			[13] = "Tusk Act 2",
			[14] = "Tusk Act 3",
			[15] = "Tusk Act 4",
		}
		for _, v in next, require(game:GetService("Lighting").StandStats) do
			if not table.find(blacklist, v.Name) then
				stands[#stands + 1] = v.Name
			end
		end
		for _, v in next, require(game:GetService("Lighting").AttributeStats) do
			attributes[#attributes + 1] = v.Attribute
		end
	end
	standFarm:Section("")
	toggleStandFarm = standFarm:Toggle("Enabled", {
		location = options.standFarm,
		flag = "enabled",
	}, function()
		spawn(startStandFarm)
		if options.standFarm.enabled and rconsoleclear ~= nil then
			rconsoleclear()
		end
	end)
	standFarm:Section("Prioritize").Self:FindFirstChild("section_lbl").TextColor3 = Color3.new(1, 0.435294, 0)
	standFarm:Dropdown("Prioritize", {
		location = options.standFarm,
		flag = "prioritize",
		list = {
			"Attribute",
			"Stand",
			"Any",
			"Both"
		}
	}):Refresh({
		"Any"
	})
	standFarm:Section("Select Stand").Self:FindFirstChild("section_lbl").TextColor3 = Color3.new(1, 0.435294, 0)
	standFarm:SearchBox("Select Stand", {
		location = options.standFarm,
		flag = "selectedStand",
		list = stands,
	})
	standFarm:SearchBox("Selected Attribute", {
		location = options.standFarm,
		flag = "selectedAttr",
		list = attributes
	})
	standFarm:Button("Add Config", function()
		local stand = standFarm:Section("Stand: " .. tostring(options.standFarm.selectedStand))
		local attr = standFarm:Section("Attribute: " .. tostring(options.standFarm.selectedAttr))
		standFarm:Button("Remove", function(self)
			local cache = {
				tostring(options.standFarm.selectedStand),
				tostring(options.standFarm.selectedAttr)
			}
			stand:Destroy()
			attr:Destroy()
			self:Destroy()
			table.remove(configs, table.find(configs, cache))
		end)
		table.insert(configs, {
			tostring(options.standFarm.selectedStand),
			tostring(options.standFarm.selectedAttr)
		})
	end)
	standFarm:Section("Whitelisted").Self:FindFirstChild("section_lbl").TextColor3 = Color3.new(1, 0.435294, 0)
	for _, v in next, configs do
		local stand = standFarm:Section("Stand: " .. v[1])
		local attr = standFarm:Section("Attribute: " .. v[2])
		standFarm:Button("Remove", function(self)
			local cache = {
				tostring(v[1]),
				tostring(v[2])
			}
			stand:Destroy()
			attr:Destroy()
			self:Destroy()
			table.remove(configs, table.find(configs, cache))
		end)
	end
end
do -- misc
	miscUI:Section("")
	for _,v in next, player.StandSlots:GetChildren() do
		local slot = v.Name:split("Slot")[2]
		local stand = v:FindFirstChild('Stand')
		local attr = v:FindFirstChild('Attribute')

		local button = miscUI:Button(stand.Value .. " | ".. attr.Value, function()
			storeStand:FireServer(tonumber(slot))
		end)
		stand:GetPropertyChangedSignal('Value'):Connect(function()
			attr:GetPropertyChangedSignal('Value'):Wait()
			button.Self:FindFirstChildOfClass('TextButton').Text = stand.Value .. " | ".. attr.Value
		end)
	end
	miscUI:Section("")
end
do --functions
	function useAbilities()
		local function presskey(keyCode, time)
			vim:SendKeyEvent(true, Enum.KeyCode[keyCode], false, game)
			wait(time)
			vim:SendKeyEvent(false, Enum.KeyCode[keyCode], false, game)
		end
		for i, v in next, options.npcFarm.abilities do
			if v == true then
				if tostring(i) == "punch" then
					for i = 1, 3 do
						ability:FireServer("Punch", {})
						wait()
					end
				elseif tostring(i) == "R" then
					ability:FireServer("Heavy Punch", {})
				elseif tostring(i) == "barrage" then
					ability:FireServer("Barrage", {
						true,
						"Hand"
					})
				else
					presskey(i, 0)
				end
			end
		end
	end

	function startNpcFarm()
		while options.npcFarm.enabled do
			wait()
			chr = player.Character
			enemy = options.npcFarm.selectedEnemy
			if chr ~= nil and enemy:FindFirstChild("HumanoidRootPart") ~= nil then
				chr.HumanoidRootPart.CFrame = CFrame.new(enemy.HumanoidRootPart.Position.X, enemy.HumanoidRootPart.Position.Y + options.npcFarm.selectedDistance, enemy.HumanoidRootPart.Position.Z) * CFrame.Angles(-math.rad(90), 0, -math.rad(180))
				if chr:WaitForChild("Summoned").Value == false then
					repeat
						wait(1)
						ability:FireServer("Stand Summon", {})
					until chr:FindFirstChild("Summoned").Value == true and chr:WaitForChild("Stand", 9e9):WaitForChild("HumanoidRootPart") ~= nil
				end
				useAbilities()
				if enemy:FindFirstChild("Humanoid") ~= nil and enemy.Humanoid.Health < 1 then
					for _, v in next, game:GetService("Workspace").Alive:GetChildren() do
						if v:WaitForChild("Humanoid").Health > 0 and tostring(v) == tostring(enemy) then
							options.npcFarm.selectedEnemy = v
							break
						end
					end
				end
			end
		end
	end

	function startDungeonFarm()
		connection = workspace["Dungeons"].ChildAdded:connect(function(v)
			if tostring(v):match(options.npcFarm.selectedDungeon.Name) then
				dungeon = v
				connection:Disconnect()
			end
		end)
		createLair:FireServer(tostring(options.npcFarm.selectedDungeon))
		repeat
			wait()
		until dungeon ~= nil and wait(2)
		while options.npcFarm.enabledDungeonFarm do
			game:GetService("RunService").Stepped:wait()
			if options.npcFarm.enabled then
				toggleNPCFarm:Set(false)
			end 
			if not options.npcFarm.enabledDungeonFarm then
				break
			end
			chr = player.Character
			if chr ~= nil then
				noClip()
				for _, v in next, dungeon:WaitForChild("NPCS", 9e9):GetChildren() do
					local oldParent = v.Parent
					repeat
						if chr:WaitForChild("Summoned").Value == false then
							repeat
								ability:FireServer("Stand Summon", {})
								wait(3)
							until chr:FindFirstChild("Summoned").Value == true and chr:WaitForChild("Stand", 9e9):WaitForChild("HumanoidRootPart") ~= nil
						end 
						if not options.npcFarm.enabledDungeonFarm then
							break
						end
						if 1 > chr:FindFirstChild("Humanoid").Health then
							local chr2 = player.CharacterAdded:Wait()
							print(chr2)
							chr2:WaitForChild("HumanoidRootPart", 9e9):WaitForChild("bV", 9e9).MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
							chr2:WaitForChild("HumanoidRootPart", 9e9):WaitForChild("bAV", 9e9).MaxTorque = Vector3.new(1 / 0, 1 / 0, 1 / 0)
							startDungeonFarm()
							break
						end
						if v == nil or v:FindFirstChild("HumanoidRootPart") == nil then
							return
						end
						local enemy = v
						game:GetService("RunService").Stepped:wait()
						chr.HumanoidRootPart.CFrame = CFrame.new(enemy.HumanoidRootPart.Position.X, enemy.HumanoidRootPart.Position.Y + options.npcFarm.selectedDistance, enemy.HumanoidRootPart.Position.Z) * CFrame.Angles(-math.rad(90), 0, -math.rad(180))
						useAbilities()
					until v.Parent ~= oldParent or 1 > v:WaitForChild("Humanoid").Health 
				end
			end
			if not options.npcFarm.enabledDungeonFarm then
				break
			end
			noClip()
			startDungeonFarm()
			break
		end
	end

	function getItems()
		if options.npcFarm.enabled then
			oldStatus = options.npcFarm.enabled 
			toggleNPCFarm:Set(false)
		end 
		chr:FindFirstChild("HumanoidRootPart").bV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
		chr:FindFirstChild("HumanoidRootPart").bAV.MaxTorque = Vector3.new(1 / 0, 1 / 0, 1 / 0)
		noClip()
		local orig = chr.HumanoidRootPart.CFrame
		for i, v in next, game:GetService("Workspace"):GetChildren() do
			if v:FindFirstChild("Handler") and not v:IsA("Model") and v:FindFirstChildOfClass("TouchTransmitter") then
				repeat
					if not options.itemFarm.enabled then
						break
					end
					chr:WaitForChild("HumanoidRootPart", 9e99).CFrame = chr:WaitForChild("HumanoidRootPart", 9e99).CFrame:lerp(CFrame.new(v.Position), options.itemFarm.selectedSpeed)
					game:GetService("RunService").Stepped:Wait()
				until v.Parent ~= workspace
			end
		end
		if oldStatus == true then
			toggleNPCFarm:Set(true)
			oldStatus = nil
		end
		chr.HumanoidRootPart.CFrame = orig
		chr:FindFirstChild("HumanoidRootPart").bV.MaxForce = Vector3.new()
		chr:FindFirstChild("HumanoidRootPart").bAV.MaxTorque = Vector3.new()
		noClip()
	end

	function startStandFarm()
		curr = player.Data.Stand.Value .. "/" .. player.Data.Attribute.Value
		data = curr:split("/")
		local function useItem()
			local useItem = game:GetService("ReplicatedStorage").Useitem
			if data[1] == "None" then
				local arr = player.Backpack:FindFirstChild("Unusual Arrow") or player.Backpack:WaitForChild("Stand Arrow", 9e99)
				chr:WaitForChild("Humanoid", 387420489):EquipTool(arr)
				do
					if not options.standFarm.enabled then
						return
					end
					repeat
						if not options.standFarm.enabled then
							return
						end
						wait()
						useItem:FireServer(arr)
					until player.PlayerGui:FindFirstChild("ItemPrompt") ~= nil and player.PlayerGui.ItemPrompt.Frame:FindFirstChild("Yes") ~= nil
					local itemPrompt = player.PlayerGui:FindFirstChild("ItemPrompt").Frame
					X, Y = ScaleToOffset(itemPrompt.Yes.Position.X.Scale, itemPrompt.Yes.Position.Y.Scale)
					repeat
						if not options.standFarm.enabled then
							return
						end
						wait(1)
						vim:SendMouseButtonEvent(X + (itemPrompt.Yes.AbsoluteSize.X / 2), Y + (itemPrompt.Yes.AbsoluteSize.Y / 2), 0, true, game, 0)
						wait()
						vim:SendMouseButtonEvent(X + (itemPrompt.Yes.AbsoluteSize.X / 2) , Y + (itemPrompt.Yes.AbsoluteSize.Y / 2), 0, false, game, 0)
					until player.PlayerGui:FindFirstChild("ItemPrompt") == nil
				end
			else
				local roka = player.Backpack:WaitForChild("Rokakaka", 9e99)
				chr:WaitForChild("Humanoid", 387420489):EquipTool(roka)
				do
					if not options.standFarm.enabled then
						return
					end
					repeat
						if not options.standFarm.enabled then
							break
						end
						wait()
						useItem:FireServer(roka)
					until player.PlayerGui:FindFirstChild("ItemPrompt") ~= nil and player.PlayerGui.ItemPrompt.Frame:FindFirstChild("Yes") ~= nil
					local itemPrompt = player.PlayerGui:FindFirstChild("ItemPrompt").Frame
					X, Y = ScaleToOffset(itemPrompt.Yes.Position.X.Scale, itemPrompt.Yes.Position.Y.Scale)
					repeat
						if not options.standFarm.enabled then
							break
						end
						wait(1)
						vim:SendMouseButtonEvent(X + (itemPrompt.Yes.AbsoluteSize.X / 2), Y + (itemPrompt.Yes.AbsoluteSize.Y / 2), 0, true, game, 0)
						wait()
						vim:SendMouseButtonEvent(X + (itemPrompt.Yes.AbsoluteSize.X / 2) , Y + (itemPrompt.Yes.AbsoluteSize.Y / 2), 0, false, game, 0)
					until player.PlayerGui:FindFirstChild("ItemPrompt") == nil
				end
			end
		end
		while options.standFarm.enabled do
			curr = tostring(player.Data.Stand.Value) .. "/" .. tostring(player.Data.Attribute.Value)
			data = curr:split("/")
			local console = rconsolewarn or warn 
			console('Got: \n	Stand: '..data[1]..'\n	Attribute: '..data[2])
			wait()
			
			if options.standFarm.prioritize == "Both" then
				for _, v in next, configs do
					if table.find(v, data[1]) and table.find(v, data[2]) then
						if data[1] ~= "None" then 
							console("Got wanted stand, stopping...")
							toggleStandFarm:Set(false)
							options.standFarm.enabled = false
							break
						end
					end
				end
			elseif options.standFarm.prioritize == "Any" then
				for _, v in next, configs do
					if table.find(v, data[1]) or table.find(v, data[2]) then
						if data[1] ~= "None" then 
							console("Got wanted stand, stopping...")
							toggleStandFarm:Set(false)
							options.standFarm.enabled = false
							break
						end
					end
				end
			elseif options.standFarm.prioritize == "Stand" then
				for _, v in next, configs do
					if table.find(v, data[1]) ~= nil then
						if not data[1] ~= "None" then 
							console("Got wanted stand, stopping...")
							toggleStandFarm:Set(false)
							options.standFarm.enabled = false
							break
						end
					end
				end
			elseif options.standFarm.prioritize == "Attribute" then
				for _, v in next, configs do
					if table.find(v, data[2]) ~= nil then
						console("Got wanted attribute, stopping...")
						toggleStandFarm:Set(false)
						options.standFarm.enabled = false
						break
					end
				end
			end
			if options.standFarm.enabled == false then
				break
			end
			useItem()
		end
	end
end
