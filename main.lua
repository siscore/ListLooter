AutoLoot = LibStub("AceAddon-3.0"):NewAddon("AutoLoot", "AceConsole-3.0","AceEvent-3.0")

local VerName = "0.1"
local Disabled = false
local isCancel = false

local options = {
	type = "group",
	name = "Options",
	args = 	{
		isEnable =
		{   
		    order = 0,
			type = "toggle",
			name = "Enable AutoLoot",
			width = "full",
			desc = "Enable or disable addon",
			get = function(info) 
					AutoLoot:BuildItemTree();
					return not Disabled 
				  end,
			set = function(info, value) 
					Disabled = not value 
				  end,
		},
		AutoClose =
		{   
		    order = 1,
			type = "toggle",
			name = "Auto close loot frame",
			width = "normal",
			desc = "Enable or disable auto close loot frame",
			get = function(info) 
					return ALAC
				  end,
			set = function(info, value) 
					ALAC = value 
				  end,
		},
		addItem = {
			order = 2,
			type = "input",
			width = "double",
			name = "Add new Item ID:",
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
		if item ~= "isEnable" and item ~= "addItem" and item ~= "removeAllItem" and item ~= "AutoClose" then
			itemsList[item] = nil
		end
	end
	
	local List = AutoLootListDB;
	
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
						name = "ItemID: "..List[i],
						width = "full",
					},	
					removeItem = {
						order = 7,
						width = "double",
						type = "execute",
						name = "Remove item "..itemLink,
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
						name = "Clear all item list",
						confirm = true,
						func = function(info)
									AutoLoot:RemoveAllFromList(List[i]);
									AutoLoot:BuildItemTree()
									self:Print("Done");
								end,
					},
			},
		}
	end
	--self:Print("end BuildItemTree");
end

function AutoLoot:OnInitialize()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AutoLootOptions", options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AutoLootOptions", "AutoLoot Options")
	self.db = LibStub("AceDB-3.0"):New("AutoLootDB",defaults,true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
end

function AutoLoot:OnEnable()
	self:Print("Version " .. VerName .. " Loaded!")
	AutoLoot:RegisterEvent("LOOT_OPENED")
	AutoLoot:RegisterEvent("PLAYER_ENTERING_WORLD")
	AutoLoot:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
	AutoLoot:RegisterChatCommand("AL", "AutoLootTest")
	AutoLoot:RegisterChatCommand("ALD", "AutoLootDisable")
	AutoLoot:RegisterChatCommand("ALH", "AutoLootHelp")
	AutoLoot:RegisterChatCommand("ALA", "AddToList")
	AutoLoot:RegisterChatCommand("ALL", "PrintList")
	AutoLoot:RegisterChatCommand("ALR", "RemoveFromList") 
	AutoLoot:RegisterChatCommand("ALAC", "AutoListAutoClose") 
	AutoLoot:RegisterChatCommand("ALUI", "AutoLootShowUI")
	AutoLoot:BuildItemTree();
	end

function AutoLoot:PLAYER_ENTERING_WORLD()
	AutoLootListDB = AutoLootListDB or {}
	ALAC = ALAC
end

function AutoLoot:LFG_PROPOSAL_SUCCEEDED()
	Disabled = true
	AutoLoot:UnregisterEvent("LOOT_OPENED")
	self:Print("You Have entered a dungeon and therefore AutoLoot Has been disabled , it will re-enable on leaving the dungeon")
	AutoLoot:RegisterEvent("LFG_COMPLETION_REWARD")
end

function AutoLoot:LFG_COMPLETION_REWARD()
    Disabled = false
	AutoLoot:RegisterEvent("LOOT_OPENED")
	self:Print("You have exited the dungeon so AutoLoot has been enabled")
	AutoLoot:UnregisterEvent("LFG_COMPLETION_REWARD")
end

function AutoLoot:LOOT_OPENED()
	local numLootItems = GetNumLootItems();
	
		self:Print("Loot Opened")
	
	for i= 1, numLootItems , 1 do
		local lootIcon, lootName, lootQuantity, rarity, locked = GetLootSlotInfo(i);
		
		itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
		itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
		isCraftingReagent = GetItemInfo(lootName);
		
		local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
		
		--self:Print("|cFF186aa7Check loot |cFF00FF00"..i.." |cFF186aa7name: |cFF00FF00"..itemName)
		
		TestChecked = {}
				
		for c=1 ,(table.getn(AutoLootListDB)),1 do		
			if lootQuantity == 0 then --Money
				self:Print("|cFF00FF00 Current Slot:" .. lootName .. " is MONEY")
				LootSlot(i)
			end 
			
			if AutoLootListDB[c] == Id then
					self:Print("|cFF00FF00 Current Slot:|cFF186aa7" .. lootName .. "|cFF00FF00, Checked With:|cFF186aa7" .. Id .. "|cFF00FF00  (MATCHED)")
					LootSlot(i)
			end	
		end
		
		if ALAC == true then
				CloseLoot()
		end
	end
end

function AutoLoot:AutoLootDisable(input)
	if Disabled == false then
		Disabled = true
		AutoLoot:UnregisterEvent("LOOT_OPENED")
		self:Print("Is Now Disabled!")
	elseif Disabled == true then
		Disabled = false
		AutoLoot:RegisterEvent("LOOT_OPENED")
		self:Print("Is Now Enabled!")
	end
end

function AutoLoot:AutoLootTest(input)
	self:Print("|cFF00FF00 Currently running Version " .. VerName)
	self:Print("|cFF00FF00 Developed by Wicked7000")
end

function AutoLoot:AutoLootHelp(input)
	self:Print("/AL - Tells you the version of AutoLoot you are running")
	self:Print("/ALH - (The Command you used to get this)")
	self:Print("/ALL - Prints the White-list")
	self:Print("/ALA <Item> - Add an item to the White-list (Don't use <>)")
	self:Print("/ALR <Item> - Remove an item to the White-list (Don't use <>)")
	self:Print("/ALAC (yes/no/print) - Change the setting for AutoLoot AutoClose (don't use ())")
	self:Print("/ALD use to enabled and disable AutoLoot")
end

function AutoLoot:AutoListAutoClose(input)
	local boolString
	
	if ALAC == true then
		boolString = "true"
	elseif ALAC == false then
		boolString = "false"
	else
		ALAC = false
		boolString = "false"
		self:Print("|cFFFF0000 No Auto Close Setting , defaulting to false")
	end
	
	if input == "yes" then
		ALAC  = true
		self:Print("|cFF00FF00 AutoLoot Auto Close has been set to true")
	elseif input == "no" then
		ALAC = false
		self:Print("|cFF00FF00 AutoLoot Auto Close has been set to false")
	elseif input == "print" then
		self:Print("|cFF00FF00 The current setting for Auto Close is as follows: " .. boolString)
	else 
		self:Print("|cFFFF0000 Input not recognized please use: (yes) or (no)")
	end
end

function AutoLoot:AddToList(input)
	itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
	itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
	isCraftingReagent = GetItemInfo(input);
	
	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
		
	if Id then 
		self:Print("Item added: "..Id);
		table.insert(AutoLootListDB,Id);
	end
end
 
 function AutoLoot:RemoveFromList(input)
	itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
	itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
	isCraftingReagent = GetItemInfo(input);
	
	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	
	for c=1, table.getn(AutoLootListDB),1 do
		if Id == AutoLootListDB[c] then
			table.remove(AutoLootListDB, c)
			self:Print("|cFF00FF00 Removed " .. input .. " From Whitelist")
		end
	end
 end
 
	function AutoLoot:RemoveAllFromList(input)
		for c = table.getn(AutoLootListDB), 1, -1 do
			table.remove(AutoLootListDB, c)
			self:Print("|cFF00FF00 Removed " .. c .. " From Whitelist")
		end
	end
 
	function AutoLoot:PrintList(input)
		self:Print("|cFF00FF00 Here are the current Items in the Whitelist:")
		for i = 1, table.getn(AutoLootListDB) ,1 do
			self:Print("|cFF00FF00" .. AutoLootListDB[i]);
		end
 end
