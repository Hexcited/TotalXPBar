-- TotalXPBar.lua


-- Event frame
local f = CreateFrame("Frame")

-- XP Table
local XPPerLevel = {
    400, 900, 1400, 2100, 2800, 3600, 4500, 5400, 6500, 7600,
    8800, 10100, 11400, 12900, 14400, 16000, 17700, 19400, 21300, 23200,
    25200, 27300, 29400, 31700, 34000, 36400, 38900, 41400, 44300, 47400,
    50800, 54500, 58600, 62800, 67100, 71600, 76100, 80800, 85700, 90700,
    95800, 101000, 106300, 111800, 117500, 123200, 129100, 135100, 141200, 147500,
    153900, 160400, 167100, 173900, 180800, 187900, 195000, 202300, 209800
}

-- Compute TOTAL XP (1 -> 60)
local TOTAL_XP_NEEDED = 0
for i = 1, #XPPerLevel do
    TOTAL_XP_NEEDED = TOTAL_XP_NEEDED + XPPerLevel[i]
end

-- Format numbers with commas
local function CommaValue(n)
    local s = tostring(n)
    local rev = s:reverse():gsub("(%d%d%d)","%1,"):reverse()
    rev = rev:gsub("^,", "")
    return rev
end

-- Create main frame
local main = CreateFrame("Frame", "TotalXPBarMainFrame", UIParent)
main:SetSize(500, 22)
main:SetPoint("TOP", UIParent, "TOP", 0, -10)

local padding = 2

-- Background texture
local bg = main:CreateTexture(nil, "BACKGROUND")
bg:SetPoint("TOPLEFT", main, "TOPLEFT", padding, -padding)
bg:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -padding, padding)
bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)

-- Border frame
local border = CreateFrame("Frame", nil, main, BackdropTemplateMixin and "BackdropTemplate" or nil)
border:SetAllPoints(main)
border:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
})
border:SetBackdropBorderColor(1,1,1,1)
border:SetFrameLevel(main:GetFrameLevel() + 2)

-- SavedVariables DB
if not TotalXPBarDB then TotalXPBarDB = {} end
if TotalXPBarDB.showStatusText == nil then TotalXPBarDB.showStatusText = false end
if TotalXPBarDB.showPercent == nil then TotalXPBarDB.showPercent = false end
if TotalXPBarDB.showCurrent == nil then TotalXPBarDB.showCurrent = false end
if TotalXPBarDB.unlocked == nil then TotalXPBarDB.unlocked = false end
if TotalXPBarDB.font == nil then TotalXPBarDB.font = "GameFontNormal" end

-- Status bar
local bar = CreateFrame("StatusBar", "TotalXPBarStatusBar", main)
bar:SetPoint("TOPLEFT", main, "TOPLEFT", padding, -padding)
bar:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -padding, padding)
bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
bar:GetStatusBarTexture():SetHorizTile(false)
bar:SetMinMaxValues(0, TOTAL_XP_NEEDED)
bar:SetValue(0)
bar:SetStatusBarColor(1, 0.84, 0)

-- Centered overlay text with fade
infoText = main:CreateFontString(nil, "OVERLAY", "GameFontNormal")
infoText:SetPoint("CENTER", main, "CENTER", 0, 0)
infoText:SetJustifyH("CENTER")
infoText:SetTextColor(1,1,1,1)
infoText:SetAlpha(TotalXPBarDB.showStatusText and 1 or 0)
infoText:SetDrawLayer("OVERLAY", 2)

-- Apply saved settings
local function ApplySavedSettings()
    infoText:SetFontObject(TotalXPBarDB.font or "GameFontNormal")
    infoText:SetAlpha(TotalXPBarDB.showStatusText and 1 or 0)
    TotalXPBar_UpdateBar()
end	

-- Fade functions
local function FadeIn(self)
    if not TotalXPBarDB.showStatusText then
        UIFrameFadeIn(infoText, 0.3, infoText:GetAlpha(), 1)
    end
end

local function FadeOut(self)
    if not TotalXPBarDB.showStatusText then
        UIFrameFadeOut(infoText, 0.3, infoText:GetAlpha(), 0)
    end
end

-- Enable mouse for main frame
main:EnableMouse(true)
main:SetScript("OnEnter", FadeIn)
main:SetScript("OnLeave", FadeOut)

-- Absolute XP
local function GetAbsoluteXP()
    local lvl = UnitLevel("player") or 1
    local xp = UnitXP("player") or 0
    local total = xp
    for i=1, math.max(0, lvl-1) do
        total = total + XPPerLevel[i]
    end
    return total
end

-- Update bar
function TotalXPBar_UpdateBar()
    if not UnitLevel("player") then return end
    local currentXP = GetAbsoluteXP()
    local percent = (currentXP / TOTAL_XP_NEEDED) * 100
    bar:SetMinMaxValues(0, TOTAL_XP_NEEDED)
    bar:SetValue(currentXP)
	
    local text
    if TotalXPBarDB.showCurrent then
		text = CommaValue(currentXP)
		if TotalXPBarDB.showPercent then
			text = text .. string.format(" (%.2f%%)", percent)
		end
	else
		text = CommaValue(currentXP) .. " / " .. CommaValue(TOTAL_XP_NEEDED)
		if TotalXPBarDB.showPercent then
			text = text .. string.format(" (%.2f%%)", percent)
		end
	end
	
    infoText:SetText(text)
end

-- Update position from saved DB
function TotalXPBar_UpdatePosition()
    main:ClearAllPoints()
    local x = TotalXPBarDB.posX or 0
    local y = TotalXPBarDB.posY or -10
    main:SetPoint("TOP", UIParent, "TOP", x, y)
end

-- Movable toggle
function SetBarMovable(movable)
    if movable then
        main:SetMovable(true)
        main:EnableMouse(true)
        main:RegisterForDrag("LeftButton")
        main:SetScript("OnDragStart", main.StartMoving)
        main:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local xOfs = self:GetLeft() + self:GetWidth()/2 - UIParent:GetWidth()/2
            local yOfs = self:GetTop() - UIParent:GetTop()
            TotalXPBarDB.posX = xOfs
            TotalXPBarDB.posY = yOfs
        end)
    else
        main:SetMovable(false)
        main:EnableMouse(true)
        main:SetScript("OnDragStart", nil)
        main:SetScript("OnDragStop", nil)
    end
end

-- Register events
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_XP_UPDATE")
f:RegisterEvent("PLAYER_LEVEL_UP")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        TotalXPBar_UpdatePosition()
        SetBarMovable(TotalXPBarDB.unlocked or false)
        ApplySavedSettings()
    end
    TotalXPBar_UpdateBar()
end)


-- Initial update
print("|cFFFFFF00# TotalXPBar|r: Loaded! /txp for Options or /txp help")
print("|cFFFFFF00# TotalXPBar|r: Version 1.1")

