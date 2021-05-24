--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Override = {}; -- adds Config table to addon namespace

local Override = core.Override;
local Retail = 90000
local TBC = 20000
local RLC = 30000

--------------------------------------
-- Override functions
--------------------------------------

function Override:CreateFrameA(frameType, name, parent, template)
	if Override:CheckVerion() then 
		if (not template) then 
			template = (BackdropTemplateMixin and "BackdropTemplate" or nil);
		end 
		
		local newFrame = CreateFrame(frameType, name, parent, template);
		return newFrame;
	end 
		
	local oldFrame = CreateFrame(frameType, name, parent, template);
	return oldFrame;
end

function Override:ApplyBackdropA(frame, backdrop)
	if Override:CheckVerion() then 
		frame.backdropInfo = backdrop;
		frame:ApplyBackdrop();
	else 
		frame:SetBackdrop(backdrop);
	end
end

function Override:CheckVerion()
	local _, _, _, wowtocversion = GetBuildInfo();
	if wowtocversion and ((wowtocversion >= TBC and wowtocversion < RLC) or  wowtocversion > 90000) then 
		return true;
	end

	return false;
end