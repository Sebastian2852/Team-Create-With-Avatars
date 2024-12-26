local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")
local Trove = require(script.Parent.Parent.Packages.Trove)

export type Avatar = {
    UserID :number;
    Model :Model|nil;
    Trove :Trove.Trove;

    Destroy :(Avatar) -> ();
}

local Avatar = {}
Avatar.__index = Avatar

function Avatar.new(UserID :number, OwnerUserID :number) :Avatar
    local self = setmetatable({}, Avatar)
    self.Trove = Trove.new()
    self.Tag = `TCWA_{self.Owner}`
    self:Clean()

    PhysicsService:RegisterCollisionGroup("StudioUnselectable")
    self.UserID = UserID
    self.Owner = OwnerUserID
    self.Model = nil
    self.PositionLoop = nil
    self:ConstructModel()
    return self
end

function Avatar:SetTransparency(New :number)
    assert(self.Model, "No model!")

    for _, Object :Instance|BasePart|Decal in pairs(self.Model:GetDescendants()) do
        Object.Archivable = false

        if Object:IsA("BasePart") or Object:IsA("Decal") then
            Object.LocalTransparencyModifier = New
        end

        if Object:IsA("BasePart") then
            Object.Locked = true
            Object.CastShadow = false
            Object.CollisionGroup = "StudioUnselectable"

            if Object.Parent:IsA("Accessory") then
                continue
            end

            Object.CanCollide = false
            Object.CanQuery = false
            Object.CanTouch = false
            Object.Anchored = true
            Object.EnableFluidForces = false
        end

        if Object:IsA("Script") or Object:IsA("LocalScript") then
            Object:Destroy()
        end
    end
end

function Avatar:PositionModelLoop()
    self.PositionLoop = RunService.PreRender:Connect(function()
        if not self.Model then return end
        self.Model:PivotTo(workspace.CurrentCamera.CFrame)
    end)

    self.Trove:Add(self.PositionLoop)
end

function Avatar:ConstructModel()
    assert(self.UserID, "No UserID")
    assert(self.UserID ~= 0, "Invalid UserID")

    self:Clean()

    self.Model = Players:CreateHumanoidModelFromUserId(self.UserID)
    local Humanoid = self.Model:WaitForChild("Humanoid") :: Humanoid
    local Head = self.Model:WaitForChild("Head")

    self.Model.PrimaryPart = Head
    Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    self:SetTransparency(1)
    self:PositionModelLoop()

    self.Model.Name = `TCWA_{Players:GetNameFromUserIdAsync(StudioService:GetUserId())}`
    self.Model.Parent = workspace.Terrain
    self.Model.Archivable = false
    self.Model:AddTag(self.Tag)
    self.Trove:Add(self.Model)
end

function Avatar:Clean()
    self.Trove:Clean()

    local Avatars = CollectionService:GetTagged(self.Tag)
    for _, v in pairs(Avatars) do
        v:Destroy()
    end
end

function Avatar:Destroy()
    self:Clean()
    self = nil
end

return Avatar