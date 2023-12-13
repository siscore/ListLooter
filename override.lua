--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
core.Override = {} -- adds Config table to addon namespace

local Override = core.Override

--------------------------------------
-- Override functions
--------------------------------------

function Override:CreateFrameA(frameType, name, parent, template)
    if Override:CheckVerion() then
        if (not template) then
            template = (BackdropTemplateMixin and "BackdropTemplate" or nil)
        end

        local newFrame = CreateFrame(frameType, name, parent, template)
        return newFrame
    end

    local oldFrame = CreateFrame(frameType, name, parent, template)
    return oldFrame
end

function Override:ApplyBackdropA(frame, backdrop)
    if Override:CheckVerion() then
        frame.backdropInfo = backdrop
        frame:ApplyBackdrop()
    else
        frame:SetBackdrop(backdrop)
    end
end

function Override:CheckVerion()
    return Override:IfNewVersion();
end

function Override:IfNewVersion()
    local _, _, _, tocversion = GetBuildInfo();
    if (tocversion >= 100000) then
        return true;
    else
        return false;
    end
end
