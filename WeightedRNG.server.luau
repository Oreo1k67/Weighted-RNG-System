--[[ Connected Discord-GitHub
Discord: iccyyeti, Roblox: Sheldonmail]]
--// referencing some variables
local Player = game:GetService("Players") -- this is the player Service where all the players that join the game will be stored game.Players
local replicatedStorage = game:GetService("ReplicatedStorage") -- ReplicatedStorage Service where I store items that wont be in the game unless i call them game.ReplicatedStorage
local tweenService = game:GetService("TweenService") -- TweenService goes from the starting point to the goal using EasingStyles and EasingDirections
local DataStoreService = game:GetService("DataStoreService") -- DataStoreService a roblox service that keeps data for all the players that join, inside, or leaves the game
local SoundService = game:GetService("SoundService") -- SoundService For my Audio
local DataStore = DataStoreService:GetDataStore("production") -- DataStore this is my DataStore for all my players and I can change it up by just switching the name from production to anything else and it will reset
local Display = workspace.RollMachineModel:WaitForChild("DisplayPoint") -- A variable for my RollMachine Model
local prompt = workspace.RollMachineModel.Union.ProximityPrompt -- A proximity prompt that gives the player a oppurtunity to interact with it
local rngSound = SoundService:WaitForChild("rng roll") -- These are Variables for my sounds that were stored in soundService
local rngEnd = SoundService:WaitForChild("rollEnd")
local lever = SoundService:WaitForChild("Lever Flick")
local camera = workspace.Camera -- This controls the player camera
local rollMachine = workspace.RollMachineModel.Union -- The lever variable
local RollCamera = replicatedStorage.RollCamera -- This is a remoteEvent so the server can speak to the client or viceVersa
local Devs = replicatedStorage:WaitForChild("Devs") -- This is where I store all my developers
local ti = TweenInfo.new(0.50, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0) -- This is tweenInfo basically just how you want your part to look when its going from the starting point to its goal

-- this is a table for the goal I made that has Position and Orientatoin/Rotation inside
local goal = {
	Position = Vector3.new(31.262, 1.175, 92.219),
	Orientation = Vector3.new(-18.063, -90, 0)
}
-- A table to see the price on how much you can sell your developer for
local SellValues = {
	Common = 10,
	Uncommon = 25,
	Rare = 75,
	Epic = 200,
	Legendary = 500
}
-- A table that stores your developer Name, the weight of your developer, and your developer rarity
local DevData = {
	{
		Name = "Scripter",
		Weight = 40,
		Rarity = "Common",
	},
	{
		Name = "Builder",
		Weight = 20,
		Rarity = "Uncommon"
	},
	{
		Name = "Animator",
		Weight = 20,
		Rarity = "Rare"
	},
	{
		Name = "UiDesigner",
		Weight = 15,
		Rarity = "Epic"
	},
	{
		Name = "VFXArtist",
		Weight = 5,
		Rarity = "Legendary"
	},
}
Player.PlayerAdded:Connect(function(player) -- when a player joins the game this function runs
	local Inventory = Instance.new("Folder") -- creates a new inventory folder inside each player so I can store all the developers in there
	Inventory.Parent = player
	Inventory.Name = "inventory"
	local Leaderstats = Instance.new("Folder") -- creates a leaderstats Folder inside each player so you can see your data that would be stored in here
	Leaderstats.Parent = player
	Leaderstats.Name = "leaderstats"
	local Coins = Instance.new("IntValue") -- Creates a value that is stored inside the leaderstats folder
	Coins.Name = "coins"
	Coins.Value = 0
	Coins.Parent = Leaderstats
	local data -- nil variable
	local success, errormessage = pcall(function() -- a protected function
		data = DataStore:GetAsync(tostring(player.UserId)) -- Gets each player data through the player user ID
	end)
	if not success then -- this runs if the protected function did not execute successfully
		return warn(errormessage)
	end
	if not data then return	warn("Nothing Saved") end -- another check that checks if the player has any data
	local updatedCoins = data.Coins or 0 -- A variable for how much coins you currently have that is saved
	Coins.Value = updatedCoins -- changes your leaderstats coins value to how much coins you have saved
	local inventoryData -- empty variable
	if typeof(data.Inventory) == "table" then -- runs if data.Inventory is a table
		inventoryData = data.Inventory -- stores data.Inventory in the empty variable
	else
		inventoryData = data -- if the data.Inventory was not a table then the empty variable stores each player data
	end
	for i, v in pairs(inventoryData) do -- go through and collects through every key and value in the inventoryData table
		local dev = Instance.new("Folder") -- creating a new folder
		dev.Name = tostring(i) -- sets the folder Name of a key and key is the name whichever dev that is in data.Invetory
		dev:SetAttribute("Number", v) -- gives the folder a attrivbute to see how much quantity there is of that developer
		dev.Parent = Inventory -- sets the parent to the Inventory folder inside the player
	end
end)



local function SellPrice(devName)
	for _, i in ipairs(DevData) do -- goes through the devData table in order
		if i.Name == devName then -- checks if any of the names of the developers inside the DevData folder equal to the parameters
			local rarity = i.Rarity -- gets the rariity of the developer that passed through the if statement in the table
			local price = SellValues[rarity] -- creates a variable for the price of the developer and checks the SellValues table for the key that i.Rarity equals to
			return price -- send the variable back to the function
		end
	end
end



local function saveInventory(player)
	local inventory:Folder = player:FindFirstChild("inventory") -- looks for the inventory folder inside the player
	if not inventory then return end -- if you cant find the folder dont move forward with the function
	local data = {} -- a empty table
	for _, i in ipairs(inventory:GetChildren()) do -- goes through each child of the inventory folder
		local number = i:GetAttribute("Number") -- gets the attribute of each child that was in the inventory folder
		data[i.Name] = number -- the table create a key for each child that is the child Name and equals it to the childs Attribute Value
	end
	-- a table that stores the Inventory and Coins values
	local saveData = {
		Inventory = data,
		Coins = player:FindFirstChild("leaderstats"):FindFirstChild("coins").Value
	}
 
	local success, errormessage = pcall(function() -- a protected function
		DataStore:SetAsync(tostring(player.UserId), saveData) -- saves the player data with the saveData table
	end)
	if not success then -- if the funnction failed
		warn(errormessage) -- the reason why it failed
		return
	end
end



local function addDev(player:Player, devName)
	local inventory = player:WaitForChild("inventory") -- looks for the inventory folder inside the player
	local dev = inventory:FindFirstChild(devName) -- looks through the inventory to see if any child has the same name as the devName parameter
		if not dev then -- if it couldnt find any
		local Folder = Instance.new("Folder", inventory) -- it creates a new folder inside inventory
		Folder.Name = devName -- sets the folder name to the devName Parameter
		Folder:SetAttribute("Number", 1) -- gives the folder an Staring attribute of 1
		else -- if it does happen to find the devName
	local developer = player:WaitForChild("inventory"):WaitForChild(devName) -- variable for the Folder that was in the Inventory
		local number = developer:GetAttribute("Number") -- Gets the attribute from the child
		developer:SetAttribute("Number", number + 1) -- sets the  attribute to add another + 1 so the quantity can go up
	end
end



local function removeDev(player: Player, devName)
	local inventory = player:WaitForChild("inventory") -- looks for the inventory folder inside the player
	local dev = inventory:FindFirstChild(devName) -- looks through the inventory to see if any child has the same name as the devName parameyer
	if not dev then -- if it couldnt find any
		return warn("You dont have this developer") -- lets the server know he couldnt find a child inside the Inventory folder with the devName paramenter
	end
	-- if it does then it ignores that and continues with the function
	local number = dev:GetAttribute("Number") -- get the attribute of the child in the inventory folder
	if number == 1 then -- if the attribute value == 1 then this runs
		dev:Destroy() -- removes the developer from the inventory Folder
	elseif number == nil then -- if number is equal to nothing
		return warn("You dont have any") -- tells the server he doesnt have any
	elseif number > 1 then -- if number is more than 1
		dev:SetAttribute("Number", number - 1) -- subtracts the attribute value by 1
	else -- if for any reason it doesnt apply to the first three 
		return warn("You have none") -- tells the server it has none
	end
end



local function chooseDev(devData)
	local totalweight = 0 -- creates a variable with a value of 0
	for _, dev in ipairs(devData) do -- goes throguh every dev in order in the parameter table
		totalweight += dev.Weight -- adds the weight of the dev to the total weight variable and it should equal 100
	end
	local roll = math.random() * totalweight -- math.random picks a random number between a minimum number you pick and a maximum number since i didnt put any of those the minimum number is going to be 0 and maximum is going to be 1 and its going to pick a decimal between them and then im going to multiply it by the total number which should be 100 and whatever its equal to would be equal to the roll variable
	local currentWeight = 0 -- creates a variable with the value of 0
	for _, dev in ipairs(devData) do -- goes throguh every dev in order in the parameter table
		currentWeight += dev.Weight -- adds the weight of each dev  in order to the current weight variable
		if roll <= currentWeight then -- if the weight of the first dev is greater than or equal to the number we got from roll than we continue with the function and if its less than then the function adds the next weight of the dev until the if statement is true
			return dev -- whichever dev thats weight make the if statement true gets returned to the function
		end
	end
end



local function Silhouette(model: Model)
	for _, object in ipairs(model:GetDescendants()) do -- goes through every child in the model variable in order
		if object:IsA("BasePart") then -- if the child is a basepart then continue the function
			object.Color = Color3.new(0,0,0) -- changes the child color to black
			object.Material = Enum.Material.SmoothPlastic --  changes the child texture to smooth plastic
		elseif object:IsA("Decal") or object:IsA("Texture") then -- checks whether the child is a decal or texture
			object.Transparency = 1 -- if it is than we make it invisible by setting transparency to 1
		elseif object:IsA("Shirt") or object:IsA("Pants") then -- checks whether the child is a shirt or pants
			object.Color3 = Color3.new(0,0,0) -- if it is than we also make the color of that black
		end
	end
end


local currentDisplay -- a nil variable
local function DisplayDev(devName, silhouette)
	if currentDisplay then -- if the variable is not nil then this runs
		currentDisplay:Destroy() -- destroys the variable reference
	end
	local template = Devs:FindFirstChild(devName) -- goes through the folder with all the developers and try to find the devName parameter
	if not template then return end -- if it couldnt find any developers with that parameter than stops the function
	local dev = template:Clone() -- clones the developer that it found with the devName parameter
	dev:PivotTo(Display.CFrame +  Vector3.new(0,5,0)) -- puts the developer on the platform and add +5 to the Y axis
	dev.Parent = workspace -- sets the clone parent to workspace so you would be able to see it in game
	if silhouette then -- if the 2nd parameter is true then it runs
		Silhouette(dev) -- runs the Silhouette function with the clone dev as the parameter
	end
	
	currentDisplay = dev -- sets the variable to the cloned dev
end



local function playRollingAnimation(winningDev)
	local delayTime = 0.05 -- a variable with a number reference
	
	for rollNumber = 1, 20, 1 do -- a loop that runs 20 times starting from 1 and incrementing by 1
		local randomDev = DevData[math.random(1, #DevData)] -- a variable and the reference gets a random developer bwtween 1 and how much developers i have which is 5 and stores the developer data inside the variable
		DisplayDev(randomDev.Name, true) -- runs the DisplayDev function with the 1st variable being the random developer Name and the 2nd parameter is true
		task.wait(delayTime) -- waits the time that the delayTime variable referenced
		delayTime += 0.015 -- adds to the delay time by 0.015 to make the dev switch gradullay slower
	end
	DisplayDev(winningDev.Name, false) -- whichever developer that is picked runs this functon and doesnt Silhouette so you he shouldnt be all black
end


local rolling = false -- A boolean variable

prompt.Triggered:Connect(function(player) -- a player interacted with the proximity prompt
	
	if rolling then return end -- if the rolling variable = true then the function stops
	tweenService:Create(rollMachine, ti, goal):Play() -- creates a tweenService for the Instance which is the rollMachine it uses ti that we made for the setting we want to use to hit its goal and the goal is the table we made with the Position and Orientation
	RollCamera:FireClient(player) -- Fires a remote event to the client to make the camera smoothly zoom in and pop out at the end
	lever:Play() -- the sound that the lever makes when its interacted with
	local winningDev = chooseDev(DevData) -- a variable and its reference is the function that picked the dev already and returned it to the function
	task.spawn(function() -- runs alongside the other functions when the prompt triggered
		for count = 1,20,1 do -- a loop that runs 20 times and start at 1 and increment by 1 
			rngSound:Play() -- the loop calls play rngSound audio 20 times
			task.wait(.20) -- waits .20 seconds before the sound runs again
		if count == 20 then -- once the count equals 20
			rngEnd:Play() -- the end sound plays
		end
		end
	end)
	rolling = true -- the boolean switches to true
	prompt.Enabled = false -- it disables the prompt so it cant be spammed
	playRollingAnimation(winningDev) -- runs the playRollingAnimation function with the winningDev variable as the parameter
	print(player.Name .. " rolled " .. winningDev.Name) -- the output prints which player rolled which developer
	task.wait(1) -- waits 1 second
	addDev(player, winningDev.Name) -- runs the addDev function with the player as the 1st parameter and the winningDev.Name as the 2nd parameter
	prompt.Enabled = true -- Enables the proximity prompt again
	rolling = false -- switches the boolean variable back to false
end)




replicatedStorage.SellDev.OnServerEvent:Connect(function(player, devName) -- recieves a call from the client through the remote event when the sell button is activated
	if typeof(devName) ~= "string" then return end -- checks if the type of devName is not equal to string and its its not then the function stops
	removeDev(player, devName) -- runs the removeDev function
	local price = SellPrice(devName) -- a variable that has the sellPrice function as the reference and it uses the devName as the parameter
	if typeof(price) ~= "number" then return warn("Price is not valid") end -- checks to see if the type of price is not equal to a number and if its not it warns the server and stop running the function
	local coins = player:WaitForChild("leaderstats"):WaitForChild("coins") -- a variable that reference the coins intvalue from the leaderstats folder
	coins.Value = coins.Value + price -- adds the price to the coins Value
end)




Player.PlayerRemoving:Connect(function(player) -- when a player leaves the game this function runs
	saveInventory(player) -- runs the saveInventory function with the parameter player
end)




game:BindToClose(function() -- if the game is shutting down this function runs
	for _, player in Player:GetPlayers() do -- goes through every player in the Player Service
			saveInventory(player) -- runs the saveinventory function with the parameter player
	end
end)
