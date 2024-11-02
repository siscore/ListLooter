--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
core.FontProvider = {} -- adds FontProvider table to addon namespace

local LSM = nil
local LSM3 = LibStub("LibSharedMedia-3.0", true)
local LSM2 = LibStub("LibSharedMedia-2.0", true)
local SML = LibStub("SharedMedia-1.0", true)

local FontProvider = core.FontProvider
local defaultFont = GameFontWhite:GetFont()

-- Fonts if not LSM used
function FontProvider:GetFontsList()
    local appName = core.Config:GetAppName()
    local fontFolderName = "Interface\\AddOns\\" .. appName .. "\\fonts\\"
    return {
        Default = defaultFont,
        Enigmatic = fontFolderName .. "EnigmaU_2.ttf"
    }
end

--------------------------------------
-- FontProvider functions
--------------------------------------
function FontProvider:Init()
    if (not LSM) then
        if (not SML) then
            SML = LibStub("SharedMedia-1.0", true)
            if (SML) then
                LSM = SML
            end
        else
            LSM = SML
        end

        if (not LSM2) then
            LSM2 = LibStub("LibSharedMedia-2.0", true)
            if (LSM2) then
                LSM = LSM2
            end
        else
            LSM = LSM2
        end

        if (not LSM3) then
            LSM3 = LibStub("LibSharedMedia-3.0", true)
            if (LSM3) then
                LSM = LSM3
            end
        else
            LSM = LSM3
        end

        if (LSM) then
            FontProvider:RegisterCustomFonts()
            core.Config.LSMDetected()
        end
    end
end

function FontProvider:RegisterCustomFonts()
    local appName = core.Config:GetAppName()
    local fontFolderName = "Interface\\AddOns\\" .. appName .. "\\fonts\\"
    local customFontsList = {
        Enigmatic = {
            fontFolderName .. "EnigmaU_2.ttf",
            LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western
        }
    }

    for key, val in pairs(customFontsList) do
        if (LSM == LSM3) then
            LSM:Register(LSM.MediaType.FONT, key, val[1], val[2])
        else
            LSM:Register(LSM.MediaType.FONT, key, val[1])
        end
    end
end

function FontProvider:GetFontsName()
    if (LSM) then
        return LSM:HashTable(LSM.MediaType.FONT)
    else
        return FontProvider:GetFontsList()
    end
end

function FontProvider:GetFontName()
    local config = core.Config:GetSettings()
    local hashTable = nil

    if (LSM) then
        hashTable = LSM:HashTable(LSM.MediaType.FONT)
    else
        hashTable = FontProvider:GetFontsList()
    end

    for key, item in pairs(hashTable) do
        if (key == config.customFontName) then
            return item
        end
    end

    return defaultFont
end
