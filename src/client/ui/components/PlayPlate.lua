local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Theme = require(script.Parent.Parent.Theme)
local Typography = require(script.Parent.Parent.Typography)

local PlayPlate = Roact.Component:extend("PlayPlate")

function PlayPlate:render()
    local props = self.props
    local text = props.Text or "PLAY"
    local onClick = props.OnClick
    local layoutOrder = props.LayoutOrder or 0
    
    return Roact.createElement("ImageButton", {
        Size = UDim2.new(0, 320, 0, 100),
        BackgroundColor3 = Theme.Colors.BgPlateB,
        BorderSizePixel = 3,
        BorderColor3 = Theme.Colors.Brass,
        LayoutOrder = layoutOrder,
        [Roact.Event.Activated] = onClick,
    }, {
        -- Linear Gradient (UIGradient)
        Gradient = Roact.createElement("UIGradient", {
            Color = ColorSequence.new(Theme.Colors.BgPlateA, Theme.Colors.BgPlateB),
            Rotation = 135,
        }),
        
        -- Corner rivets
        RivetTL = Roact.createElement("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = Color3.fromRGB(42, 42, 42),
        }, {
            Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0.5, 0) }),
            Stroke = Roact.createElement("UIStroke", { Color = Color3.fromRGB(10, 10, 10), Thickness = 1 }),
        }),
        
        RivetTR = Roact.createElement("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(1, -18, 0, 8),
            BackgroundColor3 = Color3.fromRGB(42, 42, 42),
        }, {
            Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0.5, 0) }),
            Stroke = Roact.createElement("UIStroke", { Color = Color3.fromRGB(10, 10, 10), Thickness = 1 }),
        }),
        
        RivetBL = Roact.createElement("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0, 8, 1, -18),
            BackgroundColor3 = Color3.fromRGB(42, 42, 42),
        }, {
            Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0.5, 0) }),
            Stroke = Roact.createElement("UIStroke", { Color = Color3.fromRGB(10, 10, 10), Thickness = 1 }),
        }),
        
        RivetBR = Roact.createElement("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(1, -18, 1, -18),
            BackgroundColor3 = Color3.fromRGB(42, 42, 42),
        }, {
            Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0.5, 0) }),
            Stroke = Roact.createElement("UIStroke", { Color = Color3.fromRGB(10, 10, 10), Thickness = 1 }),
        }),
        
        -- Plate Stroke
        Stroke = Roact.createElement("UIStroke", {
            Color = Theme.Colors.Brass,
            Thickness = 3,
        }),
        
        -- Text Label
        Label = Roact.createElement("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Colors.Cream,
            Font = Typography.Fonts.Display,
            TextSize = Typography.Sizes.Play,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
    })
end

return PlayPlate
