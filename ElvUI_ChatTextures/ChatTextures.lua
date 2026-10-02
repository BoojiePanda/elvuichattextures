local addonName = ...
local window
local fontWidgets = {}
local pathFields = {}
local textureRoot = "Interface\\AddOns\\" .. addonName .. "\\"

local groups = {
    { title = "Classes", entries = {
        { "Death Knight", "deathknight" },
        { "Demon Hunter", "demonhunter" },
        { "Druid", "druid" },
        { "Evoker", "evoker" },
        { "Hunter", "hunter" },
        { "Mage", "mage" },
        { "Monk", "monk" },
        { "Paladin", "paladin" },
        { "Priest", "priest" },
        { "Rogue", "rogue" },
        { "Shaman", "shaman" },
        { "Warlock", "warlock" },
        { "Warrior", "warrior" },
    } },
    { title = "Factions", entries = {
        { "Alliance", "alliance" },
        { "Horde", "horde" },
    } },
    { title = "Races", entries = {
        { "Blood Elf", "bloodelf" },
        { "Dark Iron Dwarf", "darkirondwarf" },
        { "Dracthyr", "dracthyr" },
        { "Draenei", "draenei" },
        { "Dwarf", "dwarf" },
        { "Earthen", "earthen" },
        { "Gnome", "gnome" },
        { "Goblin", "goblin" },
        { "Highmountain Tauren", "highmountaintauren" },
        { "Human", "human" },
        { "Kul Tiran", "kultiran" },
        { "Lightforged Draenei", "lightforgeddraenei" },
        { "Mag'har Orc", "magharorc" },
        { "Mechagnome", "mechagnome" },
        { "Night Elf", "nightelf" },
        { "Nightborne", "nightborne" },
        { "Orc", "orc" },
        { "Pandaren", "pandaren" },
        { "Tauren", "tauren" },
        { "Troll", "troll" },
        { "Undead", "undead" },
        { "Void Elf", "voidelf" },
        { "Vulpera", "vulpera" },
        { "Worgen", "worgen" },
        { "Zandalari Troll", "zandalaritroll" },
    } },
}

for _, group in ipairs(groups) do
    table.sort(group.entries, function(a, b)
        return a[1] < b[1]
    end)
end

local function GetFontPath()
    local engine = _G.ElvUI and _G.ElvUI[1]
    return engine and engine.media and engine.media.normFont or _G.STANDARD_TEXT_FONT
end

local function ApplyFonts()
    local font = GetFontPath()
    for _, entry in ipairs(fontWidgets) do
        entry.widget:SetFont(font, entry.size, "")
    end
end

local function RegisterFont(widget, size)
    fontWidgets[#fontWidgets + 1] = { widget = widget, size = size }
    widget:SetFont(GetFontPath(), size, "")
end

local function AddText(parent, text, size)
    local label = parent:CreateFontString(nil, "OVERLAY")
    RegisterFont(label, size)
    label:SetTextColor(1, 1, 1)
    label:SetJustifyH("LEFT")
    label:SetText(text)
    return label
end

local function CreatePathField(parent, path, offset)
    local field = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    field:SetPoint("TOPLEFT", 5, -offset)
    field:SetPoint("TOPRIGHT", 0, -offset)
    field:SetHeight(28)
    RegisterFont(field, 13)
    field:SetTextColor(1, 1, 1)
    field:SetTextInsets(8, 8, 0, 0)
    field:SetAutoFocus(false)
    field:SetMultiLine(false)
    field:SetText(path)
    field:SetCursorPosition(0)
    field:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    field:SetScript("OnMouseUp", function(self)
        self:HighlightText()
    end)
    field:SetScript("OnTextChanged", function(self, userInput)
        if userInput and self:GetText() ~= path then
            self:SetText(path)
            self:HighlightText()
        end
    end)
    field:SetScript("OnEditFocusLost", function(self)
        self:HighlightText(0, 0)
        self:SetCursorPosition(0)
    end)
    field:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    field:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    pathFields[#pathFields + 1] = field
end

local function CreateWindow()
    local frame = CreateFrame("Frame", "ElvUIChatTexturesWindow", UIParent, "BasicFrameTemplateWithInset")
    frame:Hide()
    frame:SetSize(740, 620)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    table.insert(UISpecialFrames, "ElvUIChatTexturesWindow")

    local dragArea = CreateFrame("Frame", nil, frame)
    dragArea:SetPoint("TOPLEFT", 1, -1)
    dragArea:SetPoint("TOPRIGHT", -48, -1)
    dragArea:SetHeight(24)
    dragArea:EnableMouse(true)
    dragArea:RegisterForDrag("LeftButton")
    dragArea:SetScript("OnDragStart", function() frame:StartMoving() end)
    dragArea:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    local title = frame.TitleText
    RegisterFont(title, 14)

    local shortcut = AddText(frame, "/ect", 14)
    shortcut:SetPoint("TOPLEFT", 20, -49)
    local instructions = AddText(frame, "Type /ec to open ElvUI settings. Click on Chat > Panels, then scroll to the bottom and paste in your chosen texture making sure you copied the complete path. Do this for both left and right panels.", 15)
    instructions:SetPoint("TOPLEFT", 20, -72)
    instructions:SetPoint("TOPRIGHT", -20, -72)
    instructions:SetHeight(80)
    instructions:SetJustifyV("TOP")
    instructions:SetWordWrap(true)

    local scroll = CreateFrame("ScrollFrame", nil, frame)
    scroll:SetPoint("TOPLEFT", 20, -170)
    scroll:SetPoint("BOTTOMRIGHT", -44, 20)
    scroll:EnableMouseWheel(true)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(676)
    scroll:SetScrollChild(content)

    local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 12, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 12, 0)
    ScrollUtil.InitScrollFrameWithScrollBar(scroll, scrollBar)
    scroll:SetPanExtent(64)

    local offset = 0
    for _, group in ipairs(groups) do
        local heading = AddText(content, group.title, 17)
        heading:SetPoint("TOPLEFT", 0, -offset)
        offset = offset + 32
        for _, entry in ipairs(group.entries) do
            local label = AddText(content, entry[1], 14)
            label:SetPoint("TOPLEFT", 0, -offset)
            CreatePathField(content, textureRoot .. entry[2] .. ".tga", offset + 20)
            offset = offset + 64
        end
        offset = offset + 20
    end
    content:SetHeight(offset)

    local function UpdateScrollRange()
        content:SetWidth(scroll:GetWidth())
        local range = math.max(0, content:GetHeight() - scroll:GetHeight())
        scroll:UpdateScrollChildRect()
        scroll:SetVerticalScroll(math.min(scroll:GetVerticalScroll(), range))
    end
    scroll:SetScript("OnSizeChanged", UpdateScrollRange)
    frame:SetScript("OnShow", function()
        ApplyFonts()
        local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "?"
        title:SetText("ElvUI Chat Textures ver " .. version)
        UpdateScrollRange()
    end)
    frame:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
        for _, field in ipairs(pathFields) do
            field:ClearFocus()
        end
    end)
    return frame
end

SLASH_ELVUICHATTEXTURES1 = "/ect"
SlashCmdList.ELVUICHATTEXTURES = function()
    if not window then
        window = CreateWindow()
    end
    window:SetShown(not window:IsShown())
end
