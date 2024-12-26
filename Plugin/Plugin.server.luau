if not plugin then return end
local ShouldRun = require(script.Parent.Util.ShouldRun)
if not ShouldRun then return end

local Players = game:GetService("Players")
local Root = script.Parent

local AvatarClass = require(Root.Classes.Avatar)
local Avatar = AvatarClass.new(Players.LocalPlayer.UserId, Players.LocalPlayer.UserId)

plugin.Unloading:Connect(function()
    Avatar:Destroy()
end)