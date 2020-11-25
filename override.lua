--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;
core.Override = {}; -- adds Config table to addon namespace

local Override = core.Override;

--------------------------------------
-- Override functions
--------------------------------------

function Override:CreateFrameA(frameType, name, parent, template)
	local _, _, _, wowtocversion = GetBuildInfo();
	
	--print(frameType);
	
	if wowtocversion and wowtocversion > 90000 then 
		if (not template) then 
			template = 'BackdropTemplate';
		end 
		
		local newFrame = CreateFrame(frameType, name, parent, template);
		return newFrame;
	end 
		
	local oldFrame = CreateFrame(frameType, name, parent, template);
	return oldFrame;
end

function Override:ApplyBackdropA(frame, backdrop)
	local _, _, _, wowtocversion = GetBuildInfo();
	
	if (wowtocversion and wowtocversion > 90000) then 
		frame.backdropInfo = backdrop;
		frame:ApplyBackdrop();
	else 
		frame:SetBackdrop(backdrop);
	end
end
