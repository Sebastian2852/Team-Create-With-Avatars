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

--[=[
    @class Avatar

    This class manages an avatar model. It includes methods for constructing, positioning, cleaning, and destroying avatar instances.
]=]

--[=[
    @within Avatar
    @readonly
    @prop Trove Trove

    Handles cleaning up after models are changed or deleted
]=]

--[=[
    @within Avatar
    @readonly
    @prop Tag String

    The tag that all avatar models get when created by this Avatar class
]=]

--[=[
    @within Avatar
    @readonly
    @prop UserID number

    The userID of which the avatar model is created after
]=]

--[=[
    @within Avatar
    @readonly
    @prop Owner number

    The UserID of which this avatar model is made for
]=]

--[=[
    @within Avatar
    @readonly
    @prop Model Model?

    The current Avatar model which is being used by this class.

    :::caution
    This can be nil at times like when the avatar is being made, or when the userID is switched and a new model is being made!
    :::
]=]

--[=[
    @within Avatar
    @readonly
    @prop PositionLoop RBXScriptConnection

    The current bind for `RunService.PreRender` used for positioning the Avatar model
]=]

local Avatar = {}
Avatar.__index = Avatar

--[=[
    @return Avatar
    @param UserID number -- The userID that the avatar model should use
    @param OwnerUserID number -- The userID of the person the avatar model is for

    Create a new avatar class instance
]=]
function Avatar.new(UserID :number, OwnerUserID :number) :Avatar
    local self = setmetatable({}, Avatar)
    self.Trove = Trove.new()
    self.UserID = UserID
    self.Owner = OwnerUserID
    self.Tag = `TCWA_{self.Owner}`
    self:Clean()

    PhysicsService:RegisterCollisionGroup("StudioUnselectable")
    self.Model = nil
    self.PositionLoop = nil
    self:ConstructModel()
    return self
end

--[=[
    @param New number

    Sets the current **LOCAL** transparency for the avatar model. Meaning that this method only changes the transparency for the owner of the Avatar model.
]=]
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

--[=[
    Sets up a new position loop for the current avatar model

    :::warning
    Intended for internal use only!
    :::
]=]
function Avatar:PositionModelLoop()
    self.PositionLoop = RunService.PreRender:Connect(function()
        if not self.Model then return end
        self.Model:PivotTo(workspace.CurrentCamera.CFrame)
    end)

    self.Trove:Add(self.PositionLoop)
end

--[=[
    Deletes old Avatar model, disconnects all events and creates new Avatar model and connects new events

    :::warning
    Intended for internal use only!
    :::
]=]
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

--[=[
    Disconnect all events and delete any avatars with the objects tag

    :::warning
    Intended for internal use only!
    :::
]=]
function Avatar:Clean()
    self.Trove:Clean()

    local Avatars = CollectionService:GetTagged(self.Tag)
    for _, v in pairs(Avatars) do
        v:Destroy()
    end
end

--[=[
    Destroy the avatar model as well as all data about it
]=]
function Avatar:Destroy()
    self:Clean()
    self = nil
end

return Avatar