--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
core.Localization = {} -- adds Config table to addon namespace

L_WELCOMEBACK = "Weclome back"

-- Options
L_OPTIONS_MAINSETTINGS = "Main Settings"
L_OPTIONS_ENABLE = "Loot by list"
L_OPTIONS_CURRENCY = "Loot currency"
L_OPTIONS_QUESTITEMS = "Loot quest items"
L_OPTIONS_AFTERCLOSE = "Close after loot"
L_OPTIONS_FISHLOOT = "Loot fishing items"
L_OPTIONS_LISTPANELNAME = "Item list"
L_OPTIONS_LISTADDTEXT = "Enter ItemID:"
L_OPTIONS_FRAMESETTINGS = "Frame Settings"
L_OPTIONS_FRAMEICOSIZE = "Icon size"
L_OPTIONS_FRAMEFONTITEMSIZE = "Item font size"
L_OPTIONS_FRAMEFONTCOUNTSIZE = "Count font size"
L_OPTIONS_FRAMEENABLE = "Replace default loot frame"
L_OPTIONS_USECUSTOMFONT = "Use custom font"
L_OPTIONS_CUSTOMFONTNAME = "Custom font"

local clientLocale = GetLocale()

if clientLocale == "deDE" then
    L_WELCOMEBACK = "%s geladen (%d)"

    -- Options
    L_OPTIONS_MAINSETTINGS = "Main Settings"
    L_OPTIONS_ENABLE = "Loot by list"
    L_OPTIONS_CURRENCY = "Loot currency"
    L_OPTIONS_QUESTITEMS = "Loot quest items"
    L_OPTIONS_AFTERCLOSE = "Close after loot"
    L_OPTIONS_FISHLOOT = "Loot fishing items"
    L_OPTIONS_LISTPANELNAME = "Item list"
    L_OPTIONS_LISTADDTEXT = "Enter ItemID:"
    L_OPTIONS_FRAMESETTINGS = "Frame Settings"
    L_OPTIONS_FRAMEICOSIZE = "Icon size"
    L_OPTIONS_FRAMEFONTITEMSIZE = "Item font size"
    L_OPTIONS_FRAMEFONTCOUNTSIZE = "Count font size"
    L_OPTIONS_FRAMEENABLE = "Replace default loot frame"
    L_OPTIONS_USECUSTOMFONT = "Use custom font"
    L_OPTIONS_CUSTOMFONTNAME = "Custom font"
elseif clientLocale == "esES" or clientLocale == "esMX" then
    L_WELCOMEBACK = "%s loaded (%d)"

    -- Options
    L_OPTIONS_MAINSETTINGS = "Main Settings"
    L_OPTIONS_ENABLE = "Loot by list"
    L_OPTIONS_CURRENCY = "Loot currency"
    L_OPTIONS_QUESTITEMS = "Loot quest items"
    L_OPTIONS_AFTERCLOSE = "Close after loot"
    L_OPTIONS_FISHLOOT = "Loot fishing items"
    L_OPTIONS_LISTPANELNAME = "Item list"
    L_OPTIONS_LISTADDTEXT = "Enter ItemID:"
    L_OPTIONS_FRAMESETTINGS = "Frame Settings"
    L_OPTIONS_FRAMEICOSIZE = "Icon size"
    L_OPTIONS_FRAMEFONTITEMSIZE = "Item font size"
    L_OPTIONS_FRAMEFONTCOUNTSIZE = "Count font size"
    L_OPTIONS_FRAMEENABLE = "Replace default loot frame"
    L_OPTIONS_USECUSTOMFONT = "Use custom font"
    L_OPTIONS_CUSTOMFONTNAME = "Custom font"
elseif clientLocale == "frFR" then
    L_WELCOMEBACK = "%s chargé (%d)"

    -- Options
    L_OPTIONS_MAINSETTINGS = "Main Settings"
    L_OPTIONS_ENABLE = "Loot by list"
    L_OPTIONS_CURRENCY = "Loot currency"
    L_OPTIONS_QUESTITEMS = "Loot quest items"
    L_OPTIONS_AFTERCLOSE = "Close after loot"
    L_OPTIONS_FISHLOOT = "Loot fishing items"
    L_OPTIONS_LISTPANELNAME = "Item list"
    L_OPTIONS_LISTADDTEXT = "Enter ItemID:"
    L_OPTIONS_FRAMESETTINGS = "Frame Settings"
    L_OPTIONS_FRAMEICOSIZE = "Icon size"
    L_OPTIONS_FRAMEFONTITEMSIZE = "Item font size"
    L_OPTIONS_FRAMEFONTCOUNTSIZE = "Count font size"
    L_OPTIONS_FRAMEENABLE = "Replace default loot frame"
    L_OPTIONS_USECUSTOMFONT = "Use custom font"
    L_OPTIONS_CUSTOMFONTNAME = "Custom font"
elseif clientLocale == "ruRU" then
    L_WELCOMEBACK = "С возвращением."

    -- Options
    L_OPTIONS_MAINSETTINGS = "Основные настройки"
    L_OPTIONS_ENABLE = "Собирать по списку"
    L_OPTIONS_CURRENCY = "Собирать деньги и валюту"
    L_OPTIONS_QUESTITEMS = "Собирать квестовые предметы"
    L_OPTIONS_AFTERCLOSE = "Закрыть окно добычи"
    L_OPTIONS_FISHLOOT = "Собирать улов"
    L_OPTIONS_LISTPANELNAME = "Список предметов"
    L_OPTIONS_LISTADDTEXT = "Для добавления нового предмета введите ItemID:"
    L_OPTIONS_FRAMESETTINGS = "Настройка фрейма сбора"
    L_OPTIONS_FRAMEICOSIZE = "Размер иконки"
    L_OPTIONS_FRAMEFONTITEMSIZE = "Размер шрифта предмета"
    L_OPTIONS_FRAMEFONTCOUNTSIZE = "Размер щрифта количества"
    L_OPTIONS_FRAMEENABLE = "Заменить стандартный фрейм сбора"
    L_OPTIONS_USECUSTOMFONT = "Использовать сторонний шрифт"
    L_OPTIONS_CUSTOMFONTNAME = "Шрифт"
end
