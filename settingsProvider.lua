--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
core.SettingsProvider = {} -- adds SettingsProvider table to addon namespace

local SettingsProvider = core.SettingsProvider

function SettingsProvider:InterfaceOptions_AddCategory(panel, addonName, parentCategory)
    -- print('InterfaceOptionsFrame_OpenToCategory')
    if (Settings ~= nil) then
        -- wow10
        local newCategory = nil;
        
        if(parentCategory == nil) then
            newCategory = Settings.RegisterCanvasLayoutCategory(panel, addonName)
        else
            newCategory = Settings.RegisterCanvasLayoutSubcategory(parentCategory, panel, addonName);
        end
        newCategory.ID = panel.name

        Settings.RegisterAddOnCategory(newCategory)
        panel.categoryId = newCategory:GetID() -- for OpenToCategory use
        panel.category = newCategory
    else
        InterfaceOptions_AddCategory(panel)
    end
end


function SettingsProvider:InterfaceOptionsFrame_OpenToCategory(settingsCategoryId, addonName)
    print('InterfaceOptionsFrame_OpenToCategory')
    if (Settings ~= nil) then
        Settings.OpenToCategory(settingsCategoryId)
    else
        -- wow classic
        InterfaceAddOnsList_Update()
        InterfaceOptionsFrame_OpenToCategory(addonName)
    end
end
