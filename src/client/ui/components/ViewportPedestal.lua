local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Theme = require(script.Parent.Parent.Theme)

local ViewportPedestal = Roact.Component:extend("ViewportPedestal")

function ViewportPedestal:init()
    self.viewportRef = Roact.createRef()
end

function ViewportPedestal:didMount()
    local viewport = self.viewportRef:getValue()
    if not viewport then return end
    
    -- Setup Viewport space
    local worldModel = Instance.new("WorldModel")
    worldModel.Parent = viewport
    
    -- Pedestal part
    local pedestal = Instance.new("Part")
    pedestal.Size = Vector3.new(4, 0.5, 4)
    pedestal.Color = Theme.Colors.BgPlateB
    pedestal.Material = Enum.Material.Slate
    pedestal.Position = Vector3.new(0, -0.25, 0)
    pedestal.Anchored = true
    pedestal.Parent = worldModel
    
    -- Light inside Viewport to create rim lights / orange candlelight from below
    local spotlight = Instance.new("SpotLight")
    spotlight.Color = Theme.Colors.Ember
    spotlight.Brightness = 5
    spotlight.Range = 10
    spotlight.Face = Enum.NormalId.Top
    spotlight.Parent = pedestal
    
    -- Create camera
    local camera = Instance.new("Camera")
    camera.FieldOfView = 35
    viewport.CurrentCamera = camera
    camera.Parent = viewport
    
    -- Clone local player character or fallback dummy
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    character.Archivable = true
    
    local characterClone = character:Clone()
    -- Clear scripts and physics anchors to prevent engine running code inside viewport
    for _, item in ipairs(characterClone:GetDescendants()) do
        if item:IsA("LuaSourceContainer") or item:IsA("Script") then
            item:Destroy()
        elseif item:IsA("BasePart") then
            item.Anchored = true
        end
    end
    
    -- Position character on pedestal
    characterClone:SetPrimaryPartCFrame(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0))
    characterClone.Parent = worldModel
    
    -- Gentle rotating camera loop
    local angle = 0
    self.conn = RunService.RenderStepped:Connect(function(dt)
        angle = angle + dt * 0.3 -- slow spin
        local camPos = Vector3.new(math.sin(angle) * 7, 2, math.cos(angle) * 7)
        camera.CFrame = CFrame.lookAt(camPos, Vector3.new(0, 1.5, 0))
    end)
end

function ViewportPedestal:willUnmount()
    if self.conn then
        self.conn:Disconnect()
        self.conn = nil
    end
end

function ViewportPedestal:render()
    return Roact.createElement("ViewportFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        [Roact.Ref] = self.viewportRef,
    })
end

return ViewportPedestal
