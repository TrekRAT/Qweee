local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Qwee Hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Qwee Hub Loading....",
   LoadingSubtitle = "by KLPN",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

--Main
local MainTab = Window:CreateTab("🏠 Home", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

local player = game:GetService("Players").LocalPlayer
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

-- WalkSpeed Input
local WalkSpeedInput = MainTab:CreateInput({
   Name = "WalkSpeed",
   CurrentValue = "",
   PlaceholderText = "Enter Speed",
   RemoveTextAfterFocusLost = false,
   Flag = "input_ws",
   Callback = function(Text)
       local Value = tonumber(Text)
       if humanoid and Value then
           humanoid.WalkSpeed = math.clamp(Value, 1, 350)
       end
   end,
})

-- JumpPower Input
local JumpPowerInput = MainTab:CreateInput({
   Name = "JumpPower",
   CurrentValue = "",
   PlaceholderText = "Enter Power",
   RemoveTextAfterFocusLost = false,
   Flag = "input_jp",
   Callback = function(Text)
       local Value = tonumber(Text)
       if humanoid and Value then
           humanoid.JumpPower = math.clamp(Value, 1, 350)
       end
   end,
})

--Infinity Jump

local localPlayer = game:GetService("Players").LocalPlayer
local userInputService = game:GetService("UserInputService")
local infiniteJumpEnabled = false

local Toggle = MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "infinite_jump_flag",
   Callback = function(Value)
        infiniteJumpEnabled = Value

        if infiniteJumpEnabled then
            -- Powiadomienie o aktywacji
            game.StarterGui:SetCore("SendNotification", {
                Title = "Qwee Hub",
                Text = "Infinite Jump Activated!",
                Duration = 5
            })
        end
   end
})

-- Obsługa skoku
userInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)


-- Noclip

local RunService = game:GetService("RunService")
local localPlayer = game:GetService("Players").LocalPlayer
local noclipLoop

local Toggle = MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "klpn444",
   Callback = function(Value)
        if Value then
            -- Włączanie Noclip
            noclipLoop = RunService.Stepped:Connect(function()
                if localPlayer.Character then
                    for _, part in pairs(localPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Natychmiastowe wyłączenie Noclip
            if noclipLoop then 
                noclipLoop:Disconnect()
                noclipLoop = nil
            end
            
            -- Przywrócenie kolizji od razu po wyłączeniu
            if localPlayer.Character then
                for _, part in pairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
   end
})

--Fly------------------------------------------------------------------------------------------------------------------
local localPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local flyEnabled = false
local flySpeed = 50
local FLY_SPEED_MULTIPLIER = 2
local activeKeys = {}
local bodyVelocity
local bodyGyro
local flyConnection

-- Klawisze sterowania lotem
local flyKeys = {
    Forward = Enum.KeyCode.S,
    Backward = Enum.KeyCode.W,
    Left = Enum.KeyCode.A,
    Right = Enum.KeyCode.D,
    Up = Enum.KeyCode.Space,
    Down = Enum.KeyCode.LeftShift
}

local function getHumanoid()
    return localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function toggleFly()
    flyEnabled = not flyEnabled

    if flyEnabled then
        -- Włączenie lotu
        local humanoid = getHumanoid()
        local rootPart = humanoid and humanoid.RootPart

        if humanoid and rootPart then
            humanoid.PlatformStand = true
            
            -- Tworzenie obiektów fizyki
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 10000
            bodyGyro.D = 100
            bodyGyro.MaxTorque = Vector3.new(20000, 20000, 20000)
            bodyGyro.CFrame = rootPart.CFrame
            bodyGyro.Parent = rootPart
            
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new()
            bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            bodyVelocity.Parent = rootPart
            
            -- Start lotu
            flyConnection = RunService.Heartbeat:Connect(function()
                if not flyEnabled or not bodyVelocity or not bodyGyro then return end
                
                local currentSpeed = flySpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    currentSpeed = flySpeed * FLY_SPEED_MULTIPLIER
                end
                
                -- Kierunek lotu
                local camera = workspace.CurrentCamera
                local cameraCFrame = camera.CFrame
                local direction = Vector3.new()

                if activeKeys[flyKeys.Forward] then direction -= cameraCFrame.LookVector end
                if activeKeys[flyKeys.Backward] then direction += cameraCFrame.LookVector end
                if activeKeys[flyKeys.Left] then direction -= cameraCFrame.RightVector end
                if activeKeys[flyKeys.Right] then direction += cameraCFrame.RightVector end
                if activeKeys[flyKeys.Up] then direction += cameraCFrame.UpVector end
                if activeKeys[flyKeys.Down] then direction -= cameraCFrame.UpVector end

                if direction.Magnitude > 0 then
                    bodyVelocity.Velocity = direction.Unit * currentSpeed
                else
                    bodyVelocity.Velocity = Vector3.new()
                end

                bodyGyro.CFrame = cameraCFrame
            end)
        end
    else
        -- Wyłączenie lotu
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- Obsługa klawiszy
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if flyEnabled and not gameProcessed then
        activeKeys[input.KeyCode] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if flyEnabled then
        activeKeys[input.KeyCode] = nil
    end
end)

-- Tworzenie Toggle dla Fly
local flyToggle = MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "fly_toggle",
    Callback = function(Value)
        toggleFly()
    end
})


---------------------------------------------------Auto Farm-----------------------------------------------------------------------------------------------------------
local AutoTab = Window:CreateTab("👩🏻‍🌾Auto Farm", nil)
local AutoSection = AutoTab:CreateSection("Main")

local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local autoFarmEnabled = false  -- To control the auto-farming loop

-- Lista ore'ów (modele zbierane w grze)
local oreNames = {
    "Crystal Rock", "Gold Rock", "Ice1", "Turquoise Rock", 
    "Topaz Rock", "Titanium Rock", "Green Quartz Rock", "Coal Rock", 
    "Amethyst Rock", "Apatite Rock", "Iron Rock", "Jade Rock", 
    "Rhodonite Rock", "Ruby Rock", "Sapphire Rock", "Tanzanite Rock",
    "Hiddenite Rock", "Olivine Rock", "Sodalite Rock",
}

-- Lista kilofów uporządkowana od najlepszego do najgorszego  
local toolPriority = {
    "Spinel Pick", "Sodalite Pick", "Serpentine Pick", "Olivine Pick",
    "Hiddenite Pick", "Fire Opal Pick", "Obsidian Pick", "Jade Pick",
    "Titanium Pick", "Topaz Pick", "Ruby Pick", "Shell Pick", "Apatite Pick",
    "Tanzanite Pick", "Sapphire Pick", "Green Quartz Pick", "Meteorite Pick",
    "Rhodonite Pick", "Crystal Pick", "Gold Pick", "Iron Pick", "Amethyst Pick",
    "Turquoise Pick", "Stone Pick", "Ice Pick", "Wood Pick"
}
local totalTools = #toolPriority  -- Całkowita liczba narzędzi

-- Funkcja wyszukiwania najlepszego dostępnego kilofa
local function findBestTool()
    for index, toolName in ipairs(toolPriority) do
        local tool = player.Backpack:FindFirstChild(toolName)
        if tool then
            return tool, index
        end
    end
    if player.Character then
        for index, toolName in ipairs(toolPriority) do
            local tool = player.Character:FindFirstChild(toolName)
            if tool then
                return tool, index
            end
        end
    end
    return nil, nil
end

-- Funkcja ustawiająca/wyłączająca noclip (przechodzenie przez przeszkody)
local function setNoclip(enabled)
    for _, part in pairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = not enabled
        end
    end
end

-- Funkcja zamrażająca postać
local function freezeCharacter()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(hrp.Position)
    end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
end

-- Funkcja odmrażająca postać
local function unfreezeCharacter()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
end

-- Funkcja ataku ore
local function attackOre(ore)
    if ore and ore:GetAttribute("Health") then
        local tool, toolIndex = findBestTool()
        if not tool then
            return  -- Jeśli brak narzędzia, przerywamy atak
        end

        -- Obliczanie obrażeń:
        local damageIndex = totalTools - toolIndex + 1
        local damage = 10 + (damageIndex - 1) * 5

        -- Automatyczne wyposażenie narzędzia (jeśli znajduje się w plecaku)
        if tool.Parent == player.Backpack then
            player.Character.Humanoid:EquipTool(tool)
            wait(0.5)
        end

        -- Jeśli ore nie ma PrimaryPart – aktywujemy noclip
        if not ore.PrimaryPart then
            setNoclip(true)
            wait(0.5)
        end

        -- Przeniesienie postaci bliżej ore
        local rootPart = player.Character.HumanoidRootPart
        local orePosition = ore.PrimaryPart and ore.PrimaryPart.Position or ore:GetPivot().Position
        rootPart.CFrame = CFrame.new(orePosition + Vector3.new(0, 5, 0))
        wait(0.5)

        -- Zamrażamy postać w pozycji prostej
        freezeCharacter()

        -- Pętla ataku – jeżeli postać jest za daleko (więcej niż 10 jednostek), przerywamy atak
        while autoFarmEnabled and ore:GetAttribute("Health") > 0 do
            local distance = (rootPart.Position - orePosition).Magnitude
            if distance <= 10 then
                local currentHealth = ore:GetAttribute("Health")
                tool:Activate()
                ore:SetAttribute("Health", currentHealth - damage)
                wait(1)  -- 1-second cooldown after each attack
            else
                break  -- jeżeli jesteśmy za daleko, przerywamy atak
            end
        end

        -- Wyłączamy noclip i odmrażamy postać
        setNoclip(false)
        unfreezeCharacter()

        if ore:GetAttribute("Health") <= 0 then
            ore:Destroy()
        end
    else
        -- Jeżeli ore nie ma atrybutu Health, nic nie robimy
    end
end

-- Funkcja autoFarm – przeszukuje workspace i atakuje znalezione ore
local function autoFarm()
    while autoFarmEnabled do
        local foundOre = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and table.find(oreNames, obj.Name) then
                if not obj.PrimaryPart then
                    setNoclip(true)
                    wait(0.5)
                end

                -- Teleportacja do ore
                player.Character.HumanoidRootPart.CFrame = obj.PrimaryPart and obj.PrimaryPart.CFrame or obj:GetPivot()
                wait(0.3)
                attackOre(obj)
                foundOre = true
                break  -- atakujemy tylko jedno ore na raz
            end
        end
        
        if not foundOre then
            -- Jeśli nie znaleziono ore, teleportacja do bezpiecznego punktu
            local safeSpot = Vector3.new(1141.60205078125, 64.95022583007812, -538.654541015625)  -- Możesz ustawić własną pozycję
            player.Character.HumanoidRootPart.CFrame = CFrame.new(safeSpot)
            wait(1)  -- Oczekiwanie na ponowne przeszukanie
        end
    end
end

-- Function to toggle Auto Farm with the provided callback
if AutoTab and AutoTab.CreateToggle then
    local AutoFarmOreToggle = AutoTab:CreateToggle({
        Name = "Auto Farm Ore",
        CurrentValue = autoFarmEnabled,
        Flag = "AutoFarm_toggled",
        Callback = function(value)
            autoFarmEnabled = value
            if autoFarmEnabled then
                autoFarm()
            else
                -- Jeśli auto farm jest wyłączony, nic nie robimy
            end
        end
    })
end


-----------------------------Auto Pick Up----------------------------------------------------------------------------------------------

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local PICKUP_RANGE = 10
local AUTO_PICKUP_ENABLED = false

-- Pełna lista rud bez "Rock" i "Ore"
local ALL_ORES = {
    "All", "Stone", "Crystal", "Gold", "Ice", "Turquoise", "Topaz", "Titanium", "Green Quartz", "Coal",
    "Amethyst", "Apatite", "Iron", "Jade", "Rhodonite", "Ruby", "Sapphire", "Tanzanite",
    "Hiddenite", "Olivine", "Sodalite", "Serpentine", "Spinel", "Fire Opal", "Obsidian", "Meteorite"
}

local ALLOWED_ORES = {} -- Domyślnie nic nie zbiera

-- Funkcja sprawdzająca, które przedmioty można podnieść
local function findPickableItems()
    local items = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("MeshPart") or obj:IsA("UnionOperation")) and obj:FindFirstChildOfClass("ProximityPrompt") then
            local oreName = obj.Name:gsub(" Rock", ""):gsub(" Ore", "") -- Usuwanie "Rock" i "Ore"
            if ALLOWED_ORES["All"] or ALLOWED_ORES[oreName] then
                table.insert(items, obj)
            end
        end
    end
    return items
end

-- Funkcja aktywująca ProximityPrompt
local function activateProximityPrompt(prompt)
    if prompt.Enabled then
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        prompt:InputHoldEnd()
    end
end

-- Główna pętla zbierania przedmiotów
local lastCheck = 0
runService.Heartbeat:Connect(function(dt)
    if not AUTO_PICKUP_ENABLED then return end

    lastCheck += dt
    if lastCheck < 0.1 then return end -- Ograniczenie do 10 razy na sekundę
    lastCheck = 0

    local character = player.Character
    local humanoidRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRoot then return end

    for _, item in ipairs(findPickableItems()) do
        if (item.Position - humanoidRoot.Position).Magnitude <= PICKUP_RANGE then
            local prompt = item:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                activateProximityPrompt(prompt)
            end
        end
    end
end)

-- Przycisk do włączania/wyłączania auto-pickupu
if AutoTab and AutoTab.CreateToggle then
    AutoTab:CreateToggle({
        Name = "Auto Pick Up Ores",
        CurrentValue = AUTO_PICKUP_ENABLED,
        Flag = "AutoPickupToggle",
        Callback = function(value)
            AUTO_PICKUP_ENABLED = value
            print("Auto pickup:", value and "ENABLED" or "DISABLED")
        end
    })
end

-- Dropdown do wyboru zbieranych przedmiotów
local Dropdown = AutoTab:CreateDropdown({
    Name = "Select Ores",
    Options = ALL_ORES,
    CurrentOption = {}, -- Domyślnie nic nie jest zaznaczone
    MultipleOptions = true, -- Można zaznaczyć wiele opcji
    Flag = "OreSelection",
    Callback = function(selectedOptions)
        -- Aktualizacja listy zbieranych przedmiotów
        ALLOWED_ORES = {}

        if #selectedOptions == 0 then
            -- Jeśli nic nie wybrano, nic nie zbieraj
            print("Ore pickup disabled.")
            return
        end

        if table.find(selectedOptions, "All") then
            -- Jeśli wybrano "All", zbieraj wszystko
            ALLOWED_ORES["All"] = true
        else
            -- W przeciwnym razie, zbieraj tylko wybrane
            for _, ore in ipairs(selectedOptions) do
                ALLOWED_ORES[ore] = true
            end
        end

        print("Updated Ore Selection:", selectedOptions)
    end,
})


--------------------------------------------------------------------------------------------PLayer auto---------------------------------------------------------------

local PlayerTab = Window:CreateTab("🤖 Player", nil) -- Title, Image
local PlayerSection = PlayerTab:CreateSection("Main")



-----------------------------------------ESp--------------------------------

-- Variables
local ESP_ENABLED = false
local textSize = 16
local oreColor = Color3.fromRGB(170, 0, 255)  -- Purple
local playerColor = Color3.fromRGB(0, 255, 0) -- Green
local animalColor = Color3.fromRGB(255, 165, 0) -- Orange
local lineColor = Color3.fromRGB(255, 255, 255) -- White
local lineThickness = 2

-- Store ESP objects for easy cleanup
local espCache = {
    billboards = {},
    lines = {},
    connections = {}
}

-- Improved ESP creation with caching
local function createESP(target, targetType)
    if not target.PrimaryPart then return end

    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = target.PrimaryPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target.PrimaryPart

    -- Create TextLabel
    local label = Instance.new("TextLabel")
    label.Text = target.Name
    label.TextColor3 = (targetType == "ore" and oreColor) or (targetType == "player" and playerColor) or animalColor
    label.BackgroundTransparency = 1
    label.TextSize = textSize
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.SourceSansBold
    label.TextStrokeTransparency = 0.5
    label.Parent = billboard

    -- Create Line
    local line = Instance.new("LineHandleAdornment")
    line.Name = "ESPLine"
    line.Adornee = target.PrimaryPart
    line.Length = 5
    line.Thickness = lineThickness
    line.Color3 = lineColor
    line.ZIndex = 10
    line.Parent = target.PrimaryPart

    -- Store references
    espCache.billboards[target] = billboard
    espCache.lines[target] = line

    -- Add position update connection
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not target.PrimaryPart or not ESP_ENABLED then
            connection:Disconnect()
            return
        end
        
        -- Update line position
        local camera = workspace.CurrentCamera
        if camera then
            line.Length = (target.PrimaryPart.Position - camera.CFrame.Position).Magnitude
        end
    end)

    espCache.connections[target] = connection
end

-- Improved cleanup function
local function clearESP()
    for target, billboard in pairs(espCache.billboards) do
        billboard:Destroy()
    end
    for target, line in pairs(espCache.lines) do
        line:Destroy()
    end
    for target, connection in pairs(espCache.connections) do
        connection:Disconnect()
    end
    
    espCache = {
        billboards = {},
        lines = {},
        connections = {}
    }
end

-- Optimized ESP toggle with option selection
local function toggleESP(option)
    ESP_ENABLED = true
    clearESP()

    -- Ore ESP
    local function handleOre(ore)
        if ore:IsA("Model") then
            createESP(ore, "ore")
        end
    end

    -- Player ESP
    local function handlePlayer(player)
        if player ~= game.Players.LocalPlayer and player.Character then
            createESP(player.Character, "player")
        end
    end

    -- Animal ESP
    local function handleAnimal(animal)
        if animal:IsA("Model") then
            createESP(animal, "animal")
        end
    end

    -- Setup listeners based on selected option
    if option == "Ores" then
        if workspace:FindFirstChild("Ores") then
            workspace.Ores.ChildAdded:Connect(handleOre)
            for _, ore in ipairs(workspace.Ores:GetChildren()) do
                handleOre(ore)
            end
        end
    elseif option == "Players" then
        game.Players.PlayerAdded:Connect(handlePlayer)
        for _, player in ipairs(game.Players:GetPlayers()) do
            handlePlayer(player)
        end
    elseif option == "Animals" then
        if workspace:FindFirstChild("Animals") then
            workspace.Animals.ChildAdded:Connect(handleAnimal)
            for _, animal in ipairs(workspace.Animals:GetChildren()) do
                handleAnimal(animal)
            end
        end
    end
end

-- GUI Player Toggle for ESP
if PlayerTab and PlayerTab.CreateToggle then
    PlayerTab:CreateToggle({
        Name = "Player ESP",
        CurrentValue = ESP_ENABLED,
        Flag = "Player_ESP_Toggle", -- Unique flag for the toggle
        Callback = function(value)
            ESP_ENABLED = value
            print("Player ESP:", value and "ENABLED" or "DISABLED")
            if value then
                toggleESP("Players") -- Enable or disable player ESP based on the toggle
            else
                clearESP() -- Disable all ESP when Player ESP toggle is off
            end
        end
    })
end

-- GUI Dropdown for ESP options
local PlayerDropdown = Tab:CreateDropdown({ 
    Name = "ESP Options", 
    Options = {"Ores", "Players", "Animals"},
    CurrentOption = {"Players"},
    MultipleOptions = false,
    Flag = "ESP_Dropdown",  -- A flag is the identifier for the configuration file
    Callback = function(Options)
        -- The callback function takes place when the selected option is changed
        -- 'Options' is a table of strings for the current selected options
        local selectedOption = Options[1] -- Get the selected option
        print("ESP Option selected: " .. selectedOption)
        toggleESP(selectedOption) -- Toggle the selected ESP option
    end,
})
