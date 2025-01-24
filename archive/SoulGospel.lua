-- Addon namespace
local addonName, addonTable = ...
-- Saved variables
SoulGospelDB = SoulGospelDB or {}

-- Create a frame to handle events
local eventFrame = CreateFrame("Frame")

-- Function to initialize settings
local function InitializeSettings()
    SoulGospelDB.volume = SoulGospelDB.volume or 50
    SoulGospelDB.soundEnabled = SoulGospelDB.soundEnabled == nil or SoulGospelDB.soundEnabled
    SoulGospelDB.position = SoulGospelDB.position or {point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER", xOfs = 0, yOfs = 0}
    SoulGospelDB.frameSize = SoulGospelDB.frameSize or {width = 200, height = 150}
end

-- Function to play the sound with the specified volume
local function PlaySoulSound()
    if SoulGospelDB.soundEnabled then
        local originalVolume = tonumber(GetCVar("Sound_MasterVolume"))
        SetCVar("Sound_MasterVolume", SoulGospelDB.volume / 100)
        PlaySoundFile("Interface\\AddOns\\SoulGospel\\mine.mp3", "Master")
        C_Timer.After(5, function() SetCVar("Sound_MasterVolume", originalVolume) end) -- Restore volume after 5 seconds
    end
end

-- Initialize settings before creating the UI frame
InitializeSettings()

-- Create a frame for the UI
local uiFrame = CreateFrame("Frame", "SoulGospelFrame", UIParent, "BackdropTemplate")
uiFrame:SetSize(SoulGospelDB.frameSize.width, SoulGospelDB.frameSize.height)
uiFrame:SetPoint(SoulGospelDB.position.point, SoulGospelDB.position.relativeTo, SoulGospelDB.position.relativePoint, SoulGospelDB.position.xOfs, SoulGospelDB.position.yOfs)
uiFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
uiFrame:SetBackdropColor(0, 0, 0, 0.8)
uiFrame:SetBackdropBorderColor(0, 0, 0)
uiFrame:Hide() -- Hide the frame initially

-- Make the UI frame movable
uiFrame:EnableMouse(true)
uiFrame:SetMovable(true)
uiFrame:RegisterForDrag("LeftButton")
uiFrame:SetScript("OnDragStart", uiFrame.StartMoving)
uiFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    SoulGospelDB.position = {point = point, relativeTo = relativeTo or "UIParent", relativePoint = relativePoint, xOfs = xOfs, yOfs = yOfs}
end)
uiFrame:SetClampedToScreen(true)

-- Title text for the UI frame
local titleText = uiFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("TOP", uiFrame, "TOP", 0, -10)
titleText:SetText("|cFF800080Soul|r |cFFFFD700Gospel|r") -- Purple and golden text

-- Close button for the UI frame
local closeButton = CreateFrame("Button", nil, uiFrame)
closeButton:SetSize(24, 24)
closeButton:SetPoint("TOPRIGHT", uiFrame, "TOPRIGHT", -5, -5)
closeButton:SetNormalTexture("Interface\\AddOns\\SoulGospel\\close.png")
closeButton:SetHighlightTexture("Interface\\AddOns\\SoulGospel\\close.png")
closeButton:SetScript("OnClick", function()
    uiFrame:Hide()
end)

-- Function to create a slider
local function CreateSlider(parent, label, minVal, maxVal, defaultVal, yOffset, onValueChanged)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOP", parent, "TOP", 0, yOffset)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValue(defaultVal)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(150)

    local sliderLabel = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sliderLabel:SetPoint("BOTTOM", slider, "TOP", 0, 0)
    sliderLabel:SetText(label)

    local sliderValue = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sliderValue:SetPoint("TOP", slider, "BOTTOM", 0, 0)
    sliderValue:SetText(slider:GetValue())

    slider:SetScript("OnValueChanged", function(self, value)
        sliderValue:SetText(value)
        if onValueChanged then
            onValueChanged(value)
        end
    end)

    return slider
end

-- Function to create a checkbox
local function CreateCheckbox(parent, label, yOffset, tooltip, onClick)
    local checkbox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    checkbox.Text:SetText(label)
    checkbox.tooltip = tooltip
    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    checkbox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    checkbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            self.Text:SetTextColor(1, 1, 0) -- Yellow
            if onClick then onClick(true) end
        else
            self.Text:SetTextColor(0.5, 0.5, 0.5) -- Gray
            if onClick then onClick(false) end
        end
    end)
    return checkbox
end

-- Create the sound enabled checkbox
local soundCheckbox = CreateCheckbox(uiFrame, "Enable Sound", -40, "Toggle the sound on or off", function(checked)
    SoulGospelDB.soundEnabled = checked
end)

-- Function to initialize the checkbox state
local function InitializeCheckbox(checkbox, isChecked)
    checkbox:SetChecked(isChecked)
    if isChecked then
        checkbox.Text:SetTextColor(1, 1, 0) -- Yellow
    else
        checkbox.Text:SetTextColor(0.5, 0.5, 0.5) -- Gray
    end
end

-- Create the volume slider
local volumeSlider = CreateSlider(uiFrame, "Volume", 1, 100, SoulGospelDB.volume, -80, function(value)
    SoulGospelDB.volume = value
end)

-- Initialize settings and UI elements
local function InitializeUI()
    InitializeCheckbox(soundCheckbox, SoulGospelDB.soundEnabled)
    volumeSlider:SetValue(SoulGospelDB.volume)
end

-- Create the "Test" button
local testButton = CreateFrame("Button", nil, uiFrame, "UIPanelButtonTemplate")
testButton:SetSize(100, 24)
testButton:SetPoint("BOTTOM", uiFrame, "BOTTOM", 0, 10)
testButton:SetText("Test")
testButton:SetNormalFontObject("GameFontNormal")
testButton:SetHighlightFontObject("GameFontHighlight")
testButton:SetScript("OnClick", function()
    PlaySoulSound()
end)

-- Cooldown variable to prevent sound from playing too frequently
local lastPlayTime = 0
local cooldown = 5 -- Cooldown in seconds

-- Function to play the sound with the specified volume
local function PlaySoulSound()
    local currentTime = GetTime()
    if SoulGospelDB.soundEnabled and (currentTime - lastPlayTime) >= cooldown then
        lastPlayTime = currentTime
        local originalVolume = tonumber(GetCVar("Sound_MasterVolume"))
        SetCVar("Sound_MasterVolume", SoulGospelDB.volume / 100)
        PlaySoundFile("Interface\\AddOns\\SoulGospel\\mine.mp3", "Master")
        C_Timer.After(5, function() SetCVar("Sound_MasterVolume", originalVolume) end) -- Restore volume after 5 seconds
    end
end

-- Event handler for soul shard
local frame = CreateFrame("Frame")

frame:RegisterEvent("BAG_UPDATE_DELAYED")

frame:SetScript("OnEvent", function(self, event)
    if event == "BAG_UPDATE_DELAYED" then
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemID = C_Container.GetContainerItemID(bag, slot)
                if itemID == 6265 then
                    PlaySoulSound()
                    return
                end
            end
        end
    end
end)

-- Register the event handlers
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("CHAT_MSG_LOOT")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")  -- Add this line to register for system messages
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        OnCombatLogEvent(self, event, CombatLogGetCurrentEventInfo())
    elseif event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_SYSTEM" then  -- 
        OnChatMessage(self, event, ...)
    end
end)

-- Slash command handler
SLASH_SOULGOSPEL1 = "/souls"
SlashCmdList["SOULGOSPEL"] = function(msg)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    if command == "on" then
        SoulGospelDB.soundEnabled = true
        print("|cFF800080/souls|r Sound enabled.")
    elseif command == "off" then
        SoulGospelDB.soundEnabled = false
        print("|cFF800080/souls|r Sound disabled.")
    elseif command == "volume" then
        local volume = tonumber(rest)
        if volume and volume >= 1 and volume <= 100 then
            SoulGospelDB.volume = volume
            print("|cFF800080/souls|r Volume set to " .. volume .. ".")
        else
            print("|cFF800080/souls|r Invalid volume. Please enter a value between 1 and 100.")
        end
    elseif command == "menu" then
        if uiFrame:IsShown() then
            uiFrame:Hide()
        else
            uiFrame:Show()
        end
    else
        print("|cFF800080Souls|r Commands:")
        print("|cFF800080/souls|r on - Enable sound")
        print("|cFF800080/souls|r off - Disable sound")
        print("|cFF800080/souls|r volume <1-100> - Set volume")
        print("|cFF800080/souls|r menu - Open settings menu")
    end
end

-- Event frame for saving settings
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize settings and UI elements
        InitializeSettings()
        InitializeUI()
    elseif event == "PLAYER_LOGOUT" then
        -- Save current settings
        SoulGospelDB.soundEnabled = soundCheckbox:GetChecked()
        SoulGospelDB.volume = volumeSlider:GetValue()
        -- Save frame position
        local point, relativeTo, relativePoint, xOfs, yOfs = uiFrame:GetPoint()
        SoulGospelDB.position = {point = point, relativeTo = relativeTo or "UIParent", relativePoint = relativePoint, xOfs = xOfs, yOfs = yOfs}
        -- Save frame size
        SoulGospelDB.frameSize = {width = uiFrame:GetWidth(), height = uiFrame:GetHeight()}
    end
end)
