L_WELCOMEBACK = "Weclome back";

--Options
L_OPTIONS_MAINSETTINGS = "Main Settings"
L_OPTIONS_ENABLE = "Enable";
L_OPTIONS_CURRENCY = "Loot currency";
L_OPTIONS_QUESTITEMS = "Loot quest items";
L_OPTIONS_AFTERCLOSE = "Close after loot";
L_OPTIONS_LISTPANELNAME = "Item list";
L_OPTIONS_LISTADDTEXT = "Enter ItemID:";

local clientLocale = GetLocale();

if clientLocale == "deDE" then

    L_WELCOMEBACK = "%s geladen (%d)";
	
	--Options
	L_OPTIONS_MAINSETTINGS = "Main Settings"
	L_OPTIONS_ENABLE = "Enable";
	L_OPTIONS_CURRENCY = "Loot currency";
	L_OPTIONS_QUESTITEMS = "Loot quest items";
	L_OPTIONS_AFTERCLOSE = "Close after loot";
	L_OPTIONS_LISTPANELNAME = "Item list";
	L_OPTIONS_LISTADDTEXT = "Enter ItemID:";
    
elseif clientLocale == "esES" or clientLocale == "esMX" then

    L_WELCOMEBACK = "%s loaded (%d)";
    
	--Options
	L_OPTIONS_MAINSETTINGS = "Main Settings"
	L_OPTIONS_ENABLE = "Enable";
	L_OPTIONS_CURRENCY = "Loot currency";
	L_OPTIONS_QUESTITEMS = "Loot quest items";
	L_OPTIONS_AFTERCLOSE = "Close after loot";
	L_OPTIONS_LISTPANELNAME = "Item list";
	L_OPTIONS_LISTADDTEXT = "Enter ItemID:";

elseif clientLocale == "frFR" then

    L_WELCOMEBACK = "%s chargé (%d)";
    
	--Options
	L_OPTIONS_MAINSETTINGS = "Main Settings"
	L_OPTIONS_ENABLE = "Enable";
	L_OPTIONS_CURRENCY = "Loot currency";
	L_OPTIONS_QUESTITEMS = "Loot quest items";
	L_OPTIONS_AFTERCLOSE = "Close after loot";
	L_OPTIONS_LISTPANELNAME = "Item list";
	L_OPTIONS_LISTADDTEXT = "Enter ItemID:";
    
elseif clientLocale == "ruRU" then

    L_WELCOMEBACK = "С возвращением.";
	
	--Options
	L_OPTIONS_MAINSETTINGS = "Основные настройки"
	L_OPTIONS_ENABLE = "Включено";
	L_OPTIONS_CURRENCY = "Собирать деньги и валюту";
	L_OPTIONS_QUESTITEMS = "Собирать квестовые предметы";
	L_OPTIONS_AFTERCLOSE = "Закрыть окно добычи";
	L_OPTIONS_LISTPANELNAME = "Список предметов";
	L_OPTIONS_LISTADDTEXT = "Для добавления нового предмета введите ItemID:";
end
