-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local DebrisService = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui") -- Added for UI parent

local player = Players.LocalPlayer

-- Main ScreenGui setup for UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LightHub | RFL"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local uiScale = Instance.new("UIScale")
uiScale.Scale = 0.6 -- Reduced scale for a smaller UI
uiScale.Parent = ScreenGui

-- MainFrame (Draggable UI Window)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 700, 0, 500) -- Fixed pixel size
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250) -- Fixed pixel position for centering
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = false
MainFrame.Visible = true -- Main UI is now visible from the start
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- TopBar for Title and Control Buttons
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "Light Hub | V1.0.0"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -190, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local InjectCheatBtn = Instance.new("TextButton")
InjectCheatBtn.Text = "INJECT CHEAT"
InjectCheatBtn.Font = Enum.Font.GothamBold
InjectCheatBtn.TextSize = 16
InjectCheatBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
InjectCheatBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
InjectCheatBtn.Size = UDim2.new(0, 100, 0, 36)
InjectCheatBtn.Position = UDim2.new(1, -190, 0, 0)
InjectCheatBtn.BorderSizePixel = 0
InjectCheatBtn.Parent = TopBar
-- InjectCheatBtn functionality (if any) would be added here

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "_"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 24
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
MinBtn.Size = UDim2.new(0, 36, 0, 36)
MinBtn.Position = UDim2.new(1, -72, 0, 0)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    MinBtn.Text = MainFrame.Visible and "_" or "O"
end)

local ExitBtn = Instance.new("TextButton")
ExitBtn.Text = "X"
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.TextSize = 24
ExitBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
ExitBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
ExitBtn.Size = UDim2.new(0, 36, 0, 36)
ExitBtn.Position = UDim2.new(1, -36, 0, 0)
ExitBtn.BorderSizePixel = 0
ExitBtn.Parent = TopBar
ExitBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tabs Frame (Left Side Navigation)
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 130, 1, -TopBar.Size.Y.Offset)
TabsFrame.Position = UDim2.new(0, 0, 0, TopBar.Size.Y.Offset)
TabsFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Vertical
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
TabListLayout.Padding = UDim.new(0, 2)
TabListLayout.Parent = TabsFrame

-- Define tabs
local tabNames = {
    "Main", "Misc", "Game", "Visuals", "OP", "Config", "GK", "Player", "Methods", "Credits"
}
local tabButtons = {}
local tabFrames = {}
local tabContentScrollingFrames = {} -- New table to hold the ScrollingFrames

-- Function to select a tab (moved outside loop for reusability)
local function selectTab(selectedTabName)
    for tabName, tabFrame in pairs(tabFrames) do
        local isSelected = (tabName == selectedTabName)
        tabFrame.Visible = isSelected
        if isSelected then
            TweenService:Create(tabFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 0}):Play()
        else
            -- Only fade out if currently visible or not fully transparent
            if tabFrame.Visible or tabFrame.BackgroundTransparency == 0 then
                local fadeOutTween = TweenService:Create(tabFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                fadeOutTween:Play()
                fadeOutTween.Completed:Connect(function()
                    tabFrame.Visible = false
                end)
            end
        end

        local button = tabButtons[tabName]
        if button then
            button.BackgroundColor3 = isSelected and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(27, 27, 27) -- More distinct color
        end
    end
end

-- Create tab buttons and content frames
for i, tab in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Name = tab .. "TabButton"
    btn.Text = tab
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BorderSizePixel = 0
    btn.Parent = TabsFrame
    tabButtons[tab] = btn

    local frame = Instance.new("Frame")
    frame.Name = tab .. "ContentFrame"
    frame.Size = UDim2.new(1, -TabsFrame.Size.X.Offset, 1, -TopBar.Size.Y.Offset)
    frame.Position = UDim2.new(0, TabsFrame.X.Offset, 0, TopBar.Size.Y.Offset)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    -- Explicitly set initial visibility
    if tab == "Main" then
        frame.Visible = true
        frame.BackgroundTransparency = 0
    else
        frame.Visible = false
        frame.BackgroundTransparency = 1
    end
    frame.ClipsDescendants = true -- Ensure children are clipped within the frame's bounds
    frame.Parent = MainFrame
    tabFrames[tab] = frame

    -- Create a ScrollingFrame inside each tab content frame
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = tab .. "ContentScrollingFrame"
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated by UIListLayout.AbsoluteContentSize
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Automatically adjust CanvasSize Y
    scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.Parent = frame
    tabContentScrollingFrames[tab] = scrollingFrame -- Store reference

    local ContentListLayout = Instance.new("UIListLayout")
    ContentListLayout.FillDirection = Enum.FillDirection.Vertical
    ContentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ContentListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    ContentListLayout.Padding = UDim.new(0, 8)
    ContentListLayout.Parent = scrollingFrame -- Parent the layout to the ScrollingFrame

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 20)
    contentPadding.PaddingBottom = UDim.new(0, 20)
    contentPadding.PaddingLeft = UDim.new(0, 20)
    contentPadding.PaddingRight = UDim.new(0, 20)
    contentPadding.Parent = scrollingFrame -- Apply padding to the ScrollingFrame's content

    btn.MouseButton1Click:Connect(function()
        selectTab(tab)
    end)
end

-- Character and Player related variables
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

local toggleConnections = {}

-- Configuration Table
local Config = {
    autoGKEnabled = false,
    autoCatchEnabled = false,
    autoCatchDistance = 10,
    ballAimbotEnabled = false,
    ballAimbotSmoothness = 0.1,
    infiniteStaminaEnabled = false,
    antiAnkleEnabled = false,
    antiSlowdownEnabled = false,
    speedValue = 16,
    antiShieldEnabled = false,
    fovValue = 80,
    lastFovValue = 80,
    lastWalkSpeed = 16,
    lastJumpPower = 50,
    walkFlingEnabled = false,
    ragdollEnabled = false, -- Will be managed by the new ragdoll system
    lagBallEnabled = false, -- Used for Ball Freeze (keybind Q)
    ballGravityEnabled = false,
    ballGravityStrength = 196.2,
    antiGoalEnabled = false,
    pitchPosition = Vector3.new(0, 5, 0),
    infiniteReachEnabled = false,
    studReachV2Enabled = false,
    studReachV2Range = 10,
    ballPredictorEnabled = false,
    autoFreekickEnabled = false,
    freekickGoalSpeedMultiplier = 2.0,
    freekickShotPower = 300,
    freekickShotHeight = 100,
    knuckleballEnabled = false,
    knuckleballHeight = 50,
    knuckleballSpeed = 50,
    autoGoalEnabled = false,
    autoGoalSpeed = 100,
    autoGoalHeight = 100,
    curvePowerEnabled = false,
    curvePowerValue = 100,
    curveHeightValue = 50,
    ronaldoShotPowerEnabled = false,
    ronaldoShotPowerStrength = 300,
    ronaldoShotHeight = 100,
    antiAfkEnabled = false,
    ragdollAuraEnabled = false,
    unragdollAuraEnabled = false,
    antiFoulEnabled = false,
    antiOffsideEnabled = false,
    antiBarriersEnabled = false,
    maxVelocity = 200, -- Shot Power (Velocity)
    yAxisMultiplier = 1, -- Shot Power (Height)
    auraRadius = 15, -- Default aura radius for ragdoll/unragdoll aura
    kickActivationDistance = 5, -- Default distance for kick activation
    goalTargetEnabled = false, -- New: Toggle for 2D goal targeting
    goalTarget2D = Vector2.new(0.5, 0.5), -- New: Relative 2D position (0-1, 0-1) on the goal
    goalTargetShotSpeed = 100, -- New: Speed for goal target shots
    telekenisisEnabled = false, -- Added from my previous script
    shieldBallEnabled = false, -- Added from my previous script
    shieldBallOffsetX = 0, -- Added from my previous script
    shieldBallOffsetY = -2, -- Added from my previous script
    shieldBallOffsetZ = -1, -- Added from my previous script
    speedBoostEnabled = false, -- Added from my previous script
    walkSpeedValue = 16, -- Added from my previous script
    mouseClickTPEnabled = false, -- Added from my previous script
    -- New: Modified Infinite Reach specific config
    modifiedInfiniteReachEnabled = false,
    -- New: Recommended Reach specific config
    recommendedReachEnabled = false,
    recommendedReachX = 5,
    recommendedReachY = 5,
    recommendedReachZ = 5,
}

local autoCatchConnection = nil
local ballGravityForce = nil
local knuckleballWobbleEffectConnection = nil
local autoGoalAnimationConnection = nil
local curveBodyAngularVelocity = nil
local ballFreezeKeybindConnection = nil
local predictionLine = nil
local trackedBall = nil
local ballState = { isPaused = false, originalProperties = nil }
local antiBarrierOriginalProperties = {}
local antiOutConnection = nil
local deleteBarrierConnection = nil
local gkReachConnection = nil
local reachVisualizerBox = nil
local speedBoostConnection = nil
local magnetModeConnection = nil
local aimbotCameraConnection = nil
local fpsBoostConnection = nil
local antiAfkConnection = nil
local ragdollAuraConnection = nil
local unragdollAuraConnection = nil
local mouseClickTPConnection = nil -- Added from my previous script
local infiniteStaminaConnection = nil -- Added from my previous script
local telekenisisLoopConnection = nil -- Added from my previous script
local telekinesisMouseClickConnection = nil -- Added from my previous script
local shieldBallConnection = nil -- Added from my previous script

-- Variables for the integrated main reach logic (retained from your script)
local workspaceFolder = Workspace.game
local sharedFolder = ReplicatedStorage:WaitForChild("network"):WaitForChild("Shared")
local weatherRemote = sharedFolder:WaitForChild("hi") -- Assuming "hi" is your weather remote
local targetFolderName = "Found"
local parentFolderName = "Here"
local reachenabled = false -- This is now managed by Config.reachenabled
local reachX = 17.5 -- Managed by Config.reachX
local reachY = 17.5 -- Managed by Config.reachY
local reachZ = 17.5 -- Managed by Config.reachZ
local offsetX = 0 -- Managed by Config.offsetX
local offsetZ = 0 -- Managed by Config.offsetZ
local showVisualizer = false -- This is not used, Config.hitboxTransparency controls visibility
local hitboxPart = nil
local cachedball = nil
local lastCheckTime = 0
local ballCheckInterval = 0.1
local lastPrintTime = 0
local targetcolor = BrickColor.new(Color3.fromRGB(237, 234, 234))
local hitboxTransparency = 0.5 -- Managed by Config.hitboxTransparency
local hitboxMaterial = Enum.Material.ForceField -- Managed by Config.hitboxMaterial

-- For Auto Goal path visualization (retained)
local pathMarkers = {}
local pathColor = Color3.fromRGB(96, 205, 255)
local pathTransparency = 0
local touchedBalls = {}

-- Corner positions - These represent the real 3D corners of the goals.
-- They are crucial for mapping 2D goal target to 3D space.
local cornerPositions = {
    ["Away Top Left"] = CFrame.new(13, 7.9000001, 359.299988, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Away Top Right"] = CFrame.new(-13.8999996, 7.9000001, 359.299988, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Home Top Left"] = CFrame.new(-13.8999996, 9.60000038, -354.700012, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Home Top Right"] = CFrame.new(13.8000002, 9.60000038, -354.700012, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}
-- Approx goal dimensions for mapping 2D to 3D
local GOAL_WIDTH_STUD = 27.9 -- approx abs(13 - (-13.8999996))
local GOAL_HEIGHT_STUD = 8 -- from 0 to 8 studs high for a shot on goal

-- UI Elements for Goal Target (from your script)
local goalBallIndicator = nil

-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
-- ! MODIFIED INFINITE REACH SPECIFIC VARIABLES AND FUNCTIONS !
-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
local MODIFIED_REACH_TARGET_PART_NAME = "lIIllIIllIIIllIllIIllIIllIIIlIllIIIIlIIIlIlIlllIlIIIlIllllIllIIIllIIll"
local MODIFIED_REACH_TARGET_FOLDER_NAME = "game" -- As requested, the folder is "game"

local modifiedReach_currentTarget = nil
local modifiedReach_highlightPart = nil
local modifiedReach_renderSteppedConnection = nil
local modifiedReach_inputBeganConnection = nil

--- Checks if a given part matches the specific criteria (name and parent folder).
-- This function traverses up the hierarchy to find if the part is a descendant
-- of a folder with the MODIFIED_REACH_TARGET_FOLDER_NAME.
-- @param part BasePart The part to check.
-- @return boolean True if the part matches the criteria, false otherwise.
local function doesPartMatchModifiedReachCriteria(part)
    -- Ensure the part is a BasePart or a MeshPart/UnionOperation (which inherit from BasePart)
    if not (part and (part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation"))) then
        return false
    end

    -- Check if the part's name matches the target name
    if part.Name ~= MODIFIED_REACH_TARGET_PART_NAME then
        return false
    end

    -- Traverse up the hierarchy to find if any ancestor is the target folder
    local currentParent = part.Parent
    while currentParent do
        if currentParent.Name == MODIFIED_REACH_TARGET_FOLDER_NAME and currentParent:IsA("Folder") then
            return true -- Found the target folder as an ancestor
        end
        currentParent = currentParent.Parent
    end

    return false -- Did not find the target folder in the ancestry
end

--- Initializes the highlight part for Modified Infinite Reach.
local function initializeModifiedReachHighlight()
    if not modifiedReach_highlightPart then
        modifiedReach_highlightPart = Instance.new("Part")
        modifiedReach_highlightPart.Name = "ModifiedReachHighlight"
        modifiedReach_highlightPart.Transparency = 0.7
        modifiedReach_highlightPart.CanCollide = false
        modifiedReach_highlightPart.Anchored = true
        modifiedReach_highlightPart.BrickColor = BrickColor.new("Really blue")
        modifiedReach_highlightPart.Size = Vector3.new(1, 1, 1) -- Will be resized to fit target
        modifiedReach_highlightPart.Parent = nil -- Start hidden
        modifiedReach_highlightPart.ZIndex = 10 -- Ensure it renders on top
        warn("Modified Infinite Reach: Highlight part created.")
    end
end

--- Performs the raycast for Modified Infinite Reach and updates the target.
local function updateModifiedReach()
    if not Workspace.CurrentCamera or not character or not humanoidRootPart then return end

    local rayOrigin = Workspace.CurrentCamera.CFrame.Position
    local rayDirection = Workspace.CurrentCamera.CFrame.LookVector * math.huge -- Infinite distance

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character} -- Ignore player's own character
    raycastParams.IgnoreWater = true

    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    local newTarget = nil
    if raycastResult and raycastResult.Instance then
        local hitPart = raycastResult.Instance
        if doesPartMatchModifiedReachCriteria(hitPart) then
            newTarget = hitPart
        end
    end

    -- Update the current target and visual highlight
    if newTarget ~= modifiedReach_currentTarget then
        modifiedReach_currentTarget = newTarget

        if modifiedReach_currentTarget then
            -- Show highlight
            modifiedReach_highlightPart.Size = modifiedReach_currentTarget.Size
            modifiedReach_highlightPart.CFrame = modifiedReach_currentTarget.CFrame
            modifiedReach_highlightPart.Parent = Workspace
            warn("Modified Infinite Reach: Targeted specific part: " .. modifiedReach_currentTarget.Name)
        else
            -- Hide highlight
            if modifiedReach_highlightPart.Parent then
                modifiedReach_highlightPart.Parent = nil
            end
        end
    end
end

--- Handles player input (e.g., mouse click) to "affect" the targeted part for Modified Infinite Reach.
local function handleModifiedReachClick(inputObject, gameProcessedEvent)
    -- Only process if the game hasn't already handled it (e.g., UI click)
    if gameProcessedEvent then return end

    -- Check for left mouse button click (or touch tap)
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or
       inputObject.UserInputType == Enum.UserInputType.Touch then

        if modifiedReach_currentTarget then
            warn("--- MODIFIED INFINITE REACH: ACTING ON TARGETED PART ---")
            warn("Attempting to affect: " .. modifiedReach_currentTarget.Name)

            -- ! YOUR DESIRED ACTION ON THE PART GOES HERE !
            -- For demonstration, let's toggle its transparency and color
            modifiedReach_currentTarget.Transparency = modifiedReach_currentTarget.Transparency == 0 and 0.5 or 0
            modifiedReach_currentTarget.BrickColor = BrickColor.random()

            warn("Action performed on " .. modifiedReach_currentTarget.Name)
        else
            warn("Modified Infinite Reach: No valid target found.")
        end
    end
end

-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
-- ! END MODIFIED INFINITE REACH SPECIFIC FUNCTIONS !
-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
-- ! RECOMMENDED REACH SPECIFIC VARIABLES AND FUNCTIONS !
-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
local RecommendedReachData = {
    collidePart = nil,
    originalProperties = nil,
    updateConnection = nil,
}

--- Toggles the Recommended Reach feature on or off.
-- When enabled, it finds the "Collide" part in the player's character,
-- modifies its properties (material, transparency, massless, canCollide),
-- and sets its size based on the configured X, Y, Z values.
-- When disabled, it reverts the "Collide" part's properties to their original state.
-- @param state boolean True to enable, false to disable.
local function toggleRecommendedReach(state)
    Config.recommendedReachEnabled = state

    -- Disconnect any existing update connection
    if RecommendedReachData.updateConnection then
        RecommendedReachData.updateConnection:Disconnect()
        RecommendedReachData.updateConnection = nil
    end

    if state then
        -- Find the "Collide" part in the player's character
        RecommendedReachData.collidePart = character:FindFirstChild("Collide")
        if not RecommendedReachData.collidePart then
            warn("Recommended Reach: 'Collide' part not found in character. Disabling feature.")
            Config.recommendedReachEnabled = false -- Turn off toggle if part not found
            return
        end

        -- Store original properties of the "Collide" part for reversion
        RecommendedReachData.originalProperties = {
            Material = RecommendedReachData.collidePart.Material,
            Transparency = RecommendedReachData.collidePart.Transparency,
            Massless = RecommendedReachData.collidePart.Massless,
            CanCollide = RecommendedReachData.collidePart.CanCollide,
            Size = RecommendedReachData.collidePart.Size,
        }

        -- Apply new properties to the "Collide" part
        RecommendedReachData.collidePart.Material = Enum.Material.ForceField
        RecommendedReachData.collidePart.Transparency = 0
        RecommendedReachData.collidePart.Massless = true
        RecommendedReachData.collidePart.CanCollide = false
        RecommendedReachData.collidePart.Size = Vector3.new(Config.recommendedReachX, Config.recommendedReachY, Config.recommendedReachZ)

        -- Set up a continuous update loop for the part's size, in case sliders are adjusted
        RecommendedReachData.updateConnection = RunService.RenderStepped:Connect(function()
            -- Ensure feature is still enabled and part exists before updating
            if not Config.recommendedReachEnabled or not RecommendedReachData.collidePart or not RecommendedReachData.collidePart.Parent then
                -- If feature disabled or part removed, disconnect and cleanup
                if RecommendedReachData.updateConnection then
                    RecommendedReachData.updateConnection:Disconnect()
                    RecommendedReachData.updateConnection = nil
                end
                return
            end
            -- Update size based on current config values
            RecommendedReachData.collidePart.Size = Vector3.new(Config.recommendedReachX, Config.recommendedReachY, Config.recommendedReachZ)
        end)
        warn("Recommended Reach enabled. 'Collide' part modified.")
    else
        -- Revert properties of the "Collide" part to their original state
        if RecommendedReachData.collidePart and RecommendedReachData.originalProperties then
            RecommendedReachData.collidePart.Material = RecommendedReachData.originalProperties.Material
            RecommendedReachData.collidePart.Transparency = RecommendedReachData.originalProperties.Transparency
            RecommendedReachData.collidePart.Massless = RecommendedReachData.originalProperties.Massless
            RecommendedReachData.collidePart.CanCollide = RecommendedReachData.originalProperties.CanCollide
            RecommendedReachData.collidePart.Size = RecommendedReachData.originalProperties.Size
            warn("Recommended Reach disabled. 'Collide' part reverted.")
        else
            warn("Recommended Reach disabled. 'Collide' part or original properties not found to revert.")
        end
        -- Clear references
        RecommendedReachData.collidePart = nil
        RecommendedReachData.originalProperties = nil
    end
end
-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
-- ! END RECOMMENDED REACH SPECIFIC FUNCTIONS !
-- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


local function getClosestBall()
    local ballsFolder = Workspace:FindFirstChild("game")
    if not ballsFolder then return nil end
    local closestBall
    local shortestDist = math.huge
    for _, item in ipairs(ballsFolder:GetDescendants()) do
        if item:IsA("BasePart") and (item:GetAttribute("networkOwner") or item:GetAttribute("lastTouch")) then
            local dist = (item.Position - humanoidRootPart.Position).Magnitude
            if dist < shortestDist and dist <= 10000 then -- TELEPORT_DISTANCE simplified
                shortestDist = dist
                closestBall = item
            end
        end
    end
    trackedBall = closestBall
    return closestBall
end

local function getBallByName(ballName)
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower() == ballName:lower() then
            return part
        end
    end
    return nil
end

local function getClosestGoal()
    local closestGoal
    local shortestDist = math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("goal") or obj.Name:lower():find("net")) then
            local dist = (obj.Position - humanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closestGoal = obj
            end
        end
    end
    return closestGoal
end

local function runNextRenderStep(callback)
    local connection = RunService.RenderStepped:Connect(function() connection:Disconnect(); callback() end)
end

-- Modified UI element creation functions to parent to the ScrollingFrame
local function addToggle(parentScrollingFrame, label, configTable, configKey, callback)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 250, 0, 32)
    toggle.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 16
    toggle.Text = label .. ": " .. (configTable and (configTable[configKey] and "ON" or "OFF") or (_G[configKey] and "ON" or "OFF"))
    toggle.Parent = parentScrollingFrame -- Parent to ScrollingFrame
    warn(string.format("Added Toggle '%s' to %s. Visible: %s", label, parentScrollingFrame.Name, toggle.Visible))
    local function onToggleClick()
        if configTable then
            configTable[configKey] = not configTable[configKey]
            toggle.Text = label .. ": " .. (configTable[configKey] and "ON" or "OFF")
            if callback then callback(configTable[configKey]) end
        else -- For global variables like 'reachenabled', pass reference directly
            _G[configKey] = not _G[configKey]
            toggle.Text = label .. ": " .. (_G[configKey] and "ON" or "OFF")
            if callback then callback(_G[configKey]) end
        end
    end
    toggle.MouseButton1Click:Connect(onToggleClick)
    return toggle
end

local function addSlider(parentScrollingFrame, label, min, max, configTable, configKey, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    frame.Parent = parentScrollingFrame -- Parent to ScrollingFrame
    warn(string.format("Added Slider Frame for '%s' to %s. Visible: %s", label, parentScrollingFrame.Name, frame.Visible))

    local horizontalLayout = Instance.new("UIListLayout")
    horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
    horizontalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    horizontalLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    horizontalLayout.Padding = UDim.new(0, 5)
    horizontalLayout.Parent = frame

    local labelBox = Instance.new("TextLabel")
    labelBox.Text = label .. ": " .. tostring(string.format("%.1f", (configTable and configTable[configKey] or _G[configKey])))
    labelBox.Font = Enum.Font.Gotham
    labelBox.TextSize = 16
    labelBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelBox.BackgroundTransparency = 1
    labelBox.Size = UDim2.new(1, -70, 1, 0)
    labelBox.Parent = frame
    warn(string.format("  - Added Slider Label '%s' to %s. Visible: %s", label, frame.Name, labelBox.Visible))

    local minus = Instance.new("TextButton")
    minus.Text = "-"
    minus.Size = UDim2.new(0, 32, 1, 0)
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 20
    minus.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    minus.TextColor3 = Color3.fromRGB(255, 255, 255)
    minus.Parent = frame
    warn(string.format("  - Added Slider Minus Button to %s. Visible: %s", frame.Name, minus.Visible))

    local plus = Instance.new("TextButton")
    plus.Text = "+"
    plus.Size = UDim2.new(0, 32, 1, 0)
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 20
    plus.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    plus.TextColor3 = Color3.fromRGB(255, 255, 255)
    plus.Parent = frame
    warn(string.format("  - Added Slider Plus Button to %s. Visible: %s", frame.Name, plus.Visible))

    local function updateSliderValue()
        local currentValue = (configTable and configTable[configKey] or _G[configKey])
        currentValue = math.round(currentValue * 10) / 10
        if configTable then configTable[configKey] = currentValue else _G[configKey] = currentValue end
        labelBox.Text = label .. ": " .. tostring(string.format("%.1f", currentValue))
        if callback then callback(currentValue) end
    end

    minus.MouseButton1Click:Connect(function()
        local currentValue = (configTable and configTable[configKey] or _G[configKey])
        if configTable then configTable[configKey] = math.max(min, currentValue - 0.1) else _G[configKey] = math.max(min, currentValue - 0.1) end
        updateSliderValue()
    end)

    plus.MouseButton1Click:Connect(function()
        local currentValue = (configTable and configTable[configKey] or _G[configKey])
        if configTable then configTable[configKey] = math.min(max, currentValue + 0.1) else _G[configKey] = math.min(max, currentValue + 0.1) end
        updateSliderValue()
    end)

    updateSliderValue()
    return frame
end

local function addButton(parentScrollingFrame, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 250, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = label
    btn.Parent = parentScrollingFrame -- Parent to ScrollingFrame
    warn(string.format("Added Button '%s' to %s. Visible: %s", label, parentScrollingFrame.Name, btn.Visible))
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function addTextbox(parentScrollingFrame, placeholder, defaultText, callback)
    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0, 250, 0, 32)
    textbox.PlaceholderText = placeholder
    textbox.Text = defaultText or ""
    textbox.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 16
    textbox.ClearTextOnFocus = false
    textbox.Parent = parentScrollingFrame -- Parent to ScrollingFrame
    warn(string.format("Added Textbox '%s' to %s. Visible: %s", placeholder, parentScrollingFrame.Name, textbox.Visible))
    -- Corrected 'this.Text' to 'textbox.Text' in the FocusLost callback
    textbox.FocusLost:Connect(function(enterPressed)
        if callback then
            callback(enterPressed, textbox) -- Pass textbox reference to callback
        end
    end)
    return textbox
end

local function addDropdown(parentScrollingFrame, label, options, configTable, configKey, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0, 250, 0, 32)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    dropdownFrame.Parent = parentScrollingFrame -- Parent to ScrollingFrame
    warn(string.format("Added Dropdown Frame for '%s' to %s. Visible: %s", label, parentScrollingFrame.Name, dropdownFrame.Visible))

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextSize = 16
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.Text = label .. ": " .. (configTable and configTable[configKey] or options[1])
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Parent = dropdownFrame
    warn(string.format("  - Added Dropdown Button for '%s' to %s. Visible: %s", label, dropdownFrame.Name, dropdownButton.Visible))

    local currentOptionIndex = 1
    if configTable and configKey and table.find(options, configTable[configKey]) then
        currentOptionIndex = table.find(options, configTable[configKey])
    end

    local function updateDropdownText()
        local selectedValue = options[currentOptionIndex]
        dropdownButton.Text = label .. ": " .. selectedValue
        if configTable and configKey then
            configTable[configKey] = selectedValue
        end
        if callback then callback(selectedValue) end
    end

    dropdownButton.MouseButton1Click:Connect(function()
        currentOptionIndex = currentOptionIndex % #options + 1
        updateDropdownText()
    end)
    updateDropdownText() -- Set initial text
    return dropdownFrame
end

local targetAnimationIds = {}
local function scanToolAnimations()
    local toolsFolder = ReplicatedStorage:FindFirstChild("game") and ReplicatedStorage.game:FindFirstChild("animations") and ReplicatedStorage.game.animations:FindFirstChild("Tools")
    if toolsFolder then
        for _, anim in ipairs(toolsFolder:GetDescendants()) do
            if anim:IsA("Animation") then table.insert(targetAnimationIds, anim.AnimationId) end
        end
    end
end
scanToolAnimations()

local function handleKickAnimationEnd(track)
    local isTargetAnim = false
    for _, animId in ipairs(targetAnimationIds) do
        if track.Animation and track.Animation.AnimationId == animId then isTargetAnim = true; break end
    }
    if not isTargetAnim then return end

    local ball = getClosestBall()
    if not ball then warn("No ball for kick."); return end
    if (ball.Position - humanoidRootPart.Position).Magnitude > Config.kickActivationDistance then warn("Ball too far for kick."); return end

    task.delay(track.Length * 0.9, function()
        if not ball or not ball.Parent then warn("Ball no longer exists for kick."); return end

        -- Prevent conflicting features
        if Config.telekenisisEnabled then warn("Telekinesis is enabled, preventing kick action."); return end
        if Config.shieldBallEnabled then warn("Shield Ball is enabled, preventing kick action."); return end

        local directionToGoal = Vector3.new(0,0,0)
        local targetCFrameForShot = nil
        local playerTeam = player.Team and player.Team.Name

        -- New Goal Target System
        if Config.goalTargetEnabled then
            local goalTopLeft, goalTopRight
            if playerTeam == "Home" or playerTeam == "Home GK" then
                goalTopLeft = cornerPositions["Away Top Left"]
                goalTopRight = cornerPositions["Away Top Right"]
            elseif playerTeam == "Away" or playerTeam == "Away GK" then
                goalTopLeft = cornerPositions["Home Top Left"]
                goalTopRight = cornerPositions["Home Top Right"]
            else
                -- Default to away goal if team is unknown
                goalTopLeft = cornerPositions["Away Top Left"]
                goalTopRight = cornerPositions["Away Top Right"]
            end

            -- Interpolate target position based on 2D goalTarget2D
            local targetHorizontalOffset = (Config.goalTarget2D.X - 0.5) * GOAL_WIDTH_STUD
            local targetVerticalOffset = Config.goalTarget2D.Y * GOAL_HEIGHT_STUD

            -- Calculate a point on the top bar based on horizontal offset
            local topBarMidPoint = goalTopLeft.p:Lerp(goalTopRight.p, 0.5)
            local topBarDirection = (goalTopRight.p - goalTopLeft.p).Unit
            local horizontalTargetPoint = topBarMidPoint - topBarDirection * targetHorizontalOffset

            -- Now add vertical offset (downwards from the top bar)
            local verticalOffsetVector = Vector3.new(0, -targetVerticalOffset, 0)
            local finalTargetPosition = horizontalTargetPoint + verticalOffsetVector

            directionToGoal = (finalTargetPosition - ball.Position).Unit
            ball.AssemblyLinearVelocity = directionToGoal * Config.goalTargetShotSpeed
            warn("Goal Target activated: Shooting ball to calculated 3D position at speed: " .. tostring(Config.goalTargetShotSpeed))

        -- Existing Auto Goal Logic (falls back if Goal Target is not enabled)
        elseif Config.autoGoalEnabled then
            local opponentGoalCorners = {}
            if playerTeam == "Home" or playerTeam == "Home GK" then
                table.insert(opponentGoalCorners, cornerPositions["Away Top Left"])
                table.insert(opponentGoalCorners, cornerPositions["Away Top Right"])
            elseif playerTeam == "Away" or playerTeam == "Away GK" then
                table.insert(opponentGoalCorners, cornerPositions["Home Top Left"])
                table.insert(opponentGoalCorners, cornerPositions["Home Top Right"])
            else
                -- Default to away goal if team is unknown
                table.insert(opponentGoalCorners, cornerPositions["Away Top Left"])
                table.insert(opponentGoalCorners, cornerPositions["Away Top Right"])
            end
            local shortestDistToOpponentGoal = math.huge
            for _, goalCFrame in ipairs(opponentGoalCorners) do
                local dist = (ball.Position - goalCFrame.p).Magnitude
                if dist < shortestDistToOpponentGoal then
                    shortestDistToOpponentGoal = dist
                    targetCFrameForShot = goalCFrame
                end
            end
            if targetCFrameForShot then
                directionToGoal = (targetCFrameForShot.p - ball.Position).Unit
                ball.AssemblyLinearVelocity = directionToGoal * Config.autoGoalSpeed + Vector3.new(0, Config.autoGoalHeight, 0)
                warn("Auto Goal activated: Shooting to closest corner.")
            else
                warn("Auto Goal: Could not find a target goal.")
            end

        -- Other shot power options (if neither Goal Target nor Auto Goal is enabled)
        elseif Config.insaneShotPowerEnabled then
            firetouchinterest(humanoidRootPart, ball, 0) -- Simulate touch
            firetouchinterest(humanoidRootPart, ball, 1) -- Simulate release
            ball.AssemblyLinearVelocity = directionToGoal * Config.maxVelocity + Vector3.new(0, Config.yAxisMultiplier, 0)
            warn("Insane Shot Power active.")
        elseif Config.ronaldoShotPowerEnabled then
            firetouchinterest(humanoidRootPart, ball, 0) -- Simulate touch
            firetouchinterest(humanoidRootPart, ball, 1) -- Simulate release
            ball.AssemblyLinearVelocity = directionToGoal * Config.ronaldoShotPowerStrength + Vector3.new(0, Config.ronaldoShotHeight, 0)
            warn("Ronaldo Shot active.")
        elseif Config.curvePowerEnabled then
            firetouchinterest(humanoidRootPart, ball, 0) -- Simulate touch
            firetouchinterest(humanoidRootPart, ball, 1) -- Simulate release
            ball.AssemblyLinearVelocity = directionToGoal * Config.curvePowerValue + Vector3.new(0, Config.curveHeightValue, 0)
            if curveBodyAngularVelocity then curveBodyAngularVelocity:Destroy() end
            curveBodyAngularVelocity = Instance.new("BodyAngularVelocity"); curveBodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            curveBodyAngularVelocity.AngularVelocity = directionToGoal:Cross(Vector3.new(0,1,0)) * (Config.curvePowerValue / 50)
            curveBodyAngularVelocity.Parent = ball
            warn("Curve Power active!")
            task.delay(1, function() if curveBodyAngularVelocity and curveBodyAngularVelocity.Parent then curveBodyAngularVelocity:Destroy() end end)
        elseif Config.knuckleballEnabled then
            firetouchinterest(humanoidRootPart, ball, 0) -- Simulate touch
            firetouchinterest(humanoidRootPart, ball, 1) -- Simulate release
            local bodyVelocity = Instance.new("BodyVelocity"); bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bodyVelocity.Parent = ball
            local startTime = tick()
            if knuckleballWobbleEffectConnection then knuckleballWobbleEffectConnection:Disconnect() end
            knuckleballWobbleEffectConnection = RunService.Heartbeat:Connect(function()
                if not Config.knuckleballEnabled or not bodyVelocity.Parent then if bodyVelocity then bodyVelocity:Destroy() end; if knuckleballWobbleEffectConnection then knuckleballWobbleEffectConnection:Disconnect() end; knuckleballWobbleEffectConnection = nil; return end
                local timeElapsed = tick() - startTime; local xWobble = math.sin(timeElapsed * Config.knuckleballSpeed) * (Config.knuckleballSpeed / 20)
                local yWobble = math.cos(timeElapsed * (Config.knuckleballSpeed + 2)) * (Config.knuckleballHeight / 20)
                local zWobble = math.sin(timeElapsed * (Config.knuckleballSpeed + 1)) * (Config.knuckleballSpeed / 20)
                bodyVelocity.Velocity = ball.Velocity + Vector3.new(xWobble, yWobble, zWobble)
            end)
            task.delay(0.6, function() if bodyVelocity and bodyVelocity.Parent then bodyVelocity:Destroy() end; if knuckleballWobbleEffectConnection then knuckleballWobbleEffectConnection:Disconnect() end; knuckleballWobbleEffectConnection = nil; warn("Knuckleball applied.") end)
            warn("Knuckleball active!")
        end
    end)
end
local kickAnimationListenerConnection = humanoid.AnimationPlayed:Connect(handleKickAnimationEnd)

local function enableAutoCatch(state)
    Config.autoCatchEnabled = state
    if autoCatchConnection then autoCatchConnection:Disconnect(); autoCatchConnection = nil end
    if state then
        autoCatchConnection = RunService.Heartbeat:Connect(function()
            if not Config.autoCatchEnabled then return end
            local ball = getClosestBall()
            if ball and player.Character:FindFirstChild("GK") and (humanoidRootPart.Position - ball.Position).Magnitude <= Config.autoCatchDistance then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                warn("Auto Catch active!")
            end
        end)
    end
end

local function enableBallAimbot(state)
    Config.ballAimbotEnabled = state
    if aimbotCameraConnection then aimbotCameraConnection:Disconnect(); aimbotCameraConnection = nil; Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end
    if state then
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        aimbotCameraConnection = RunService.RenderStepped:Connect(function()
            if not Config.ballAimbotEnabled or not character or not humanoidRootPart then return end
            local targetPos = getClosestBall() and getClosestBall().Position or getClosestGoal() and getClosestGoal().Position
            if targetPos then Workspace.CurrentCamera.CFrame = Workspace.CurrentCamera.CFrame:Lerp(CFrame.new(Workspace.CurrentCamera.CFrame.p, targetPos), Config.ballAimbotSmoothness) end
        end)
    end
end

local function updateBallPrediction(state)
    Config.ballPredictorEnabled = state
    if state then
        if not predictionLine then
            predictionLine = Instance.new("Part"); predictionLine.Name = "BallPredictionLine"; predictionLine.Parent = Workspace
            predictionLine.Anchored = true; predictionLine.CanCollide = false; predictionLine.Transparency = 0.5
            predictionLine.BrickColor = BrickColor.new(Color3.fromRGB(0, 255, 0)); predictionLine.FormFactor = Enum.FormFactor.SlightlyRounded; predictionLine.Size = Vector3.new(0.2, 0.2, 0.2)
        end
        toggleConnections.BallPredictionLoop = RunService.RenderStepped:Connect(function()
            if Config.ballPredictorEnabled and getClosestBall() then
                local ball = getClosestBall(); local playerPos = humanoidRootPart.Position; local distance = (ball.Position - playerPos).Magnitude
                predictionLine.CFrame = CFrame.new(playerPos, ball.Position) * CFrame.new(0, 0, -distance / 2); predictionLine.Size = Vector3.new(0.2, 0.2, distance)
            else
                if predictionLine then predictionLine.Parent = nil end
            end
        end)
    else
        if toggleConnections.BallPredictionLoop then toggleConnections.BallPredictionLoop:Disconnect(); toggleConnections.BallPredictionLoop = nil end
        if predictionLine then predictionLine.Parent = nil; predictionLine = nil end
    end
end

local function togglePerformanceMode(state)
    Config.performanceModeEnabled = state
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight") then v.Enabled = not state end
    end
    Lighting.GlobalShadows = not state; UserSettings.GameSettings.RenderingQualityLevel = state and 1 or 10
    local cam = Workspace.CurrentCamera
    if cam then for _, effect in pairs(cam:GetChildren()) do if effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then effect.Enabled = not state end end end
end

local function cleanMemory() if collectgarbage then collectgarbage("collect") end end
local function reducePing() warn("Ping reduction attempted (client-side only). This is usually a spoof.") end

local function enableFPSBoost(state)
    Config.fpsBoostEnabled = state
    if fpsBoostConnection then fpsBoostConnection:Disconnect(); fpsBoostConnection = nil end
    if state then
        fpsBoostConnection = RunService.Heartbeat:Connect(function()
            local pingLabel = player.PlayerGui:FindFirstChild("PingDisplay") or player.PlayerGui:FindFirstChild("NetworkStats") and player.PlayerGui.NetworkStats:FindFirstChild("Ping")
            local fpsLabel = player.PlayerGui:FindFirstChild("FPSCounter") or player.PlayerGui:FindFirstChild("DebugUI") and player.PlayerGui.DebugUI:FindFirstChild("FPS")
            if pingLabel then pingLabel.Text = "Ping: " .. math.random(70, 150) .. "ms (Spoofed)" end
            if fpsLabel then fpsLabel.Text = "FPS: " .. math.random(20, 40) .. " (Spoofed)" end
        end)
    end
end

local function enableInfiniteStamina(state)
    Config.infiniteStaminaEnabled = state
    if infiniteStaminaConnection then infiniteStaminaConnection:Disconnect(); infiniteStaminaConnection = nil end
    if state then
        infiniteStaminaConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local staminaValue = nil
                local playerScripts = player:FindFirstChild("PlayerScripts")
                if playerScripts then
                    local movementController = playerScripts:FindFirstChild("controllers")
                    and playerScripts.controllers:FindFirstChild("movementController")
                    if movementController and movementController:FindFirstChild("stamina") and movementController.stamina:IsA("ValueBase") then
                        staminaValue = movementController.stamina
                    end
                }
                if staminaValue and staminaValue:IsA("ValueBase") then
                    staminaValue.Value = 100
                end
            end)
        end)
        local staminaFrame = player:WaitForChild("PlayerGui"):FindFirstChild("UI") and player.PlayerGui.UI:FindFirstChild("Stamina"); local infiniteFrame = staminaFrame and staminaFrame:FindFirstChild("Infinite")
        if infiniteFrame then infiniteFrame.Visible = true end
    else
        if infiniteStaminaConnection then infiniteStaminaConnection:Disconnect(); infiniteStaminaConnection = nil end
        local staminaFrame = player.PlayerGui:FindFirstChild("UI") and player.PlayerGui.UI:FindFirstChild("Stamina"); local infiniteFrame = staminaFrame and staminaFrame:FindFirstChild("Infinite")
        if infiniteFrame then infiniteFrame.Visible = false end
    end
end

local function teleportToPitch()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        local originalProps = { CanCollide = root.CanCollide, Anchored = root.Anchored }
        root.CanCollide = false; root.Anchored = true; root.CFrame = CFrame.new(Config.pitchPosition); task.wait(0.1)
        root.Anchored = originalProps.Anchored; root.CanCollide = originalProps.CanCollide
    end
end

local function setPitchPositionToCurrent()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        Config.pitchPosition = root.Position
        warn("Pitch position set to current character position: " .. tostring(Config.pitchPosition))
    end
end

local function loadUniversalScripts()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        warn("Attempted to load Universal Scripts (Infinite Yield).")
    end)
end

local function startWalkFling()
    Config.walkFlingEnabled = true
    toggleConnections.WalkFlingLoop = RunService.Heartbeat:Connect(function()
        if not Config.walkFlingEnabled then return end
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then root.Velocity = Vector3.new(100, 50, 100) end
    end)
    warn("Walk Fling started.")
end

local function stopWalkFling()
    Config.walkFlingEnabled = false
    if toggleConnections.WalkFlingLoop then toggleConnections.WalkFlingLoop:Disconnect(); toggleConnections.WalkFlingLoop = nil end
    warn("Walk Fling stopped.")
end

local function updateBallGravity(state, strength)
    Config.ballGravityEnabled = state
    Config.ballGravityStrength = strength or Config.ballGravityStrength

    local ball = getClosestBall()
    if not ball then warn("No ball found to apply gravity."); return end

    if ballGravityForce then ballGravityForce:Destroy(); ballGravityForce = nil end

    if Config.ballGravityEnabled then
        ballGravityForce = Instance.new("BodyForce")
        ballGravityForce.Force = Vector3.new(0, ball:GetMass() * (-Config.ballGravityStrength + Workspace.Gravity), 0)
        ballGravityForce.Parent = ball
        warn("Ball Gravity enabled with strength: " .. tostring(Config.ballGravityStrength))
    else
        warn("Ball Gravity disabled.")
    end
end

local function togglePreventGoals(state)
    Config.antiGoalEnabled = state
    if state then
        warn("Anti-Goal enabled. This feature typically requires server-side interaction or specific game mechanics to work effectively.")
    else
        warn("Anti-Goal disabled.")
    end
end

local function toggleBallFreeze(state)
    Config.lagBallEnabled = state
    if ballFreezeKeybindConnection then ballFreezeKeybindConnection:Disconnect(); ballFreezeKeybindConnection = nil end
    if state then
        ballFreezeKeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if input.KeyCode == Enum.KeyCode.Q and not gameProcessedEvent then
                if not trackedBall or not trackedBall.Parent then warn("No ball to freeze/unfreeze."); return end
                if ballState.isPaused then
                    trackedBall.Anchored = false
                    if ballState.originalProperties then
                        trackedBall.AssemblyLinearVelocity = ballState.originalProperties.AssemblyLinearVelocity
                        trackedBall.AssemblyAngularVelocity = ballState.originalProperties.AssemblyAngularVelocity
                    end
                    ballState.isPaused = false
                    warn("Ball unfreezed.")
                else
                    ballState.originalProperties = {
                        AssemblyLinearVelocity = trackedBall.AssemblyLinearVelocity,
                        AssemblyAngularVelocity = trackedBall.AssemblyAngularVelocity
                    }
                    trackedBall.Anchored = true
                    trackedBall.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    trackedBall.AssemblyAngularVelocity = Vector3.new(0,0,0)
                    ballState.isPaused = true
                    warn("Ball freezed.")
                end
            end
        end)
        warn("Ball Freeze (Q) enabled.")
    else
        warn("Ball Freeze (Q) disabled.")
    end
end

local function updateGoalTargetIndicator(relativeX, relativeY)
    Config.goalTarget2D = Vector2.new(relativeX, relativeY)
    if goalBallIndicator then
        goalBallIndicator.Position = UDim2.new(relativeX, -goalBallIndicator.Size.X.Offset / 2, relativeY, -goalBallIndicator.Size.Y.Offset / 2)
        warn("Goal target indicator updated to: " .. tostring(relativeX) .. ", " .. tostring(relativeY))
    end
end

local function sendWeatherCommand(weatherType)
    if weatherRemote then
        local args = {1000, "editMatchSettings", "idle", "Weather", weatherType}
        pcall(function() weatherRemote:FireServer(args[1], args[2], args[3], args[4], args[5]) end)
        warn("Sent weather command: " .. weatherType)
    else
        warn("Weather remote not found.")
    end
end

local function sendTimeCommand(timeOfDay)
    if weatherRemote then
        local args = {1000, "editMatchSettings", "idle", "Time", timeOfDay}
        pcall(function() weatherRemote:FireServer(args[1], args[2], args[3], args[4], args[5]) end)
        warn("Sent time command: " .. timeOfDay)
    else
        warn("Time remote not found.")
    end
end

local function selectMatchBall(selectedBall)
    -- Assuming 'hi' remote handles ball selection too, or there's another remote for it
    -- Based on your previous script, it seemed to use the same remote
    if weatherRemote then
        local args = {1000, "ballSelection", "idle", selectedBall}
        pcall(function() weatherRemote:FireServer(args[1], args[2], args[3], args[4]) end)
        warn("Selected match ball: " .. selectedBall)
    else
        warn("Ball selection remote not found.")
    end
end

local function toggleAntiAfk(state)
    Config.antiAfkEnabled = state
    if antiAfkConnection then antiAfkConnection:Disconnect(); antiAfkConnection = nil end
    if state then
        antiAfkConnection = RunService.Heartbeat:Connect(function()
            if not Config.antiAfkEnabled then return end
            if Workspace.CurrentCamera then Workspace.CurrentCamera.CFrame = Workspace.CurrentCamera.CFrame * CFrame.Angles(0, 0.0001, 0) end
        end)
        warn("Anti-AFK enabled.")
    else
        warn("Anti-AFK disabled.")
    end
end

local Network = {
    send = function(selfRef, param1, param2, param3, param4, param5)
        pcall(function()
            local targetRemoteEvent = nil
            if sharedFolder then -- Using the global sharedFolder
                for _, service in pairs(sharedFolder:GetChildren()) do
                    if service:IsA("RemoteEvent") then
                        targetRemoteEvent = service
                        break
                    else
                        for _, childOfService in pairs(service:GetChildren()) do
                            if childOfService:IsA("RemoteEvent") then
                                targetRemoteEvent = childOfService
                                break
                            end
                        end
                    end
                    if targetRemoteEvent then break end
                }
            end

            if targetRemoteEvent then
                targetRemoteEvent:FireServer(param1, param2, param3, param4, param5)
            else
                -- Fallback logic for ragdoll/unragdoll if no remote found
                if param3 and param3:IsA("Model") and param3:FindFirstChildOfClass("Humanoid") then
                    local char = param3
                    if param4 == "serverRagdollBinder" or param4 == "clientRagdollBinder" then
                        if param5 == true then
                            char.Humanoid.PlatformStand = true
                            warn("Local ragdoll applied to " .. char.Name)
                        else
                            char.Humanoid.PlatformStand = false
                            char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                            warn("Local unragdoll applied to " .. char.Name)
                        end
                    end
                else
                    warn("Network.send: No target remote found and no local ragdoll fallback for: " .. tostring(param3))
                end
            end
        end)
    end
}

local function ragdollPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        Network.send(nil, 1000, "ballAttribute", targetPlayer.Character, "serverRagdollBinder", true)
        Network.send(nil, 1000, "ballAttribute", targetPlayer.Character, "clientRagdollBinder", true)
        warn("Attempted to ragdoll player: " .. targetPlayer.Name)
    else
        warn("Failed to ragdoll player: Invalid target or character.")
    end
end

local function unragdollPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        Network.send(nil, 1000, "ballAttribute", targetPlayer.Character, "serverRagdollBinder", false)
        Network.send(nil, 1000, "ballAttribute", targetPlayer.Character, "clientRagdollBinder", false)
        warn("Attempted to unragdoll player: " .. targetPlayer.Name)
    else
        warn("Failed to unragdoll player: Invalid target or character.")
    end
end

local function getPlayerNames()
    local playerNames = {};
    for _, pObj in pairs(Players:GetPlayers()) do
        if pObj ~= player then
            table.insert(playerNames, pObj.Name)
        end
    end
    return playerNames
end

local function toggleRagdollAura(state)
    Config.ragdollAuraEnabled = state
    if ragdollAuraConnection then ragdollAuraConnection:Disconnect(); ragdollAuraConnection = nil end
    if state then
        ragdollAuraConnection = RunService.Heartbeat:Connect(function()
            if not Config.ragdollAuraEnabled or not humanoidRootPart then return end
            local radius = Config.auraRadius or 15
            local localPos = humanoidRootPart.Position
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if (otherPlayer.Character.HumanoidRootPart.Position - localPos).Magnitude <= radius then
                        ragdollPlayer(otherPlayer)
                    end
                end
            end
        end)
        warn("Ragdoll Aura enabled.")
    else
        warn("Ragdoll Aura disabled.")
    end
end

local function toggleUnragdollAura(state)
    Config.unragdollAuraEnabled = state
    if unragdollAuraConnection then unragdollAuraConnection:Disconnect(); unragdollAuraConnection = nil end
    if state then
        unragdollAuraConnection = RunService.Heartbeat:Connect(function()
            if not Config.unragdollAuraEnabled or not humanoidRootPart then return end
            local radius = Config.auraRadius or 15
            local localPos = humanoidRootPart.Position
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if (otherPlayer.Character.HumanoidRootPart.Position - localPos).Magnitude < radius then
                        unragdollPlayer(otherPlayer)
                    end
                end
            end
        end)
        warn("Unragdoll Aura enabled.")
    else
        warn("Unragdoll Aura disabled.")
    end
end

local function ragdollReferee()
    local referee = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Name:lower():find("referee") then
            referee = p; break
        end
    end
    if referee and referee.Character and referee.Character:FindFirstChildOfClass("Humanoid") then
        referee.Character.Humanoid.PlatformStand = true
        warn("Ragdolled referee.")
    else
        warn("Referee not found.")
    end
end

local function unragdollReferee()
    local referee = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Name:lower():find("referee") then
            referee = p; break
        end
    end
    if referee and referee.Character and referee.Character:FindFirstChildOfClass("Humanoid") then
        referee.Character.Humanoid.PlatformStand = false
        referee.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        warn("Unragdolled referee.")
    else
        warn("Referee not found.")
    end
end

local function toggleAntiFoul(state)
    Config.antiFoulEnabled = state
    if state then
        warn("Anti-Foul enabled. This feature typically requires server-side interaction to work.")
    else
        warn("Anti-Foul disabled.")
    end
end

local function toggleAntiOffside(state)
    Config.antiOffsideEnabled = state
    if state then
        warn("Anti-Offside enabled. This feature typically requires server-side interaction to work.")
    else
        warn("Anti-Offside disabled.")
    end
end

local function toggleAntiOut(state)
    Config.antiOutEnabled = state
    if antiOutConnection then antiOutConnection:Disconnect(); antiOutConnection = nil end
    if state then
        antiOutConnection = RunService.Heartbeat:Connect(function()
            if not Config.antiOutEnabled then return end
            local outFolder = Workspace:FindFirstChild("system") and Workspace.system:FindFirstChild("out")
            if outFolder then
                outFolder:Destroy()
                warn("Removed 'out' folder.")
            end
        end)
        warn("Anti-Out enabled.")
    else
        warn("Anti-Out disabled.")
    end
end

local function toggleAntiBarriers(state)
    Config.antiBarriersEnabled = state
    if deleteBarrierConnection then deleteBarrierConnection:Disconnect(); deleteBarrierConnection = nil end
    if state then
        deleteBarrierConnection = RunService.Heartbeat:Connect(function()
            if not Config.antiBarriersEnabled then return end
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc:IsA("BasePart") and desc.Name == "barrier" then
                    desc:Destroy()
                    warn("Removed barrier part.")
                end
            end
        end)
        warn("Anti-Barriers enabled.")
    else
        warn("Anti-Barriers disabled.")
    end
end

local function lockAndChangeNames()
    local sharedFolder = ReplicatedStorage:FindFirstChild("network") and ReplicatedStorage.network:FindFirstChild("Shared")
    if sharedFolder then
        for _, child in pairs(sharedFolder:GetChildren()) do
            child.Name = "hi"
            if child:IsA("BasePart") or child:IsA("Model") then child.Anchored = true; child.Locked = true end
        end
        warn("Locked and changed names in Shared folder to 'hi'.")
    else
        warn("Shared folder not found for name locking.")
    end
end

local function blockNameChange()
    local sharedFolder = ReplicatedStorage:FindFirstChild("network") and ReplicatedStorage.network:FindFirstChild("Shared")
    if sharedFolder then
        sharedFolder.ChildAdded:Connect(function(child)
            child.Name = "hi";
            if child:IsA("BasePart") or child:IsA("Model") then child.Anchored = true; child.Locked = true end
            child:GetPropertyChangedSignal("Name"):Connect(function() if child.Name ~= "hi" then child.Name = "hi" end end)
            warn("Blocking name change for new child in Shared folder.")
        end)
        warn("Name change blocking enabled for Shared folder.")
    else
        warn("Shared folder not found for name change blocking.")
    end
end

local function isBallWithinReach(ball)
    if not ball or not ball.Parent then return false end
    local relativePos = humanoidRootPart.CFrame:PointToObjectSpace(ball.Position)
    return (math.abs(relativePos.X - Config.offsetX) <= Config.reachX/2) and
           (math.abs(relativePos.Y) <= Config.reachY/2) and
           (math.abs(relativePos.Z - Config.offsetZ) <= Config.reachZ/2)
end

local function createHitbox()
    if hitboxPart then hitboxPart:Destroy() end
    hitboxPart = Instance.new("Part"); hitboxPart.Name = "ReachHitbox"; hitboxPart.Size = Vector3.new(Config.reachX, Config.reachY, Config.reachZ)
    hitboxPart.Transparency = Config.hitboxTransparency; hitboxPart.Material = Config.hitboxMaterial; hitboxPart.CanCollide = false
    hitboxPart.Massless = true; hitboxPart.Anchored = false; hitboxPart.CastShadow = false; hitboxPart.Parent = Workspace -- Changed parent to Workspace for general visibility

    local weld = Instance.new("Weld"); weld.Name = "HitboxWeld"; weld.Part0 = humanoidRootPart; weld.Part1 = hitboxPart
    weld.C0 = CFrame.new(Config.offsetX, 0, Config.offsetZ); weld.Parent = humanoidRootPart
    warn("Reach hitbox created.")
end

local function destroyHitbox()
    if hitboxPart then
        hitboxPart:Destroy(); hitboxPart = nil
        warn("Reach hitbox destroyed.")
    end
end

local function scanForFriction(folder)
    if not folder then warn("Folder not found for friction scan."); return end
    for _, part in pairs(folder:GetDescendants()) do
        if part:IsA("BasePart") then
            local friction = part:FindFirstChild("friction")
            if friction then
                local parentFolder = part.Parent
                if parentFolder and parentFolder.Name ~= targetFolderName then
                    parentFolder.Name = targetFolderName
                    parentFolder.Changed:Connect(function()
                        if parentFolder.Name ~= targetFolderName then parentFolder.Name = targetFolderName end
                        if parentFolder.Parent and parentFolder.Parent.Name ~= parentFolderName then parentFolder.Parent.Name = parentFolderName end
                    end)
                    warn("Scanned and renamed folder for friction: " .. parentFolder.Name)
                end
            end
        end
    end
end

local function toggleMainReach(state)
    Config.reachenabled = state
    if toggleConnections.ReachLoopConnection then toggleConnections.ReachLoopConnection:Disconnect(); toggleConnections.ReachLoopConnection = nil end
    if state then
        if not hitboxPart then createHitbox() end

        toggleConnections.ReachLoopConnection = RunService.RenderStepped:Connect(function()
            if not Config.reachenabled then return end
            if tick() - lastCheckTime < ballCheckInterval then return end
            lastCheckTime = tick()

            local ball = getBallByName("ball")

            if ball and ball.Parent and isBallWithinReach(ball) then
                firetouchinterest(humanoidRootPart, ball, 0)
                firetouchinterest(humanoidRootPart, ball, 1)
                if tick() - lastPrintTime > 1 then warn("Main Reach: Firing touch interest to ball."); lastPrintTime = tick() end
            end

            if hitboxPart then
                local weld = hitboxPart:FindFirstChild("HitboxWeld")
                if weld then
                    weld.C0 = CFrame.new(Config.offsetX, 0, Config.offsetZ)
                    hitboxPart.Size = Vector3.new(Config.reachX, Config.reachY, Config.reachZ)
                    hitboxPart.Material = Config.hitboxMaterial
                    hitboxPart.Transparency = Config.hitboxTransparency
                else
                    createHitbox() -- Recreate if weld is somehow lost
                end
            else
                createHitbox()
            end
        end)
        warn("Main Reach enabled.")
    else
        destroyHitbox()
        warn("Main Reach disabled.")
    end
end

local function toggleGKToolsOutsideBox(state)
    if not state then
        for _, part in ipairs(Workspace:GetChildren()) do
            if (part.Name:find("_Cloned_" .. player.Name)) then part:Destroy() end
        end
        warn("Removed GK cloned parts.")
        return
    end
    local regions = Workspace:FindFirstChild("regions")
    if not regions then warn("Regions folder not found for GK tools."); return end
    local function duplicateAndWeld(partName)
        local part = regions:FindFirstChild(partName)
        if part then
            local clonedPart = part:Clone(); clonedPart.Name = partName .. "_Cloned_" .. player.Name; clonedPart.Parent = regions
            clonedPart.Size = Vector3.new(10, 10, 10); clonedPart.Anchored = false; clonedPart.Massless = true; clonedPart.Transparency = 1
            local weld = Instance.new("Weld"); weld.Part0 = humanoidRootPart; weld.Part1 = clonedPart; weld.C0 = CFrame.new(); weld.Parent = clonedPart
            warn("Duplicated and welded GK tool: " .. partName)
        else
            warn("GK tool part not found: " .. partName)
        end
    end
    duplicateAndWeld("home"); duplicateAndWeld("away")
    warn("GK Tools Outside Box enabled.")
end

local function toggleGKReach(state)
    Config.gkReachEnabled = state
    if gkReachConnection then gkReachConnection:Disconnect(); gkReachConnection = nil end
    if state then
        gkReachConnection = humanoid.AnimationPlayed:Connect(function(track)
            local id = track.Animation and track.Animation.AnimationId; local isTargetAnim = false
            for _, animId in ipairs(targetAnimationIds) do if id == animId then isTargetAnim = true; break end end
            if isTargetAnim and getClosestBall() then
                local ball = getClosestBall(); local originalCFrame = ball.CFrame; ball.Transparency = 1
                runNextRenderStep(function() ball.CFrame = humanoidRootPart.CFrame; runNextRenderStep(function() ball.Transparency = 0; ball.CFrame = originalCFrame end) end)
                warn("GK Reach: Teleported ball to player during animation.")
            end
        end)
        warn("GK Reach enabled.")
    else
        warn("GK Reach disabled.")
    end
end

local function setPlayerTeam(teamName)
    local teams = game:GetService("Teams"); local targetTeam = teams:FindFirstChild(teamName)
    if targetTeam then
        player.Team = targetTeam
        warn("Player team set to: " .. teamName)
    else
        warn("Team not found: " .. teamName)
    end
end

local function toggleInfiniteReach(state)
    Config.infiniteReachEnabled = state
    if toggleConnections.InfiniteReachLoop then toggleConnections.InfiniteReachLoop:Disconnect(); toggleConnections.InfiniteReachLoop = nil end
    if state then
        toggleConnections.InfiniteReachLoop = humanoid.AnimationPlayed:Connect(function(track)
            local id = track.Animation and track.Animation.AnimationId
            local isTargetAnim = false
            for _, animId in ipairs(targetAnimationIds) do
                if id == animId then
                    isTargetAnim = true
                    break
                end
            end

            if isTargetAnim then
                local ball = getClosestBall()
                if ball then
                    local originalCFrame = ball.CFrame
                    ball.Transparency = 1
                    runNextRenderStep(
                        function()
                            ball.CFrame = humanoidRootPart.CFrame
                            runNextRenderStep(
                                function()
                                    ball.Transparency = 0
                                    ball.CFrame = originalCFrame
                                end
                            )
                        end
                    )
                    warn("Infinite Reach: Teleported ball to player during animation.")
                else
                    warn("Infinite Reach: No ball found for action.")
                end
            end
        end)
        warn("Infinite Reach enabled.")
    else
        warn("Infinite Reach disabled.")
    end
end

local function toggleStudReachV2(state)
    Config.studReachV2Enabled = state
    if toggleConnections.StudReachV2Loop then toggleConnections.StudReachV2Loop:Disconnect(); toggleConnections.StudReachV2Loop = nil end
    if reachVisualizerBox then reachVisualizerBox:Destroy(); reachVisualizerBox = nil end

    if state then
        reachVisualizerBox = Instance.new("Part")
        reachVisualizerBox.Name = "StudReachV2Box"
        reachVisualizerBox.Size = Vector3.new(Config.studReachV2Range * 2, Config.studReachV2Range * 2, Config.studReachV2Range * 2)
        reachVisualizerBox.Position = humanoidRootPart.Position
        reachVisualizerBox.Anchored = true
        reachVisualizerBox.CanCollide = false
        reachVisualizerBox.Transparency = 0.7
        reachVisualizerBox.BrickColor = BrickColor.new(Color3.fromRGB(0, 255, 0))
        reachVisualizerBox.Parent = Workspace
        warn("Stud Reach V2 visualizer created.")

        toggleConnections.StudReachV2Loop = RunService.RenderStepped:Connect(function()
            if not Config.studReachV2Enabled then return end
            if humanoidRootPart then
                reachVisualizerBox.Position = humanoidRootPart.Position
                local ball = getClosestBall()
                if ball then
                    local distance = (ball.Position - humanoidRootPart.Position).Magnitude
                    if distance <= Config.studReachV2Range then
                        local rightBoot = character:FindFirstChild("RightBoot") -- Assuming "RightBoot" is the part that kicks
                        if rightBoot then
                            rightBoot.CFrame = ball.CFrame -- Move boot to ball
                            task.wait(0.05) -- Small delay to simulate kick
                            -- Move boot back to original position relative to HRP
                            rightBoot.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 1) -- Example offset
                            warn("Stud Reach V2: Kicked ball.")
                        else
                            warn("Stud Reach V2: RightBoot not found for kick simulation.")
                        end
                    end
                end
            end
        end)
        warn("Stud Reach V2 enabled.")
    else
        if reachVisualizerBox then reachVisualizerBox:Destroy(); reachVisualizerBox = nil end
        warn("Stud Reach V2 disabled.")
    end
end

local function toggleModifiedInfiniteReach(state)
    Config.modifiedInfiniteReachEnabled = state
    if modifiedReach_renderSteppedConnection then modifiedReach_renderSteppedConnection:Disconnect(); modifiedReach_renderSteppedConnection = nil end
    if modifiedReach_inputBeganConnection then modifiedReach_inputBeganConnection:Disconnect(); modifiedReach_inputBeganConnection = nil end

    if state then
        initializeModifiedReachHighlight() -- Ensure highlight part exists
        modifiedReach_renderSteppedConnection = RunService.Heartbeat:Connect(updateModifiedReach)
        modifiedReach_inputBeganConnection = UserInputService.InputBegan:Connect(handleModifiedReachClick)
        warn("Modified Infinite Reach enabled.")
    else
        if modifiedReach_highlightPart and modifiedReach_highlightPart.Parent then
            modifiedReach_highlightPart.Parent = nil -- Hide highlight
        end
        modifiedReach_currentTarget = nil -- Clear target
        warn("Modified Infinite Reach disabled.")
    end
end

local function disableOtherReachMethods(enabledKey)
    if enabledKey ~= "reachenabled" and Config.reachenabled then
        toggleMainReach(false)
    end
    if enabledKey ~= "infiniteReachEnabled" and Config.infiniteReachEnabled then
        toggleInfiniteReach(false)
    end
    if enabledKey ~= "studReachV2Enabled" and Config.studReachV2Enabled then
        toggleStudReachV2(false)
    end
    if enabledKey ~= "modifiedInfiniteReachEnabled" and Config.modifiedInfiniteReachEnabled then
        toggleModifiedInfiniteReach(false)
    end
    if enabledKey ~= "recommendedReachEnabled" and Config.recommendedReachEnabled then
        toggleRecommendedReach(false)
    end
end

local function toggleSpeedBoost(state)
    Config.speedBoostEnabled = state
    if speedBoostConnection then speedBoostConnection:Disconnect(); speedBoostConnection = nil end
    if state then
        humanoid.WalkSpeed = Config.walkSpeedValue
        speedBoostConnection = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.WalkSpeed ~= Config.walkSpeedValue then
                humanoid.WalkSpeed = Config.walkSpeedValue
            end
        end)
        warn("Speed Boost enabled. WalkSpeed set to: " .. tostring(Config.walkSpeedValue))
    else
        if humanoid then
            humanoid.WalkSpeed = Config.lastWalkSpeed -- Revert to original or default
            warn("Speed Boost disabled. WalkSpeed reverted to: " .. tostring(Config.lastWalkSpeed))
        end
    end
end

local function toggleMouseClickTP(state)
    Config.mouseClickTPEnabled = state
    if mouseClickTPConnection then mouseClickTPConnection:Disconnect(); mouseClickTPConnection = nil end

    if state then
        mouseClickTPConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
                local mouse = player:GetMouse()
                if mouse.Hit and humanoidRootPart then
                    local targetPosition = mouse.Hit.p
                    humanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 2, 0))
                    warn("Teleported to mouse click position.")
                end
            end
        end)
        warn("Mouse Click TP enabled.")
    else
        warn("Mouse Click TP disabled.")
    end
end

local function toggleTelekenisis(state)
    Config.telekenisisEnabled = state
    if telekenisisLoopConnection then telekenisisLoopConnection:Disconnect(); telekenisisLoopConnection = nil end
    if telekinesisMouseClickConnection then telekinesisMouseClickConnection:Disconnect(); telekinesisMouseClickConnection = nil end

    if state then
        local mouse = player:GetMouse()
        telekenisisLoopConnection = RunService.RenderStepped:Connect(function()
            if not Config.telekenisisEnabled then return end
            local ball = getClosestBall()
            if ball and mouse.Hit then
                ball.CFrame = CFrame.new(mouse.Hit.p)
            end
        end)

        telekinesisMouseClickConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if not Config.telekenisisEnabled then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
                local ball = getClosestBall()
                if ball and mouse.Hit then
                    local direction = (mouse.Hit.p - ball.Position).Unit
                    ball.AssemblyLinearVelocity = direction * 500
                    warn("Telekinesis: Fired ball in direction of click.")
                end
            end
        end)
        warn("Telekinesis enabled.")
    else
        warn("Telekinesis disabled.")
    end
end

local function toggleShieldBall(state)
    Config.shieldBallEnabled = state
    if shieldBallConnection then shieldBallConnection:Disconnect(); shieldBallConnection = nil end
    if state then
        shieldBallConnection = RunService.Heartbeat:Connect(function()
            if not Config.shieldBallEnabled then return end
            local ball = getClosestBall()
            if ball and humanoidRootPart then
                local offsetVector = Vector3.new(Config.shieldBallOffsetX, Config.shieldBallOffsetY, Config.shieldBallOffsetZ)
                local targetCFrame = humanoidRootPart.CFrame * CFrame.new(offsetVector)
                ball.CFrame = targetCFrame
                ball.AssemblyLinearVelocity = Vector3.new(0,0,0)
                ball.AssemblyAngularVelocity = Vector3.new(0,0,0)

                local lastTouch = ball:FindFirstChild("lastTouch")
                if lastTouch and lastTouch:IsA("ObjectValue") then
                    lastTouch.Value = player
                end
            end
        end)
        warn("Shield Ball enabled.")
    else
        local ball = getClosestBall()
        if ball then
            ball.AssemblyLinearVelocity = Vector3.new(0,0,0)
            ball.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end
        warn("Shield Ball disabled.")
    end
end

-- UI Population
local function populateUI()
    warn("Populating UI elements for Light Hub...")
    local mainTab = tabContentScrollingFrames["Main"] -- Get the ScrollingFrame
    local miscTab = tabContentScrollingFrames["Misc"]
    local gameTab = tabContentScrollingFrames["Game"]
    local visualsTab = tabContentScrollingFrames["Visuals"]
    local opTab = tabContentScrollingFrames["OP"]
    local configTab = tabContentScrollingFrames["Config"]
    local gkTab = tabContentScrollingFrames["GK"]
    local playerTab = tabContentScrollingFrames["Player"]
    local methodsTab = tabContentScrollingFrames["Methods"]
    local creditsTab = tabContentScrollingFrames["Credits"]

    -- Main Tab
    warn("Adding elements to Main Tab...")
    addToggle(mainTab, "Auto Catch", Config, "autoCatchEnabled", enableAutoCatch)
    addSlider(mainTab, "Auto Catch Distance", 1, 50, Config, "autoCatchDistance", function(val) Config.autoCatchDistance = val end)
    addToggle(mainTab, "Ball Aimbot", Config, "ballAimbotEnabled", enableBallAimbot)
    addSlider(mainTab, "Aimbot Smoothness", 0.01, 1.0, Config, "ballAimbotSmoothness", function(val) Config.ballAimbotSmoothness = val end)
    addToggle(mainTab, "Enable Main Reach (Method 1)", Config, "reachenabled", function(state) disableOtherReachMethods("reachenabled"); toggleMainReach(state) end)
    addSlider(mainTab, "Reach Width (X)", 1, 100, Config, "reachX", function(val) Config.reachX = val end)
    addSlider(mainTab, "Reach Height (Y)", 1, 100, Config, "reachY", function(val) Config.reachY = val end)
    addSlider(mainTab, "Reach Depth (Z)", 1, 100, Config, "reachZ", function(val) Config.reachZ = val end)
    addSlider(mainTab, "Horizontal Offset (X)", -50, 50, Config, "offsetX", function(val) Config.offsetX = val end)
    addSlider(mainTab, "Forward Offset (Z)", -50, 50, Config, "offsetZ", function(val) Config.offsetZ = val end)
    addButton(mainTab, "Fix Main Reach", function()
        scanForFriction(workspaceFolder);
        if hitboxPart then destroyHitbox() end;
        if Config.reachenabled then createHitbox() end;
    end)
    warn("Finished adding elements to Main Tab.")

    -- Misc Tab
    warn("Adding elements to Misc Tab...")
    addToggle(miscTab, "Infinite Stamina", Config, "infiniteStaminaEnabled", enableInfiniteStamina)
    addToggle(miscTab, "Performance Mode", Config, "performanceModeEnabled", togglePerformanceMode)
    addButton(miscTab, "Clean Memory", cleanMemory)
    addButton(miscTab, "Reduce Ping (Spoof)", reducePing)
    addToggle(miscTab, "FPS Boost (Spoof)", Config, "fpsBoostEnabled", enableFPSBoost)
    addToggle(miscTab, "Anti AFK", Config, "antiAfkEnabled", toggleAntiAfk)
    warn("Finished adding elements to Misc Tab.")

    -- Game Tab
    warn("Adding elements to Game Tab...")
    addToggle(gameTab, "Ball Freeze (Keybind Q)", Config, "lagBallEnabled", toggleBallFreeze)
    addToggle(gameTab, "Ball Gravity", Config, "ballGravityEnabled", function(state) updateBallGravity(state, Config.ballGravityStrength) end)
    addSlider(gameTab, "Ball Gravity Strength", 0, 500, Config, "ballGravityStrength", function(val) updateBallGravity(Config.ballGravityEnabled, val) end)
    addToggle(gameTab, "Prevent Goals", Config, "antiGoalEnabled", togglePreventGoals)
    addButton(gameTab, "Start Walk Fling", startWalkFling)
    addButton(gameTab, "Stop Walk Fling", stopWalkFling)
    addToggle(gameTab, "Mouse Click TP", Config, "mouseClickTPEnabled", toggleMouseClickTP)
    addToggle(gameTab, "Speed Boost", Config, "speedBoostEnabled", toggleSpeedBoost)
    addSlider(gameTab, "Walkspeed", 16, 100, Config, "walkSpeedValue", function(value)
        Config.walkSpeedValue = value
        if Config.speedBoostEnabled then
            humanoid.WalkSpeed = value
        end
    end)
    warn("Finished adding elements to Game Tab.")

    -- Visuals Tab
    warn("Adding elements to Visuals Tab...")
    addSlider(visualsTab, "Visualizer Transparency (Hidden)", 0, 1, Config, "hitboxTransparency", function(val)
        Config.hitboxTransparency = val; if hitboxPart then hitboxPart.Transparency = val end
    end)
    local materialOptions = {"ForceField", "Neon", "Glass", "Plastic", "Metal", "Wood", "Concrete", "Ice", "Fabric", "Slate"}
    addDropdown(visualsTab, "Visualizer Material (Hidden)", materialOptions, Config, "hitboxMaterial", function(selectedName)
        Config.hitboxMaterial = Enum.Material[selectedName]
        if hitboxPart then hitboxPart.Material = Config.hitboxMaterial end
    end)
    addToggle(visualsTab, "Ball Predictor", Config, "ballPredictorEnabled", updateBallPrediction)
    warn("Finished adding elements to Visuals Tab.")

    -- OP Tab
    warn("Adding elements to OP Tab...")
    addToggle(opTab, "Insane Shot Power", Config, "insaneShotPowerEnabled", function(state) Config.insaneShotPowerEnabled = state end)
    addTextbox(opTab, "Shot Power Value (1-9999999)", tostring(Config.maxVelocity), function(enterPressed, textbox)
        if enterPressed then
            local num = tonumber(textbox.Text)
            if num then
                Config.maxVelocity = math.max(1, math.min(9999999, num))
                textbox.Text = tostring(Config.maxVelocity)
            else
                textbox.Text = tostring(Config.maxVelocity)
            end
        end
    end)
    addSlider(opTab, "Insane Shot Height", 0, 500, Config, "yAxisMultiplier", function(val) Config.yAxisMultiplier = val end)

    addToggle(opTab, "Ronaldo Shot Power", Config, "ronaldoShotPowerEnabled", function(state) Config.ronaldoShotPowerEnabled = state end)
    addSlider(opTab, "Ronaldo Shot Strength", 100, 1000, Config, "ronaldoShotPowerStrength", function(val) Config.ronaldoShotPowerStrength = val end)
    addSlider(opTab, "Ronaldo Shot Height", 0, 500, Config, "ronaldoShotHeight", function(val) Config.ronaldoShotHeight = val end)
    addToggle(opTab, "Knuckleball", Config, "knuckleballEnabled", function(state) Config.knuckleballEnabled = state end)
    addSlider(opTab, "Knuckleball Height", 0, 200, Config, "knuckleballHeight", function(val) Config.knuckleballHeight = val end)
    addSlider(opTab, "Knuckleball Speed", 0, 200, Config, "knuckleballSpeed", function(val) Config.knuckleballSpeed = val end)
    addToggle(opTab, "Curve Power", Config, "curvePowerEnabled", function(state) Config.curvePowerEnabled = state end)
    addSlider(opTab, "Curve Shot Strength", 0, 500, Config, "curvePowerValue", function(val) Config.curvePowerValue = val end)
    addSlider(opTab, "Curve Shot Height", 0, 200, Config, "curveHeightValue", function(val) Config.curveHeightValue = val end)
    addToggle(opTab, "Telekinesis", Config, "telekenisisEnabled", toggleTelekenisis)

    addToggle(opTab, "Shield Ball (Stuck to Player)", Config, "shieldBallEnabled", toggleShieldBall)
    addSlider(opTab, "Shield Ball Offset X", -5, 5, Config, "shieldBallOffsetX", function(val) Config.shieldBallOffsetX = val end)
    addSlider(opTab, "Shield Ball Offset Y", -5, 5, Config, "shieldBallOffsetY", function(val) Config.shieldBallOffsetY = val end)
    addSlider(opTab, "Shield Ball Offset Z", -5, 5, Config, "shieldBallOffsetZ", function(val) Config.shieldBallOffsetZ = val end)

    local goalTargetFrame = Instance.new("Frame")
    goalTargetFrame.Size = UDim2.new(0, 200, 0, 120)
    goalTargetFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    goalTargetFrame.Name = "GoalTargetDisplay"
    goalTargetFrame.Parent = opTab -- Parent to ScrollingFrame
    goalTargetFrame.ZIndex = 4
    warn(string.format("  - Added Goal Target Frame to %s. Visible: %s", opTab.Name, goalTargetFrame.Visible))

    local goalPostsLeft = Instance.new("Frame"); goalPostsLeft.Size = UDim2.new(0, 10, 1, 0); goalPostsLeft.Position = UDim2.new(0, 0, 0, 0); goalPostsLeft.BackgroundColor3 = Color3.fromRGB(200, 200, 200); goalPostsLeft.Parent = goalTargetFrame; goalPostsLeft.ZIndex = 5
    local goalPostsRight = Instance.new("Frame"); goalPostsRight.Size = UDim2.new(0, 10, 1, 0); goalPostsRight.Position = UDim2.new(1, -10, 0, 0); goalPostsRight.BackgroundColor3 = Color3.fromRGB(200, 200, 200); goalPostsRight.Parent = goalTargetFrame; goalPostsRight.ZIndex = 5
    local goalCrossbar = Instance.new("Frame"); goalCrossbar.Size = UDim2.new(1, -20, 0, 10); goalCrossbar.Position = UDim2.new(0, 10, 0, 0); goalCrossbar.BackgroundColor3 = Color3.fromRGB(200, 200, 200); goalCrossbar.Parent = goalTargetFrame; goalCrossbar.ZIndex = 5

    goalBallIndicator = Instance.new("Frame"); goalBallIndicator.Size = UDim2.new(0, 16, 0, 16); goalBallIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    goalBallIndicator.Position = UDim2.new(Config.goalTarget2D.X, -8, Config.goalTarget2D.Y, -8)
    goalBallIndicator.BorderSizePixel = 0; goalBallIndicator.ZIndex = 6
    local UICornerBall = Instance.new("UICorner"); UICornerBall.CornerRadius = UDim.new(0.5, 0); UICornerBall.Parent = goalBallIndicator
    goalBallIndicator.Parent = goalTargetFrame
    warn(string.format("  - Added Goal Ball Indicator to %s. Visible: %s", goalTargetFrame.Name, goalBallIndicator.Visible))

    goalTargetFrame.MouseButton1Click:Connect(function(x, y)
        local relativeX = (x - goalTargetFrame.AbsolutePosition.X) / goalTargetFrame.AbsoluteSize.X
        local relativeY = (y - goalTargetFrame.AbsolutePosition.Y) / goalTargetFrame.AbsoluteSize.Y
        updateGoalTargetIndicator(relativeX, relativeY)
    end)
    addToggle(opTab, "Goal Target Enable", Config, "goalTargetEnabled", function(state) Config.goalTargetEnabled = state end)
    addSlider(opTab, "Target Shot Speed", 10, 500, Config, "goalTargetShotSpeed", function(val) Config.goalTargetShotSpeed = val end)

    addButton(opTab, "Top Left Corner", function() updateGoalTargetIndicator(0, 0) end)
    addButton(opTab, "Top Right Corner", function() updateGoalTargetIndicator(1, 0) end)
    addButton(opTab, "Bottom Left Corner", function() updateGoalTargetIndicator(0, 1) end) -- Added
    addButton(opTab, "Bottom Right Corner", function() updateGoalTargetIndicator(1, 1) end) -- Added
    addButton(opTab, "Center Goal", function() updateGoalTargetIndicator(0.5, 0.5) end) -- Added

    addButton(opTab, "FE Snow", function() sendWeatherCommand("Snow") end)
    addButton(opTab, "FE Rain", function() sendWeatherCommand("Rain") end)
    addButton(opTab, "FE Overcast", function() sendWeatherCommand("Overcast") end)
    addButton(opTab, "FE Clear", function() sendWeatherCommand("Clear") end)
    addButton(opTab, "FE Morning", function() sendTimeCommand("Morning") end)
    addButton(opTab, "FE Noon", function() sendTimeCommand("Noon") end)
    addButton(opTab, "FE Afternoon", function() sendTimeCommand("Afternoon") end)
    addButton(opTab, "FE Night", function() sendTimeCommand("Night") end)

    local ballOptions = {"Default"};
    local ballsFolder = ReplicatedStorage:FindFirstChild("game") and ReplicatedStorage.game:FindFirstChild("balls");
    if ballsFolder then for _, ball in ipairs(ballsFolder:GetChildren()) do table.insert(ballOptions, ball.Name) end end
    addDropdown(opTab, "Select Ball", ballOptions, nil, nil, selectMatchBall) -- Changed to use global selectMatchBall
    addToggle(opTab, "Auto Goal", Config, "autoGoalEnabled", function(state) Config.autoGoalEnabled = state end)
    warn("Finished adding elements to OP Tab.")

    -- Config Tab
    warn("Adding elements to Config Tab...")
    addButton(configTab, "Set Pitch Teleport Position", setPitchPositionToCurrent)
    addButton(configTab, "Teleport to Pitch", teleportToPitch)
    addButton(configTab, "Load Universal Scripts", loadUniversalScripts)
    addTextbox(configTab, "Walkspeed", tostring(Config.lastWalkSpeed), function(enterPressed, textbox)
        if enterPressed then
            local num = tonumber(textbox.Text); if num then Config.lastWalkSpeed = num; humanoid.WalkSpeed = num end
        end
    end)
    addTextbox(configTab, "Jump Power", tostring(Config.lastJumpPower), function(enterPressed, textbox)
        if enterPressed then
            local num = tonumber(textbox.Text); if num then Config.lastJumpPower = num; humanoid.JumpPower = num end
        end
    end)
    addToggle(configTab, "Ragdoll Aura", Config, "ragdollAuraEnabled", toggleRagdollAura)
    addSlider(configTab, "Aura Radius", 5, 100, Config, "auraRadius", function(val) Config.auraRadius = val end)
    addButton(configTab, "Ragdoll All Players", function() for _, p in pairs(Players:GetPlayers()) do if p ~= player then ragdollPlayer(p) end end end)
    addButton(configTab, "Unragdoll All Players", function() for _, p in pairs(Players:GetPlayers()) do unragdollPlayer(p) end end)
    addToggle(configTab, "Unragdoll Aura", Config, "unragdollAuraEnabled", toggleUnragdollAura)
    addButton(configTab, "Ragdoll Referee", ragdollReferee)
    addButton(configTab, "Unragdoll Referee", unragdollReferee)

    local playerNames = getPlayerNames()
    addDropdown(configTab, "Ragdoll Player", playerNames, nil, nil, ragdollPlayer) -- Updated to use ragdollPlayer directly
    addDropdown(configTab, "Unragdoll Player", playerNames, nil, nil, unragdollPlayer) -- Updated to use unragdollPlayer directly
    -- Note: These dropdowns will need a mechanism to refresh their options if players join/leave.
    -- The provided `updatePlayerDropdowns` was in the previous script's `LightHub` table.
    -- For now, they will populate once on UI creation.

    addToggle(configTab, "Anti Foul", Config, "antiFoulEnabled", toggleAntiFoul)
    addToggle(configTab, "Anti Offside", Config, "antiOffsideEnabled", toggleAntiOffside)
    addToggle(configTab, "Anti Out", Config, "antiOutEnabled", toggleAntiOut)
    addToggle(configTab, "Anti Barriers", Config, "antiBarriersEnabled", toggleAntiBarriers)
    warn("Finished adding elements to Config Tab.")

    -- GK Tab
    warn("Adding elements to GK Tab...")
    addToggle(gkTab, "Auto GK", Config, "autoGKEnabled", function(state) Config.autoGKEnabled = state end) -- Placeholder
    addToggle(gkTab, "GK Reach", Config, "gkReachEnabled", toggleGKReach)
    addToggle(gkTab, "GK Tools Outside Box", Config, "autoGKEnabled", toggleGKToolsOutsideBox) -- Reused autoGKEnabled for this
    addDropdown(gkTab, "Set Player Team", {"Home", "Away", "Home GK", "Away GK", "Spectator"}, nil, nil, setPlayerTeam)
    warn("Finished adding elements to GK Tab.")

    -- Player Tab
    warn("Adding elements to Player Tab...")
    addToggle(playerTab, "Anti AFK", Config, "antiAfkEnabled", toggleAntiAfk)
    warn("Finished adding elements to Player Tab.")

    -- Methods Tab
    warn("Adding elements to Methods Tab...")
    addToggle(methodsTab, "Infinite Reach (Method 2)", Config, "infiniteReachEnabled", function(state) disableOtherReachMethods("infiniteReachEnabled"); toggleInfiniteReach(state) end)
    addSlider(methodsTab, "Stud Reach V2 Range", 1, 100, Config, "studReachV2Range", function(val) Config.studReachV2Range = val end)
    addToggle(methodsTab, "Stud Reach V2 (Method 3)", Config, "studReachV2Enabled", function(state) disableOtherReachMethods("studReachV2Enabled"); toggleStudReachV2(state) end)
    addToggle(methodsTab, "Modified Infinite Reach (Method 4)", Config, "modifiedInfiniteReachEnabled", function(state) disableOtherReachMethods("modifiedInfiniteReachEnabled"); toggleModifiedInfiniteReach(state) end)
    -- New: Recommended Reach (Method 5)
    addToggle(methodsTab, "Recommended Reach (Method 5)", Config, "recommendedReachEnabled", function(state) disableOtherReachMethods("recommendedReachEnabled"); toggleRecommendedReach(state) end)
    addSlider(methodsTab, "Recommended Reach X", 1, 100, Config, "recommendedReachX", function(val)
        Config.recommendedReachX = val
        -- Update the part's size immediately if active (redundant with RenderStepped, but good for instant feedback)
        if Config.recommendedReachEnabled and RecommendedReachData.collidePart then
            RecommendedReachData.collidePart.Size = Vector3.new(Config.recommendedReachX, Config.recommendedReachY, Config.recommendedReachZ)
        end
    end)
    addSlider(methodsTab, "Recommended Reach Y", 1, 100, Config, "recommendedReachY", function(val)
        Config.recommendedReachY = val
        if Config.recommendedReachEnabled and RecommendedReachData.collidePart then
            RecommendedReachData.collidePart.Size = Vector3.new(Config.recommendedReachX, Config.recommendedReachY, Config.recommendedReachZ)
        end
    end)
    addSlider(methodsTab, "Recommended Reach Z", 1, 100, Config, "recommendedReachZ", function(val)
        Config.recommendedReachZ = val
        if Config.recommendedReachEnabled and RecommendedReachData.collidePart then
            RecommendedReachData.collidePart.Size = Vector3.new(Config.recommendedReachX, Config.recommendedReachY, Config.recommendedReachZ)
        end
    end)
    warn("Finished adding elements to Methods Tab.")

    -- Credits Tab
    warn("Adding elements to Credits Tab...")
    local creditsLabel = Instance.new("TextLabel"); creditsLabel.Text = "LightHub by aidenrosal146.dev\nVersion: 1.0.0\nFor Real Futbol 24";
    creditsLabel.Size = UDim2.new(1, -40, 1, -40); creditsLabel.Position = UDim2.new(0.5, -creditsLabel.Size.X.Offset/2, 0.5, -creditsLabel.Size.Y.Offset/2);
    creditsLabel.Parent = creditsTab; creditsLabel.BackgroundTransparency = 1; creditsLabel.TextColor3 = Color3.fromRGB(200,200,200); creditsLabel.TextWrapped = true; creditsLabel.TextXAlignment = Enum.TextXAlignment.Center; creditsLabel.TextYAlignment = Enum.TextYAlignment.Center
    creditsLabel.Font = Enum.Font.GothamMedium
    creditsLabel.TextSize = 14
    warn("Finished adding elements to Credits Tab.")
end

-- Main Initialization Function
local function Init()
    -- Ensure character is loaded
    if not character then
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid")
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    end

    -- Initialize Modified Reach Highlight (before it might be used)
    initializeModifiedReachHighlight()

    -- Ensure sharedFolder and weatherRemote are found
    sharedFolder = ReplicatedStorage:WaitForChild("network"):WaitForChild("Shared")
    weatherRemote = sharedFolder:WaitForChild("hi") -- This is the "HI" part you mentioned

    -- Initial setup for "HI" related functions
    scanForFriction(workspaceFolder)
    lockAndChangeNames()
    blockNameChange()
    -- Re-connect property changed signal for existing children in Shared folder
    for _, child in pairs(sharedFolder:GetChildren()) do
        child:GetPropertyChangedSignal("Name"):Connect(function()
            if child.Name ~= "hi" then child.Name = "hi" end
        end)
    end

    -- Initialize UI
    populateUI()
    selectTab("Main") -- Ensure Main tab is selected initially

    -- Connect kick animation handler
    if kickAnimationListenerConnection then kickAnimationListenerConnection:Disconnect() end -- Disconnect old if exists
    kickAnimationListenerConnection = humanoid.AnimationPlayed:Connect(handleKickAnimationEnd)

    -- Re-enable main reach if it was configured to be on
    if Config.reachenabled then
        toggleMainReach(true)
    end

    warn("Light Hub Initialized and Running.")
end

-- Call the main initialization function
Init()

-- Cleanup on script removal
script.AncestryChanged:Connect(function()
    if not script.Parent then
        -- Disconnect all active connections
        for _, conn in pairs(toggleConnections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        toggleConnections = {}

        -- Disconnect specific global connections
        if autoCatchConnection then autoCatchConnection:Disconnect(); autoCatchConnection = nil end
        if ballGravityForce then ballGravityForce:Destroy(); ballGravityForce = nil end
        if knuckleballWobbleEffectConnection then knuckleballWobbleEffectConnection:Disconnect(); knuckleballWobbleEffectConnection = nil end
        if autoGoalAnimationConnection then autoGoalAnimationConnection:Disconnect(); autoGoalAnimationConnection = nil end
        if curveBodyAngularVelocity then curveBodyAngularVelocity:Destroy(); curveBodyAngularVelocity = nil end
        if ballFreezeKeybindConnection then ballFreezeKeybindConnection:Disconnect(); ballFreezeKeybindConnection = nil end
        if predictionLine then predictionLine:Destroy(); predictionLine = nil end
        if antiOutConnection then antiOutConnection:Disconnect(); antiOutConnection = nil end
        if deleteBarrierConnection then deleteBarrierConnection:Disconnect(); deleteBarrierConnection = nil end
        if gkReachConnection then gkReachConnection:Disconnect(); gkReachConnection = nil end
        if reachVisualizerBox then reachVisualizerBox:Destroy(); reachVisualizerBox = nil end
        if speedBoostConnection then speedBoostConnection:Disconnect(); speedBoostConnection = nil end
        if magnetModeConnection then magnetModeConnection:Disconnect(); magnetModeConnection = nil end
        if aimbotCameraConnection then aimbotCameraConnection:Disconnect(); aimbotCameraConnection = nil end
        if fpsBoostConnection then fpsBoostConnection:Disconnect(); fpsBoostConnection = nil end
        if antiAfkConnection then antiAfkConnection:Disconnect(); antiAfkConnection = nil end
        if ragdollAuraConnection then ragdollAuraConnection:Disconnect(); ragdollAuraConnection = nil end
        if unragdollAuraConnection then unragdollAuraConnection:Disconnect(); unragdollAuraConnection = nil end
        if mouseClickTPConnection then mouseClickTPConnection:Disconnect(); mouseClickTPConnection = nil end
        if infiniteStaminaConnection then infiniteStaminaConnection:Disconnect(); infiniteStaminaConnection = nil end
        if telekenisisLoopConnection then telekenisisLoopConnection:Disconnect(); telekenisisLoopConnection = nil end
        if telekinesisMouseClickConnection then telekinesisMouseClickConnection:Disconnect(); telekinesisMouseClickConnection = nil end
        if shieldBallConnection then shieldBallConnection:Disconnect(); shieldBallConnection = nil end

        -- Disconnect Modified Infinite Reach connections
        if modifiedReach_renderSteppedConnection then modifiedReach_renderSteppedConnection:Disconnect(); modifiedReach_renderSteppedConnection = nil end
        if modifiedReach_inputBeganConnection then modifiedReach_inputBeganConnection:Disconnect(); modifiedReach_inputBeganConnection = nil end
        if modifiedReach_highlightPart then modifiedReach_highlightPart:Destroy(); modifiedReach_highlightPart = nil end

        -- Disconnect Recommended Reach connections and revert part
        if RecommendedReachData.updateConnection then RecommendedReachData.updateConnection:Disconnect(); RecommendedReachData.updateConnection = nil end
        if RecommendedReachData.collidePart and RecommendedReachData.originalProperties then
            RecommendedReachData.collidePart.Material = RecommendedReachData.originalProperties.Material
            RecommendedReachData.collidePart.Transparency = RecommendedReachData.originalProperties.Transparency
            RecommendedReachData.collidePart.Massless = RecommendedReachData.originalProperties.Massless
            RecommendedReachData.collidePart.CanCollide = RecommendedReachData.originalProperties.CanCollide
            RecommendedReachData.collidePart.Size = RecommendedReachData.originalProperties.Size
        end
        RecommendedReachData.collidePart = nil
        RecommendedReachData.originalProperties = nil

        -- Destroy UI
        if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end

        -- Destroy any created hitboxes
        destroyHitbox()

        warn("Light Hub Script Cleaned Up.")
    end
end)
