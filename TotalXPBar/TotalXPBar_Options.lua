-- TotalXPBar_Options.lua
-- /txp

-- Panel
local panel
if BackdropTemplateMixin then
    panel = CreateFrame("Frame", "TotalXPBarOptionsFrame", UIParent, "BackdropTemplate")
else
    panel = CreateFrame("Frame", "TotalXPBarOptionsFrame", UIParent)
end
panel:SetSize(500, 500)
panel:SetPoint("CENTER")
panel:SetFrameStrata("DIALOG")
panel:SetFrameLevel(100)
panel:Hide()
tinsert(UISpecialFrames, "TotalXPBarOptionsFrame")

-- Backdrop
if panel.SetBackdrop then
    panel:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile     = true,
        tileSize = 32,
        edgeSize = 16,
        insets   = { left = 4, right = 4, top = 4, bottom = 4 }
    })
end

-- Draggable
panel:EnableMouse(true)
panel:SetMovable(true)
panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart", panel.StartMoving)
panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

-- Title
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("TotalXPBar Options")

-- Subtitle
local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Configure TotalXPBar status bar or status text.")

-- Close button
local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -4)

-- Slash command
SLASH_TOTALXPBAR1 = "/txp"
SlashCmdList["TOTALXPBAR"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "" then
        if panel:IsShown() then
            panel:Hide()
        else
            panel:Show()
        end
    elseif msg == "help" then
        print("|cFFFFFF00# TotalXPBar|r commands:")
        print("/txp - Toggle options panel")
        print("/txp help - Show this help message")
        print("/txp unlock - Unlock the XP bar for moving")
        print("/txp lock - Lock the XP bar in place")
        print("/txp reset - Reset the XP bar position")
    elseif msg == "unlock" then
        TotalXPBarDB.unlocked = true
        SetBarMovable(true)
        print("|cFFFFFF00# TotalXPBar|r: Bar unlocked.")
    elseif msg == "lock" then
        TotalXPBarDB.unlocked = false
        SetBarMovable(false)
        print("|cFFFFFF00# TotalXPBar|r: Bar locked.")
    elseif msg == "reset" then
        TotalXPBarDB.posX = 0
        TotalXPBarDB.posY = -10
        if TotalXPBar_UpdatePosition then TotalXPBar_UpdatePosition() end
        print("|cFFFFFF00# TotalXPBar|r: Position reset.")
    else
        print("|cFFFFFF00# TotalXPBar|r: Unknown command. Type /txp help for options.")
    end
end

-- === ScrollFrame Setup ===
local scrollFrame = CreateFrame("ScrollFrame", "TotalXPBar_ScrollFrame", panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -20)
scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 60)

-- Content frame inside scrollFrame
local content = CreateFrame("Frame", "TotalXPBar_ScrollContent", scrollFrame)
content:SetSize(1, 1)
scrollFrame:SetScrollChild(content)

-- Create checkboxes
local function CreateCheckbox(name, parent, label, anchorTo, x, y)
    local cb = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", x, y)
    cb.text = _G[cb:GetName().."Text"]
    cb.text:SetText(label)
    return cb
end

-- Create a slider
local function CreateSlider(name, parent, anchorTo, x, y, minVal, maxVal, step, label)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", x, y)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    _G[slider:GetName().."Text"]:SetText(label)
    _G[slider:GetName().."Low"]:SetText(minVal)
    _G[slider:GetName().."High"]:SetText(maxVal)
    slider:SetValue((minVal + maxVal)/2)
    return slider
end

-- === Separator ===
local separator = content:CreateTexture(nil, "ARTWORK")
separator:SetColorTexture(1, 1, 1, 1)
separator:SetHeight(1)
separator:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -10)
separator:SetPoint("RIGHT", content, "RIGHT", -16, 0)

-- === Status Text ===
local statusTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
statusTitle:SetPoint("TOPLEFT", separator, "BOTTOMLEFT", 0, -10)
statusTitle:SetText("Status Text")

-- Font Dropdown
local fontDropdown = CreateFrame("Frame", "TotalXPBar_FontDropdown", content, "UIDropDownMenuTemplate")
fontDropdown:SetPoint("TOPRIGHT", separator, "BOTTOMRIGHT", 450, -25)

-- Font Dropdown Title
local fontLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
fontLabel:SetPoint("BOTTOMLEFT", fontDropdown, "TOPLEFT", 20, 3)
fontLabel:SetText("Font")

-- Fonts
local availableFonts = {
    { text = "Default", value = "GameFontNormal" },
    { text = "Default Small", value = "GameFontNormalSmall" },
    { text = "Default Large", value = "GameFontHighlightLarge" },
}

-- Font Display text
local function GetFontText(value)
    for _, font in ipairs(availableFonts) do
        if font.value == value then
            return font.text
        end
    end
    return "Default"
end

-- Initialize dropdown
UIDropDownMenu_Initialize(fontDropdown, function(self, level)
    for _, font in ipairs(availableFonts) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = font.text
        info.func = function(self)
            TotalXPBarDB.font = font.value
            infoText:SetFontObject(TotalXPBarDB.font)
            UIDropDownMenu_SetSelectedValue(fontDropdown, font.value)
            UIDropDownMenu_SetText(font.text, fontDropdown)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

-- Set default/selected value
UIDropDownMenu_SetWidth(fontDropdown, 140)
UIDropDownMenu_SetSelectedValue(fontDropdown, TotalXPBarDB.font)
UIDropDownMenu_SetText(fontDropdown, GetFontText(TotalXPBarDB.font))

-- Default Color
if not TotalXPBarDB.fontColor then
    TotalXPBarDB.fontColor = {1, 1, 1} -- white
end
infoText:SetTextColor(unpack(TotalXPBarDB.fontColor))

-- Font Color Title
local colorLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
colorLabel:SetPoint("TOPRIGHT", separator, "BOTTOMRIGHT", 345, -62)
colorLabel:SetText("Font Color")

-- Change Color
local colorButton = CreateFrame("Button", "TotalXPBar_ColorButton", content, "UIPanelButtonTemplate")
colorButton:SetSize(100, 22)
colorButton:SetPoint("TOPLEFT", colorLabel, "BOTTOMLEFT", 28, -7)
colorButton:SetText("Change Color")

-- ColorPicker
colorButton:SetScript("OnClick", function()
    local r, g, b = unpack(TotalXPBarDB.fontColor)
    ColorPickerFrame.func = function()
        local newR, newG, newB = ColorPickerFrame:GetColorRGB()
        TotalXPBarDB.fontColor = {newR, newG, newB}
        infoText:SetTextColor(newR, newG, newB)
        
        RBox:SetText(math.floor(newR*255))
        GBox:SetText(math.floor(newG*255))
        BBox:SetText(math.floor(newB*255))
    end
    ColorPickerFrame.cancelFunc = function(prev)
        local pr, pg, pb = unpack(prev)
        TotalXPBarDB.fontColor = {pr, pg, pb}
        infoText:SetTextColor(pr, pg, pb)
        RBox:SetText(math.floor(pr*255))
        GBox:SetText(math.floor(pg*255))
        BBox:SetText(math.floor(pb*255))
    end
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame.previousValues = {r, g, b}
    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end)

-- EditBoxes (R, G, B)
local function CreateColorBox(name, anchor, label, default)
    local eb = CreateFrame("EditBox", name, content, "InputBoxTemplate")
    eb:SetSize(40, 20)
    eb:SetAutoFocus(false)
    eb:SetNumeric(true)
    eb:SetMaxLetters(3)
    eb:SetPoint("LEFT", anchor, "RIGHT", 14, 0)
    eb:SetText(default)
    
    local lbl = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    lbl:SetPoint("BOTTOMLEFT", eb, "TOPLEFT", 0, 2)
    lbl:SetText(label)
    
    return eb
end

local rVal, gVal, bVal = unpack(TotalXPBarDB.fontColor)
rVal, gVal, bVal = math.floor(rVal*255), math.floor(gVal*255), math.floor(bVal*255)

local RBox = CreateColorBox("TotalXPBar_RBox", colorLabel, "R", rVal)
RBox:ClearAllPoints()
RBox:SetPoint("TOPLEFT", colorLabel, "BOTTOMLEFT", 5, -45)
local GBox = CreateColorBox("TotalXPBar_GBox", RBox, "G", gVal)
local BBox = CreateColorBox("TotalXPBar_BBox", GBox, "B", bVal)

-- Input changes
local function OnColorBoxEnter(self)
    local r = tonumber(RBox:GetText()) or 0
    local g = tonumber(GBox:GetText()) or 0
    local b = tonumber(BBox:GetText()) or 0

    r = math.min(255, math.max(0, r))/255
    g = math.min(255, math.max(0, g))/255
    b = math.min(255, math.max(0, b))/255

    TotalXPBarDB.fontColor = {r, g, b}
    infoText:SetTextColor(r, g, b)
end

RBox:SetScript("OnEnterPressed", OnColorBoxEnter)
GBox:SetScript("OnEnterPressed", OnColorBoxEnter)
BBox:SetScript("OnEnterPressed", OnColorBoxEnter)

-- Default hint (255,255,255)
local defaultHint = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
defaultHint:SetPoint("TOPLEFT", RBox, "BOTTOMLEFT", 0, -2)
defaultHint:SetText("(Default: 255, 255, 255)")


-- Checkboxes
local statusCB = CreateCheckbox("TotalXPBar_StatusCB", content, "Show Status Text", statusTitle, 0, -5)
statusCB:SetChecked(TotalXPBarDB.showStatusText)
statusCB:SetScript("OnClick", function(self)
    local checked = self:GetChecked()
    TotalXPBarDB.showStatusText = checked
    if checked then
        infoText:SetAlpha(1)
    else
        infoText:SetAlpha(0)
    end
    TotalXPBar_UpdateBar()
end)

local currentCB = CreateCheckbox("TotalXPBar_CurrentCB", content, "Show Current", statusCB, 0, -5)
currentCB:SetChecked(TotalXPBarDB.showCurrent)
currentCB:SetScript("OnClick", function(self)
    TotalXPBarDB.showCurrent = self:GetChecked()
    TotalXPBar_UpdateBar()
end)

local percentCB = CreateCheckbox("TotalXPBar_PercentCB", content, "Show Percent", currentCB, 0, -5)
percentCB:SetChecked(TotalXPBarDB.showPercent)
percentCB:SetScript("OnClick", function(self)
    TotalXPBarDB.showPercent = self:GetChecked()
    TotalXPBar_UpdateBar()
end)

-- Refresh checkboxes and font dropdown
panel:SetScript("OnShow", function()
    -- Refresh Checkboxes
    statusCB:SetChecked(TotalXPBarDB.showStatusText)
    currentCB:SetChecked(TotalXPBarDB.showCurrent)
    percentCB:SetChecked(TotalXPBarDB.showPercent)

    -- Refresh Font Dropdown
    UIDropDownMenu_SetSelectedValue(fontDropdown, TotalXPBarDB.font)
    UIDropDownMenu_SetText(GetFontText(TotalXPBarDB.font), fontDropdown)
end)

-- Descriptions
local statusCBDesc = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
statusCBDesc:SetPoint("TOPLEFT", statusCB, "BOTTOMLEFT", 30, 6)
statusCBDesc:SetText("(Default: Mouseover)")

local currentCBDesc = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
currentCBDesc:SetPoint("TOPLEFT", currentCB, "BOTTOMLEFT", 30, 6)
currentCBDesc:SetText("(Default: Current/Max)")

-- === Buttons at bottom of panel ===
local unlockBtn = CreateFrame("Button", "TotalXPBar_UnlockBtn", panel, "UIPanelButtonTemplate")
unlockBtn:SetSize(120, 22)
unlockBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 26)
unlockBtn:SetText(TotalXPBarDB.unlocked and "Lock" or "Unlock")
unlockBtn:SetScript("OnClick", function(self)
    TotalXPBarDB.unlocked = not TotalXPBarDB.unlocked
    SetBarMovable(TotalXPBarDB.unlocked)
    self:SetText(TotalXPBarDB.unlocked and "Lock" or "Unlock")
end)

local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetBtn:SetSize(120, 22)
resetBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 26)
resetBtn:SetText("Reset Position")
resetBtn:SetScript("OnClick", function()
    TotalXPBarDB.posX = 0
    TotalXPBarDB.posY = -10
    if TotalXPBar_UpdatePosition then TotalXPBar_UpdatePosition() end
end)

-- Dev Subtext
local devSubtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
devSubtext:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 8)
devSubtext:SetText("v1.1 | (https://github.com/Hexcited)")
