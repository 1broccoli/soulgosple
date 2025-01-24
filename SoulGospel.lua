-- Addon namespace
local addonName, addonTable = ...
-- Saved variables
SoulGospelDB = SoulGospelDB or {
    volume = 50,
    soundEnabled = true,
    playAllSounds = true,  -- Add setting to play all sounds or only PvP sounds
    position = {point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER", xOfs = 0, yOfs = 0},
    frameSize = {width = 200, height = 150}
}

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
uiFrame:SetSize(SoulGospelDB.frameSize.width, SoulGospelDB.frameSize.height + 65) -- Adjust the frame's height
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
titleText:SetText("|cFF39FF14Soul Gospel|r") -- Neon green text

-- Texture on the left of the title
local leftTexture = uiFrame:CreateTexture(nil, "OVERLAY")
leftTexture:SetSize(24, 24)
leftTexture:SetPoint("RIGHT", titleText, "LEFT", -5, 0)
leftTexture:SetTexture("Interface\\AddOns\\SoulGospel\\sglol3.png")

-- Animation group for left pulsating effect
local leftPulsate = leftTexture:CreateAnimationGroup()
local leftScaleUp = leftPulsate:CreateAnimation("Scale")
leftScaleUp:SetScale(1.2, 1.2)
leftScaleUp:SetDuration(0.5)
leftScaleUp:SetSmoothing("IN_OUT")

local leftScaleDown = leftPulsate:CreateAnimation("Scale")
leftScaleDown:SetScale(0.8333, 0.8333) -- Inverse of 1.2 to return to original size
leftScaleDown:SetDuration(0.5)
leftScaleDown:SetSmoothing("IN_OUT")
leftScaleDown:SetStartDelay(0.5)

local leftAlphaChange = leftPulsate:CreateAnimation("Alpha")
leftAlphaChange:SetFromAlpha(1)
leftAlphaChange:SetToAlpha(0.5)
leftAlphaChange:SetDuration(0.5)
leftAlphaChange:SetSmoothing("IN_OUT")

leftPulsate:SetLooping("REPEAT")
leftPulsate:Play()

-- Texture on the right of the title
local rightTexture = uiFrame:CreateTexture(nil, "OVERLAY")
rightTexture:SetSize(24, 24)
rightTexture:SetPoint("LEFT", titleText, "RIGHT", 5, 0)
rightTexture:SetTexture("Interface\\AddOns\\SoulGospel\\sglol3.png")

-- Animation group for right pulsating effect
local rightPulsate = rightTexture:CreateAnimationGroup()
local rightScaleUp = rightPulsate:CreateAnimation("Scale")
rightScaleUp:SetScale(1.2, 1.2)
rightScaleUp:SetDuration(0.5)
rightScaleUp:SetSmoothing("IN_OUT")

local rightScaleDown = rightPulsate:CreateAnimation("Scale")
rightScaleDown:SetScale(0.8333, 0.8333) -- Inverse of 1.2 to return to original size
rightScaleDown:SetDuration(0.5)
rightScaleDown:SetSmoothing("IN_OUT")
rightScaleDown:SetStartDelay(0.5)

local rightAlphaChange = rightPulsate:CreateAnimation("Alpha")
rightAlphaChange:SetFromAlpha(1)
rightAlphaChange:SetToAlpha(0.5)
rightAlphaChange:SetDuration(0.5)
rightAlphaChange:SetSmoothing("IN_OUT")

rightPulsate:SetLooping("REPEAT")
rightPulsate:Play()

-- Texture next to the title
local titleTexture = uiFrame:CreateTexture(nil, "OVERLAY")
titleTexture:SetSize(24, 24)
titleTexture:SetPoint("RIGHT", titleText, "LEFT", -5, 0)
titleTexture:SetTexture("Interface\\AddOns\\SoulGospel\\soulslol.png")

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
    sliderLabel:SetPoint("BOTTOM", slider, "TOP", 0, 10)  -- Move the slider slightly down from its title
    sliderLabel:SetText(label)

    local sliderValue = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sliderValue:SetPoint("TOP", slider, "BOTTOM", 0, -10)
    sliderValue:SetText(slider:GetValue())

    slider:SetScript("OnValueChanged", function(self, value)
        sliderValue:SetText(value)
        if onValueChanged then
            onValueChanged(value)
        end
    end)

    local inputBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    inputBox:SetSize(50, 20)
    inputBox:SetPoint("CENTER", sliderLabel, "CENTER")  -- Place input box over the title's text
    inputBox:SetAutoFocus(true)
    inputBox:SetNumeric(true)
    inputBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value then
            slider:SetValue(value)
        end
        self:Hide()
        sliderLabel:Show()  -- Show the title text
    end)
    inputBox:SetScript("OnEscapePressed", function(self)
        self:Hide()
        sliderLabel:Show()  -- Show the title text
    end)
    inputBox:Hide()

    sliderLabel:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            inputBox:SetText(tostring(math.floor(slider:GetValue())))
            inputBox:Show()
            self:Hide()  -- Hide the title text
        end
    end)

    sliderLabel:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click title to set volume", 1, 1, 1)
        GameTooltip:Show()
    end)
    sliderLabel:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
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

-- Create the play all sounds checkbox
local playAllSoundsCheckbox = CreateCheckbox(uiFrame, "Play All Sounds", -70, "Uncheck for PvP only", function(checked)
    SoulGospelDB.playAllSounds = checked
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
local volumeSlider = CreateSlider(uiFrame, "|cFFA020F0Volume|r", 1, 100, SoulGospelDB.volume, -125, function(value)
    SoulGospelDB.volume = value
end)

-- Initialize settings and UI elements
local function InitializeUI()
    InitializeCheckbox(soundCheckbox, SoulGospelDB.soundEnabled)
    InitializeCheckbox(playAllSoundsCheckbox, SoulGospelDB.playAllSounds)
    volumeSlider:SetValue(SoulGospelDB.volume)
end

-- Create the "Test" button
local testButton = CreateFrame("Button", nil, uiFrame)
testButton:SetSize(40, 40)
testButton:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -30)

-- Set button texture
testButton:SetNormalTexture("Interface\\AddOns\\SoulGospel\\testsound.png")

-- Set button script to play sound
testButton:SetScript("OnClick", function()
    PlaySoulSound()
end)

-- Add tooltip to the button
testButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Click to Test volume", 0, 1, 0) -- Neon green text
    GameTooltip:Show()
end)

testButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
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

-- Function to check if the player is a warlock
local function IsPlayerWarlock()
    local _, class = UnitClass("player")
    return class == "WARLOCK"
end

-- Create the prompt frame
local promptFrame = CreateFrame("Frame", "SoulGospelPromptFrame", UIParent, "BackdropTemplate")
promptFrame:SetSize(300, 150)  -- Adjust the frame's height
promptFrame:SetPoint("CENTER")
promptFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
promptFrame:SetBackdropColor(0, 0, 0, 0.8)
promptFrame:SetBackdropBorderColor(0, 0, 0)
promptFrame:EnableMouse(true)
promptFrame:SetMovable(true)
promptFrame:RegisterForDrag("LeftButton")
promptFrame:SetScript("OnDragStart", promptFrame.StartMoving)
promptFrame:SetScript("OnDragStop", promptFrame.StopMovingOrSizing)
promptFrame:Hide() -- Hide the frame initially

-- Title text for the prompt frame
local promptTitleText = promptFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
promptTitleText:SetPoint("TOP", promptFrame, "TOP", 0, -10)
promptTitleText:SetText("|cFF39FF14Soul Gospel|r") -- Neon green text

-- Warning text in red color
local warningText = promptFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
warningText:SetPoint("TOP", promptTitleText, "BOTTOM", 0, -10)
warningText:SetText("|cFFFF0000WARNING|r") -- Red text

-- Texture to the left of the warning text
local leftPulsatingTexture = promptFrame:CreateTexture(nil, "OVERLAY")
leftPulsatingTexture:SetSize(24, 24)
leftPulsatingTexture:SetPoint("RIGHT", warningText, "LEFT", -10, 0)
leftPulsatingTexture:SetTexture("Interface\\AddOns\\SoulGospel\\sglol3.png")

-- Animation group for left pulsating effect
local leftPulsate = leftPulsatingTexture:CreateAnimationGroup()
local leftScaleUp = leftPulsate:CreateAnimation("Scale")
leftScaleUp:SetScale(1.2, 1.2)
leftScaleUp:SetDuration(0.5)
leftScaleUp:SetSmoothing("IN_OUT")

local leftScaleDown = leftPulsate:CreateAnimation("Scale")
leftScaleDown:SetScale(0.8333, 0.8333) -- Inverse of 1.2 to return to original size
leftScaleDown:SetDuration(0.5)
leftScaleDown:SetSmoothing("IN_OUT")
leftScaleDown:SetStartDelay(0.5)

local leftColorChange = leftPulsate:CreateAnimation("Alpha")
leftColorChange:SetFromAlpha(1)
leftColorChange:SetToAlpha(0)
leftColorChange:SetDuration(0.5)
leftColorChange:SetSmoothing("IN_OUT")

leftPulsate:SetLooping("REPEAT")
leftPulsate:Play()

-- Texture to the right of the warning text
local rightPulsatingTexture = promptFrame:CreateTexture(nil, "OVERLAY")
rightPulsatingTexture:SetSize(24, 24)
rightPulsatingTexture:SetPoint("LEFT", warningText, "RIGHT", 10, 0)
rightPulsatingTexture:SetTexture("Interface\\AddOns\\SoulGospel\\sglol3.png")

-- Animation group for right pulsating effect
local rightPulsate = rightPulsatingTexture:CreateAnimationGroup()
local rightScaleUp = rightPulsate:CreateAnimation("Scale")
rightScaleUp:SetScale(1.2, 1.2)
rightScaleUp:SetDuration(0.5)
rightScaleUp:SetSmoothing("IN_OUT")

local rightScaleDown = rightPulsate:CreateAnimation("Scale")
rightScaleDown:SetScale(0.8333, 0.8333) -- Inverse of 1.2 to return to original size
rightScaleDown:SetDuration(0.5)
rightScaleDown:SetSmoothing("IN_OUT")
rightScaleDown:SetStartDelay(0.5)

local rightColorChange = rightPulsate:CreateAnimation("Color")
local rightColorChange = rightPulsate:CreateAnimation("Alpha")
rightColorChange:SetFromAlpha(1)
rightColorChange:SetToAlpha(0)
rightColorChange:SetDuration(0.5)
rightColorChange:SetSmoothing("IN_OUT")
rightPulsate:SetLooping("REPEAT")
rightPulsate:Play()

-- Text explaining the addon
local promptText = promptFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
promptText:SetPoint("TOP", warningText, "BOTTOM", 0, -10)
promptText:SetWidth(260)  -- Set width to ensure word wrapping
promptText:SetText("|cFFFFFFFFThis addon is designed for |cFF8787EDwarlocks|r. If you are not a |cFF8787EDwarlock|r, it is recommended to disable this addon to avoid unnecessary functionality.|r")
promptText:SetWordWrap(true)

-- Texture on the left of the title
local leftTexture = promptFrame:CreateTexture(nil, "OVERLAY")
leftTexture:SetSize(24, 24)
leftTexture:SetPoint("RIGHT", promptTitleText, "LEFT", -5, 0)
leftTexture:SetTexture("Interface\\AddOns\\SoulGospel\\sglol.png")

-- Texture on the right of the title
local rightTexture = promptFrame:CreateTexture(nil, "OVERLAY")
rightTexture:SetSize(24, 24)
rightTexture:SetPoint("LEFT", promptTitleText, "RIGHT", 5, 0)
rightTexture:SetTexture("Interface\\AddOns\\SoulGospel\\sglol.png")

-- Close button for the prompt frame
local promptCloseButton = CreateFrame("Button", nil, promptFrame)
promptCloseButton:SetSize(24, 24)
promptCloseButton:SetPoint("TOPRIGHT", promptFrame, "TOPRIGHT", -5, -5)
promptCloseButton:SetNormalTexture("Interface\\AddOns\\SoulGospel\\close.png")
promptCloseButton:SetHighlightTexture("Interface\\AddOns\\SoulGospel\\close.png")
promptCloseButton:SetScript("OnClick", function()
    promptFrame:Hide()
end)
-- Button to keep the addon loaded
local keepAddonButton = CreateFrame("Button", nil, promptFrame, "UIPanelButtonTemplate")
keepAddonButton:SetSize(100, 24)
keepAddonButton:SetPoint("BOTTOMLEFT", promptFrame, "BOTTOMLEFT", 20, 10)  -- Adjust button position
keepAddonButton:SetText("Keep Loaded")
keepAddonButton:SetNormalFontObject("GameFontNormal")
keepAddonButton:SetHighlightFontObject("GameFontHighlight")
keepAddonButton:SetScript("OnClick", function()
    promptFrame:Hide()

    -- Create a large texture
    local largeTexture = UIParent:CreateTexture(nil, "OVERLAY")
    largeTexture:SetSize(300, 350)  -- Set the size of the texture
    largeTexture:SetPoint("CENTER", UIParent, "CENTER")
    largeTexture:SetTexture("Interface\\AddOns\\SoulGospel\\sglol2.png")
    largeTexture:SetAlpha(1)

    -- Fade out the large texture
    local fadeOut = largeTexture:CreateAnimationGroup()
    local fade = fadeOut:CreateAnimation("Alpha")
    fade:SetFromAlpha(1)
    fade:SetToAlpha(0)
    fade:SetDuration(1)  -- Duration of the fade out
    fade:SetSmoothing("OUT")
    fadeOut:SetScript("OnFinished", function()
        largeTexture:Hide()
    end)
    fadeOut:Play()
end)

-- Show the prompt frame if the player is not a warlock
if not IsPlayerWarlock() then
    promptFrame:Show()
end

-- Button to disable the addon
local disableAddonButton = CreateFrame("Button", nil, promptFrame, "UIPanelButtonTemplate")
disableAddonButton:SetSize(100, 24)
disableAddonButton:SetPoint("BOTTOMRIGHT", promptFrame, "BOTTOMRIGHT", -20, 10)  -- Adjust button position
disableAddonButton:SetText("Disable Addon")
disableAddonButton:SetNormalFontObject("GameFontNormal")
disableAddonButton:SetHighlightFontObject("GameFontHighlight")
disableAddonButton:SetScript("OnClick", function()
    DisableAddOn(addonName)
    ReloadUI()
end)

-- Show the prompt frame if the player is not a warlock
if not IsPlayerWarlock() then
    promptFrame:Show()
end

-- Slash command handler
SLASH_SOULGOSPEL1 = "/soulgospel"
SlashCmdList["SOULGOSPEL"] = function(msg)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    if command == "on" then
        SoulGospelDB.soundEnabled = true
        print("|cFF39FF14/soulgospel|r Sound enabled.")
    elseif command == "off" then
        SoulGospelDB.soundEnabled = false
        print("|cFF39FF14/soulgospel|r Sound disabled.")
    elseif command == "volume" then
        local volume = tonumber(rest)
        if volume and volume >= 1 and volume <= 100 then
            SoulGospelDB.volume = volume
            print("|cFF39FF14/soulgospel|r Volume set to " .. volume .. ".")
        else
            print("|cFF39FF14/soulgospel|r Invalid volume. Please enter a value between 1 and 100.")
        end
    end

    -- Always show the UI frame and print commands
    if not uiFrame:IsShown() then
        uiFrame:Show()
    end

    print("|cFF39FF14Soul Gospel|r Commands:")
    print("|cFF39FF14/SoulGospel|r on - Enable sound")
    print("|cFF39FF14/SoulGospel|r off - Disable sound")
    print("|cFF39FF14/SoulGospel|r volume <1-100> - Set volume")
    print("|cFF39FF14/SoulGospel|r - Toggle settings menu")
end

-- Event frame for saving settings
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize settings and UI elements
        InitializeSettings()
        InitializeUI()
        -- Show the prompt frame if the player is not a warlock
        if not IsPlayerWarlock() then
            promptFrame:Show()
        end
    elseif event == "PLAYER_LOGOUT" then
        -- Save current settings
        SoulGospelDB.soundEnabled = soundCheckbox:GetChecked()
        SoulGospelDB.playAllSounds = playAllSoundsCheckbox:GetChecked()
        SoulGospelDB.volume = volumeSlider:GetValue()
        -- Save frame position
        local point, relativeTo, relativePoint, xOfs, yOfs = uiFrame:GetPoint()
        SoulGospelDB.position = {point = point, relativeTo = relativeTo or "UIParent", relativePoint = relativePoint, xOfs = xOfs, yOfs = yOfs}
        -- Save frame size
        SoulGospelDB.frameSize = {width = uiFrame:GetWidth(), height = uiFrame:GetHeight()}
    end
end)
