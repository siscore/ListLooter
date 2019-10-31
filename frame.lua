--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Frame = {}; -- adds Frame table to addon namespace

local Frame = core.Frame;
local UIFrame;
local UIDebug;
local Loot = {};

function Frame:DebugFrame()
	local frame = UIDebug or Frame:CreateDebugFrame();
	frame:SetShown(not frame:IsShown());
end

function Frame:CreateDebugFrame()
	UIDebug = CreateFrame("Frame","ListLotterDebugFrame",UIParent,"BasicFrameTemplate");
	UIDebug:SetSize(400,100);
	UIDebug:SetPoint("CENTER");
	UIDebug:SetShown(false);
	
	UIDebug.button1 = CreateFrame("Button","TestButton1",UIDebug,"UIPanelButtonTemplate");
	UIDebug.button1:SetSize(300,20);
	UIDebug.button1:SetPoint("TOP",0,-40);
	UIDebug.button1:SetText("Emulate Open Loot Event");
	UIDebug.button1:SetScript("OnClick", function(self, button, down)
												Frame:AddItemToLoot(-1); 
												Frame:AddItemToLoot(-2);--32458
												Frame:AddItemToLoot(-3); 
												Frame:AddItemToLoot(-4); 
												Frame:ShowLootFrame();
										 end);
	
	UIDebug.button2 = CreateFrame("Button","TestButton1",UIDebug,"UIPanelButtonTemplate");
	UIDebug.button2:SetSize(300,20);
	UIDebug.button2:SetPoint("TOP",0,-65);
	UIDebug.button2:SetText("Emulate Close Loot Event");
	UIDebug.button2:SetScript("OnClick", function(self, button, down)
												Frame:LootClosed();
										 end);
	
	return UIDebug;
end

function Frame:CreateLootFrame()
	local lootCount = table.getn(Loot);
	local frameH = 200;
	local frameW = 40;
	
	local delta = 5; 
	local frameTop = -1 * delta;
	
	UIFrame = CreateFrame("Frame","ListLotterLootFrame",UIParent)
	UIFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -100);
	UIFrame:SetSize(frameH + 2*delta, lootCount*frameW-((lootCount-3)*delta));
	UIFrame:SetShown(false);
	UIFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	UIFrame:SetBackdropColor(0,0,0,0.5);
	UIFrame.Items = {};
	
	for c=1, lootCount, 1 do
		local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(Loot[c]);
		------------------------
		if Loot[c]<0 then 
			lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = 134371,"Испорченный мех",c,nil,0,nil,nil,nil,nil
		end
		------------------------
		if (c > 1) then 
			frameTop = frameTop - frameW + delta;
		end
		local UIItem = CreateFrame("Button","ListLotterLootFrameItem"..c,UIFrame);
		UIItem.index = Loot[c];
		UIItem:SetPoint("TOP", UIFrame, "TOP", 0, frameTop);
		UIItem:SetSize(frameH, frameW);
		UIItem:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
		UIItem:SetBackdropColor(0,0,0,0.7);
		UIItem:SetScript("OnClick", function(self, button, down)
										Frame:LootItem(self);
										self:SetShown(false);
									end);
		
		local UIItemIco = CreateFrame("Frame","ListLotterLootFrameItemIco",UIItem)
		UIItemIco:SetSize(frameW - 2*delta, frameW - 2*delta);
		UIItemIco:SetPoint("TOPLEFT", UIItem, delta, -delta);
		local ico = UIItem:CreateTexture(nil,"BACKGROUND");
		ico:SetTexture(lootIcon);
		ico:SetAllPoints(UIItemIco);
		UIItemIco.texture = ico;
		if (lootQuantity>1) then 
			UIItemIco.text = UIItemIco:CreateFontString(nil, "ARTWORK", "GameFontNormal");
			UIItemIco.text:SetPoint("BOTTOMRIGHT", -delta, delta/2)
			UIItemIco.text:SetText(lootQuantity);
		end 
		
		local UIItemText = CreateFrame("Frame","ListLotterLootFrameItemText",UIItem)
		UIItemText:SetSize(frameH - frameW - 2*delta, frameW - 2*delta);
		UIItemText:SetPoint("LEFT", UIItemIco, frameW - 2*delta,0);
		UIItemText.text = UIItemText:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		UIItemText.text:SetPoint("LEFT",delta,0)
		UIItemText.text:SetText(lootName);
		
		table.insert(UIFrame.Items, UIItem);
	end
	
	return UIFrame;
end 

function Frame:ShowLootFrame()
	local frame = UIFrame or Frame:CreateLootFrame();
	frame:SetShown(not frame:IsShown());	
end 

function Frame:AddItemToLoot(...)
	local lootInfo = {...};
	table.insert(Loot, lootInfo[1]);
end 

function Frame:LootItem(self, button)
	LootSlot(self.index);
end 

function Frame:LootClosed()
	Loot = {};
	UIFrame:Hide();
	UIFrame = nil;
end