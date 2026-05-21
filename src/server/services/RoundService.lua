local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RoundState = require(Shared:WaitForChild("constants"):WaitForChild("RoundState"))

local RoundService = {
    CurrentState = nil,
    StateValue = nil,
}

function RoundService:Init()
    print("[RoundService] Initializing RoundService...")
    
    -- Create replication value under ReplicatedStorage
    local stateValue = ReplicatedStorage:FindFirstChild("RoundStateValue")
    if not stateValue then
        stateValue = Instance.new("StringValue")
        stateValue.Name = "RoundStateValue"
        stateValue.Value = RoundState.Start
        stateValue.Parent = ReplicatedStorage
    end
    self.StateValue = stateValue
    self.CurrentState = stateValue.Value

    -- Start mock game loop in background to demonstrate state machine
    task.spawn(function()
        self:StartMockGameLoop()
    end)
end

function RoundService:SetState(state)
    assert(RoundState[state], "[RoundService] Invalid state: " .. tostring(state))
    print("[RoundService] Transitioning state to:", state)
    self.CurrentState = state
    self.StateValue.Value = state
end

function RoundService:StartMockGameLoop()
    task.wait(5) -- Wait for client to boot
    
    local roundCount = 0
    while true do
        -- Transition to Lobby
        self:SetState(RoundState.Lobby)
        task.wait(15)
        
        -- Transition to Role Reveal
        self:SetState(RoundState.RoleReveal)
        task.wait(8)
        
        -- Transition to Playing
        self:SetState(RoundState.Playing)
        task.wait(20)
        
        -- Transition to EndWin / EndLoss (alternating)
        roundCount = roundCount + 1
        if roundCount % 2 == 1 then
            self:SetState(RoundState.EndWin)
        else
            self:SetState(RoundState.EndLoss)
        end
        task.wait(10)
        
        -- Transition to Shop
        self:SetState(RoundState.Shop)
        task.wait(10)
    end
end

return RoundService
