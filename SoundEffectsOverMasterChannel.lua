local READY_CHECK_SOUNDKIT = SOUNDKIT and SOUNDKIT.READY_CHECK
if not READY_CHECK_SOUNDKIT then
    error("There was an error loading SOUNDKIT.READY_CHECK. This addon cannot function without it.")
end

local f = CreateFrame("Frame")
local isSFXEnabled = false
local ADDON_PREFIX = "|cff33ff99[SoundEffectsOverMasterChannel]|r"

local function RefreshSFXState(showWarning)
    local wasSFXEnabled = isSFXEnabled
    isSFXEnabled = GetCVarBool("Sound_EnableSFX")

    if showWarning and isSFXEnabled and not wasSFXEnabled then
        print(ADDON_PREFIX .. " |cffff3333Sound effects are enabled. This addon is meant to be used with it disabled.|r")
    end
end

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("CVAR_UPDATE")
f:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

f:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        RefreshSFXState(true)
        return
    end

    if event == "CVAR_UPDATE" then
        local cvarName = ...
        if cvarName == "Sound_EnableSFX" then
            RefreshSFXState(true)
        end
        return
    end

    if event == "LFG_LIST_APPLICATION_STATUS_UPDATED" then
        local _, newStatus = ...
        if not isSFXEnabled and newStatus == "invited" then
            PlaySound(READY_CHECK_SOUNDKIT, "Master")
        end
    end
end)
