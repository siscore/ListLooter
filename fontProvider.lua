--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.FontProvider = {}; -- adds Config table to addon namespace

local FontProvider = core.FontProvider;
local fontFolderName = "Interface\\AddOns\\!ListLooter\\Fonts\\"

local fontsList = 
{
    {name = "Default                 ", file = ""},
    {name = "Enigmatic               ", file ="EnigmaU_2"}
}
--------------------------------------
-- FontProvider functions
--------------------------------------

function FontProvider:getFontName()
    local config = core.Config:GetSettings();
    local result = GameFontWhite:GetFont();
    local isDefault = (trim(config.customFontName) == "Default");

    if (not isDefault) then
        local result = fontFolderName..ListLooterDB.font.name:lower();
        local extension = ".ttf";

        if (not ends_with(result, extension)) then
            result = result..".ttf";
        end

        return result;
    end 

    return result;
end

function FontProvider:GetFontsName()
    local result = {};
    for c=1, table.getn(fontsList), 1 do
        table.insert(result, fontsList[c].name);
    end

    return result;
end

function trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end
