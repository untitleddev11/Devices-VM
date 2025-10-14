local DevicesVM = {}

function DevicesVM:Init()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    if game.CoreGui:GetAttribute("RunningDVM") then print("retard") return end
    game.CoreGui:SetAttribute("RunningDVM", true)

    local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/untitleddev11/Devices-VM/refs/heads/main/dependencies/functions.lua"))()
    local Games = game:HttpGet("https://raw.githubusercontent.com/untitleddev11/Devices-VM/refs/heads/main/dependencies/games.json")
    local ImGui = loadstring(game:HttpGet('https://github.com/depthso/Roblox-ImGUI/raw/main/ImGui.lua'))()

    local Success, GamesData = pcall(function()
        return HttpService:JSONDecode(Games)
    end)

    local CurrentPlaceId = game.PlaceId
    local PlaceId, MainEvent, Event = nil, nil, nil

    coroutine.wrap(function()
        for Id, Data in pairs(GamesData) do
            if not Id or typeof(Data) ~= "table" then continue end
            if tonumber(Id) == CurrentPlaceId then
                PlaceId = Id
                MainEvent = Data.Remote and Functions:SearchRemotes(Data.Remote) or "MainEvent"
                Event = Data.Event or "UpdateMousePos"
                break
            end
        end
    end)()

    RunService.RenderStepped:Wait()

    if PlaceId == nil then
        setclipboard("https://github.com/untitleddev11/Devices-VM/blob/main/dependencies/games.json")
        LocalPlayer:Kick("This game is not supported! check our github repository to see supported games. (copied to ur clipboard)")
        return
    end

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.new(1, 1, 1)
    FOVCircle.Thickness = 1
    FOVCircle.Transparency = 1
    FOVCircle.Filled = false

    local function UpdateFOVCircle()
        FOVCircle.Radius = getgenv().CheatSettings.Preferences.MaxMouseDistance
        FOVCircle.Visible = getgenv().CheatSettings.Preferences.DrawFOV
        local MousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(MousePos.X, MousePos.Y)
    end

    RunService.RenderStepped:Connect(UpdateFOVCircle)

    coroutine.wrap(function()
        local Window = ImGui:CreateWindow({
            Title = "MADE BY - APOLLO ",
            Size = UDim2.fromOffset(550, 500),
            Position = UDim2.new(0.5, 0, 0, 70),
        })

        local TabAiming = Window:CreateTab({ Name = "Aiming", Visible = true })
        local TabSettings = Window:CreateTab({ Name = "Settings", Visible = false })

        -- ✅ NEW: Hitbox Expander Tab
        local TabHitbox = Window:CreateTab({ Name = "Hitbox Expander", Visible = false })
        TabHitbox:Separator({ Text = "Settings" })

        TabHitbox:Checkbox({
            Label = "Enable Hitbox Expander",
            Value = getgenv().CheatSettings.HitboxEnabled or false,
            Callback = function(_, Value)
                getgenv().CheatSettings.HitboxEnabled = Value
            end
        })

        TabHitbox:Slider({
            Label = "Hitbox Size",
            Min = 1,
            Max = 15,
            Value = getgenv().CheatSettings.HitboxSize or 5,
            Callback = function(_, Value)
                getgenv().CheatSettings.HitboxSize = Value
            end
        })

        TabHitbox:Slider({
            Label = "Transparency",
            Min = 0,
            Max = 1,
            Value = getgenv().CheatSettings.HitboxTransparency or 0.5,
            Callback = function(_, Value)
                getgenv().CheatSettings.HitboxTransparency = Value
            end
        })
        -- ✅ END NEW TAB

        -- (Everything below is your original GUI)
        TabAiming:Separator({ Text = "Toggles" })
        TabAiming:Checkbox({
            Label = "aimlock",
            Value = getgenv().CheatSettings.Aiming.AimLock,
            Callback = function(_, v) getgenv().CheatSettings.Aiming.AimLock = v end
        })
        TabAiming:Checkbox({
            Label = "silentaim",
            Value = getgenv().CheatSettings.Aiming.SilentAim,
            Callback = function(_, v) getgenv().CheatSettings.Aiming.SilentAim = v end
        })
        TabAiming:Checkbox({
            Label = "use multiple body parts [SILENT - LEGIT]",
            Value = getgenv().CheatSettings.Aiming.MultiParts,
            Callback = function(_, v) getgenv().CheatSettings.Aiming.MultiParts = v end
        })
        TabAiming:Checkbox({
            Label = "notify (notification when locked)",
            Value = getgenv().CheatSettings.Preferences.Notify,
            Callback = function(_, v) getgenv().CheatSettings.Preferences.Notify = v end
        })
        TabAiming:Separator({ Text = "Keybinds" })
        TabAiming:Keybind({
            Label = "aimlock bind",
            Value = getgenv().CheatSettings.Aiming.AimLockBind,
            IgnoreGameProcessed = false,
            Callback = function(_, KeyCode)
                getgenv().CheatSettings.Aiming.AimLockBind = KeyCode
            end
        })
        TabAiming:Separator({ Text = "Values" })
        TabAiming:InputText({
            Label = "aimlock smoothing",
            Value = getgenv().CheatSettings.Aiming.AimSmoothing,
            PlaceHolder = "insert here (NO NUMBER = NO CHANGE)",
            Callback = function(_, Value)
                if tonumber(Value) then getgenv().CheatSettings.Aiming.AimSmoothing = Value end
            end
        })
        TabAiming:InputText({
            Label = "aimlock prediction",
            Value = getgenv().CheatSettings.Aiming.AimPrediction,
            PlaceHolder = "insert here (NO NUMBER = NO CHANGE)",
            Callback = function(_, Value)
                if tonumber(Value) then getgenv().CheatSettings.Aiming.AimPrediction = Value end
            end
        })
        TabAiming:InputText({
            Label = "silentaim prediction",
            Value = getgenv().CheatSettings.Aiming.SilentPrediction,
            PlaceHolder = "insert here (NO NUMBER = NO CHANGE)",
            Callback = function(_, Value)
                if tonumber(Value) then getgenv().CheatSettings.Aiming.SilentPrediction = Value end
            end
        })
        TabAiming:Separator({ Text = "Dropdowns" })
        TabAiming:Combo({
            Selected = getgenv().CheatSettings.Aiming.BodyPart,
            Label = "body part",
            Items = { "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm" },
            Callback = function(_, Value)
                getgenv().CheatSettings.Aiming.BodyPart = Value
            end
        })

        TabSettings:Separator({ Text = "Toggles" })
        TabSettings:Checkbox({
            Label = "check KO",
            Value = getgenv().CheatSettings.Preferences.CheckKO,
            Callback = function(_, v) getgenv().CheatSettings.Preferences.CheckKO = v end
        })
        TabSettings:Checkbox({
            Label = "check player KO",
            Value = getgenv().CheatSettings.Preferences.CheckPlayerKO,
            Callback = function(_, v) getgenv().CheatSettings.Preferences.CheckPlayerKO = v end
        })
        TabSettings:Checkbox({
            Label = "visibility check",
            Value = getgenv().CheatSettings.Preferences.VisibilityCheck,
            Callback = function(_, v) getgenv().CheatSettings.Preferences.VisibilityCheck = v end
        })
        TabSettings:Checkbox({
            Label = "use silentaim fov",
            Value = getgenv().CheatSettings.Preferences.SilentAimMouseDistanceCheck,
            Callback = function(_, v) getgenv().CheatSettings.Preferences.SilentAimMouseDistanceCheck = v end
        })
        TabSettings:Checkbox({
            Label = "draw silentaim fov",
            Value = getgenv().CheatSettings.Preferences.DrawFOV,
            Callback = function(_, v) getgenv().CheatSettings.Preferences.DrawFOV = v end
        })
        TabSettings:Separator({ Text = "Values" })
        TabSettings:InputText({
            Label = "silentaim fov",
            Value = getgenv().CheatSettings.Preferences.MaxMouseDistance,
            PlaceHolder = "insert here (NO NUMBER = NO CHANGE)",
            Callback = function(_, Value)
                if tonumber(Value) then getgenv().CheatSettings.Preferences.MaxMouseDistance = Value end
            end
        })
        TabSettings:Separator({ Text = "Keybinds" })
        TabSettings:Keybind({
            Label = "script visible bind",
            Value = Enum.KeyCode.Equals,
            IgnoreGameProcessed = false,
            Callback = function() Window:SetVisible(true) end
        })
    end)()

    ----------------------------------------------------
    -- ✅ Hitbox Expander Runtime Logic
    ----------------------------------------------------
    local RS = game:GetService("RunService")
    RS.RenderStepped:Connect(function()
        if not getgenv().CheatSettings.HitboxEnabled then return end
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player == LocalPlayer then continue end
            local Char = Player.Character
            if Char and Char:FindFirstChild("HumanoidRootPart") then
                local HRP = Char.HumanoidRootPart
                local Humanoid = Char:FindFirstChild("Humanoid")
                if Humanoid and Humanoid.Health > 0 then
                    HRP.Size = Vector3.new(getgenv().CheatSettings.HitboxSize or 5,
                                            getgenv().CheatSettings.HitboxSize or 5,
                                            getgenv().CheatSettings.HitboxSize or 5)
                    HRP.Transparency = getgenv().CheatSettings.HitboxTransparency or 0.5
                    HRP.CanCollide = false
                    if not HRP:FindFirstChild("SelectionBox") then
                        local box = Instance.new("SelectionBox")
                        box.Name = "SelectionBox"
                        box.Adornee = HRP
                        box.LineThickness = 0.05
                        box.Color3 = Color3.fromRGB(255, 0, 0)
                        box.Parent = HRP
                    end
                else
                    HRP.Size = Vector3.new(2, 2, 1)
                    HRP.Transparency = 1
                    local box = HRP:FindFirstChild("SelectionBox")
                    if box then box:Destroy() end
                end
            end
        end
    end)
end

return DevicesVM
