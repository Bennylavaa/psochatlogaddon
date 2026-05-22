local core_mainmenu = require("core_mainmenu")
local cfg = require("Chatlog.configuration")
local optionsLoaded, options = pcall(require, "Chatlog.options")
local image = require("Chatlog.image")

local optionsFileName = "addons/Chatlog/options.lua"
local firstPresent = true
local ConfigurationWindow

-- Helpers in solylib
local function _getMenuState()
    local offsets = {
        0x00A98478,
        0x00000010,
        0x0000001E,
    }
    local address = 0
    local value = -1
    local bad_read = false
    for k, v in pairs(offsets) do
        if address ~= -1 then
            address = pso.read_u32(address + v)
            if address == 0 then
                address = -1
            end
        end
    end
    if address ~= -1 then
        value = bit.band(address, 0xFFFF)
    end
    return value
end
local function IsMenuOpen()
    local menuOpen = 0x43
    local menuState = _getMenuState()
    return menuState == menuOpen
end
local function IsSymbolChatOpen()
    local wordSelectOpen = 0x40
    local menuState = _getMenuState()
    return menuState == wordSelectOpen
end
local function IsMenuUnavailable()
    local menuState = _getMenuState()
    return menuState == -1
end
local function NotNilOrDefault(value, default)
    if value == nil then
        return default
    else
        return value
    end
end
local function GetPosBySizeAndAnchor(_x, _y, _w, _h, _anchor)
    local x
    local y

    local resW = pso.read_u16(0x00A46C48)
    local resH = pso.read_u16(0x00A46C4A)

    -- Top left
    if _anchor == 1 then
        x = _x
        y = _y

    -- Left
    elseif _anchor == 2 then
        x = _x
        y = (resH / 2) - (_h / 2) + _y

    -- Bottom left
    elseif _anchor == 3 then
        x = _x
        y = resH - _h + _y

    -- Top
    elseif _anchor == 4 then
        x = (resW / 2) - (_w / 2) + _x
        y = _y

    -- Center
    elseif _anchor == 5 then
        x = (resW / 2) - (_w / 2) + _x
        y = (resH / 2) - (_h / 2) + _y

    -- Bottom
    elseif _anchor == 6 then
        x = (resW / 2) - (_w / 2) + _x
        y = resH - _h + _y

    -- Top right
    elseif _anchor == 7 then
        x = resW - _w + _x
        y = _y

    -- Right
    elseif _anchor == 8 then
        x = resW - _w + _x
        y = (resH / 2) - (_h / 2) + _y

    -- Bottom right
    elseif _anchor == 9 then
        x = resW - _w + _x
        y = resH - _h + _y

    -- Whatever
    else
        x = _x
        y = _y
    end

    return { x, y }
end
-- End of helpers in solylib

if optionsLoaded then
    -- If options loaded, make sure we have all those we need
    options.configurationEnableWindow = NotNilOrDefault(options.configurationEnableWindow, true)
    options.enable                    = NotNilOrDefault(options.enable, true)
    options.useCustomTheme            = NotNilOrDefault(options.useCustomTheme, false)
    options.fontScale                 = NotNilOrDefault(options.fontScale, 1.0)
    options.toolbarFontScale          = NotNilOrDefault(options.toolbarFontScale, 1.0)

    options.clEnableWindow            = NotNilOrDefault(options.clEnableWindow, true)
    options.clHideWhenMenu            = NotNilOrDefault(options.clHideWhenMenu, true)
    options.clHideWhenSymbolChat      = NotNilOrDefault(options.clHideWhenSymbolChat, true)
    options.clHideWhenMenuUnavailable = NotNilOrDefault(options.clHideWhenMenuUnavailable, true)
    options.clChanged                 = NotNilOrDefault(options.clChanged, false)
    options.clAnchor                  = NotNilOrDefault(options.clAnchor, 1)
    options.clX                       = NotNilOrDefault(options.clX, 50)
    options.clY                       = NotNilOrDefault(options.clY, 50)
    options.clW                       = NotNilOrDefault(options.clW, 450)
    options.clH                       = NotNilOrDefault(options.clH, 350)
    options.clNoTitleBar              = NotNilOrDefault(options.clNoTitleBar, "")
    options.clNoResize                = NotNilOrDefault(options.clNoResize, "")
    options.clNoMove                  = NotNilOrDefault(options.clNoMove, "")
    options.clNoTimestamp             = NotNilOrDefault(options.clNoTimestamp, "")
    options.clTransparentWindow       = NotNilOrDefault(options.clTransparentWindow, false)
    options.clMessageSeparator        = NotNilOrDefault(options.clMessageSeparator, " | ")
    options.clFixedWidthNames         = NotNilOrDefault(options.clFixedWidthNames, true)
    options.clColoredNames            = NotNilOrDefault(options.clColoredNames, false)
    options.clNameColorR              = NotNilOrDefault(options.clNameColorR, 0.5)
    options.clNameColorG              = NotNilOrDefault(options.clNameColorG, 0.8)
    options.clNameColorB              = NotNilOrDefault(options.clNameColorB, 1.0)
    options.clNameColorA              = NotNilOrDefault(options.clNameColorA, 1.0)
    options.clCustomHighlight         = NotNilOrDefault(options.clCustomHighlight, false)
    options.clHighlightColorR         = NotNilOrDefault(options.clHighlightColorR, 0.5)
    options.clHighlightColorG         = NotNilOrDefault(options.clHighlightColorG, 1.0)
    options.clHighlightColorB         = NotNilOrDefault(options.clHighlightColorB, 0.0)
    options.clHighlightColorA         = NotNilOrDefault(options.clHighlightColorA, 1.0)
    options.clTeamChatEnable          = NotNilOrDefault(options.clTeamChatEnable, true)
    options.clTeamChatColorR          = NotNilOrDefault(options.clTeamChatColorR, 0.4)
    options.clTeamChatColorG          = NotNilOrDefault(options.clTeamChatColorG, 0.7)
    options.clTeamChatColorB          = NotNilOrDefault(options.clTeamChatColorB, 1.0)
    options.clTeamChatColorA          = NotNilOrDefault(options.clTeamChatColorA, 1.0)
    options.clColorByClass            = NotNilOrDefault(options.clColorByClass, true)
    options.clShowSectionID           = NotNilOrDefault(options.clShowSectionID, false)
    options.clSectionIDCompact        = NotNilOrDefault(options.clSectionIDCompact, true)
    options.clShowLobbyChat           = NotNilOrDefault(options.clShowLobbyChat, true)
    options.clMuteList                = NotNilOrDefault(options.clMuteList, "")
    options.clLogToFile               = NotNilOrDefault(options.clLogToFile, false)
    options.clRestoreOnStartup        = NotNilOrDefault(options.clRestoreOnStartup, true)
    options.clRestoreLines            = NotNilOrDefault(options.clRestoreLines, 100)
    options.clHighlightWords          = NotNilOrDefault(options.clHighlightWords, "")
    options.clShowSearchBar           = NotNilOrDefault(options.clShowSearchBar, true)
    options.clShowChannelTabs         = NotNilOrDefault(options.clShowChannelTabs, true)
    options.clShowStatsButton         = NotNilOrDefault(options.clShowStatsButton, true)

else
    options =
    {
        configurationEnableWindow = true,
        enable = true,
        useCustomTheme = false,
        fontScale = 1.0,
        toolbarFontScale = 1.0,

        clEnableWindow = true,
        clHideWhenMenu = true,
        clHideWhenSymbolChat = true,
        clHideWhenMenuUnavailable = true,
        clChanged = false,
        clAnchor = 1,
        clX = 50,
        clY = 50,
        clW = 450,
        clH = 350,
        clNoTitleBar = "",
        clNoResize = "",
        clNoMove = "",
        clNoTimestamp = "",
        clTransparentWindow = false,
        clMessageSeparator = " | ",
        clFixedWidthNames = true,
        clColoredNames = false,
        clNameColorR = 0.5,
        clNameColorG = 0.8,
        clNameColorB = 1.0,
        clNameColorA = 1.0,
        clCustomHighlight = false,
        clHighlightColorR = 0.5,
        clHighlightColorG = 1.0,
        clHighlightColorB = 0.0,
        clHighlightColorA = 1.0,
        clTeamChatEnable = true,
        clTeamChatColorR = 0.4,
        clTeamChatColorG = 0.7,
        clTeamChatColorB = 1.0,
        clTeamChatColorA = 1.0,
        clColorByClass = true,
        clShowSectionID = false,
        clSectionIDCompact = true,
        clShowLobbyChat = true,
        clMuteList = "",
        clLogToFile = false,
        clRestoreOnStartup = true,
        clRestoreLines = 100,
        clHighlightWords = "",
        clShowSearchBar = true,
        clShowChannelTabs = true,
        clShowStatsButton = true,

    }
end

local function SaveOptions(options)
    local file = io.open(optionsFileName, "w")
    if file ~= nil then
        io.output(file)

        io.write("return\n")
        io.write("{\n")
        io.write(string.format("    configurationEnableWindow = %s,\n", tostring(options.configurationEnableWindow)))
        io.write(string.format("    enable = %s,\n", tostring(options.enable)))
        io.write(string.format("    useCustomTheme = %s,\n", tostring(options.useCustomTheme)))
        io.write(string.format("    fontScale = %s,\n", tostring(options.fontScale)))
        io.write(string.format("    toolbarFontScale = %s,\n", tostring(options.toolbarFontScale)))
        io.write("\n")
        io.write(string.format("    clEnableWindow = %s,\n", tostring(options.clEnableWindow)))
        io.write(string.format("    clHideWhenMenu = %s,\n", tostring(options.clHideWhenMenu)))
        io.write(string.format("    clHideWhenSymbolChat = %s,\n", tostring(options.clHideWhenSymbolChat)))
        io.write(string.format("    clHideWhenMenuUnavailable = %s,\n", tostring(options.clHideWhenMenuUnavailable)))
        io.write(string.format("    clChanged = %s,\n", tostring(options.clChanged)))
        io.write(string.format("    clAnchor = %i,\n", options.clAnchor))
        io.write(string.format("    clX = %i,\n", options.clX))
        io.write(string.format("    clY = %i,\n", options.clY))
        io.write(string.format("    clW = %i,\n", options.clW))
        io.write(string.format("    clH = %i,\n", options.clH))
        io.write(string.format("    clNoTitleBar = \"%s\",\n", options.clNoTitleBar))
        io.write(string.format("    clNoResize = \"%s\",\n", options.clNoResize))
        io.write(string.format("    clNoMove = \"%s\",\n", options.clNoMove))
        io.write(string.format("    clNoTimestamp = \"%s\",\n", options.clNoTimestamp))
        io.write(string.format("    clTransparentWindow = %s,\n", tostring(options.clTransparentWindow)))
        io.write(string.format("    clMessageSeparator = %q,\n", options.clMessageSeparator))
        io.write(string.format("    clFixedWidthNames = %s,\n", tostring(options.clFixedWidthNames)))
        io.write(string.format("    clColoredNames = %s,\n", tostring(options.clColoredNames)))
        io.write(string.format("    clNameColorR = %s,\n", tostring(options.clNameColorR)))
        io.write(string.format("    clNameColorG = %s,\n", tostring(options.clNameColorG)))
        io.write(string.format("    clNameColorB = %s,\n", tostring(options.clNameColorB)))
        io.write(string.format("    clNameColorA = %s,\n", tostring(options.clNameColorA)))
        io.write(string.format("    clCustomHighlight = %s,\n", tostring(options.clCustomHighlight)))
        io.write(string.format("    clHighlightColorR = %s,\n", tostring(options.clHighlightColorR)))
        io.write(string.format("    clHighlightColorG = %s,\n", tostring(options.clHighlightColorG)))
        io.write(string.format("    clHighlightColorB = %s,\n", tostring(options.clHighlightColorB)))
        io.write(string.format("    clHighlightColorA = %s,\n", tostring(options.clHighlightColorA)))
        io.write(string.format("    clTeamChatEnable = %s,\n", tostring(options.clTeamChatEnable)))
        io.write(string.format("    clTeamChatColorR = %s,\n", tostring(options.clTeamChatColorR)))
        io.write(string.format("    clTeamChatColorG = %s,\n", tostring(options.clTeamChatColorG)))
        io.write(string.format("    clTeamChatColorB = %s,\n", tostring(options.clTeamChatColorB)))
        io.write(string.format("    clTeamChatColorA = %s,\n", tostring(options.clTeamChatColorA)))
        io.write(string.format("    clColorByClass = %s,\n", tostring(options.clColorByClass)))
        io.write(string.format("    clShowSectionID = %s,\n", tostring(options.clShowSectionID)))
        io.write(string.format("    clSectionIDCompact = %s,\n", tostring(options.clSectionIDCompact)))
        io.write(string.format("    clShowLobbyChat = %s,\n", tostring(options.clShowLobbyChat)))
        io.write(string.format("    clMuteList = %q,\n", options.clMuteList))
        io.write(string.format("    clLogToFile = %s,\n", tostring(options.clLogToFile)))
        io.write(string.format("    clRestoreOnStartup = %s,\n", tostring(options.clRestoreOnStartup)))
        io.write(string.format("    clRestoreLines = %i,\n", options.clRestoreLines))
        io.write(string.format("    clHighlightWords = %q,\n", options.clHighlightWords))
        io.write(string.format("    clShowSearchBar = %s,\n", tostring(options.clShowSearchBar)))
        io.write(string.format("    clShowChannelTabs = %s,\n", tostring(options.clShowChannelTabs)))
        io.write(string.format("    clShowStatsButton = %s,\n", tostring(options.clShowStatsButton)))

        io.write("}\n")

        io.close(file)
    end
end


local CHAT_PTR = 0x00A9A920
local prevmaxy = 0
-- One-shot: snap to bottom the first time we have measurable content. The
-- normal follow-bottom logic in DoChat can't do this on the opening frame
-- because GetScrollMaxY hasn't been measured yet (returns 0), so prevmaxy
-- stays 0 and the "grew taller" check never fires.
local needsInitialScroll = true
-- E english
-- J japonese
-- B simple chinese
-- T traditional chinese
-- K korean
-- i think there's more but haven't run into any ingame yet
-- unknown locales will cause parsing issues
local LOCALES = "EJTKB"
local MSG_MATCH = "^(.-) > \t([" .. LOCALES .. "])(.+)"
local MSG_REPLACE = "^\t[" .. LOCALES .. "]"
local QCHAT_MATCH = "^(.-) >( )(.+)$"
local QCHAT_REPLACE = "(> )\t[" .. LOCALES .. "]"
local MAX_GAME_LOG = 29 -- max amount of messages the game stores
local MAX_MSG_SIZE = 100 -- not correct but close enough, character name length seems to affect it
local output_messages = {}

-- Team chat lives in a separate fixed-slot ring buffer (no pointer indirection
-- like lobby uses). Stride per slot is 0x120 bytes; 30 slots total.
local TEAM_CHAT_BASE = 0x00A98600
local TEAM_CHAT_PER_SLOT = 0x120
local TEAM_CHAT_SLOTS = 30
local team_chat_memory = {}
for i = 1, TEAM_CHAT_SLOTS do team_chat_memory[i] = "" end
local team_chat_initialized = false

-- Last-seen lobby messages used only for diff alignment, never for rendering.
-- Lets the Clear Chat Log button wipe output_messages without causing the next
-- tick to re-bootstrap from the in-game ring buffer.
local lobby_align = {}

local function get_chat_log()
    local messages = {}
    for i = 0, MAX_GAME_LOG do -- for each pointer to a message
        local ptr = pso.read_u32(CHAT_PTR + i * 4)

        if ptr and ptr ~= 0 then
            local rawmsg = pso.read_wstr(ptr, MAX_MSG_SIZE)
            -- was there any message?
            if rawmsg ~= nil and #rawmsg > 0 then
                rawmsg = string.gsub(rawmsg, MSG_REPLACE, "") -- remove some shit
                local name, locale, msg = string.match(rawmsg, MSG_MATCH) -- try match the rights parts
                rawmsg = string.gsub(rawmsg, "\n", " ") -- replace newlines
                if not msg then
                    -- failed to match regular message format,
                    -- so it's probably a quickchat message
                    rawmsg = string.gsub(rawmsg, QCHAT_REPLACE, "%1") -- remove some shit
                    name, locale, msg = string.match(rawmsg, QCHAT_MATCH) -- try match again
                end
                -- good enough
                if name == nil then
                    name = ""
                end
                local sanitizedName = name
                if pso.require_version == nil or not pso.require_version(3, 6, 0) then
                    sanitizedName = string.gsub(name, "%%", "%%%%") -- escape '%'
                end
                sanitizedName = string.gsub(sanitizedName, "%s+$", "")
                table.insert(messages, {name = sanitizedName, text = msg, date = "??:??:??", channel = "lobby"})
            end
        end
    end
    return messages
end

-- Return only the lobby-channel entries from a message list. Used so the lobby diff
-- aligns against lobby history when team messages are interleaved in output_messages.
local function lobby_only(messages)
    local result = {}
    for i = 1, #messages do
        if messages[i].channel ~= "team" then
            table.insert(result, messages[i])
        end
    end
    return result
end

-- Team chat uses a different format than lobby: locale markers appear inline
-- (not just leading) and the separator is ":" rather than " > ". Strip every
-- "\t<locale>" globally, then try ">" first (in case some variant uses it) and
-- ":" as the fallback. If nothing splits, return the cleaned string as body.
local TEAM_LOCALE_REPLACE = "\t[" .. LOCALES .. "]"
local function parse_team_message(raw)
    local cleaned = string.gsub(raw, TEAM_LOCALE_REPLACE, "")
    cleaned = string.gsub(cleaned, "\n", " ")
    cleaned = string.gsub(cleaned, "^%s+", "")
    cleaned = string.gsub(cleaned, "%s+$", "")

    local name, body = string.match(cleaned, "^([^>]-)%s*>%s*(.+)$")
    if not body then
        name, body = string.match(cleaned, "^([^:]-)%s*:%s*(.+)$")
    end
    if not body then
        return "", cleaned
    end
    name = string.gsub(name or "", "%s+$", "")
    return name, body
end

-- Read the team-chat ring buffer and return any messages that have appeared since
-- the last call. The first call seeds team_chat_memory without producing messages
-- so we don't dump 30 stale entries on launch / re-enable.
local function get_team_chat_changes()
    local new_messages = {}
    for slot = 1, TEAM_CHAT_SLOTS do
        local addr = TEAM_CHAT_BASE + (slot - 1) * TEAM_CHAT_PER_SLOT
        local raw = pso.read_wstr(addr, MAX_MSG_SIZE) or ""
        if raw ~= team_chat_memory[slot] then
            team_chat_memory[slot] = raw
            if team_chat_initialized and #raw > 0 then
                local name, body = parse_team_message(raw)
                local sanitizedName = name
                if pso.require_version == nil or not pso.require_version(3, 6, 0) then
                    sanitizedName = string.gsub(name, "%%", "%%%%")
                end
                table.insert(new_messages, {
                    name = sanitizedName,
                    text = body,
                    date = os.date("%H:%M:%S"),
                    channel = "team"
                })
            end
        end
    end
    team_chat_initialized = true
    return new_messages
end

local GC_PTR = 0x00A46B8C
-- Read character data from the player pointers and not the player & team data.
local CHARACTERLIST_PTR = 0x00A94254
local CHARACTERNAME_OFFSET = 0x980
local GC_OFFSET = 0xeb4
local MAX_PLAYERS = 12

-- Len is max number of wide chars to read.
local function read_wstr_max_size(addr, len)
    -- Read the UTF-16 string and convert it to UTF-8
    local wstr = pso.read_wstr(addr, len)

    -- If the first character is \t, then the name has a language code. This should 
    -- always be true while reading the character name out of the player object.
    -- utf8 library isn't available in the plugin's Lua implementation
    -- and string.byte() will truncate the return value to a single byte, so have
    -- to read the address again to check.
    local first_wchar = pso.read_u16(addr)
    if first_wchar == 0x0009 and #wstr >= 2 then
        wstr = string.sub(wstr, 3)
    end

    return wstr
end

local function get_gc()
    return pso.read_u32(GC_PTR)
end

local function get_charactername(gc)
    for i = 0, MAX_PLAYERS - 1 do

        local player = pso.read_u32(CHARACTERLIST_PTR + 4 * i)
        if player ~= 0 then
            local gc0 = pso.read_u32(player + GC_OFFSET)
            if gc == gc0 then
                -- 12 utf-16 chars because two for language code and then 10 for the name.
                return read_wstr_max_size(player + CHARACTERNAME_OFFSET, 12)
            end
        end
    end
    return nil
end

local SECTIONID_OFFSET = 0x960
local CLASS_OFFSET = 0x961

-- Class index → role tint. Indices come from solylib/characters.lua.
--   Hunter: 0,1,2,9   Ranger: 3,4,5,11   Force: 6,7,8,10
local CLASS_COLORS = {}
local hunterColor = {1.0, 0.45, 0.45, 1.0}
local rangerColor = {0.45, 0.95, 0.45, 1.0}
local forceColor  = {0.75, 0.55, 1.0,  1.0}
for _, i in ipairs({0, 1, 2, 9})  do CLASS_COLORS[i] = hunterColor end
for _, i in ipairs({3, 4, 5, 11}) do CLASS_COLORS[i] = rangerColor end
for _, i in ipairs({6, 7, 8, 10}) do CLASS_COLORS[i] = forceColor  end

local CLASS_NAMES = {
    [0]  = "HUmar",
    [1]  = "HUnewearl",
    [2]  = "HUcast",
    [3]  = "RAmar",
    [4]  = "RAcast",
    [5]  = "RAcaseal",
    [6]  = "FOmarl",
    [7]  = "FOnewm",
    [8]  = "FOnewearl",
    [9]  = "HUcaseal",
    [10] = "FOmar",
    [11] = "RAmarl",
}

-- Section ID index → display name and canonical color.
local SECTION_INFO = {
    [0] = {name = "Viridia",    color = {0.30, 0.85, 0.30, 1.0}},
    [1] = {name = "Greenill",   color = {0.55, 1.00, 0.55, 1.0}},
    [2] = {name = "Skyly",      color = {0.55, 0.95, 1.00, 1.0}},
    [3] = {name = "Bluefull",   color = {0.45, 0.55, 1.00, 1.0}},
    [4] = {name = "Purplenum",  color = {0.75, 0.45, 1.00, 1.0}},
    [5] = {name = "Pinkal",     color = {1.00, 0.55, 0.85, 1.0}},
    [6] = {name = "Redria",     color = {1.00, 0.40, 0.40, 1.0}},
    [7] = {name = "Oran",       color = {1.00, 0.65, 0.25, 1.0}},
    [8] = {name = "Yellowboze", color = {1.00, 0.95, 0.40, 1.0}},
    [9] = {name = "Whitill",    color = {1.00, 1.00, 1.00, 1.0}},
}

-- Section ID index → icon file path. Used in compact mode (clSectionIDCompact)
-- in place of "[*]". Missing files quietly fall back to "[*]" at render time,
-- so all 10 slots can be listed here even before every PNG exists on disk.
local SECTION_IMAGES = {
    [0] = "addons/Chatlog/sectionids/viridia.png",
    [1] = "addons/Chatlog/sectionids/greenill.png",
    [2] = "addons/Chatlog/sectionids/skyly.png",
    [3] = "addons/Chatlog/sectionids/bluefull.png",
    [4] = "addons/Chatlog/sectionids/purplenum.png",
    [5] = "addons/Chatlog/sectionids/pinkal.png",
    [6] = "addons/Chatlog/sectionids/redria.png",
    [7] = "addons/Chatlog/sectionids/oran.png",
    [8] = "addons/Chatlog/sectionids/yellowboze.png",
    [9] = "addons/Chatlog/sectionids/whitill.png",
}

-- Cache of currently-visible player info, keyed by lowercased name.
local player_info_cache = {}

local function update_player_info_cache()
    player_info_cache = {}
    for i = 0, MAX_PLAYERS - 1 do
        local player = pso.read_u32(CHARACTERLIST_PTR + 4 * i)
        if player ~= 0 then
            local name = read_wstr_max_size(player + CHARACTERNAME_OFFSET, 12)
            if name and #name > 0 then
                local key = string.gsub(string.lower(name), "%z", "")
                key = string.gsub(key, "%s+$", "")
                if #key > 0 then
                    player_info_cache[key] = {
                        class = pso.read_u8(player + CLASS_OFFSET),
                        sectionId = pso.read_u8(player + SECTIONID_OFFSET),
                    }
                end
            end
        end
    end
end

local function lookup_player_info(name)
    if not name or name == "" then return nil end
    local key = string.gsub(string.lower(name), "%s+$", "")
    return player_info_cache[key]
end

-- Walk output_messages backward looking for the most recent message by the
-- same player that has class/section info. Used as a fallback when the live
-- player cache doesn't know the speaker — e.g. addon reload re-imports the
-- in-game chat buffer's 30-message tail, but the speaker has since left the
-- lobby. Their earlier (pre-reload) messages, restored from disk, still
-- carry the [c=N s=M] metadata we wrote at original capture time.
local function find_historical_player_info(name)
    if not name or name == "" then return nil end
    local lowerName = string.lower(name)
    for i = #output_messages, 1, -1 do
        local m = output_messages[i]
        if m.name and string.lower(m.name) == lowerName then
            if m.class or m.sectionId then
                return { class = m.class, sectionId = m.sectionId }
            end
        end
    end
    return nil
end

-- Stamp class/sectionId onto a message in place.
local function stamp_player_info(msg)
    local info = lookup_player_info(msg.name)
    if info then
        msg.class = info.class
        msg.sectionId = info.sectionId
        return
    end
    -- Live cache miss (player offline / not in this area). Try the chat
    -- history before giving up so re-imports after reload don't lose their
    -- colors.
    local historical = find_historical_player_info(msg.name)
    if historical then
        if msg.class == nil then msg.class = historical.class end
        if msg.sectionId == nil then msg.sectionId = historical.sectionId end
    end
end

-- Single append-only log file. Each line carries its own date so we can still
-- show "MM-DD HH:MM:SS" prefixes for messages from previous days. Previously
-- the addon wrote one file per day; migrate_old_logs() at init time merges
-- any leftover daily files into this one and deletes them.
local LOG_FILE = "addons/Chatlog/log.txt"

-- Append a single message to the log file. Cheap to open/close per line
-- since chat volume is low; survives crashes without losing data.
--
-- Format: "YYYY-MM-DD HH:MM:SS [L|T] [c=N s=M] Name: body"
-- The [c=N s=M] block holds class index and section ID at capture time so
-- restored messages can be re-colored on next launch. -1 means "unknown".
-- Old logs without this block still parse via the fallback in
-- load_persisted_messages.
local function write_log_line(msg)
    if not options.clLogToFile then return end
    local file = io.open(LOG_FILE, "a")
    if file then
        local channel = msg.channel == "team" and "T" or "L"
        file:write(string.format(
            "%s [%s] [c=%d s=%d] %s: %s\n",
            os.date("%Y-%m-%d %H:%M:%S"),
            channel,
            msg.class or -1,
            msg.sectionId or -1,
            msg.name or "",
            msg.text or ""
        ))
        file:close()
    end
end

local UPDATE_INTERVAL = 30
local counter = UPDATE_INTERVAL - 1
local MAX_LOG_SIZE = 1000
local function getHighlightColor()
    if options.clCustomHighlight then
        return {
            options.clHighlightColorR,
            options.clHighlightColorG,
            options.clHighlightColorB,
            options.clHighlightColorA
        }
    else
        return {0.5, 1.0, 0.0, 1.0}
    end
end

local own_name = ""

-- Search bar state. Module-level since there's only one chat window.
local searchText = ""

-- Quick channel filter: "all" | "lobby" | "team". Layered on top of the
-- existing clShowLobbyChat / clTeamChatEnable options — those say "ever
-- show this channel"; this says "what do I want to see right now".
local channelFilter = "all"

-- Stats window state + per-session message counts. Reset on launch since
-- "session stats" should reflect the current play session.
local statsWindowOpen = false
local session_stats = {
    counts = {},
    total_lobby = 0,
    total_team = 0,
    started = os.time(),
}

local function record_stat(msg)
    if not msg.name or msg.name == "" then return end
    session_stats.counts[msg.name] = (session_stats.counts[msg.name] or 0) + 1
    if msg.channel == "team" then
        session_stats.total_team = session_stats.total_team + 1
    else
        session_stats.total_lobby = session_stats.total_lobby + 1
    end
end

local function presentStatsWindow()
    if not statsWindowOpen then return end

    imgui.SetNextWindowSize(320, 400, "FirstUseEver")
    local _, open = imgui.Begin("Chatlog - Session Stats", statsWindowOpen)
    statsWindowOpen = open

    local total = session_stats.total_lobby + session_stats.total_team
    local elapsedSec = os.time() - session_stats.started
    local hh = math.floor(elapsedSec / 3600)
    local mm = math.floor((elapsedSec % 3600) / 60)
    imgui.Text(string.format("Session: %dh %dm", hh, mm))
    imgui.Text(string.format("Total messages: %d", total))
    imgui.Text(string.format("  Lobby: %d", session_stats.total_lobby))
    imgui.Text(string.format("  Team:  %d", session_stats.total_team))
    imgui.Separator()

    local sorted = {}
    for name, count in pairs(session_stats.counts) do
        table.insert(sorted, {name = name, count = count})
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)

    if #sorted == 0 then
        imgui.Text("No captured messages yet.")
    else
        imgui.Columns(2, "stats##cols")
        imgui.SetColumnOffset(1, 200)
        imgui.Text("Player");   imgui.NextColumn()
        imgui.Text("Messages"); imgui.NextColumn()
        imgui.Separator()
        for _, entry in ipairs(sorted) do
            imgui.Text(entry.name)
            imgui.NextColumn()
            imgui.Text(tostring(entry.count))
            imgui.NextColumn()
        end
        imgui.Columns(1)
    end

    imgui.End()
end

-- "Cleared at" marker file. When the user clicks Clear Chat Log we write
-- the current timestamp here; load_persisted_messages then skips any log
-- lines older than this. Keeps the log file intact (audit trail) while
-- making Clear actually stick across reloads.
local CLEAR_MARKER_FILE = "addons/Chatlog/cleared.txt"

local function read_clear_marker()
    local file = io.open(CLEAR_MARKER_FILE, "r")
    if not file then return nil end
    local stamp = file:read("*l")
    file:close()
    if stamp and #stamp > 0 then return stamp end
    return nil
end

local function write_clear_marker()
    local file = io.open(CLEAR_MARKER_FILE, "w")
    if file then
        file:write(os.date("%Y-%m-%d %H:%M:%S"))
        file:close()
    end
end

-- One-time migration from the old per-day file scheme (log-YYYY-MM-DD.txt)
-- into the single LOG_FILE. Walks back a year to find leftover daily files,
-- appends them into LOG_FILE in chronological order, and deletes them.
-- Idempotent: a second run finds no daily files and does nothing. Runs once
-- at init() before load_persisted_messages so the merge is visible to the
-- restore step.
local function migrate_old_logs()
    local found = {}
    for daysBack = 0, 365 do
        local ts = os.time() - daysBack * 86400
        local path = "addons/Chatlog/log-" .. os.date("%Y-%m-%d", ts) .. ".txt"
        local f = io.open(path, "r")
        if f then
            f:close()
            table.insert(found, path)
        end
    end
    if #found == 0 then return end

    local out = io.open(LOG_FILE, "a")
    if not out then return end
    -- `found` is newest-first (we walked backward); iterate in reverse so
    -- entries land in LOG_FILE oldest-first, preserving chronological order.
    for i = #found, 1, -1 do
        local f = io.open(found[i], "r")
        if f then
            for line in f:lines() do
                out:write(line)
                out:write("\n")
            end
            f:close()
            os.remove(found[i])
        end
    end
    out:close()
end

-- Read the last N lines of LOG_FILE and seed output_messages (and lobby_align,
-- so the next tick's find_new_start deduplicates against whatever is still in
-- the game's 30-message ring buffer). Messages from previous days are
-- prefixed with "MM-DD" to make staleness visible.
local function load_persisted_messages()
    if not options.clRestoreOnStartup then return end
    if (options.clRestoreLines or 0) <= 0 then return end

    local file = io.open(LOG_FILE, "r")
    if not file then return end

    local lines = {}
    for line in file:lines() do
        table.insert(lines, line)
    end
    file:close()

    local startIdx = math.max(1, #lines - options.clRestoreLines + 1)
    local today = os.date("%Y-%m-%d")
    local clearMarker = read_clear_marker()

    for i = startIdx, #lines do
        local line = lines[i]

        -- Try the new format first: includes [c=N s=M] metadata block so
        -- restored messages keep their class color + section ID tag.
        local date, time, channel, classStr, sectionStr, name, text =
            string.match(line, "^(%S+) (%S+) %[(%a)%] %[c=(%-?%d+) s=(%-?%d+)%] ([^:]*): (.*)$")

        if not date then
            -- Old-format fallback for log files written before metadata was
            -- added. Class/section won't be available for these lines, but
            -- the message text still loads correctly.
            date, time, channel, name, text = string.match(line, "^(%S+) (%S+) %[(%a)%] ([^:]*): (.*)$")
            classStr, sectionStr = nil, nil
        end

        if date and text then
            -- Skip messages from before the most recent Clear. Marker uses
            -- the same "YYYY-MM-DD HH:MM:SS" format so plain string compare
            -- is a valid chronological compare.
            local lineStamp = date .. " " .. time
            local skip = clearMarker and lineStamp <= clearMarker

            if not skip then
                local displayDate = time
                if date ~= today then
                    displayDate = string.sub(date, 6) .. " " .. time
                end
                local msg = {
                    name = name or "",
                    text = text,
                    date = displayDate,
                    channel = channel == "T" and "team" or "lobby",
                    fromLog = true,
                }
                -- -1 in the log means "unknown at capture time" — leave the
                -- field nil so the renderer's class/section checks skip it.
                if classStr then
                    local c = tonumber(classStr)
                    if c and c >= 0 then msg.class = c end
                end
                if sectionStr then
                    local s = tonumber(sectionStr)
                    if s and s >= 0 then msg.sectionId = s end
                end
                table.insert(output_messages, msg)
                if msg.channel == "lobby" then
                    table.insert(lobby_align, msg)
                end
            end
        end
    end

    -- Cap lobby_align to MAX_GAME_LOG so find_new_start has a sensible window.
    while #lobby_align > MAX_GAME_LOG do
        table.remove(lobby_align, 1)
    end

    -- Backfill missing class/sectionId across restored messages. If an old
    -- log entry recorded the player's class/section (e.g. Cacha c=9 s=1
    -- when she was visible) and a later entry was written with c=-1 s=-1
    -- (e.g. a post-reload re-import of the game's chat buffer after she
    -- left), propagate the known info onto the unknown entries so the
    -- renderer can color them. Two passes: gather everything we know, then
    -- apply. Handles both directions (early-unknown / late-known and
    -- vice versa).
    local known = {}
    for i = 1, #output_messages do
        local m = output_messages[i]
        if m.name and m.name ~= "" and (m.class ~= nil or m.sectionId ~= nil) then
            local key = string.lower(m.name)
            local k = known[key] or {}
            if m.class ~= nil then k.class = m.class end
            if m.sectionId ~= nil then k.sectionId = m.sectionId end
            known[key] = k
        end
    end
    for i = 1, #output_messages do
        local m = output_messages[i]
        if m.name and m.name ~= "" then
            local k = known[string.lower(m.name)]
            if k then
                if m.class == nil and k.class ~= nil then m.class = k.class end
                if m.sectionId == nil and k.sectionId ~= nil then m.sectionId = k.sectionId end
            end
        end
    end
end

local function TextCustomColored(r, g, b, a, text)
    if not r or not g or not b or not a then
        return imgui.Text(text)
    end
    return imgui.TextColored(r, g, b, a, text)
end

-- Find the index in updated_messages where new messages start. Returns the smallest j
-- (1-based) such that updated_messages[j..upd_n] are not already in output_messages.
-- Aligns updated's tail with output's tail; handles duplicate-text messages correctly
-- by requiring the alignment to match consecutively, not just the most recent entry.
local function find_new_start(output_messages, updated_messages)
    local out_n = #output_messages
    local upd_n = #updated_messages
    if upd_n == 0 then return 1 end

    for s = 0, upd_n do
        local len = upd_n - s
        if len <= out_n then
            local aligned = true
            for i = 1, len do
                local u = updated_messages[i]
                local o = output_messages[out_n - len + i]
                if u.text ~= o.text or u.name ~= o.name then
                    aligned = false
                    break
                end
            end
            if aligned then
                return upd_n - s + 1
            end
        end
    end
    return 1
end

local function DoChat()
    counter = counter + 1

    if counter % UPDATE_INTERVAL == 0 then
        -- Check if we have a character name, can be null if we are not online yet
        local character_name = get_charactername(get_gc())
        if character_name ~= nil then
            -- apparently there's null characters in the name?
            -- so the gsub removes them
            own_name = string.gsub(string.lower(character_name), "%z", "")

            -- Refresh the player-info cache once per tick so chat messages can be
            -- stamped with the speaker's class and section ID.
            update_player_info_cache()

            local updated_messages = get_chat_log()

            if #lobby_align == 0 and #updated_messages > 0 then
                -- Initial bootstrap: import the in-game buffer's current 30
                -- messages without timestamps. Always seed lobby_align so
                -- find_new_start dedupes them next tick; only add to the
                -- visible output if the user hasn't cleared, since the game
                -- buffer can contain pre-clear chat we don't want to resurface.
                for _, msg in ipairs(updated_messages) do
                    stamp_player_info(msg)
                end
                if not read_clear_marker() then
                    for _, msg in ipairs(updated_messages) do
                        table.insert(output_messages, msg)
                    end
                end
                lobby_align = {}
                for _, msg in ipairs(updated_messages) do
                    table.insert(lobby_align, msg)
                end
            elseif #updated_messages > 0 then
                -- Diff against lobby_align (not output_messages), so the Clear
                -- button can wipe display history without re-importing.
                local idx = find_new_start(lobby_align, updated_messages)
                for i = idx, #updated_messages do
                    local msg = updated_messages[i]
                    msg.date = os.date("%H:%M:%S")
                    stamp_player_info(msg)
                    write_log_line(msg)
                    record_stat(msg)
                    table.insert(output_messages, msg)
                    table.insert(lobby_align, msg)
                    if #output_messages > MAX_LOG_SIZE then
                        table.remove(output_messages, 1)
                    end
                    if #lobby_align > MAX_GAME_LOG + 1 then
                        table.remove(lobby_align, 1)
                    end
                end
            end

            -- Pull any newly-arrived team chat messages and append them.
            local team_new = get_team_chat_changes()
            for _, msg in ipairs(team_new) do
                stamp_player_info(msg)
                write_log_line(msg)
                record_stat(msg)
                table.insert(output_messages, msg)
                if #output_messages > MAX_LOG_SIZE then
                    table.remove(output_messages, 1)
                end
            end
        end
        
        counter = 0
    end

    -- Toolbar: search / channel tabs / stats button. Each piece toggles
    -- independently. Search gets its own line so it can stretch to the
    -- window width; tabs + stats share the next line.
    local showSearch = options.clShowSearchBar
    local showTabs   = options.clShowChannelTabs
    local showStats  = options.clShowStatsButton
    local anyToolbar = showSearch or showTabs or showStats

    if anyToolbar then
        if showSearch then
            imgui.PushItemWidth(-50)
            local _, newSearch = imgui.InputText("##chatsearch", searchText, 64)
            searchText = newSearch
            imgui.PopItemWidth()
            imgui.SameLine()
            if imgui.Button("X##clearsearch") then
                searchText = ""
            end
        end

        -- Channel filter tabs. Active tab is tinted via PushStyleColor.
        -- Layered on top of clShowLobbyChat/clTeamChatEnable: those are the
        -- "ever show" toggles in config; this is the quick in-window filter.
        local function tabBtn(label, value)
            local active = channelFilter == value
            if active then
                imgui.PushStyleColor("Button",        0.30, 0.55, 0.85, 1.0)
                imgui.PushStyleColor("ButtonHovered", 0.40, 0.65, 0.95, 1.0)
                imgui.PushStyleColor("ButtonActive",  0.20, 0.45, 0.75, 1.0)
            end
            local clicked = imgui.Button(label .. "##chantab_" .. value)
            if active then
                imgui.PopStyleColor(3)
            end
            return clicked
        end

        if showTabs then
            if tabBtn("All", "all")     then channelFilter = "all"   end
            imgui.SameLine()
            if tabBtn("Lobby", "lobby") then channelFilter = "lobby" end
            imgui.SameLine()
            if tabBtn("Team", "team")   then channelFilter = "team"  end
        end

        if showStats then
            if showTabs then
                imgui.SameLine(0, 20)
            end
            if imgui.Button("Stats") then
                statsWindowOpen = not statsWindowOpen
            end
        end

        imgui.Separator()
    end

    local lowerSearch = string.lower(searchText)
    local searchActive = #lowerSearch > 0

    -- Wrap rendering in a child window so the search bar stays pinned.
    imgui.BeginChild("chatscroll", 0, 0, false)

    -- Font scale only applies to the message body, not the toolbar. ImGui's
    -- per-window FontScale doesn't propagate from parent to child, so we set
    -- it here rather than in present(). Side effect: imgui.GetTextLineHeight()
    -- inside the message loop returns the scaled value, which keeps the
    -- section-ID icons sized to match the chat text.
    imgui.SetWindowFontScale(options.fontScale)

    -- Snap to bottom only on the frame where the chat actually got taller
    -- (a new message was rendered) AND the user was sitting at the previous
    -- bottom. Doing it every frame breaks the mouse wheel: SetScrollY queues
    -- a ScrollTarget that the *next* frame's BeginChild applies, which would
    -- overwrite the wheel scroll that NewFrame applied between user-code
    -- runs. Tying it to content growth means we only re-pin to bottom when
    -- there's a reason to, leaving the wheel free the rest of the time.
    --
    -- Exception: the very first time the chat is shown (and on each
    -- subsequent hide→show), we force a snap to bottom regardless of the
    -- "grew taller" check, since GetScrollMaxY returns 0 on the opening
    -- frame and the normal logic would miss it. The flag clears as soon as
    -- we see a non-zero maxY so this stays a one-shot per show.
    do
        local sy = imgui.GetScrollY()
        local maxY = imgui.GetScrollMaxY()
        if needsInitialScroll then
            if maxY > 0 then
                imgui.SetScrollY(maxY)
                prevmaxy = maxY
                needsInitialScroll = false
            end
        else
            local atOldBottom = math.abs(sy - prevmaxy) < 1
            if maxY > prevmaxy + 0.5 and atOldBottom then
                imgui.SetScrollY(maxY)
            end
            prevmaxy = maxY
        end
    end

    -- Pre-compute per-frame state used by every message.
    local windowWidth = imgui.GetWindowWidth()
    local highlightColor = getHighlightColor()
    local teamColor = {
        options.clTeamChatColorR,
        options.clTeamChatColorG,
        options.clTeamChatColorB,
        options.clTeamChatColorA,
    }
    local userNameColor = {
        options.clNameColorR,
        options.clNameColorG,
        options.clNameColorB,
        options.clNameColorA,
    }
    local showTimestamp = options.clNoTimestamp ~= "NoTimestamp"
    local needPercentEscape = pso.require_version == nil or not pso.require_version(3, 6, 0)

    -- Escape pattern magic chars in the player's name so names like "Mr.X" or "100%"
    -- don't blow up string.match.
    local namePattern
    if #own_name > 0 then
        namePattern = string.gsub(own_name, "(%W)", "%%%1")
    end

    -- Custom highlight words use plain substring matching (string.find with the
    -- plain flag). Own name uses word-boundary matching above because partial
    -- matches against names are usually noise; custom words are user-defined,
    -- so substring is the friendlier default.
    local highlightWords = {}
    if options.clHighlightWords and options.clHighlightWords ~= "" then
        for word in string.gmatch(options.clHighlightWords, "([^,]+)") do
            local trimmed = string.match(word, "^%s*(.-)%s*$") or ""
            if #trimmed > 0 then
                table.insert(highlightWords, string.lower(trimmed))
            end
        end
    end

    imgui.PushTextWrapPos(windowWidth - 10)

    local function colorText(c, text)
        if c then
            imgui.TextColored(c[1], c[2], c[3], c[4], text)
        else
            imgui.Text(text)
        end
    end

    -- Build a per-frame mute set from the comma-separated list. Cheap for short
    -- lists and avoids per-message string parsing.
    local muteSet = {}
    if options.clMuteList and options.clMuteList ~= "" then
        for token in string.gmatch(options.clMuteList, "([^,]+)") do
            local trimmed = string.match(token, "^%s*(.-)%s*$") or ""
            if trimmed ~= "" then
                muteSet[string.lower(trimmed)] = true
            end
        end
    end

    for i, msg in ipairs(output_messages) do
        -- Channel + mute filtering happens here so the diff/log paths above are
        -- unaffected; toggling visibility never loses captured history.
        local hidden = false
        if msg.channel == "team" then
            if not options.clTeamChatEnable then hidden = true end
        else
            if not options.clShowLobbyChat then hidden = true end
        end
        if not hidden and msg.name and muteSet[string.lower(msg.name)] then
            hidden = true
        end

        -- Quick channel filter from the toolbar tabs.
        if not hidden then
            if channelFilter == "lobby" and msg.channel == "team" then
                hidden = true
            elseif channelFilter == "team" and msg.channel ~= "team" then
                hidden = true
            end
        end

        -- Search filter: hide messages that don't contain the search query
        -- in either the sender name or the body.
        if not hidden and searchActive then
            local nameMatch = msg.name and string.find(string.lower(msg.name), lowerSearch, 1, true)
            local textMatch = msg.text and string.find(string.lower(msg.text), lowerSearch, 1, true)
            if not nameMatch and not textMatch then
                hidden = true
            end
        end

        if not hidden then
        local rawText = msg.text or ""
        local formattedText = needPercentEscape and string.gsub(rawText, "%%", "%%%%") or rawText

        local timestampPart = showTimestamp and ("[" .. msg.date .. "] ") or ""
        local nameFormat = options.clFixedWidthNames and string.format("%-11s", msg.name) or msg.name
        local lower = string.lower(rawText)

        -- Highlight on full-word match of the player's own name, or any
        -- plain-substring match against the user's custom highlight words.
        local isHighlighted = namePattern and (
            string.match(lower, "^" .. namePattern .. "[%p%s]") or
            string.match(lower, "[%p%s]" .. namePattern .. "[%p%s]") or
            string.match(lower, "[%p%s]" .. namePattern .. "$") or
            string.match(lower, "^" .. namePattern .. "$")
        )
        if not isHighlighted then
            for _, word in ipairs(highlightWords) do
                if string.find(lower, word, 1, true) then
                    isHighlighted = true
                    break
                end
            end
        end
        local isTeamMessage = msg.channel == "team"

        -- backColor tints non-name segments (timestamp, separator, body).
        -- nameColor tints just the name. Priority for nameColor:
        --   highlight > class > team > user-configured name color.
        local backColor
        if isHighlighted then
            backColor = highlightColor
        elseif isTeamMessage then
            backColor = teamColor
        end

        local nameColor
        if isHighlighted then
            nameColor = highlightColor
        elseif options.clColorByClass and msg.class and CLASS_COLORS[msg.class] then
            nameColor = CLASS_COLORS[msg.class]
        elseif isTeamMessage then
            nameColor = teamColor
        elseif options.clColoredNames then
            nameColor = userNameColor
        end

        -- Timestamp
        if showTimestamp then
            colorText(backColor, timestampPart)
            imgui.SameLine(0, 0)
        end

        -- Section ID tag, with a hover tooltip showing the full section name.
        -- Compact mode uses an icon from SECTION_IMAGES when one exists, falling
        -- back to "[*]" in the section's color. Full mode is always "[Bluefull]".
        if options.clShowSectionID and msg.sectionId and SECTION_INFO[msg.sectionId] then
            local s = SECTION_INFO[msg.sectionId]
            local handle
            if options.clSectionIDCompact and SECTION_IMAGES[msg.sectionId] then
                handle = image.Handle(SECTION_IMAGES[msg.sectionId])
            end
            if handle then
                local size = imgui.GetTextLineHeight()
                imgui.Image(handle, size, size)
            else
                local sidLabel = options.clSectionIDCompact and "[*]" or ("[" .. s.name .. "]")
                imgui.TextColored(s.color[1], s.color[2], s.color[3], s.color[4], sidLabel)
            end
            if imgui.IsItemHovered() then
                imgui.SetTooltip(s.name)
            end
            imgui.SameLine(0, 4)
        end

        -- Name (with hover tooltip showing class / section if known)
        colorText(nameColor or backColor, nameFormat)
        if imgui.IsItemHovered() then
            local tooltipLines = {msg.name}
            if msg.class and CLASS_NAMES[msg.class] then
                table.insert(tooltipLines, CLASS_NAMES[msg.class])
            end
            if msg.sectionId and SECTION_INFO[msg.sectionId] then
                table.insert(tooltipLines, SECTION_INFO[msg.sectionId].name)
            end
            if #tooltipLines > 1 then
                imgui.SetTooltip(table.concat(tooltipLines, "\n"))
            end
        end
        imgui.SameLine(0, 0)

        -- Separator
        colorText(backColor, options.clMessageSeparator)
        imgui.SameLine(0, 0)

        -- Body
        colorText(backColor, formattedText)
        end
    end

    imgui.PopTextWrapPos()

    imgui.EndChild()
end

local function present()
    -- If the addon has never been used, open the config window
    -- and disable the config window setting
    if options.configurationEnableWindow then
        ConfigurationWindow.open = true
        options.configurationEnableWindow = false
    end

    local configWasOpen = ConfigurationWindow.open
    ConfigurationWindow.Update()
    -- Save only when the config window closes, to avoid disk thrash from
    -- per-frame events (e.g. dragging color sliders).
    if configWasOpen and not ConfigurationWindow.open and ConfigurationWindow.changed then
        ConfigurationWindow.changed = false
        SaveOptions(options)
    end

    -- Global enable here to let the configuration window work
    if options.enable == false then
        return
    end

    -- Stats window draws unconditionally when open, so the user can keep it
    -- visible even when the main chat window is hidden by menu state.
    presentStatsWindow()

    if (options.clEnableWindow == true)
        and (options.clHideWhenMenu == false or IsMenuOpen() == false)
        and (options.clHideWhenSymbolChat == false or IsSymbolChatOpen() == false)
        and (options.clHideWhenMenuUnavailable == false or IsMenuUnavailable() == false)
    then
        if firstPresent or options.clChanged then
            options.clChanged = false
            local ps = GetPosBySizeAndAnchor(options.clX, options.clY, options.clW, options.clH, options.clAnchor)
            imgui.SetNextWindowPos(ps[1], ps[2], "Always");
            imgui.SetNextWindowSize(options.clW, options.clH, "Always");
        end
        if options.clTransparentWindow == true then
            imgui.PushStyleColor("WindowBg", 0.0, 0.0, 0.0, 0.0)
        end
        if imgui.Begin("Chatlog", nil, { options.clNoTitleBar, options.clNoResize, options.clNoMove }) then
            -- Toolbar (buttons, search bar) lives in this parent window. The
            -- message body has its own SetWindowFontScale call inside the
            -- child window — see DoChat.
            imgui.SetWindowFontScale(options.toolbarFontScale)
            DoChat()
        end
        imgui.End()
        if options.clTransparentWindow == true then
            imgui.PopStyleColor()
        end
        if firstPresent then
            firstPresent = false
        end
    end
end

local function init()
    ConfigurationWindow = cfg.ConfigurationWindow(options, {
        clearLog = function()
            output_messages = {}
            -- Write the marker before deleting files: if a delete fails
            -- (file locked, permissions), restore-on-load will still skip
            -- everything older than this timestamp. The marker is also what
            -- the bootstrap branch checks to avoid resurfacing the game's
            -- in-memory ring buffer (separate from the log file).
            write_clear_marker()
            -- Wipe the single log file. The clear marker above is the
            -- belt-and-suspenders fallback if the delete fails (file locked,
            -- permissions): restore-on-load still skips everything older
            -- than the marker timestamp. os.remove silently no-ops if missing.
            os.remove(LOG_FILE)
            -- Keep lobby_align populated so the next tick won't re-bootstrap
            -- the in-game buffer's 30 messages back into the visible log.
        end,
    })

    -- Fold any leftover per-day log files into the single LOG_FILE before
    -- the restore step reads it. Idempotent on subsequent launches.
    migrate_old_logs()

    -- Pull recent history off disk so the chat window doesn't start empty
    -- after a relaunch. Depends on clLogToFile having been on previously;
    -- without a log file, nothing to restore.
    load_persisted_messages()

    local function mainMenuButtonHandler()
        ConfigurationWindow.open = not ConfigurationWindow.open
    end

    core_mainmenu.add_button("Chatlog", mainMenuButtonHandler)

    return
    {
        name = "Chatlog",
        version = "0.1.1",
        author = "esc",
        present = present
    }
end

return {
    __addon =
    {
        init = init,
    },
}
