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
        LocalPlayer:Kick("This game is not supported! Check our GitHub (copied to clipboard).")
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
            Title = "MADE BY - APOLLO",
            Size = UDim2.fromOffset(550, 500),
            Position = UDim2.new(0.5, 0, 0, 70),
        })

        local TabAiming = Window:CreateTab({ Name = "Aiming", Visible = true })
        local TabSettings = Window:CreateTab({ Name = "Settings", Visible = false })

        ----------------------------------------------------
        -- ✅ Hitbox Expander Tab
        ----------------------------------------------------
        local TabHitbox = Window:CreateTab({ Name = "Hitbox Expander", Visible = false })
        TabHitbox:Separator({ Text = "Settings" })

        -- Enable toggle
        TabHitbox:Checkbox({
            Label = "Enable Hitbox Expander",
            Value = getgenv().CheatSettings.HitboxEnabled or false,
            Callback = function(self, Value)
                getgenv().CheatSettings.HitboxEnabled = Value
            end
        })

        -- Size slider
        TabHitbox:Slider({
            Label = "Hitbox Size",
            Min = 1,
            Max = 15,
            Value = getgenv().CheatSettings.HitboxSize or 5,
            Callback = function(self, Value)
                getgenv().CheatSettings.HitboxSize = Value
            end
        })

        -- Transparency slider
        TabHitbox:Slider({
            Label = "Transparency",
            Min = 0,
            Max = 1,
            Value = getgenv().CheatSettings.HitboxTransparency or 0.5,
            Callback = function(self, Value)
                getgenv().CheatSettings.HitboxTransparency = Value
            end
        })
        ----------------------------------------------------

        ----------------------------------------------------
        -- Original GUI (Aiming + Settings tabs)
        ----------------------------------------------------
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
        ----------------------------------------------------
    end)()

    ----------------------------------------------------
    -- ✅ Hitbox Expander Runtime Logic
    ----------------------------------------------------
    local Players = cloneref(game:GetService("Players"))
    local RS = cloneref(game:GetService("RunService"))
    local Client = Players.LocalPlayer

    RS.RenderStepped:Connect(function()
        if not getgenv().CheatSettings.HitboxEnabled then return end
        for _, Player in pairs(Players:GetPlayers()) do
            if Player == Client then continue end
            local Character = Player.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local HRP = Character.HumanoidRootPart
                local Humanoid = Character:FindFirstChild("Humanoid")

                if Humanoid and Humanoid.Health > 0 then
                    local size = getgenv().CheatSettings.HitboxSize or 5
                    local transparency = getgenv().CheatSettings.HitboxTransparency or 0.5

                    HRP.Size = Vector3.new(size, size, size)
                    HRP.Transparency = transparency
                    HRP.CanCollide = false
                    HRP.Color = Color3.fromRGB(255, 0, 0)

                    if not HRP:FindFirstChild("SelectionBox") then
                        local outline = Instance.new("SelectionBox")
                        outline.Name = "SelectionBox"
                        outline.Adornee = HRP
                        outline.LineThickness = 0.05
                        outline.Color3 = Color3.fromRGB(0, 0, 0)
                        outline.Parent = HRP
                    end
                else
                    HRP.Size = Vector3.new(2, 2, 1)
                    HRP.Transparency = 1
                    local outline = HRP:FindFirstChild("SelectionBox")
                    if outline then outline:Destroy() end
                end
            end
        end
    end)
    ----------------------------------------------------

    -- The rest of your aiming/targeting logic remains unchanged
    -- (keeping it as-is for stability)
end

return DevicesVM
