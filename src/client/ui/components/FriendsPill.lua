local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Theme = require(script.Parent.Parent.Theme)
local Typography = require(script.Parent.Parent.Typography)

local FriendsPill = Roact.Component:extend("FriendsPill")

function FriendsPill:render()
    local props = self.props
    local text = props.Text or "0 Friends Online"
    local layoutOrder = props.LayoutOrder or 0
    
    return Roact.createElement("Frame", {
        Size = UDim2.new(0, 200, 0, 36),
        BackgroundColor3 = Theme.Colors.BgPanelB,
        BorderSizePixel = 1,
        BorderColor3 = Theme.Colors.Ember,
        LayoutOrder = layoutOrder,
    }, {
        -- Gradient background
        Gradient = Roact.createElement("UIGradient", {
            Color = ColorSequence.new(Theme.Colors.BgPanelA, Theme.Colors.BgPanelB),
            Rotation = 135,
        }),
        
        -- UICorner
        Corner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
        
        -- Border Stroke
        Stroke = Roact.createElement("UIStroke", {
            Color = Theme.Colors.Ember,
            Thickness = 1,
            Transparency = 0.7,
        }),
        
        -- Inner layout
        Layout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 12),
        }),
        
        -- Padding
        Padding = Roact.createElement("UIPadding", {
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
        }),
        
        -- Friends Icon
        Icon = Roact.createElement("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = 1,
            Image = "rbxassetid://11419712030", -- A typical standard friends/users icon ID
            ImageColor3 = Theme.Colors.Ember,
            LayoutOrder = 1,
        }),
        
        -- Text Label
        Label = Roact.createElement("TextLabel", {
            Size = UDim2.new(1, -30, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Colors.Cream,
            Font = Typography.Fonts.Body,
            TextSize = Typography.Sizes.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            LayoutOrder = 2,
        })
    })
end

return FriendsPill
