AutoLoot = LibStub("AceAddon-3.0"):NewAddon("AutoLootList", "AceConsole-3.0","AceEvent-3.0")
local config = LibStub("AceConfig-3.0")
local dialog = LibStub("AceConfigDialog-3.0")

local VerName = "0.4b"
local MainOptions
local ProfilesOptions 
local db

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLootList", false)

local defaults = {
	profile = {
		enable = true,
		autoclose = false,
		automoney = true,
		LootDB = {},
	},
}

local options = {
	type = "group",
	name = L["Options"],
	args = 	{
		isEnable =
		{   
		    order = 0,
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
		    order = 1,
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
		AutoClose =
		{   
		    order = 2,
			type = "toggle",
			name = L["Auto close loot frame"],
			width = "normal",
			desc = L["Enable or disable auto close loot frame"],
			get = function(info) 
					return db.autoclose
				  end,
			set = function(info, value) 
					db.autoclose  = value 
				  end,
		},
		addItem = {
			order = 3,
			type = "input",
			width = "double",
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
	},
}

function AutoLoot:BuildItemTree()
	--self:Print("begin BuildItemTree");
	local itemsList = options.args
	for item in pairs(itemsList) do
		if item ~= "isEnable" and item ~= "addItem" and item ~= "removeAllItem" and item ~= "AutoClose" and item ~= "AutoMoney" then
			itemsList[item] = nil
		end
	end
	
	local List = db.LootDB;
	
	for i = 1, table.getn(List) ,1 do	
		itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
		itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
		isCraftingReagent = GetItemInfo(List[i]) 
		itemIcon = GetItemIcon(List[i]) 
		itemsList[tostring(List[i])] = {
			name = itemName,
			type = "group",
			order = 10 + i,
			width = "full",
			args = {
					descItemName = {
						order = 5,
						type = "description",
						name = "\124T"..itemIcon..":0\124t".." "..itemName,
						fontSize = "large",
						width = "full",
					},
					descItemID = {
						order = 6,
						type = "description",
						name = L["ItemID: "]..List[i],
						width = "full",
					},	
					removeItem = {
						order = 7,
						width = "double",
						type = "execute",
						name = L["Remove item "]..itemLink,
						confirm = true,
						func = function(info)
									AutoLoot:RemoveFromList(List[i]);
									AutoLoot:BuildItemTree()
							end,
					},
					removeAllItem = {
						order = 8,
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
	--self:Print("end BuildItemTree");
end

function AutoLoot:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AutoLootListDB",defaults,true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	
	db = self.db.profile
	
	config:RegisterOptionsTable("AutoLootOptions", options)
	MainOptions = dialog:AddToBlizOptions("AutoLootOptions", "AutoLootList")

	config:RegisterOptionsTable("AutoLootListProfiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
	ProfilesOptions = dialog:AddToBlizOptions("AutoLootListProfiles", L["Profiles"], "AutoLootList")
end

function AutoLoot:OnProfileChanged()
	db = self.db.profile;
	AutoLoot:BuildItemTree();
end

function AutoLoot:OnEnable()
	self:Print(L["Version: "]..VerName)
	AutoLoot:RegisterEvent("LOOT_OPENED")
	AutoLoot:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
	AutoLoot:RegisterChatCommand("ALLIST", "AutoLootSlashProcessorFunc")
	AutoLoot:BuildItemTree();
	end

function AutoLoot:LFG_PROPOSAL_SUCCEEDED()
	db.enabled = false
	AutoLoot:UnregisterEvent("LOOT_OPENED")
	self:Print(L["You Have entered a dungeon and therefore AutoLoot Has been disabled , it will re-enable on leaving the dungeon"])
	AutoLoot:RegisterEvent("LFG_COMPLETION_REWARD")
end

function AutoLoot:LFG_COMPLETION_REWARD()
    db.enabled = true
	AutoLoot:RegisterEvent("LOOT_OPENED")
	self:Print(L["You have exited the dungeon so AutoLoot has been enabled"])
	AutoLoot:UnregisterEvent("LFG_COMPLETION_REWARD")
end

function AutoLoot:LOOT_OPENED()
	if db.enable == true then 
		local numLootItems = GetNumLootItems();
		
		for i= 1, numLootItems , 1 do
			local lootIcon, lootName, lootQuantity, rarity, locked = GetLootSlotInfo(i);
			
			itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
			itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
			isCraftingReagent = GetItemInfo(lootName);
								
			for c=1, table.getn(db.LootDB), 1 do
				if lootQuantity == 0 then
					if db.automoney == true then
						LootSlot(i)
					end
				else
					local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
					
					if db.LootDB[c] == Id then
						itemIcon = GetItemIcon(Id) 
						self:Print(L["Looted: "].."\124T"..itemIcon..":0\124t"..itemLink)
						LootSlot(i)
					end	
				end
			end
			
			if db.autoclose == true then
				CloseLoot()
			end
		end
	end
end

function AutoLoot:AutoLootDisable(input)
	self:Print(">>>>"..input)
	if db.enable == false and input == "yes" then
		db.enable = true
		AutoLoot:UnregisterEvent("LOOT_OPENED")
		self:Print(L["Addon is Enabled!"])
	elseif db.enable == true and input == "no" then
		db.enable = false
		AutoLoot:RegisterEvent("LOOT_OPENED")
		self:Print(L["Addon is Disabled!"])
	end
end

function AutoLoot:AutoLootSlashProcessorFunc(input)
	local Args = {}
	for token in string.gmatch(input, "[^%s]+") do
	   table.insert(Args, token);
	end
	
	if Args[1] == "" or Args[1] == nil then 
		self:Print(L["|cFF00FF00 Currently running Version "] .. VerName)
		InterfaceOptionsFrame_OpenToCategory(MainOptions)
		InterfaceOptionsFrame_OpenToCategory(MainOptions)
		InterfaceOptionsFrame_OpenToCategory(MainOptions)
	elseif Args[1] == "-help" then AutoLoot:AutoLootPrintHelp()
	elseif Args[1] == "-print" then AutoLoot:PrintList()
	elseif Args[1] == "-add" then AutoLoot:AddToList(Args[2])
	elseif Args[1] == "-rem" then AutoLoot:RemoveFromList(Args[2])
	elseif Args[1] == "-autoclose" then AutoLoot:AutoListAutoClose(Args[2])
	elseif Args[1] == "-enable" then AutoLoot:AutoLootDisable(Args[2])
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
		self:Print(L["|cFFFF0000 No Auto Close Setting , defaulting to false"])
	end
	
	if input == "yes" then
		db.autoclose  = true
		self:Print(L["|cFF00FF00 AutoLoot Auto Close has been set to true"])
	elseif input == "no" then
		db.autoclose = false
		self:Print(L["|cFF00FF00 AutoLoot Auto Close has been set to false"])
	elseif input == "print" then
		self:Print(L["|cFF00FF00 The current setting for Auto Close is as follows: "] .. boolString)
	else 
		self:Print(L["|cFFFF0000 Input not recognized please use: (yes) or (no)"])
	end
end

function AutoLoot:AddToList(input)
	itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
	itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
	isCraftingReagent = GetItemInfo(input);
	
	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
		
	if Id then 
		self:Print(L["Item added: "]..Id);
		table.insert(db.LootDB,Id);
	end
end
 
 function AutoLoot:RemoveFromList(input)
	itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
	itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
	isCraftingReagent = GetItemInfo(input);
	
	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	
	for c=1, table.getn(db.LootDB),1 do
		if Id == db.LootDB[c] then
			table.remove(db.LootDB, c)
			self:Print(L["|cFF00FF00 Removed from whitelist: "] .. input)
		end
	end
 end
 
	function AutoLoot:RemoveAllFromList(input)
		for c = table.getn(db.LootDB), 1, -1 do
			table.remove(db.LootDB, c)
			self:Print(L["|cFF00FF00 Removed from whitelist: "] .. c)
		end
	end
 
	function AutoLoot:PrintList(input)
		self:Print(L["|cFF00FF00 Here are the current Items in the Whitelist:"])
		for i = 1, table.getn(db.LootDB) ,1 do
			itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
			itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
			isCraftingReagent = GetItemInfo(db.LootDB[i]);
			self:Print("|cFF00FF00" .. itemLink);
		end
 end
