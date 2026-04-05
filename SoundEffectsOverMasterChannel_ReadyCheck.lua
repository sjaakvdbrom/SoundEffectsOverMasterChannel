local _, SEMC = ...

local READY_CHECK_SOUNDKIT = SOUNDKIT and SOUNDKIT.READY_CHECK
if not READY_CHECK_SOUNDKIT then
    error("There was an error loading SOUNDKIT.READY_CHECK. This addon cannot function without it.")
end

local readyCheckEventFrame = CreateFrame("Frame")

readyCheckEventFrame:RegisterEvent("PLAYER_LOGIN")
readyCheckEventFrame:RegisterEvent("CVAR_UPDATE")
readyCheckEventFrame:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

readyCheckEventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        SEMC.InitializeSettings()
        SEMC.RefreshSFXState(true)
        return
    end

    if event == "CVAR_UPDATE" then
        local cvarName = ...
        if cvarName == "Sound_EnableSFX" then
            SEMC.RefreshSFXState(true)
        end
        return
    end

    if event == "LFG_LIST_APPLICATION_STATUS_UPDATED" then
        local _, newStatus = ...
        if not SEMC.Runtime.isSFXEnabled and SEMC.IsSoundEnabled("readycheck") and newStatus == "invited" then
            SEMC.PlaySoundOnMaster(READY_CHECK_SOUNDKIT)
        end
    end
end)