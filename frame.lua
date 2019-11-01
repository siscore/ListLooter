--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Frame = {}; -- adds Frame table to addon namespace

local Frame = core.Frame;
local UIFrame;
local UIDebug;
local Loot = {};
local delta = 5;
local frameH = 40;
local frameW = 40;
local iconSize = frameW-1.5*delta;
local fontItem = GameFontWhite:GetFont()
local fontSizeItem = 12;
local fontCount = NumberFontNormalSmall:GetFont()
local fontSizeCount = 12;
local frameTop = -1 * delta;

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
											Frame:AddItemToLoot(-2);
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
	UIFrame = CreateFrame("Frame","ListLotterLootFrame",UIParent)
	UIFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -100);
	UIFrame:SetSize(frameH + 2*delta, lootCount*frameW-((lootCount-3)*delta));
	UIFrame:SetShown(false);
	UIFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	UIFrame:SetBackdropColor(0,0,0,0.8);
	UIFrame.Items = {};
	
	frameTop = -1 * delta;
	
	for c=1, lootCount, 1 do
		local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(Loot[c]);
		------------------------
		if Loot[c]<0 then 
			lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = 134371,"Испорченный мех",c,nil,0,nil,nil,nil,nil
		end
		------------------------
		
		
		local itemFrame = UIFrame.Items[c] or Frame:CreateItem();
		
		local color = ITEM_QUALITY_COLORS[lootQuality]
		local r, g, b = color.r, color.g, color.b
				
		itemFrame.index = c;
		itemFrame.icon:SetTexture(lootIcon);
		itemFrame.name:SetText(lootName)
		itemFrame.name:SetTextColor(r, g, b)
		if(lootQuantity > 1) then
			itemFrame.count:SetText(lootQuantity)
			itemFrame.count:Show()
		else
			itemFrame.count:Hide()
		end
		
		itemFrame:SetShown(true);
	end
	
	local maxItemWidth = 0
	for id = 1, table.getn(UIFrame.Items), 1 do
		local width = UIFrame.Items[id].name:GetWidth() + UIFrame.Items[id].iconFrame:GetWidth() + 4*delta;
		if (width > maxItemWidth) then 
			maxItemWidth = width;
		end 
	end 
	for id = 1, table.getn(UIFrame.Items), 1 do
		UIFrame.Items[id]:SetWidth(maxItemWidth);
	end 
	
	UIFrame:SetWidth(maxItemWidth + 2*delta);
	
	return UIFrame;
end 

function Frame:CreateItem()
	local posId = table.getn(UIFrame.Items)+1;
		
	if (posId > 1) then 
		frameTop = frameTop - frameW + delta;
	end	
	
	local itemFrame = CreateFrame("Button","ListLotterLootFrameItem"..posId,UIFrame);
	itemFrame:SetShown(false);
	itemFrame.index = 0;
	itemFrame:SetPoint("TOP", UIFrame, "TOP", 0, frameTop);
	itemFrame:SetSize(frameH, frameW);
	itemFrame:SetScript("OnClick", function(self, button, down)
									Frame:LootItem(self);
									self:SetShown(false);
								end);
	
	local iconFrame = CreateFrame("Frame","ListLotterLootFrameItemIco",itemFrame);
	iconFrame:SetSize(iconSize, iconSize);
	iconFrame:SetPoint("TOPLEFT", itemFrame, delta, -delta);
	itemFrame.iconFrame = iconFrame;
	
	local icon = itemFrame:CreateTexture(nil,"ARTWORK");
	icon:SetAlpha(.8);
	icon:SetTexCoord(.07, .93, .07, .93);
	icon:SetAllPoints(iconFrame);
	icon:SetTexture(0);
	itemFrame.icon = icon;
	
	local count = iconFrame:CreateFontString(nil, "OVERLAY");
	count:SetJustifyH"RIGHT";
	count:SetPoint("BOTTOMRIGHT", iconFrame, 2, 2);
	count:SetFont(fontCount, fontSizeCount, 'OUTLINE');
	count:SetShadowOffset(.8, -.8);
	count:SetShadowColor(0, 0, 0, 1);
	count:SetText("");
	itemFrame.count = count;
	
	local name = itemFrame:CreateFontString(nil, "OVERLAY");
	name:SetJustifyH"LEFT";
	name:SetPoint("LEFT", itemFrame, "LEFT", iconSize + 2*delta, 0);
	name:SetNonSpaceWrap(true);
	name:SetFont(fontItem, fontSizeItem);
	name:SetShadowOffset(.8, -.8);
	name:SetShadowColor(0, 0, 0, 1);
	name:SetText("");
	itemFrame.name = name;
	itemFrame:SetWidth(name:GetWidth() + iconSize + 4*delta);
	table.insert(UIFrame.Items, itemFrame);
	
	return itemFrame;
end 

function Frame:ShowLootFrame()
	local lootExist = (table.getn(Loot) > 0);
	if (lootExist) then 
		local frame = UIFrame or Frame:CreateLootFrame();
		frame:SetShown(not frame:IsShown());
	end 	
end 

function Frame:AddItemToLoot(...)
	local lootInfo = {...};
	table.insert(Loot, lootInfo[1]);
end 

function Frame:LootItem(self, button)
	LootSlot(self.index);
end 

function Frame:LootClosed()
	local lootExist = (table.getn(Loot) > 0);
	if (lootExist) then 
		Loot = {};
		UIFrame:SetShown(false);
		UIFrame = nil;
	end
end
