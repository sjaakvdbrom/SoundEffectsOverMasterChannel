local _, SEMC = ...

SEMC.Runtime = SEMC.Runtime or {
    isSFXEnabled = false,
}

local ADDON_PREFIX = "|cff33ff99[SoundEffectsOverMasterChannel]|r"

function SEMC.RefreshSFXState(showWarning)
    local wasSFXEnabled = SEMC.Runtime.isSFXEnabled
    SEMC.Runtime.isSFXEnabled = GetCVarBool("Sound_EnableSFX")

    if showWarning and SEMC.Runtime.isSFXEnabled and not wasSFXEnabled then
        print(ADDON_PREFIX .. " |cffff3333Sound effects are enabled. This addon is meant to be used with it disabled.|r")
    end
end

function SEMC.PlaySoundOnMaster(soundKitID)
    if type(soundKitID) ~= "number" then
        return false
    end

    return PlaySound(soundKitID, "Master")
end

function SEMC.PlaySoundFileOnMaster(soundFileID)
    if type(soundFileID) ~= "number" then
        return false
    end

    return PlaySoundFile(soundFileID, "Master")
end
