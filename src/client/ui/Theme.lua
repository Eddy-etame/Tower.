local Theme = {
    Colors = {
        BgBody = Color3.fromRGB(15, 13, 12),       -- #0F0D0C
        BgPanelA = Color3.fromRGB(47, 43, 40),     -- rgba(47, 43, 40)
        BgPanelB = Color3.fromRGB(25, 23, 21),     -- rgba(25, 23, 21)
        BgPlateA = Color3.fromRGB(80, 70, 60),     -- rgba(80, 70, 60)
        BgPlateB = Color3.fromRGB(40, 35, 30),     -- rgba(40, 35, 30)
        
        Brass = Color3.fromRGB(176, 138, 74),      -- #B08A4A
        BrassValue = Color3.fromRGB(168, 133, 71), -- #A88547
        Cream = Color3.fromRGB(232, 223, 206),     -- #E8DFCE
        Ember = Color3.fromRGB(217, 118, 53),      -- #D97635
        Crimson = Color3.fromRGB(139, 26, 26),    -- #8B1A1A
    },
    Transitions = {
        FadeDuration = 0.3,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.Out,
    }
}

return Theme
