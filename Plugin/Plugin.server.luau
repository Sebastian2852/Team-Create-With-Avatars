local RunService = game:GetService("RunService")
if not plugin then return end
if not RunService:IsEdit() then return end

local StudioService = game:GetService("StudioService")

local AvatarClass = require(script.Parent.Avatar)
local Avatar = AvatarClass.new(StudioService:GetUserId())

plugin.Unloading:Connect(function()
    Avatar:Destroy()
end)