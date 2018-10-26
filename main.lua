AutoLoot = LibStub("AceAddon-3.0"):NewAddon("AutoLootList", "AceConsole-3.0","AceEvent-3.0","AceTimer-3.0")
local config = LibStub("AceConfig-3.0")
local dialog = LibStub("AceConfigDialog-3.0")

local icon = '|TInterface\\Addons\\AutoLootList\\Art\\Main Icon:13:13:0:0:128:128:10:118:10:118|t '
local mainOptionName = icon..'AutoLootList'

local VerName = "1.0.3-release"
local MainOptions
local ProfilesOptions 
local db

local reAdd = false
local reRemove = false

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLootList", false)

local defaults = {
	profile = {
		enable = true,
		autoclose = false,
		automoney = true,
		autoquestitems = false,
		loglevel = 2,
		LootDB = {},
	},
}

local options = {
	type = "group",
	name = icon..L["Options"],
	args = 	{
		headerGroup1 =
		{
			order = 0,
			type = "header",
			name = L["Main settings"],
		},
		isEnable =
		{   
		    order = 1,
			type = "toggle",
			name = L["Enable AutoLootList"],
			width = "full",
			desc = L["Enable or disable addon"],
			get = function(info) 
					AutoLoot:BuildItemTree();
					return db.enable
				  end,
			set = function(info, value) 
					db.enable = value
				  end,
		},
		AutoMoney =
		{   
		    order = 2,
			type = "toggle",
			name = L["Auto loot money"],
			width = "full",
			desc = L["Enable or disable auto loot money"],
			get = function(info) 
					return db.automoney
				  end,
			set = function(info, value) 
					db.automoney = value 
				  end,
		},
		AutoQuestItems =
		{   
		    order = 3,
			type = "toggle",
			name = L["Auto loot quest items"],
			width = "full",
			desc = L["Enable or disable auto loot quest items"],
			get = function(info) 
					return db.autoquestitems
				  end,
			set = function(info, value) 
					db.autoquestitems = value 
				  end,
		},
		AutoClose =
		{   
		    order = 4,
			type = "toggle",
			name = L["Auto close loot frame"],
			width = "full",
			desc = L["Enable or disable auto close loot frame"],
			get = function(info) 
					return db.autoclose
				  end,
			set = function(info, value) 
					db.autoclose  = value 
				  end,
		},
		headerGroup2 =
		{
			order = 5,
			type = "header",
			name = L["Logs settings"],
		},
		LogLevel = 
		{
			order = 6,
			type = "select",
			style = "dropdown",
			name = L["Chat logs level"],
			values = {
				L["None"],
				L["Settings"],
				L["All"],
			},
			get = function(info)
					return db.loglevel
				  end,
			set = function(info, value)
				  	db.loglevel = value
				  end,
		}
	},
}

local itemsConfig = {
	type = "group",
	name = L["Items list"],
	args = 	{
		addItem = {
			order = 1,
			type = "input",
			width = "full",
			name = L["Add new Item ID:"],
			set = function(info, value)
				if value then 
					local itemID = tonumber(value)
					if itemID then
						AutoLoot:AddToList(itemID);
						AutoLoot:BuildItemTree();
					end
				end
			end,
		},
	get = function() 
				AutoLoot:BuildItemTree();
		  end,
	},
}

function AutoLoot:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AutoLootListDB",defaults,true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	
	db = self.db.profile
	
	config:RegisterOptionsTable("AutoLootOptions", options)
	MainOptions = dialog:AddToBlizOptions("AutoLootOptions", mainOptionName)
	
	config:RegisterOptionsTable("AutoLootListItemsConfig", itemsConfig)
	ProfilesOptions = dialog:AddToBlizOptions("AutoLootListItemsConfig", L["Items list"], mainOptionName)
	
	config:RegisterOptionsTable("AutoLootListProfiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
	ProfilesOptions = dialog:AddToBlizOptions("AutoLootListProfiles", L["Profiles"], mainOptionName)
end

function AutoLoot:OnProfileChanged()
	db = self.db.profile;
	AutoLoot:BuildItemTree();
end

function AutoLoot:OnEnable()
	self:Print(L["Version: "]..VerName)
	AutoLoot:RegisterEvent("LOOT_OPENED")
	AutoLoot:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
	AutoLoot:RegisterEvent("GET_ITEM_INFO_RECEIVED", "GET_ITEM_INFO_RECEIVED")
	AutoLoot:RegisterChatCommand("ALLIST", "AutoLootSlashProcessorFunc")
end

function AutoLoot:GET_ITEM_INFO_RECEIVED(event, arg1)
	if db.loglevel > 2 then
		self:Print("ITEM INFO SERVER RESPONSE RECEIVED ("..arg1..")")
	end
	
	if reAdd then 
		AutoLoot:AddToList(arg1);
		self:ScheduleTimer("WaitForCache", 1)
		AutoLoot:BuildItemTree();
		reAdd = false
	end
	
	if reRemove then 
		AutoLoot:RemoveFromList(arg1);
		self:ScheduleTimer("WaitForCache", 1)
		AutoLoot:BuildItemTree();
		reRemove = false
	end
end

function AutoLoot:LFG_PROPOSAL_SUCCEEDED()
	db.enabled = false
	AutoLoot:UnregisterEvent("LOOT_OPENED")
	if db.loglevel >= 2 then
		self:Print(L["You Have entered a dungeon and therefore AutoLoot Has been disabled , it will re-enable on leaving the dungeon"])
	end
	AutoLoot:RegisterEvent("LFG_COMPLETION_REWARD")
end

function AutoLoot:LFG_COMPLETION_REWARD()
    db.enabled = true
	AutoLoot:RegisterEvent("LOOT_OPENED")
	if db.loglevel >= 2 then
		self:Print(L["You have exited the dungeon so AutoLoot has been enabled"])
	end
	AutoLoot:UnregisterEvent("LFG_COMPLETION_REWARD")
end

function AutoLoot:LOOT_OPENED()
	if db.enable == true then
		local numLootItems = GetNumLootItems();
		for i= 1, numLootItems , 1 do
			local itemLink = GetLootSlotLink(i)
			local _, lootName, _, currencyID, _, _, isQuestItem = GetLootSlotInfo(i);
			local lootSlotType = GetLootSlotType(i);
			
			if db.automoney == true then
				if currencyID ~= nil and lootSlotType ~= LOOT_SLOT_MONEY then
					LootSlot(i)
					if db.loglevel > 2 then
						self:Print(L["Looted: "]..lootName.." as currency")
					end
				elseif currencyID == nil and lootSlotType == LOOT_SLOT_MONEY then
					LootSlot(i)
					if db.loglevel > 2 then
						self:Print(L["Looted: "]..lootName.." as money")
					end
				end
			end
				
			for c=1, table.getn(db.LootDB), 1 do
				if itemLink ~= nil then 
					local _, _, Id = string.find(itemLink, "item:(%d+):")
					if db.LootDB[c] == Id then
						itemIcon = GetItemIcon(Id)
						if db.loglevel > 2 then 
							self:Print(L["Looted: "].."\124T"..itemIcon..":0\124t"..itemLink)
						end
						LootSlot(i)
					end
				end
			end
			
			if db.autoquestitems == true then 
				if isQuestItem == true then 
					if db.loglevel > 2 then 
						local _, _, Id = string.find(itemLink, "item:(%d+):")
						itemIcon = GetItemIcon(Id)
						self:Print(L["Looted: "].."\124T"..itemIcon..":0\124t"..itemLink)
					end
					LootSlot(i)
				end 
			end 
		end
		if db.autoclose == true then
			CloseLoot()
		end
	end
end

function AutoLoot:AutoLootDisable(input)
	if db.enable == false and input == "yes" then
		db.enable = true
		AutoLoot:UnregisterEvent("LOOT_OPENED")
		if db.loglevel >= 2 then 
			self:Print(L["Addon is Enabled!"])
		end
	elseif db.enable == true and input == "no" then
		db.enable = false
		AutoLoot:RegisterEvent("LOOT_OPENED")
		if db.loglevel >= 2 then 
			self:Print(L["Addon is Disabled!"])
		end
	end
end

function AutoLoot:AutoLootSlashProcessorFunc(input)
	local Args = {}
	local params = ""
	
	for token in string.gmatch(input, "[^%s]+") do
	   table.insert(Args, token);
	end
	
	for i = 2, table.getn(Args) ,1 do
		if params=="" then 
			params = Args[i]
		else
			params = params.." "..Args[i]
		end 
	end
		
	if Args[1] == "" or Args[1] == nil then 
		self:Print(L["|cFF00FF00 Currently running Version "] .. VerName)
		InterfaceOptionsFrame_OpenToCategory(MainOptions)
		InterfaceOptionsFrame_OpenToCategory(MainOptions)
		InterfaceOptionsFrame_OpenToCategory(MainOptions)
	elseif Args[1] == "-help" then AutoLoot:AutoLootPrintHelp()
	elseif Args[1] == "-print" then AutoLoot:PrintList()
	elseif Args[1] == "-printq" then AutoLoot:PrintQuestList()
	elseif Args[1] == "-add" then AutoLoot:AddToList(params)
	elseif Args[1] == "-rem" then AutoLoot:RemoveFromList(params)
	elseif Args[1] == "-autoclose" then AutoLoot:AutoListAutoClose(params)
	elseif Args[1] == "-enable" then AutoLoot:AutoLootDisable(params)
	elseif Args[1] == "-get" then AutoLoot:PrintItemLink(params)
	else AutoLoot:AutoLootPrintHelp()
	end
end

function AutoLoot:AutoLootPrintHelp()
	self:Print(L["/ALLIST - Tells you the version of AutoLootList and open options"])
	self:Print(L["/ALLIST -help - Show help information"])
	self:Print(L["/ALLIST -print - Prints the White-list"])
	self:Print(L["/ALLIST -add <Item> - Add an item to the White-list (Don't use <>)"])
	self:Print(L["/ALLIST -rem <Item> - Remove an item to the White-list (Don't use <>)"])
	self:Print(L["/ALLIST -autoclose <yes/no> - Change the setting for AutoLoot AutoClose (don't use <>)"])
	self:Print(L["/ALLIST -enable <yes/no> use to enabled and disable AutoLoot"])
end

function AutoLoot:AutoListAutoClose(input)
	local boolString
	
	if db.autoclose == true then
		boolString = "true"
	elseif db.autoclose == false then
		boolString = "false"
	else
		db.autoclose = false
		boolString = "false"
		if db.loglevel >= 2 then 
			self:Print(L["|cFFFF0000 No Auto Close Setting , defaulting to false"])
		end
	end
	
	if input == "yes" then
		db.autoclose  = true
		if db.loglevel >= 2 then 
			self:Print(L["|cFF00FF00 AutoLoot Auto Close has been set to true"])
		end
	elseif input == "no" then
		db.autoclose = false
		if db.loglevel >= 2 then 
			self:Print(L["|cFF00FF00 AutoLoot Auto Close has been set to false"])
		end
	elseif input == "print" then
		if db.loglevel >= 2 then 
			self:Print(L["|cFF00FF00 The current setting for Auto Close is as follows: "] .. boolString)
		end
	else
		if db.loglevel >= 2 then 
			self:Print(L["|cFFFF0000 Input not recognized please use: (yes) or (no)"])
		end
	end
end

function AutoLoot:AddToList(input)
	local _, itemLink = GetItemInfo(input) 
		
	if itemLink ~= nil then 
		local _, _, Id = string.find(itemLink, "item:(%d+):")
			
		if Id then 
			if db.loglevel > 2 then 
				self:Print(L["Item added: "]..Id);
			end
			table.insert(db.LootDB,Id);
		end
	else
		reAdd = true 
	end
end
 
 function AutoLoot:RemoveFromList(input)
	local _, itemLink = GetItemInfo(input) 
	
	if itemLink ~= nil then 
		local _, _, Id = string.find(itemLink, "item:(%d+):")
		
		for c=1, table.getn(db.LootDB),1 do
			if Id == db.LootDB[c] then
				table.remove(db.LootDB, c)
				if db.loglevel > 2 then 
					self:Print(L["|cFF00FF00 Removed from whitelist: "] .. input)
				end
			end
		end
	else
		reRemove = true
	end 
 end
 
function AutoLoot:RemoveAllFromList(input)
	for c = table.getn(db.LootDB), 1, -1 do
		table.remove(db.LootDB, c)
		if db.loglevel > 2 then 
			self:Print(L["|cFF00FF00 Removed from whitelist: "] .. c)
		end
	end
end

function AutoLoot:PrintList(input)
	self:Print(L["|cFF00FF00 Here are the current Items in the Whitelist:"])
	for i = 1, table.getn(db.LootDB) ,1 do
		local _, itemLink = GetItemInfo(db.LootDB[i]) 
		if itemLink ~= nil then 
			self:Print("|cFF00FF00" .. itemLink);
		else
			self:Print("|cFFFF0000" .. db.LootDB[i]);
		end 
	end
end

function AutoLoot:PrintQuestList(input)
	self:Print(L["|cFF00FF00 Here are the current Items in the Whitelist:"])
	for i = 1, table.getn(questItemsDB) ,1 do
		self:Print("|cFF00FF00" .. questItemsDB[i]);
	end
end

function AutoLoot:BuildItemTree()
	local itemsList = itemsConfig.args
	for item in pairs(itemsList) do
		if item ~= "isEnable" and item ~= "addItem" and item ~= "removeAllItem" and item ~= "AutoClose" and item ~= "AutoMoney" then
			itemsList[item] = nil
		end
	end
	
	local List = db.LootDB;
	
	for i = 1, table.getn(List) ,1 do	
		local itemName, itemLink = GetItemInfo(List[i]) 
		local itemIcon = GetItemIcon(List[i])
		
		if itemName == nil then 
			itemName = List[i];	
			self:ScheduleTimer("WaitForCache", 3)
		end
		if itemIcon == nil then itemIcon = "0" end
		
		itemsList[tostring(List[i])] = {
			name = itemName,
			type = "group",
			order = 10 + i,
			width = "full",
			args = {
					descItemName = {
						order = 11,
						type = "description",
						name = "\124T"..itemIcon..":0\124t".." "..itemName,
						fontSize = "large",
						width = "full",
					},
					descItemID = {
						order = 12,
						type = "description",
						name = L["ItemID: "]..List[i],
						width = "full",
					},	
					removeItem = {
						order = 13,
						width = "double",
						type = "execute",
						name = L["Remove item "]..itemName,
						confirm = true,
						func = function(info)
									AutoLoot:RemoveFromList(List[i]);
									AutoLoot:BuildItemTree()
							end,
					},
					removeAllItem = {
						order = 14,
						width = "double",
						type = "execute",
						name = L["Clear all item list"],
						confirm = true,
						func = function(info)
									AutoLoot:RemoveAllFromList(List[i]);
									AutoLoot:BuildItemTree()
								end,
					},
			},
		}
	end
end

function AutoLoot:WaitForCache()
	self:CancelAllTimers();
	self:BuildItemTree();
	LibStub("AceConfigRegistry-3.0"):NotifyChange("AutoLootListItemsConfig");
end
