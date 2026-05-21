local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local RoundState = require(Shared:WaitForChild("constants"):WaitForChild("RoundState"))

local UIController = {
    ActiveState = nil,
    ActiveScreen = nil,
    Screens = {}, -- Maps RoundState to ScreenGui
    TransitionTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

function UIController:Init()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    print("[UIController] Initializing UI Screen map...")
    
    -- Setup screens mapping
    -- We assume the screens are named exactly after the RoundStates under PlayerGui
    for _, state in pairs(RoundState) do
        -- Find or wait for the corresponding ScreenGui under PlayerGui
        -- Note: during real game run, they could be added dynamically or pre-exist
        local screen = playerGui:FindFirstChild(state)
        if screen and screen:IsA("ScreenGui") then
            self.Screens[state] = screen
            -- Ensure CanvasGroup is added for smooth fading
            local canvasGroup = screen:FindFirstChildOfClass("CanvasGroup")
            if not canvasGroup then
                canvasGroup = Instance.new("CanvasGroup")
                canvasGroup.Size = UDim2.new(1, 0, 1, 0)
                canvasGroup.BackgroundTransparency = 1
                -- Move all children to CanvasGroup
                for _, child in ipairs(screen:GetChildren()) do
                    child.Parent = canvasGroup
                end
                canvasGroup.Parent = screen
            end
            screen.Enabled = false
        end
    end
    
    -- Listen to state replication from Server
    local roundStateVal = ReplicatedStorage:WaitForChild("RoundStateValue", 10)
    if roundStateVal then
        roundStateVal.Changed:Connect(function(newState)
            print("[UIController] State replicated from server:", newState)
            self:TransitionTo(newState)
        end)
        -- Init first state
        if roundStateVal.Value ~= "" then
            task.spawn(function()
                self:TransitionTo(roundStateVal.Value)
            end)
        end
    else
        warn("[UIController] RoundStateValue was not found in ReplicatedStorage! Make sure the server is running.")
    end
end

function UIController:TransitionTo(state)
    if self.ActiveState == state then return end
    
    local targetScreen = self.Screens[state]
    if not targetScreen then
        warn("[UIController] Screen not found for state:", state)
        return
    end
    
    print("[UIController] Transitioning UI to:", state)
    self.ActiveState = state
    
    local canvasGroup = targetScreen:FindFirstChildOfClass("CanvasGroup")
    
    -- Fade out current screen
    if self.ActiveScreen then
        local oldScreen = self.ActiveScreen
        local oldGroup = oldScreen:FindFirstChildOfClass("CanvasGroup")
        if oldGroup then
            local fadeOut = TweenService:Create(oldGroup, self.TransitionTweenInfo, {GroupTransparency = 1})
            fadeOut:Play()
            fadeOut.Completed:Wait()
        end
        oldScreen.Enabled = false
    end
    
    -- Fade in new screen
    targetScreen.Enabled = true
    if canvasGroup then
        canvasGroup.GroupTransparency = 1
        local fadeIn = TweenService:Create(canvasGroup, self.TransitionTweenInfo, {GroupTransparency = 0})
        fadeIn:Play()
    end
    
    self.ActiveScreen = targetScreen
end

return UIController
