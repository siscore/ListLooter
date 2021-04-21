--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
local LSM = nil;
local LSM3 = LibStub("LibSharedMedia-3.0", true)
local LSM2 = LibStub("LibSharedMedia-2.0", true)
local SML = LibStub("SharedMedia-1.0", true)

core.FontProvider = {}; -- adds FontProvider table to addon namespace

local FontProvider = core.FontProvider;
local fontFolderName = "Interface\\AddOns\\!ListLooter\\Fonts\\";
local defaultFont = GameFontWhite:GetFont();

--Fonts if not LSM used
local fontsList =
{
    Default = defaultFont,
    Enigmatic = fontFolderName.."EnigmaU_2.ttf"
}

--------------------------------------
-- FontProvider functions
--------------------------------------

function FontProvider:Init()
    if (not LSM) then
        if (not SML) then
            SML = LibStub("SharedMedia-1.0", true);
            if (SML) then
                LSM = SML;
            end
        else
            LSM = SML;
        end

        if (not LSM2) then
            LSM2 = LibStub("LibSharedMedia-2.0", true);
            if (LSM2) then
                LSM = LSM2;
            end
        else
            LSM = LSM2;
        end

        if (not LSM3) then
            LSM3 = LibStub("LibSharedMedia-3.0", true)
            if (LSM3) then
                LSM = LSM3;
            end
        else
            LSM = LSM3;
        end

        if (LSM) then
            FontProvider:RegisterCustomFonts();
            core.Config.LSMDetected();
        end
    end
end

function FontProvider:RegisterCustomFonts()
    local customFontsList = {
        Enigmatic = {fontFolderName.."EnigmaU_2.ttf", LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western}
    }

    for key, val in pairs(customFontsList) do
        if (LSM == LSM3) then
            LSM:Register(LSM.MediaType.FONT, key, val[1], val[2]);
        else
            LSM:Register(LSM.MediaType.FONT, key, val[1]);
        end
    end
end

function FontProvider:GetFontsName()
    if (LSM) then
        return LSM:HashTable(LSM.MediaType.FONT);
    else
        return fontsList;
    end;
end

function FontProvider:GetFontName()
    local config = core.Config:GetSettings();
    local hashTable = nil;

    if (LSM) then
        hashTable = LSM:HashTable(LSM.MediaType.FONT);
    else
        hashTable = fontsList;
    end

    for key, item in pairs(hashTable) do
        if (key == config.customFontName) then
            return item;
        end
    end

    return defaultFont;
end
