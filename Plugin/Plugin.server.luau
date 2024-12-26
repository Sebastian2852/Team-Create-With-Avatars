if not plugin then return end
local ShouldRun = require(script.Parent.Util.ShouldRun)
if not ShouldRun then return end

local StudioService = game:GetService("StudioService")

local AvatarClass = require(script.Parent.Avatar)
local Avatar = AvatarClass.new(StudioService:GetUserId())

plugin.Unloading:Connect(function()
    Avatar:Destroy()
end)