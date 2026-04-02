local _, SEMC = ...

local LUST_DEDUP_WINDOW_SECONDS = 1.5

local BLOODLUST_SOUND_FILE_ID = 568812
local HEROISM_SOUND_FILE_ID = 569013
local TIME_WARP_SOUND_FILE_ID = 569126

local RECENT_LUST_WINDOW_SECONDS = 40
local SATED_TOTAL_DURATION_SECONDS = 600
local MIN_REMAINING_SATED_SECONDS = SATED_TOTAL_DURATION_SECONDS - RECENT_LUST_WINDOW_SECONDS

local HEROISM_SATED_DEBUFF_IDS = {
    57723, -- Exhaustion (Heroism)
}

local BLOODLUST_SATED_DEBUFF_IDS = {
    57724, -- Sated (Bloodlust)
    95809, -- Insanity (pet lust variant)
    160455, -- Fatigued
    264689, -- Fatigued
    390435, -- Exhaustion (Evoker variant)
}

local TIME_WARP_SATED_DEBUFF_IDS = {
    80354, -- Temporal Displacement (Time Warp)
}

local function BuildSatedDebuffSoundMap()
    local soundFileIDBySatedDebuffID = {}

    local function AssignSoundToDebuffIDs(debuffSpellIDs, soundFileID)
        for i = 1, #debuffSpellIDs do
            soundFileIDBySatedDebuffID[debuffSpellIDs[i]] = soundFileID
        end
    end

    AssignSoundToDebuffIDs(HEROISM_SATED_DEBUFF_IDS, HEROISM_SOUND_FILE_ID)
    AssignSoundToDebuffIDs(BLOODLUST_SATED_DEBUFF_IDS, BLOODLUST_SOUND_FILE_ID)
    AssignSoundToDebuffIDs(TIME_WARP_SATED_DEBUFF_IDS, TIME_WARP_SOUND_FILE_ID)

    return soundFileIDBySatedDebuffID
end

local SOUND_FILE_ID_BY_SATED_DEBUFF_ID = BuildSatedDebuffSoundMap()

local lustEventFrame = CreateFrame("Frame")
local isLustAlertActive = false
local nextAllowedLustPlayTime = 0

local function IsRecentSatedDebuff(expirationTime)
    return expirationTime and (expirationTime - GetTime()) > MIN_REMAINING_SATED_SECONDS
end

local function FindFreshSatedDebuffSpellIDOnPlayer()
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        local auraIndex = 1
        while true do
            local auraData = C_UnitAuras.GetAuraDataByIndex("player", auraIndex, "HARMFUL")
            if not auraData then
                break
            end

            if SOUND_FILE_ID_BY_SATED_DEBUFF_ID[auraData.spellId] and IsRecentSatedDebuff(auraData.expirationTime) then
                return auraData.spellId
            end

            auraIndex = auraIndex + 1
        end

        return nil
    end

    for auraIndex = 1, 40 do
        local _, _, _, _, _, expirationTime, _, _, _, spellID = UnitDebuff("player", auraIndex)
        if not spellID then
            break
        end

        if SOUND_FILE_ID_BY_SATED_DEBUFF_ID[spellID] and IsRecentSatedDebuff(expirationTime) then
            return spellID
        end
    end

    return nil
end

local function PlayLustAlert(satedDebuffSpellID)
    if SEMC.Runtime.isSFXEnabled then
        return
    end

    local now = GetTime()
    if now < nextAllowedLustPlayTime then
        return
    end

    local soundFileID = SOUND_FILE_ID_BY_SATED_DEBUFF_ID[satedDebuffSpellID]
    if not soundFileID then
        return
    end

    SEMC.PlaySoundFileOnMaster(soundFileID)

    nextAllowedLustPlayTime = now + LUST_DEDUP_WINDOW_SECONDS
end

local function UpdateLustAlertStateFromAuras()
    local freshSatedDebuffSpellID = FindFreshSatedDebuffSpellIDOnPlayer()

    if freshSatedDebuffSpellID then
        if not isLustAlertActive then
            PlayLustAlert(freshSatedDebuffSpellID)
            isLustAlertActive = true
        end
        return
    end

    isLustAlertActive = false
end

local function SyncLustAlertStateFromAuras()
    isLustAlertActive = FindFreshSatedDebuffSpellIDOnPlayer() ~= nil
end

lustEventFrame:RegisterEvent("PLAYER_LOGIN")
lustEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
lustEventFrame:RegisterUnitEvent("UNIT_AURA", "player")

lustEventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        SEMC.RefreshSFXState(false)
        UpdateLustAlertStateFromAuras()
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        nextAllowedLustPlayTime = GetTime() + LUST_DEDUP_WINDOW_SECONDS
        SyncLustAlertStateFromAuras()
        return
    end

    if event == "UNIT_AURA" then
        UpdateLustAlertStateFromAuras()
    end
end)