local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Theme = require(script.Parent.Parent.Theme)
local Typography = require(script.Parent.Parent.Typography)

local StatPill = Roact.Component:extend("StatPill")

function StatPill:render()
    local props = self.props
    local label = props.Label or "STAT"
    local value = props.Value or "0"
    local layoutOrder = props.LayoutOrder or 0
    
    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Colors.BgPanelB,
        BorderSizePixel = 1,
        BorderColor3 = Theme.Colors.Brass,
        LayoutOrder = layoutOrder,
    }, {
        -- Linear Gradient (simulated using UIGradient)
        Gradient = Roact.createElement("UIGradient", {
            Color = ColorSequence.new(Theme.Colors.BgPanelA, Theme.Colors.BgPanelB),
            Rotation = 135,
        }),
        
        -- UICorner for rounded look
        Corner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
        
        -- UIStroke for elegant border
        Stroke = Roact.createElement("UIStroke", {
            Color = Theme.Colors.Brass,
            Thickness = 1,
            Transparency = 0.7,
        }),
        
        -- Celtic knot decorative overlay (represented as background image)
        DecorativeKnot = Roact.createElement("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://12345678", -- Placeholder Celtic knot asset ID
            ImageTransparency = 0.8,
            ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.new(0, 30, 0, 30),
        }),
        
        -- Horizontal padding
        Padding = Roact.createElement("UIPadding", {
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
        }),
        
        -- Label
        Label = Roact.createElement("TextLabel", {
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = string.upper(label) .. ":",
            TextColor3 = Theme.Colors.Cream,
            Font = Typography.Fonts.Body,
            TextSize = Typography.Sizes.Label,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        }),
        
        -- Value
        Value = Roact.createElement("TextLabel", {
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = value,
            TextColor3 = Theme.Colors.BrassValue,
            Font = Typography.Fonts.Display,
            TextSize = Typography.Sizes.Header,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
    })
end

return StatPill
