local _, core = ...; -- Namespace

--------------------------------------
-- Custom Slash Command
--------------------------------------
core.commands = {
	["config"] = core.Config.ToggleConfig, -- this is a function (no knowledge of Config object)
	
	["help"] = function()
		print(" ");
		core:Print("List of slash commands:")
		core:Print("|cff00cc66/ll config|r - shows config menu");
		core:Print("|cff00cc66/ll help|r - shows help info");
		print(" ");
	end,
	
	["example"] = {
		["test"] = function(...)
			core:Print("My Value:", tostringall(...));
		end
	}
};

local function HandleSlashCommands(str)	
	if (#str == 0) then	
		-- User just entered "/at" with no additional args.
		core.commands.help();
		return;		
	end	
	
	local args = {};
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end
	
	local path = core.commands; -- required for updating found table.
	
	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower();			
			if (path[arg]) then
				if (type(path[arg]) == "function") then				
					-- all remaining args passed to our function!
					path[arg](select(id + 1, unpack(args))); 
					return;					
				elseif (type(path[arg]) == "table") then				
					path = path[arg]; -- another sub-table found!
				end
			else
				-- does not exist!
				core.commands.help();
				return;
			end
		end
	end
end

function core:Print(...)
    local hex = select(4, self.Config:GetThemeColor());
    local prefix = string.format("|cff%s%s|r", hex:upper(), "List Looter:");	
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

-- WARNING: self automatically becomes events frame!
function core:init(event, name)	
	
	if (name == "!ListLooter" and event == "ADDON_LOADED") then 
		-- allows using left and right buttons to move through chat 'edit' box
		for i = 1, NUM_CHAT_WINDOWS do
			_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
		end
		
		----------------------------------
		-- Register Slash Commands!
		----------------------------------
		SLASH_RELOADUI1 = "/rl"; -- new slash command for reloading UI
		SlashCmdList.RELOADUI = ReloadUI;

		SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
		SlashCmdList.FRAMESTK = function()
			LoadAddOn("Blizzard_DebugTools");
			FrameStackTooltip_Toggle();
		end

		SLASH_ListLooter1 = "/ll";
		SlashCmdList.ListLooter = HandleSlashCommands;
		
		core.Config.Toggle();
		
		core:Print(L_WELCOMEBACK, UnitName("player").."!");
	end
	
	if (event == "LOOT_OPENED") then 
		core:Loot();
	end
end

function core:Loot()
	--print("event");
	local config = core.Config:GetSettings();
	local db = core.Config:GetLootDB();
	if config.isEnable == true then
		local numLootItems = GetNumLootItems();
		for i= 1, numLootItems , 1 do
			local itemLink = GetLootSlotLink(i)
			local _, lootName, _, currencyID, _, _, isQuestItem = GetLootSlotInfo(i);
			local lootSlotType = GetLootSlotType(i);
			
			if config.isCurrency == true then
				if currencyID ~= nil and lootSlotType ~= LOOT_SLOT_MONEY then
					LootSlot(i)
				elseif currencyID == nil and lootSlotType == LOOT_SLOT_MONEY then
					LootSlot(i)
				end
			end
				
			for c=1, table.getn(db), 1 do
				if itemLink ~= nil then 
					local _, _, Id = string.find(itemLink, "item:(%d+):")
					if db[c] == Id then
						LootSlot(i)
					end
				end
			end
			
			if config.isQuestItem == true then 
				if isQuestItem == true then 
					LootSlot(i)
				end 
			end 
		end
		if config.isAfterClose == true then
			CloseLoot()
		end
	end
end 

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("LOOT_OPENED");
events:SetScript("OnEvent", core.init);