--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
core.ThemesProvider = {} -- adds ThemesProvider table to addon namespace

local ThemesProvider = core.ThemesProvider

local themes = {
    Default = {
        Name = "Default",
        Frame = {
            Backdrop = {
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                tile = true,
                tileSize = 16,
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 16,
                insets = {
                    left = 4,
                    right = 4,
                    top = 4,
                    bottom = 4
                }
            },
            BackdropColor = {
                r = 0,
                g = 0,
                b = 0,
                alpha = .8
            }
        },
        Hex = "00ccff"
    },
    Bordless = {
        Name = "BordlessSquare",
        Frame = {
            Backdrop = {
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                tile = true,
                tileSize = 16,
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 0,
                insets = {
                    left = 4,
                    right = 4,
                    top = 4,
                    bottom = 4
                }
            },
            BackdropColor = {
                r = 0,
                g = 0,
                b = 0,
                alpha = .8
            },
            BackdropBorderColor = {
                r = 0,
                g = 0,
                b = 0,
                alpha = .8
            }
        },
        Hex = "00ccff"
    }
}

function ThemesProvider:getTheme(themeId)
    for key, item in pairs(themes) do
        if (key == themeId) then
            return item
        end
    end

    return themes.Default;
end

function ThemesProvider:GetThemesList()
    return themes
end