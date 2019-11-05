--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Frame = {}; -- adds Frame table to addon namespace

--------------------------------------
-- Defaults (usually a database!)
--------------------------------------
local defaults = {
	frame = {
		iconSize = 22,
		fontItem = GameFontWhite:GetFont(),
        fontSizeItem = 12,
        fontCount = NumberFontNormalSmall:GetFont(),
        fontSizeCount = 12
	},
	framePosition = "",
	item = {
		index = 0,
		lootIcon = 0, 
		lootName = "", 
		lootQuantity = 0, 
		currencyID = nil, 
		lootQuality = 0, 
		locked = nil, 
		isQuestItem = nil, 
		questID = nil, 
		isActive = nil
	},
	delta = 5
}
--------------------------------------
local Frame = core.Frame;
local UIFrame;
local m = 0;

local round = function(n)
	return math.floor(n * 1e5 + .5) / 1e5;
end

function Frame:SavePosition()
	local point, parent, _, x, y = UIFrame:GetPoint();

	defaults.framePosition = string.format(
		'%s\031%s\031%d\031%d',
		point, 'UIParent', round(x), round(y)
	);
end

function Frame:LoadPosition()
	local scale = UIFrame:GetScale();
	local point, parentName, x, y = string.split('\031', defaults.framePosition);

	UIFrame:ClearAllPoints();
	UIFrame:SetPoint(point, parentName, point, x / scale, y / scale);
end
	
function Frame:Init()
	UIFrame = CreateFrame("Button", "ListLooterLootFrame", UIParent)
	UIFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 2*defaults.delta, -2*defaults.delta);
	UIFrame:SetSize(1,1);
	UIFrame:SetShown(false);
	
	UIFrame:SetMovable(true)
	UIFrame:RegisterForClicks"anyup"

	UIFrame:SetBackdrop{
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	}
	UIFrame:SetBackdropColor(0, 0, 0, 0.8)

	UIFrame:SetClampedToScreen(true)
	UIFrame:SetClampRectInsets(0, 0, 14, 0)
	UIFrame:SetHitRectInsets(0, 0, -14, 0)
	UIFrame:SetFrameStrata"HIGH"
	UIFrame:SetToplevel(true)
	
	UIFrame:SetScript("OnMouseDown", function(self)
		if(IsShiftKeyDown()) then
			self:StartMoving();
		end
	end)

	UIFrame:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing();
		Frame:SavePosition();
	end)

	UIFrame:SetScript("OnHide", function(self)
		StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"
		CloseLoot();
	end)
	
	UIFrame.Items = {};
end

function Frame:GetEmptyItem()
	return defaults.item;
end

function Frame:AddItem(...)
	local lootInfo = {...};
	local item = Frame:GetEmptyItem();
	
	item.index = lootInfo[1];
	item.lootIcon = lootInfo[2];
	item.lootName = lootInfo[3];
	item.lootQuantity = lootInfo[4];
	item.currencyID = lootInfo[5];
	item.lootQuality = lootInfo[6]; 
	item.locked = lootInfo[7];
	item.isQuestItem = lootInfo[8];
	item.questID = lootInfo[9];
	item.isActive = lootInfo[10];
	
	local itemFrame = UIFrame.Items[item.index];
	
	if (not itemFrame) then
		itemFrame = Frame:CreateItemFrame();
		table.insert(UIFrame.Items, itemFrame);
	end 
	
	itemFrame.index = item.index;
	
	if (item.currencyID) then
		item.lootName, item.lootIcon, item.lootQuantity, item.lootQuality = CurrencyContainerUtil.GetCurrencyContainerInfo(item.currencyID, item.lootQuantity, item.lootName, item.lootIcon, item.lootQuality);
	end
	
	if(item.lootIcon) then 
		local color = ITEM_QUALITY_COLORS[item.lootQuality]
		local r, g, b = color.r, color.g, color.b

		local slotType = GetLootSlotType(item.index)
		if(slotType == LOOT_SLOT_MONEY) then
			item = item:gsub("\n", ", ")
		end

		if(item.lootQuantity > 1) then
			itemFrame.count:SetText(item.lootQuantity)
			itemFrame.count:Show()
		else
			itemFrame.count:Hide()
		end

		if(item.questID and not item.isActive) then
			itemFrame.quest:Show()
		else
			itemFrame.quest:Hide()
		end

		if(item.lootQuality > 1 or item.questID or item.isQuestItem) then
			if(item.questID or item.isQuestItem) then
				r, g, b = 1, 1, .2
			end

			itemFrame.drop:SetVertexColor(r, g, b)
			itemFrame.drop:Show()
		else
			itemFrame.drop:Hide()
		end

		itemFrame.isQuestItem = item.isQuestItem
		itemFrame.quality = item.lootQuality

		itemFrame.name:SetText(item.lootName)
		itemFrame.name:SetTextColor(r, g, b)
		itemFrame.icon:SetTexture(item.lootIcon)

		m = math.max(m, item.lootQuality)

		itemFrame:Enable()
		itemFrame:Show()
	end 
end

function Frame:CreateItemFrame(id)
	local iconSize = ListLooterDB.frame.iconSize;
	local fontSizeItem = ListLooterDB.frame.fontSizeItem;
	local fontSizeCount = ListLooterDB.frame.fontSizeCount;
	local fontItem = defaults.frame.fontItem;
	local fontCount = defaults.frame.fontCount;
	local posId = table.getn(UIFrame.Items)+1;
	
	local frame = CreateFrame("Button", "ListLooterLootFrameItem"..posId, UIFrame);
	frame:SetHeight(math.max(fontSizeItem, iconSize));
	frame:SetID(posId);

	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	frame:SetScript("OnEnter", function(self)
		local slot = self.index;
		if(GetLootSlotType(slot) == LOOT_SLOT_ITEM) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetLootItem(slot)
			CursorUpdate(self)
		end
		if(self.drop:IsShown()) then
			local r, g, b = self.drop:GetVertexColor()
			self.drop:SetVertexColor(r * .6, g * .6, b * .6)
		else
			self.drop:SetVertexColor(1, 1, 0)
		end

		self.drop:Show()
	end);
	
	frame:SetScript("OnLeave", function(self)
		if(self.quality > 1) then
			local color = ITEM_QUALITY_COLORS[self.quality]
			self.drop:SetVertexColor(color.r, color.g, color.b)
		elseif(self.isQuestItem) then
			self.drop:SetVertexColor(1, 1, .2)
		else
			self.drop:Hide()
		end
		
		GameTooltip:Hide()
		ResetCursor()
	end);
	
	frame:SetScript("OnClick", function(self)
		if(IsModifiedClick()) then
			HandleModifiedItemClick(GetLootSlotLink(self.index))
			if (IsAltKeyDown()) then
				core.Config.AddItemByLink("link",GetLootSlotLink(self.index));
			end 
		else
			StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION";

			LootFrame.selectedLootButton = self;
			LootFrame.selectedSlot = self.index;
			LootFrame.selectedQuality = self.quality;
			LootFrame.selectedItemName = self.name:GetText();

			LootSlot(self.index); 
		end
	end);
	
	frame:SetScript("OnUpdate", function(self)
		if(GameTooltip:IsOwned(self)) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetLootItem(self.index)
			CursorOnUpdate(self)
		end
	end);

	local iconFrame = CreateFrame("Frame", "ListLooterLootFrameItemIcon", frame);
	iconFrame:SetSize(iconSize, iconSize);
	iconFrame:SetPoint("RIGHT", frame);
	frame.iconFrame = iconFrame;

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetAlpha(.8)
	icon:SetTexCoord(.07, .93, .07, .93)
	icon:SetAllPoints(iconFrame)
	frame.icon = icon

	local quest = iconFrame:CreateTexture(nil, 'OVERLAY')
	quest:SetTexture([[Interface\Minimap\ObjectIcons]])
	quest:SetTexCoord(1/8, 2/8, 1/8, 2/8)
	quest:SetSize(iconSize * .8, iconSize * .8)
	quest:SetPoint('BOTTOMLEFT', -iconSize * .15, 0)
	frame.quest = quest

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:SetJustifyH"RIGHT"
	count:SetPoint("BOTTOMRIGHT", iconFrame, 2, 2)
	count:SetFont(fontCount, fontSizeCount, 'OUTLINE')
	count:SetShadowOffset(.8, -.8)
	count:SetShadowColor(0, 0, 0, 1)
	count:SetText(1)
	frame.count = count

	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH"LEFT"
	name:SetPoint("LEFT", frame)
	name:SetPoint("RIGHT", iconFrame, "LEFT")
	name:SetNonSpaceWrap(true)
	name:SetFont(fontItem, fontSizeItem)
	name:SetShadowOffset(.8, -.8)
	name:SetShadowColor(0, 0, 0, 1)
	frame.name = name

	local drop = frame:CreateTexture(nil, "ARTWORK")
	drop:SetTexture[[Interface\QuestFrame\UI-QuestLogTitleHighlight]]

	drop:SetPoint("LEFT", icon, "RIGHT")
	drop:SetPoint("RIGHT", frame)
	drop:SetAllPoints(frame)
	drop:SetAlpha(.3)
	frame.drop = drop
	
	return frame
end

function Frame:ShowLootList()
	if (Frame:GetVisibleListItems() == 0) then return end;
	Frame:AnchorItemsFrames();
	
	local color = ITEM_QUALITY_COLORS[m];
	UIFrame:SetBackdropBorderColor(color.r, color.g, color.b, .8);
	
	Frame:UpdateWidth();
	
	-- Blizzard uses strings here
	if(GetCVar("lootUnderMouse") == "1") then
		local x, y = GetCursorPosition();
		x = x / UIFrame:GetEffectiveScale();
		y = y / UIFrame:GetEffectiveScale();

		UIFrame:ClearAllPoints();
		UIFrame:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x-40, y+20);
		UIFrame:GetCenter();
		UIFrame:Raise();
	end
	
	UIFrame:Show();
end

function Frame:GetVisibleListItems()
	local result = 0;
	for i=1, table.getn(UIFrame.Items) do
		local frame = UIFrame.Items[i]
		if(frame:IsShown()) then
			result = result + 1;
		end
	end
	return result;
end

function Frame:AnchorItemsFrames()
	local frameSize = math.max(defaults.frame.iconSize, defaults.frame.fontSizeItem);
	local iconSize = defaults.frame.iconSize;
	local shownSlots = 0;

	local prevShown;
	for i=1, table.getn(UIFrame.Items) do
		local frame = UIFrame.Items[i]
		if(frame:IsShown()) then
			frame:ClearAllPoints()
			frame:SetPoint("LEFT", 8, 0)
			frame:SetPoint("RIGHT", -8, 0)
			if(not prevShown) then
				frame:SetPoint('TOPLEFT', UIFrame, 8, -8)
			else
				frame:SetPoint('TOP', prevShown, 'BOTTOM')
			end

			frame:SetHeight(frameSize)
			shownSlots = shownSlots + 1
			prevShown = frame
		end
	end

	local offset = UIFrame:GetTop() or 0
	UIFrame:SetHeight(math.max((shownSlots * frameSize + 16), 20))

	-- Reposition the frame so it doesn't move.
	local point, parent, relPoint, x, y = UIFrame:GetPoint()
	offset = offset - (UIFrame:GetTop() or 0)
	UIFrame:SetPoint(point, parent, relPoint, x, y + offset)
end

function Frame:UpdateWidth()
	local maxWidth = 0;
	for i=1, table.getn(UIFrame.Items) do
		local frame = UIFrame.Items[i];
		if(frame:IsShown()) then
			local width = frame.name:GetStringWidth()
			if(width > maxWidth) then
				maxWidth = width;
			end
		end
	end

	UIFrame:SetWidth(maxWidth + 30 + defaults.frame.iconSize);
end

function Frame:CloseLootFrame()
	StaticPopup_Hide"LOOT_BIND";
	UIFrame:Hide();

	for i=1, table.getn(UIFrame.Items) do
		UIFrame.Items[i]:Hide();
	end
	
	m = 0;
end

function Frame:LootFrameItemCleared(index)
	if(not UIFrame:IsShown()) then return end
	for i=1, table.getn(UIFrame.Items) do
		local frame = UIFrame.Items[i];
		if (frame.index == index) then 
			frame:Hide();
			Frame:AnchorItemsFrames();
			return;
		end 
	end
end

function Frame:UpdateSettings()
	for i=1, table.getn(UIFrame.Items) do
		local frame = UIFrame.Items[i];
		
		local fontName, sizeName, outlineName = frame.name:GetFont();
		frame.name:SetFont(fontName, ListLooterDB.frame.fontSizeItem, outlineName);
		
		local fontCount, sizeCount, outlineCount = frame.count:GetFont();
		frame.count:SetFont(fontCount, ListLooterDB.frame.fontSizeCount, outlineCount);
		
		frame:SetHeight(ListLooterDB.frame.iconSize);
		frame.iconFrame:SetSize(ListLooterDB.frame.iconSize, ListLooterDB.frame.iconSize);

		frame.quest:SetSize(ListLooterDB.frame.iconSize * .8, ListLooterDB.frame.iconSize * .8);
		frame.quest:ClearAllPoints();
		frame.quest:SetPoint('BOTTOMLEFT', -ListLooterDB.frame.iconSize * .15, 0);
		
		Frame:UpdateWidth();
		Frame:AnchorItemsFrames();
	end
end