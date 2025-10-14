local functions = {}

local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")

function functions:SearchRemotes(Name)
	for _, Descendant in next, replicatedStorage:GetDescendants() do
		if Descendant:IsA("RemoteEvent") and Descendant.Name == Name then
			return Descendant
		end
	end
end

function functions:CheckGunHold(Child)
	return Child:IsA("Tool") and Child:FindFirstChild("Ammo") and Child:FindFirstChild("Handle")
end

function functions:ReturnClosestToMouse(LocalPlayer)
	local ClosestDistance = math.huge
	local ClosestPlayer = nil

	for _, Player in next, players:GetPlayers() do
		local PlayerCharacter = Player.Character
		if not PlayerCharacter then return end
		
		if not Player:FindFirstChild("DataFolder") or not PlayerCharacter:FindFirstChild("BodyEffects") then continue end
		
		if Player ~= LocalPlayer and PlayerCharacter then
			local HumanoidRootPart = PlayerCharacter:FindFirstChild("HumanoidRootPart")
			local Humanoid = PlayerCharacter:FindFirstChild("Humanoid")

			if HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
				local RootToViewportPoint, IsOnScreen = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
				if IsOnScreen then
					local MouseLocation = userInputService:GetMouseLocation()
					local DistanceToMouse = (Vector2.new(MouseLocation.X, MouseLocation.Y) - Vector2.new(RootToViewportPoint.X, RootToViewportPoint.Y)).Magnitude
					if DistanceToMouse < ClosestDistance then
						ClosestPlayer = Player
						ClosestDistance = DistanceToMouse
					end
				end
			end
		end
	end

	return ClosestPlayer
end

function functions:VisibilityCheck(LocalPlayer, Targeting, TargetPart)
	local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Blacklist
    RayParams.FilterDescendantsInstances = {Targeting.Character, LocalPlayer.Character}

    local Camera = workspace.CurrentCamera
    local RayOrigin = Camera.CFrame.Position
    local RayDirection = (TargetPart.Position - RayOrigin).Unit * (RayOrigin - TargetPart.Position).Magnitude

    local Hit = workspace:Raycast(RayOrigin, RayDirection, RayParams)
    return Hit == nil
end

return functions
