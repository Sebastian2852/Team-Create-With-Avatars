local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function ShouldRun()
    return RunService:IsEdit() and Players.LocalPlayer ~= nil
end

return ShouldRun()