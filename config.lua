--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
core.Config = {} -- adds Config table to addon namespace

local Config = core.Config
local UIConfig

--------------------------------------
-- Defaults (usually a database!)
--------------------------------------
local defaults = {
    settings = {
        isLootEnable = true,
        isCurrency = false,
        isQuestItem = false,
        isAfterClose = false,
        isMinimap = false,
        isLootFrame = false,
        isFishingLoot = false,
        customFontName = "Default",
        showItemLevel = false
    },
    theme = "Default",
    frame = {
        iconSize = 22,
        fontSizeItem = 12,
        fontSizeCount = 12
    }
}

local actions = {
    add = false,
    read = false,
    wait = false
}

local itemsDB = {}
local previouslyItemListRow = nil

local appName = "ListLooter"

--------------------------------------
-- Config functions
--------------------------------------
function Config:OnEvent(event, name)
    if (event == "GET_ITEM_INFO_RECEIVED") then
        -- print("Call: "..name);
        Config:ItemInfoReceived(name)
    end
end

function Config:Init()
    ListLooterDB = ListLooterDB or {}
end

function Config:Toggle()
    local menu = UIConfig or Config:CreateMenu()
    menu:SetShown(not menu:IsShown())
end

function Config:LSMDetected()
    local menu = UIConfig or Config:CreateMenu()
    menu.ddCustomFont:Hide();
    local fontsList = core.FontProvider:GetFontsName()
    local font_opts = {
        ["name"] = "custom_font_name",
        ["parent"] = menu,
        ["title"] = L_OPTIONS_CUSTOMFONTNAME,
        ["items"] = fontsList,
        ["defaultVal"] = ListLooterDB.settings.customFontName or "Default",
        ["currentVal"] = function()
            return ListLooterDB.settings.customFontName or "Default"
        end,
        ["changeFunc"] = function(_, dropdown_val)
            ListLooterDB.settings.customFontName = dropdown_val
            core.Frame:UpdateSettings()
        end
    }
    menu.ddCustomFont = Config:CreateDropdown(font_opts);
    menu.ddCustomFont:SetPoint("TOPLEFT", menu.cbAfterClose, "BOTTOMLEFT", -12, -15);
end

function Config:ToggleConfig()
    Config:Toggle()
    --InterfaceOptionsFrame_OpenToCategory([[|cff00ccffList Looter|r]])
    core.SettingsProvider.InterfaceOptionsFrame_OpenToCategory(nil, UIConfig.categoryId)
end

function Config:GetSettings()
    return ListLooterDB.settings
end

function Config:GetLootDB()
    return ListLooterDB.LootDB
end

function Config:ItemInfoReceived(itemId)
    if (actions.read) then
        actions.read = false
        Config:GetListFromGlobal()
        Config:CreateContent(UIConfig.list.listFrame.ScrollFrame.content)
    end
    if (actions.add) then
        actions.add = false
        Config:AddItem(itemId)
    end
end

function Config:GetThemeColor()
    local themeId = defaults.theme;
    local theme = core.ThemesProvider.getTheme(nil, themeId);
    local c = theme.Frame.BackdropColor;
    return c.r, c.g, c.b, theme.Hex
end

function Config:CreateButton(point, relativeFrame, relativePoint, yOffset, text)
    local btn = core.Override.CreateFrameA(nil, "Button", nil, UIConfig, "GameMenuButtonTemplate")
    btn:SetPoint(point, relativeFrame, relativePoint, 0, yOffset)
    btn:SetSize(140, 40)
    btn:SetText(text)
    btn:SetNormalFontObject("GameFontNormalLarge")
    btn:SetHighlightFontObject("GameFontHighlightLarge")
    return btn
end

function Config:CreatePointer(relativeFrame, yOffset, text)
    local parent = relativeFrame:GetParent()
    local pointer = core.Override.CreateFrameA(nil, "Frame", nil, relativeFrame)
    pointer:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", 30, yOffset)
    pointer:SetSize(200, 18)
    pointer.label = pointer:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    pointer.label:SetPoint("TOP")
    pointer.label:SetPoint("BOTTOM")
    pointer.label:SetJustifyH("CENTER")
    pointer.label:SetText(text)
    pointer.left = pointer:CreateTexture(nil, "BACKGROUND")
    pointer.left:SetHeight(8)
    pointer.left:SetPoint("LEFT", 10, 0)
    pointer.left:SetPoint("RIGHT", pointer.label, "LEFT", -5, 0)
    pointer.left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    pointer.left:SetTexCoord(0.81, 0.94, 0.5, 1)
    pointer.right = pointer:CreateTexture(nil, "BACKGROUND")
    pointer.right:SetHeight(8)
    pointer.right:SetPoint("RIGHT", -10, 0)
    pointer.right:SetPoint("LEFT", pointer.label, "RIGHT", 5, 0)
    pointer.right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    pointer.right:SetTexCoord(0.81, 0.94, 0.5, 1)
    pointer.left:SetPoint("RIGHT", pointer.label, "LEFT", -5, 0)

    return pointer
end

function Config:CreateEditBox(relativeFrame, yOffset, focus)
    local editBox = core.Override.CreateFrameA(nil, "EditBox", nil, relativeFrame, "InputBoxTemplate")
    editBox:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", 40, yOffset)
    if (core.Override:IfNewVersion()) then
        editBox:SetSize(595, 18);
    else
        editBox:SetSize(InterfaceOptionsFramePanelContainer:GetWidth() - 70, 18);
    end
    editBox:SetAutoFocus(focus)

    return editBox
end

function Config:CreateTableRow(parent, rowHeight, N)
    -- print("CreateTableRow");

    local fontHeight = select(2, GameFontNormalSmall:GetFont())
    local rowHeight = fontHeight
    local row = core.Override.CreateFrameA(nil, "Button", nil, parent)
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    row.id = N
    row:SetHeight(rowHeight)
    row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    row:SetNormalFontObject("GameFontNormal")
    row:SetScript(
        "OnEnter",
        function()
            -- ** HgD CODE CHANGES START HERE ** --
            if (previouslyItemListRow and row.id ~= previouslyItemListRow.id) then
                previouslyItemListRow.delete:Hide()
            end
            row.delete:Show()
            -- ** HgD CODE CHANGES END HERE ** --
        end
    )

    row:SetScript(
        "OnLeave",
        function()
            -- ** HgD CODE CHANGES START HERE ** --
            previouslyItemListRow = row
            -- ** HgD CODE CHANGES END HERE ** --
        end
    )

    row.font = row:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    row.font:SetAllPoints()
    row.font:SetText(itemsDB[N].name)
    row.font:SetJustifyH("LEFT")

    row.delete = core.Override.CreateFrameA(nil, "Button", nil, row, "UIPanelCloseButton")
    row.delete:SetHeight(rowHeight * 1.5)
    row.delete:SetWidth(rowHeight * 1.5)
    row.delete:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    row.delete:Hide()
    row.delete:RegisterForClicks("LeftButtonUp")
    row.delete:SetScript(
        "OnClick",
        function()
            -- ** HgD CODE CHANGES START HERE ** --
            Config:DeleteItem(row.id)
            -- ** HgD CODE CHANGES END HERE ** --
        end
    )
    row.delete:SetScript(
        "OnEnter",
        function()
            -- ** HgD CODE CHANGES START HERE ** --
            row:LockHighlight()
            -- ** HgD CODE CHANGES END HERE ** --
        end
    )
    row.delete:SetScript(
        "OnLeave",
        function()
            -- ** HgD CODE CHANGES START HERE ** --
            row:UnlockHighlight()
            -- ** HgD CODE CHANGES END HERE ** --
        end
    )

    return row
end

function Config:DeleteItem(id)
    -- print("delete id: "..id);
    table.remove(ListLooterDB.LootDB, id)
    Config:GetListFromGlobal()
    Config:CreateContent(UIConfig.list.listFrame.ScrollFrame.content)
end

function Config:CreateContent(content)
    --print("CreateContent");

    for i = 1, table.getn(content.rows) do
        local r = content.rows[i]
        r:Hide()
    end

    for i = 1, table.getn(itemsDB) do
        if (content.rows[i] == nil) then
            -- Create new
            local r = Config:CreateTableRow(content, rowHeight, i)
            if #content.rows == 0 then
                r:SetPoint("TOP", 5, -5)
            else
                r:SetPoint("TOP", content.rows[#content.rows], "BOTTOM")
            end
            table.insert(content.rows, r)
        else
            -- update old
            local r = content.rows[i]
            r.font:SetText(itemsDB[i].name)
            r:Show()
        end
    end
end

function Config:AddItem(inputItem)
    -- print("Config:AddItem("..inputItem..")")
    local _, itemLink = GetItemInfo(inputItem)

    if itemLink ~= nil then
        local _, _, Id = string.find(itemLink, "item:(%d+):")

        if Id then
            table.insert(ListLooterDB.LootDB, Id)
            Config:GetListFromGlobal()
            Config:CreateContent(UIConfig.list.listFrame.ScrollFrame.content)
        end
    else
        actions.add = true
    end
end

local function ScrollFrame_OnMouseWheel(self, delta)
    --print('ScrollFrame_OnMouseWheel')
    local scrollFrame = UIConfig.list.listFrame.ScrollFrame;
    local newValue = scrollFrame:GetVerticalScroll() - (delta * 20)

    if (newValue < 0) then
        newValue = 0
    elseif (newValue > scrollFrame:GetVerticalScrollRange()) then
        newValue = scrollFrame:GetVerticalScrollRange()
    end

    scrollFrame:SetVerticalScroll(newValue)
end

function Config:GetListFromGlobal()
    -- print("GetListFromGlobal");
    itemsDB = {}

    for i = 1, table.getn(ListLooterDB.LootDB) do
        local itemName, itemLink = GetItemInfo(ListLooterDB.LootDB[i])
        local itemIcon = GetItemIcon(ListLooterDB.LootDB[i])
        local showName = ListLooterDB.LootDB[i]

        if (itemName ~= nil) then
            showName = "\124T" .. itemIcon .. ":0\124t" .. " " .. itemName .. " (" .. ListLooterDB.LootDB[i] .. ")"
        else
            actions.read = true
        end

        table.insert(
            itemsDB,
            {
                id = ListLooterDB.LootDB[i],
                name = showName
            }
        )
    end
end

function Config:UpdateSettings1()
    if (ListLooterDB.settings.isEnable ~= nil) then
        local value1, value2, value3, value4, value5, value6 =
            ListLooterDB.settings.isEnable,
            ListLooterDB.settings.isCurrency,
            ListLooterDB.settings.isQuestItem,
            ListLooterDB.settings.isAfterClose,
            ListLooterDB.settings.isMinimap,
            ListLooterDB.settings.isLootFrame

        ListLooterDB.settings = {
            isLootEnable = value1,
            isCurrency = value2,
            isQuestItem = value3,
            isAfterClose = value4,
            isMinimap = value5,
            isLootFrame = value6
        }
    end
end

function Config:UpdateSettings2()
    if (ListLooterDB.settings.isFishingLoot == nil) then
        local value1, value2, value3, value4, value5, value6 =
            ListLooterDB.settings.isLootEnable,
            ListLooterDB.settings.isCurrency,
            ListLooterDB.settings.isQuestItem,
            ListLooterDB.settings.isAfterClose,
            ListLooterDB.settings.isMinimap,
            ListLooterDB.settings.isLootFrame

        ListLooterDB.settings = {
            isLootEnable = value1,
            isCurrency = value2,
            isQuestItem = value3,
            isAfterClose = value4,
            isMinimap = value5,
            isLootFrame = value6,
            isFishingLoot = defaults.settings.isFishingLoot
        }
    end
end

function Config:UpdateSettings3()
    if (ListLooterDB.settings.customFontName == nil) then
        ListLooterDB.settings.customFontName = defaults.settings.customFontName
    end
end

function Config:UpdateSettings4()
    if (ListLooterDB.settings.theme == nil) then
        ListLooterDB.settings.theme = 'Default'
    end
end

function Config:UpdateSettings5()
    if (ListLooterDB.settings.showItemLevel == nil) then
        local value1, value2, value3, value4, value5, value6, value7 =
            ListLooterDB.settings.isLootEnable,
            ListLooterDB.settings.isCurrency,
            ListLooterDB.settings.isQuestItem,
            ListLooterDB.settings.isAfterClose,
            ListLooterDB.settings.isMinimap,
            ListLooterDB.settings.isLootFrame,
            ListLooterDB.settings.isFishingLoot

        ListLooterDB.settings = {
            isLootEnable = value1,
            isCurrency = value2,
            isQuestItem = value3,
            isAfterClose = value4,
            isMinimap = value5,
            isLootFrame = value6,
            isFishingLoot = value7,
            showItemLevel = defaults.settings.showItemLevel
        }
    end
end

function Config:GetAppName()
    return appName
end

function Config:CreateMenu()
    -- ListLooterDB = nil;

    if ListLooterDB == nil then
        ListLooterDB = {}
    end

    if ListLooterDB.settings == nil then
        ListLooterDB.settings = {
            isLootEnable = defaults.settings.isLootEnable,
            isCurrency = defaults.settings.isCurrency,
            isQuestItem = defaults.settings.isQuestItem,
            isAfterClose = defaults.settings.isAfterClose,
            isMinimap = defaults.settings.isMinimap,
            isLootFrame = defaults.settings.isLootFrame,
            isFishingLoot = defaults.settings.isFishingLoot
        }
    end

    if ListLooterDB.LootDB == nil then
        ListLooterDB.LootDB = {}
    end

    Config:UpdateSettings1()
    Config:UpdateSettings2()
    Config:UpdateSettings3()
    Config:UpdateSettings4()
    Config:UpdateSettings5()

    if (ListLooterDB.frame == nil) then
        ListLooterDB.frame = defaults.frame
    end

    Config:GetListFromGlobal()
    ----------------------------------
    -- MAIN SETTINGS
    ----------------------------------
    UIConfig = core.Override.CreateFrameA(nil, "Frame", "ListLooterConfig", InterfaceOptionsFramePanelContainer)
    UIConfig.name = "|cff00ccffList Looter|r"

    UIConfig.title = UIConfig:CreateFontString(nil, "BACKGROUND", "GameFontNormalLarge")
    UIConfig.title:SetPoint("TOPLEFT", UIConfig, "TOPLEFT", 40, -20)
    UIConfig.title:SetText("|cff00ccffList Looter|r")

    UIConfig.poiner1 = Config:CreatePointer(UIConfig, -50, L_OPTIONS_MAINSETTINGS)
    UIConfig.poiner1:SetWidth(550)

    ----------------------------------
    -- Check Buttons
    ----------------------------------
    -- Check Button 1:
    UIConfig.cbEnable = core.Override.CreateFrameA(nil, "CheckButton", nil, UIConfig, "UICheckButtonTemplate")
    UIConfig.cbEnable:SetPoint("TOPLEFT", UIConfig, "TOPLEFT", 40, -70)
    UIConfig.cbEnable.text:SetText(L_OPTIONS_ENABLE)
    UIConfig.cbEnable:SetChecked(ListLooterDB.settings.isLootEnable)
    UIConfig.cbEnable:SetScript(
        "OnClick",
        function(self)
            ListLooterDB.settings.isLootEnable = Config:GetChecked() and true or false
        end
    )

    -- Check Button 2:
    UIConfig.cbCurrency = core.Override.CreateFrameA(nil, "CheckButton", nil, UIConfig, "UICheckButtonTemplate")
    UIConfig.cbCurrency:SetPoint("TOPLEFT", UIConfig.cbEnable, "BOTTOMLEFT", 0, -5)
    UIConfig.cbCurrency.text:SetText(L_OPTIONS_CURRENCY)
    UIConfig.cbCurrency:SetChecked(ListLooterDB.settings.isCurrency)
    UIConfig.cbCurrency:SetScript(
        "OnClick",
        function(self)
            ListLooterDB.settings.isCurrency = self:GetChecked() and true or false
        end
    )

    -- Check Button 3:
    UIConfig.cbQuestItems = core.Override.CreateFrameA(nil, "CheckButton", nil, UIConfig, "UICheckButtonTemplate")
    UIConfig.cbQuestItems:SetPoint("TOPLEFT", UIConfig.cbCurrency, "BOTTOMLEFT", 0, -5)
    UIConfig.cbQuestItems.text:SetText(L_OPTIONS_QUESTITEMS)
    UIConfig.cbQuestItems:SetChecked(ListLooterDB.settings.isQuestItem)
    UIConfig.cbQuestItems:SetScript(
        "OnClick",
        function(self, button, down)
            ListLooterDB.settings.isQuestItem = self:GetChecked() and true or false
        end
    )

    -- Check Button 5:
    UIConfig.cbFishingLoot = core.Override.CreateFrameA(nil, "CheckButton", nil, UIConfig, "UICheckButtonTemplate")
    UIConfig.cbFishingLoot:SetPoint("TOPLEFT", UIConfig.cbQuestItems, "BOTTOMLEFT", 0, -5)
    UIConfig.cbFishingLoot.text:SetText(L_OPTIONS_FISHLOOT)
    UIConfig.cbFishingLoot:SetChecked(ListLooterDB.settings.isFishingLoot)
    UIConfig.cbFishingLoot:SetScript(
        "OnClick",
        function(self, button, down)
            ListLooterDB.settings.isFishingLoot = self:GetChecked() and true or false
        end
    )
    -- Check Button 4:
    UIConfig.cbAfterClose = core.Override.CreateFrameA(nil, "CheckButton", nil, UIConfig, "UICheckButtonTemplate")
    UIConfig.cbAfterClose:SetPoint("TOPLEFT", UIConfig.cbFishingLoot, "BOTTOMLEFT", 0, -5)
    UIConfig.cbAfterClose.text:SetText(L_OPTIONS_AFTERCLOSE)
    UIConfig.cbAfterClose:SetChecked(ListLooterDB.settings.isAfterClose)
    UIConfig.cbAfterClose:SetScript(
        "OnClick",
        function(self, button, down)
            ListLooterDB.settings.isAfterClose = self:GetChecked() and true or false
        end
    )

    -- Drop Down Button 1:
    local fontsList = core.FontProvider:GetFontsName()
    local font_opts = {
        ["name"] = "custom_font_name",
        ["parent"] = UIConfig,
        ["title"] = L_OPTIONS_CUSTOMFONTNAME,
        ["items"] = fontsList,
        ["defaultVal"] = ListLooterDB.settings.customFontName or "Default",
        ["currentVal"] = function()
            return ListLooterDB.settings.customFontName or "Default"
        end,
        ["changeFunc"] = function(dropdown_frame, dropdown_val)
            ListLooterDB.settings.customFontName = dropdown_val
            core.Frame:UpdateSettings()
        end
    }
    UIConfig.ddCustomFont = Config:CreateDropdown(font_opts);
    UIConfig.ddCustomFont:SetPoint("TOPLEFT", UIConfig.cbAfterClose, "BOTTOMLEFT", -12, -15);
    
    -- Drop Down Button 2:
    local themesList = core.ThemesProvider:GetThemesList()
    local themes_opts = {
        ["name"] = "custom_theme_name",
        ["parent"] = UIConfig,
        ["title"] = L_OPTIONS_CUSTOMTHEMENAME,
        ["items"] = themesList,
        ["defaultVal"] = ListLooterDB.settings.theme or "Default",
        ["currentVal"] = function()
            return ListLooterDB.settings.theme or "Default"
        end,
        ["changeFunc"] = function(dropdown_frame, dropdown_val)
            ListLooterDB.settings.theme = dropdown_val
            core.Frame:UpdateSettings()
        end
    }
    UIConfig.ddCustomTheme = Config:CreateDropdown(themes_opts);
    UIConfig.ddCustomTheme:SetPoint("TOPLEFT", UIConfig.ddCustomFont, "BOTTOMLEFT", 0, -15);

    ----------------------------------
    -- FRAME SETTINGS
    ----------------------------------
    UIConfig.poiner2 = Config:CreatePointer(UIConfig, -350, L_OPTIONS_FRAMESETTINGS)
    UIConfig.poiner2:SetWidth(550)

    -- Check Button 5:
    UIConfig.cbLootFrame = core.Override.CreateFrameA(nil, "CheckButton", nil, UIConfig, "UICheckButtonTemplate")
    UIConfig.cbLootFrame:SetPoint("TOPLEFT", UIConfig.poiner2, "BOTTOMLEFT", 0, -5)
    UIConfig.cbLootFrame.text:SetText(L_OPTIONS_FRAMEENABLE)
    UIConfig.cbLootFrame:SetChecked(ListLooterDB.settings.isLootFrame)
    UIConfig.cbLootFrame:SetScript(
        "OnClick",
        function(self, button, down)
            ListLooterDB.settings.isLootFrame = self:GetChecked() and true or false
            core.Frame.HideBlizzardLootFrame("isHide", ListLooterDB.settings.isLootFrame)
        end
    )

    UIConfig.cbItemLevel = core.Override.CreateFrameA(nil, "CheckButton", nil, UIConfig, "UICheckButtonTemplate")
    UIConfig.cbItemLevel:SetPoint("TOPLEFT", UIConfig.cbLootFrame, "BOTTOMLEFT")
    UIConfig.cbItemLevel.text:SetText(L_OPTIONS_SHOWITEMLEVEL)
    UIConfig.cbItemLevel:SetChecked(ListLooterDB.settings.showItemLevel)
    UIConfig.cbItemLevel:SetScript(
        "OnClick",
        function(self, button, down)
            ListLooterDB.settings.showItemLevel = self:GetChecked() and true or false
            core.Frame:UpdateSettings()
        end
    )

    -- Slider 1:
    UIConfig.slider1 =
        Config:CreateSlider(
        UIConfig,
        L_OPTIONS_FRAMEICOSIZE,
        10,
        50,
        ListLooterDB.frame.iconSize,
        "TOPLEFT",
        UIConfig.cbItemLevel,
        "BOTTOMLEFT",
        0,
        -20
    )
    UIConfig.slider1:SetScript(
        "OnValueChanged",
        function(self, value)
            value = math.floor(value + .5)

            ListLooterDB.frame.iconSize = value
            self.current:SetText(value)

            core.Frame.UpdateSettings()
        end
    )

    -- Slider 2:
    UIConfig.slider2 =
        Config:CreateSlider(
        UIConfig,
        L_OPTIONS_FRAMEFONTITEMSIZE,
        8,
        20,
        ListLooterDB.frame.fontSizeItem,
        "TOPLEFT",
        UIConfig.cbItemLevel,
        "BOTTOMLEFT",
        300,
        -20
    )
    UIConfig.slider2:SetScript(
        "OnValueChanged",
        function(self, value)
            value = math.floor(value + .5)

            ListLooterDB.frame.fontSizeItem = value
            self.current:SetText(value)

            core.Frame.UpdateSettings()
        end
    )

    -- Slider 3:
    UIConfig.slider3 =
        Config:CreateSlider(
        UIConfig,
        L_OPTIONS_FRAMEFONTCOUNTSIZE,
        8,
        20,
        ListLooterDB.frame.fontSizeCount,
        "TOPLEFT",
        UIConfig.slider1,
        "BOTTOMLEFT",
        0,
        -40
    )
    UIConfig.slider3:SetScript(
        "OnValueChanged",
        function(self, value)
            value = math.floor(value + .5)

            ListLooterDB.frame.fontSizeCount = value
            self.current:SetText(value)

            core.Frame.UpdateSettings()
        end
    )

    --InterfaceOptions_AddCategory(UIConfig)
    core.SettingsProvider.InterfaceOptions_AddCategory(nil, UIConfig, UIConfig.name)

    -- LIST SETTINGS
    ----------------------------------
    UIConfig.list =
        core.Override.CreateFrameA(nil, "Frame", "ListLooterConfigList", InterfaceOptionsFramePanelContainer)
    UIConfig.list.name = L_OPTIONS_LISTPANELNAME
    UIConfig.list.parent = UIConfig.name
    UIConfig.list:SetScript(
        "OnEnter",
        function()
            if (previouslyItemListRow) then
                previouslyItemListRow.delete:Hide()
                previouslyItemListRow = nil
            end
        end
    )

    -- Title:
    UIConfig.list.title = UIConfig.list:CreateFontString(nil, "BACKGROUND", "GameFontNormalLarge")
    UIConfig.list.title:SetPoint("TOPLEFT", UIConfig.list, "TOPLEFT", 40, -20)
    UIConfig.list.title:SetText(L_OPTIONS_LISTPANELNAME)

    -- Desctiption:
    UIConfig.list.description = UIConfig.list:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    UIConfig.list.description:SetPoint("TOPLEFT", UIConfig.list, "TOPLEFT", 40, -55)
    UIConfig.list.description:SetText(L_OPTIONS_LISTADDTEXT)

    -- Edit text:
    UIConfig.list.ebItemId = Config:CreateEditBox(UIConfig.list, -75, false)
    UIConfig.list.ebItemId:SetScript(
        "OnEnterPressed",
        function(self)
            local newId = self:GetText()
            self:SetText("")
            self:ClearFocus()
            Config:AddItem(newId)
        end
    )
    -- List of items:
    UIConfig.list.listFrame = core.Override.CreateFrameA(nil, "FRAME", nil, UIConfig.list)
    UIConfig.list.listFrame:SetHeight(400)
    UIConfig.list.listFrame:SetWidth(384)
    UIConfig.list.listFrame:EnableMouse(false)
    UIConfig.list.listFrame:SetAllPoints(UIConfig.list)
    UIConfig.list.listFrame:SetPoint("TOPLEFT", 35, -100)
    UIConfig.list.listFrame:SetPoint("BOTTOMRIGHT", -30, 30)

    core.Override.ApplyBackdropA(
        nil,
        UIConfig.list.listFrame,
        {
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16
        }
    )
    UIConfig.list.listFrame:SetBackdropColor(0, 0, 0, 0.2)

    -- scrollframe
    UIConfig.list.listFrame.ScrollFrame =
        core.Override.CreateFrameA(nil, "ScrollFrame", nil, UIConfig.list.listFrame, "UIPanelScrollFrameTemplate")
    UIConfig.list.listFrame.ScrollFrame:SetPoint("TOPLEFT", UIConfig.list.listFrame, "TOPLEFT", 4, -8)
    UIConfig.list.listFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", UIConfig.list.listFrame, "BOTTOMRIGHT", -3, 4)
    UIConfig.list.listFrame.ScrollFrame:SetClipsChildren(true)
    UIConfig.list.listFrame.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)

    UIConfig.list.listFrame.ScrollFrame.ScrollBar:ClearAllPoints()
    UIConfig.list.listFrame.ScrollFrame.ScrollBar:SetPoint(
        "TOPLEFT",
        UIConfig.list.listFrame.ScrollFrame,
        "TOPRIGHT",
        -12,
        -18
    )
    UIConfig.list.listFrame.ScrollFrame.ScrollBar:SetPoint(
        "BOTTOMRIGHT",
        UIConfig.list.listFrame.ScrollFrame,
        "BOTTOMRIGHT",
        -7,
        18
    )

    -- content frame
    UIConfig.list.listFrame.ScrollFrame.content = core.Override.CreateFrameA(nil, "Frame", nil, UIConfig.list.listFrame.ScrollFrame)
    if (core.Override:IfNewVersion()) then
        UIConfig.list.listFrame.ScrollFrame.content:SetSize(585, 200)
    else
        UIConfig.list.listFrame.ScrollFrame.content:SetSize(InterfaceOptionsFramePanelContainer:GetWidth() - 75, 200)
    end
    UIConfig.list.listFrame.ScrollFrame:SetScrollChild(UIConfig.list.listFrame.ScrollFrame.content)
    UIConfig.list.listFrame.ScrollFrame.content.rows = {}

    Config:CreateContent(UIConfig.list.listFrame.ScrollFrame.content)

    --InterfaceOptions_AddCategory(UIConfig.list)
    core.SettingsProvider.InterfaceOptions_AddCategory(nil, UIConfig.list, UIConfig.list.name, UIConfig.category)

    return UIConfig
end

function Config:CreateDropdown(opts)
    local dropdown_name = "$parent_" .. opts["name"] .. "_dropdown"
    local menu_items = opts["items"] or {}
    local title_text = opts["title"] or ""
    local dropdown_width = 0
    local default_val = opts["defaultVal"] or ""
    local current_val = opts["currentVal"] or function()
        end
    local change_func = opts["changeFunc"] or function()
        end

    local dropdown = CreateFrame("Frame", dropdown_name, opts["parent"], "UIDropDownMenuTemplate")
    local dd_title = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dd_title:SetPoint("TOPLEFT", 20, 10)

    for key, item in pairs(menu_items) do
        dd_title:SetText(key)
        local text_width = dd_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width + 100
        end
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(
        dropdown,
        function(self, level, _)
            local info = UIDropDownMenu_CreateInfo()
            for key, val in pairs(menu_items) do
                info.text = key
                info.checked = (current_val() == key)
                info.menuList = key
                info.hasArrow = false
                info.func = function(b)
                    UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                    UIDropDownMenu_SetText(dropdown, b.value)
                    b.checked = true
                    change_func(dropdown, b.value)
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    )

    return dropdown
end

function Config:CreateSlider(parent, name, min, max, cur, ...)
    local sliderBackdrop = {
        bgFile = [[Interface\Buttons\UI-SliderBar-Background]],
        tile = true,
        tileSize = 8,
        edgeFile = [[Interface\Buttons\UI-SliderBar-Border]],
        edgeSize = 8,
        insets = {
            left = 3,
            right = 3,
            top = 6,
            bottom = 6
        }
    }

    local slider = core.Override.CreateFrameA(nil, "Slider", nil, parent)
    slider:SetOrientation "HORIZONTAL"
    slider:SetPoint(...)
    slider:SetSize(250, 17)
    slider:SetHitRectInsets(0, 0, -10, -10)
    core.Override.ApplyBackdropA(nil, slider, sliderBackdrop)

    slider:SetThumbTexture [[Interface\Buttons\UI-SliderBar-Button-Horizontal]]
    slider:SetMinMaxValues(min, max)
    slider:SetValue(cur)

    slider.label = Config:CreateFontString(parent, name, "GameFontHighlightCenter", "BOTTOM", slider, "TOP")
    slider.min = Config:CreateFontString(parent, min, "GameFontHighlightSmall", "TOPLEFT", slider, "BOTTOMLEFT", 2, 2)
    slider.max = Config:CreateFontString(parent, max, "GameFontHighlightSmall", "TOPRIGHT", slider, "BOTTOMRIGHT", -2, 2)
    slider.current = Config:CreateFontString(parent, cur, "GameFontHighlightSmall", "TOP", slider, "BOTTOM")

    return slider
end

function Config:CreateFontString(parent, text, template, ...)
    local label = parent:CreateFontString(nil, nil, template or "GameFontHighlight")
    label:SetPoint(...)
    label:SetText(text)

    return label
end

function Config:AddItemByLink(itemLink)
    if itemLink ~= nil then
        local _, _, Id = string.find(itemLink, "item:(%d+):")

        if Id then
            table.insert(ListLooterDB.LootDB, Id)
            Config:GetListFromGlobal()
            Config:CreateContent(UIConfig.list.listFrame.ScrollFrame.content)
            print("ListLooter: " .. itemLink .. " added")
        end
    end
end

--------------------------------------
-- Events
--------------------------------------
local events = CreateFrame("Frame")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
events:SetScript("OnEvent", Config.OnEvent)
