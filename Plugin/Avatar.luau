local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")
local Trove = require(script.Parent.Packages.Trove)

export type Avatar = {
    UserID :number;
    Model :Model|nil;
    Trove :Trove.Trove;

    Destroy :(Avatar) -> ();
}

local Avatar = {}
Avatar.__index = Avatar

function Avatar.new(UserID :number) :Avatar
    local self = setmetatable({}, Avatar)
    self.Trove = Trove.new()
    self.UserID = UserID
    self.Model = nil
    self.PositionLoop = nil
    self:ConstructModel()
    return self
end

function Avatar:SetTransparency(New :number)
    assert(self.Model, "No model!")

    for _, Object :BasePart in pairs(self.Model:GetDescendants()) do
        if Object:IsA("BasePart") or Object:IsA("Decal") then
            Object.LocalTransparencyModifier = New
        end

        if Object:IsA("BasePart") then
            Object.Locked = true
        end
    end
end

function Avatar:PositionModelLoop()
    local Bind = RunService.Heartbeat:Connect(function()
        if not self.Model then return end
        self.Model:PivotTo(workspace.CurrentCamera.CFrame)
    end)

    self.Trove:Add(Bind)
end

function Avatar:ConstructModel()
    assert(self.UserID, "No UserID")
    assert(self.UserID ~= 0, "Invalid UserID")

    self.Trove:Clean()

    self.Model = Players:CreateHumanoidModelFromUserId(self.UserID)
    local Humanoid = self.Model:WaitForChild("Humanoid") :: Humanoid
    local Head = self.Model:WaitForChild("Head")

    self.Model.PrimaryPart = Head
    Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    self:SetTransparency(1)
    self:PositionModelLoop()

    self.Model.Name = `TCWA_{Players:GetNameFromUserIdAsync(StudioService:GetUserId())}`
    self.Model.Parent = workspace.Terrain
    self.Trove:Add(self.Model)
end

function Avatar:Destroy()
    self.Trove:Clean()
end

return Avatar