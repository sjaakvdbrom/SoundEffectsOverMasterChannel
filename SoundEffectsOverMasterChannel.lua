local _, SEMC = ...

SEMC.Runtime = SEMC.Runtime or {
    isSFXEnabled = false,
}

SEMC.DEFAULT_SOUND_SETTINGS = {
    bloodlust = true,
    readycheck = true,
}

SEMC.SOUND_NAME_ALIASES = {
    bloodlust = "bloodlust",
    lust = "bloodlust",
    heroism = "bloodlust",
    timewarp = "bloodlust",
    time_warp = "bloodlust",
    readycheck = "readycheck",
    ready_check = "readycheck",
    lfg = "readycheck",
}

local ADDON_PREFIX = "|cff33ff99[SoundEffectsOverMasterChannel]|r"

local function EnsureSettingsTable()
    if type(SEMCDB) ~= "table" then
        SEMCDB = {}
    end

    if type(SEMCDB.soundSettings) ~= "table" then
        SEMCDB.soundSettings = {}
    end

    for soundKey, defaultValue in pairs(SEMC.DEFAULT_SOUND_SETTINGS) do
        if type(SEMCDB.soundSettings[soundKey]) ~= "boolean" then
            SEMCDB.soundSettings[soundKey] = defaultValue
        end
    end
end

local function NormalizeSoundKey(soundName)
    if type(soundName) ~= "string" then
        return nil
    end

    local key = soundName:lower():gsub("[%s%-]+", "_")
    return SEMC.SOUND_NAME_ALIASES[key]
end

local function PrintUsage()
    print(ADDON_PREFIX .. " Usage:")
    print(ADDON_PREFIX .. "   /semc on <sound>")
    print(ADDON_PREFIX .. "   /semc off <sound>")
    print(ADDON_PREFIX .. "   /semc status [sound]")
    print(ADDON_PREFIX .. "   /semc list")
    print(ADDON_PREFIX .. " Sounds: bloodlust, readycheck")
end

function SEMC.InitializeSettings()
    EnsureSettingsTable()
end

function SEMC.IsSoundEnabled(soundKey)
    EnsureSettingsTable()
    return SEMCDB.soundSettings[soundKey] == true
end

function SEMC.SetSoundEnabled(soundKey, isEnabled)
    EnsureSettingsTable()

    if SEMC.DEFAULT_SOUND_SETTINGS[soundKey] == nil then
        return false
    end

    SEMCDB.soundSettings[soundKey] = isEnabled == true
    return true
end

local function PrintSoundStatus(soundKey)
    local isEnabled = SEMC.IsSoundEnabled(soundKey)
    local stateText = isEnabled and "ON" or "OFF"
    print(ADDON_PREFIX .. " " .. soundKey .. " is " .. stateText)
end

local function HandleSlashCommand(msg)
    EnsureSettingsTable()

    local command, soundName = msg:match("^(%S+)%s*(.-)%s*$")
    command = command and command:lower() or ""
    soundName = soundName ~= "" and soundName or nil

    if command == "" or command == "help" then
        PrintUsage()
        return
    end

    if command == "list" then
        PrintSoundStatus("bloodlust")
        PrintSoundStatus("readycheck")
        return
    end

    if command == "status" then
        if not soundName then
            PrintSoundStatus("bloodlust")
            PrintSoundStatus("readycheck")
            return
        end

        local normalizedSoundKey = NormalizeSoundKey(soundName)
        if not normalizedSoundKey then
            print(ADDON_PREFIX .. " Unknown sound: " .. soundName)
            PrintUsage()
            return
        end

        PrintSoundStatus(normalizedSoundKey)
        return
    end

    if command == "on" or command == "off" then
        if not soundName then
            print(ADDON_PREFIX .. " Missing sound name.")
            PrintUsage()
            return
        end

        local normalizedSoundKey = NormalizeSoundKey(soundName)
        if not normalizedSoundKey then
            print(ADDON_PREFIX .. " Unknown sound: " .. soundName)
            PrintUsage()
            return
        end

        SEMC.SetSoundEnabled(normalizedSoundKey, command == "on")
        PrintSoundStatus(normalizedSoundKey)
        return
    end

    print(ADDON_PREFIX .. " Unknown command: " .. command)
    PrintUsage()
end

SLASH_SOUNDEFFECTSOVERMASTERCHANNEL1 = "/semc"
SlashCmdList.SOUNDEFFECTSOVERMASTERCHANNEL = HandleSlashCommand

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
