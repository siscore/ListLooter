--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.FontProvider = {}; -- adds Config table to addon namespace

local FontProvider = core.FontProvider;
local fontFolderName = "Interface\\AddOns\\!ListLooter\\Fonts\\"

local fontsList = 
{
    {name = "Default", file = ""},
    {name = "Enigmatic", file ="EnigmaU_2"}
}
--------------------------------------
-- FontProvider functions
--------------------------------------

function FontProvider:getFontName()
    local config = core.Config:GetSettings();
    local result = GameFontWhite:GetFont();
    local fontName = trim(config.customFontName);
    local isDefault = (fontName == "Default");

    if (not isDefault) then
        local result = fontFolderName..self:GetFileName();
        local extension = ".ttf";

        if (not ends_with(result, extension)) then
            result = result..".ttf";
        end

        --print(result);
        return result;
    end 

    --print(result);
    return result;
end

function FontProvider:GetFontsName()
    local result = {};
    for c=1, table.getn(fontsList), 1 do
        table.insert(result, fontsList[c].name);
    end

    return result;
end

function FontProvider:GetFileName()
    local config = core.Config:GetSettings();
    for c=1, table.getn(fontsList), 1 do
        if (fontsList[c].name == trim(config.customFontName)) then 
            return fontsList[c].file;
        end 
    end

    return GameFontWhite:GetFont();
end

function trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end
