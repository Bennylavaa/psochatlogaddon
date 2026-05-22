local function ConfigurationWindow(configuration, callbacks)
    local this =
    {
        title = "Chatlog - Configuration",
        fontScale = 1.0,
        open = false,
        changed = false,
    }

    local _configuration = configuration
    local _callbacks = callbacks or {}

    local function PresentColorEditor(label, default, custom)
        custom = custom or 0xFFFFFFFF

        local changed = false
        local i_default =
        {
            bit.band(bit.rshift(default, 24), 0xFF),
            bit.band(bit.rshift(default, 16), 0xFF),
            bit.band(bit.rshift(default, 8), 0xFF),
            bit.band(default, 0xFF)
        }
        local i_custom =
        {
            bit.band(bit.rshift(custom, 24), 0xFF),
            bit.band(bit.rshift(custom, 16), 0xFF),
            bit.band(bit.rshift(custom, 8), 0xFF),
            bit.band(custom, 0xFF)
        }

        local ids = { "##X", "##Y", "##Z", "##W" }
        local fmt = { "A:%3.0f", "R:%3.0f", "G:%3.0f", "B:%3.0f" }

        imgui.BeginGroup()
        imgui.PushID(label)

        imgui.PushItemWidth(75)
        for n = 1, 4, 1 do
            local success = false
            if n ~= 1 then
                imgui.SameLine(0, 5)
            end

            success, i_custom[n] = imgui.DragInt(ids[n], i_custom[n], 1.0, 0, 255, fmt[n])
            if success then
                this.changed = true
            end
        end
        imgui.PopItemWidth()

        imgui.SameLine(0, 5)
        imgui.ColorButton(i_custom[2] / 255, i_custom[3] / 255, i_custom[4] / 255, i_custom[1] / 255)
        if imgui.IsItemHovered() then
            imgui.SetTooltip(
                string.format(
                    "#%02X%02X%02X%02X",
                    i_custom[4],
                    i_custom[1],
                    i_custom[2],
                    i_custom[3]
                )
            )
        end

        imgui.SameLine(0, 5)
        imgui.Text(label)

        default =
        bit.lshift(i_default[1], 24) +
        bit.lshift(i_default[2], 16) +
        bit.lshift(i_default[3], 8) +
        bit.lshift(i_default[4], 0)

        custom =
        bit.lshift(i_custom[1], 24) +
        bit.lshift(i_custom[2], 16) +
        bit.lshift(i_custom[3], 8) +
        bit.lshift(i_custom[4], 0)

        if custom ~= default then
            imgui.SameLine(0, 5)
            if imgui.Button("Revert") then
                custom = default
                this.changed = true
            end
        end

        imgui.PopID()
        imgui.EndGroup()

        return custom
    end

    local function RGBAToHex(r, g, b, a)
        local alpha = math.floor(a * 255)
        local red = math.floor(r * 255)
        local green = math.floor(g * 255)
        local blue = math.floor(b * 255)
        
        return bit.lshift(alpha, 24) + bit.lshift(red, 16) + bit.lshift(green, 8) + blue
    end

    local function HexToRGBA(hex)
        local alpha = bit.band(bit.rshift(hex, 24), 0xFF) / 255
        local red = bit.band(bit.rshift(hex, 16), 0xFF) / 255
        local green = bit.band(bit.rshift(hex, 8), 0xFF) / 255
        local blue = bit.band(hex, 0xFF) / 255
        
        return red, green, blue, alpha
    end

    local _showWindowSettings = function()
        local success
        local anchorList =
        {
            "Top Left (Disabled)", "Left", "Bottom Left",
            "Top", "Center", "Bottom",
            "Top Right", "Right", "Bottom Right",
        }

        -- ===== General =====
        if imgui.TreeNodeEx("General", "DefaultOpen") then
            if imgui.Checkbox("Enable", _configuration.enable) then
                _configuration.enable = not _configuration.enable
                this.changed = true
            end

            success, _configuration.fontScale = imgui.InputFloat("Message Font Scale", _configuration.fontScale)
            if success then
                this.changed = true
            end

            success, _configuration.toolbarFontScale = imgui.InputFloat("Toolbar Font Scale", _configuration.toolbarFontScale)
            if success then
                this.changed = true
            end

            imgui.TreePop()
        end

        -- ===== Window =====
        if imgui.TreeNodeEx("Window") then

            if imgui.TreeNodeEx("Visibility") then
                if imgui.Checkbox("Hide when menus are open", _configuration.clHideWhenMenu) then
                    _configuration.clHideWhenMenu = not _configuration.clHideWhenMenu
                    this.changed = true
                end
                if imgui.Checkbox("Hide when symbol chat/word select is open", _configuration.clHideWhenSymbolChat) then
                    _configuration.clHideWhenSymbolChat = not _configuration.clHideWhenSymbolChat
                    this.changed = true
                end
                if imgui.Checkbox("Hide when the menu is unavailable", _configuration.clHideWhenMenuUnavailable) then
                    _configuration.clHideWhenMenuUnavailable = not _configuration.clHideWhenMenuUnavailable
                    this.changed = true
                end
                imgui.TreePop()
            end

            if imgui.TreeNodeEx("Appearance") then
                if imgui.Checkbox("No title bar", _configuration.clNoTitleBar == "NoTitleBar") then
                    if _configuration.clNoTitleBar == "NoTitleBar" then
                        _configuration.clNoTitleBar = ""
                    else
                        _configuration.clNoTitleBar = "NoTitleBar"
                    end
                    this.changed = true
                end
                if imgui.Checkbox("No resize", _configuration.clNoResize == "NoResize") then
                    if _configuration.clNoResize == "NoResize" then
                        _configuration.clNoResize = ""
                    else
                        _configuration.clNoResize = "NoResize"
                    end
                    this.changed = true
                end
                if imgui.Checkbox("No move", _configuration.clNoMove == "NoMove") then
                    if _configuration.clNoMove == "NoMove" then
                        _configuration.clNoMove = ""
                    else
                        _configuration.clNoMove = "NoMove"
                    end
                    this.changed = true
                end
                if imgui.Checkbox("Transparent window", _configuration.clTransparentWindow) then
                    _configuration.clTransparentWindow = not _configuration.clTransparentWindow
                    this.changed = true
                end
                imgui.TreePop()
            end

            if imgui.TreeNodeEx("Position & Size") then
                imgui.PushItemWidth(200)
                success, _configuration.clAnchor = imgui.Combo("Anchor", _configuration.clAnchor, anchorList, table.getn(anchorList))
                imgui.PopItemWidth()
                if success then
                    _configuration.clChanged = true
                    this.changed = true
                end

                imgui.PushItemWidth(100)
                success, _configuration.clX = imgui.InputInt("X", _configuration.clX)
                imgui.PopItemWidth()
                if success then
                    _configuration.clChanged = true
                    this.changed = true
                end
                imgui.SameLine(0, 38)
                imgui.PushItemWidth(100)
                success, _configuration.clY = imgui.InputInt("Y", _configuration.clY)
                imgui.PopItemWidth()
                if success then
                    _configuration.clChanged = true
                    this.changed = true
                end

                imgui.PushItemWidth(100)
                success, _configuration.clW = imgui.InputInt("Width", _configuration.clW)
                imgui.PopItemWidth()
                if success then
                    _configuration.clChanged = true
                    this.changed = true
                end
                imgui.SameLine(0, 10)
                imgui.PushItemWidth(100)
                success, _configuration.clH = imgui.InputInt("Height", _configuration.clH)
                imgui.PopItemWidth()
                if success then
                    _configuration.clChanged = true
                    this.changed = true
                end
                imgui.TreePop()
            end

            imgui.TreePop()
        end

        -- ===== Toolbar =====
        if imgui.TreeNodeEx("Toolbar") then
            if imgui.Checkbox("Show search bar", _configuration.clShowSearchBar) then
                _configuration.clShowSearchBar = not _configuration.clShowSearchBar
                this.changed = true
            end
            if imgui.Checkbox("Show channel tabs (All / Lobby / Team)", _configuration.clShowChannelTabs) then
                _configuration.clShowChannelTabs = not _configuration.clShowChannelTabs
                this.changed = true
            end
            if imgui.Checkbox("Show stats button", _configuration.clShowStatsButton) then
                _configuration.clShowStatsButton = not _configuration.clShowStatsButton
                this.changed = true
            end
            imgui.TreePop()
        end

        -- ===== Messages =====
        if imgui.TreeNodeEx("Messages") then

            if imgui.TreeNodeEx("Format") then
                if imgui.Checkbox("No timestamps", _configuration.clNoTimestamp == "NoTimestamp") then
                    if _configuration.clNoTimestamp == "NoTimestamp" then
                        _configuration.clNoTimestamp = ""
                    else
                        _configuration.clNoTimestamp = "NoTimestamp"
                    end
                    this.changed = true
                end

                if imgui.Checkbox("Fixed-width names", _configuration.clFixedWidthNames) then
                    _configuration.clFixedWidthNames = not _configuration.clFixedWidthNames
                    this.changed = true
                end

                imgui.PushItemWidth(40)
                success, _configuration.clMessageSeparator = imgui.InputText("Separator", _configuration.clMessageSeparator, 5)
                imgui.PopItemWidth()
                if success then
                    _configuration.clChanged = true
                    this.changed = true
                end

                if imgui.Checkbox("Color names by class (Hunter/Ranger/Force)", _configuration.clColorByClass) then
                    _configuration.clColorByClass = not _configuration.clColorByClass
                    this.changed = true
                end

                if imgui.Checkbox("Custom colored names", _configuration.clColoredNames) then
                    _configuration.clColoredNames = not _configuration.clColoredNames
                    this.changed = true
                end

                -- Name color picker only when custom names are on AND class
                -- coloring isn't already overriding it anyway.
                if _configuration.clColoredNames and not _configuration.clColorByClass then
                    imgui.Text("Name Color")
                    local nameColorHex = RGBAToHex(
                        _configuration.clNameColorR,
                        _configuration.clNameColorG,
                        _configuration.clNameColorB,
                        _configuration.clNameColorA
                    )
                    local defaultNameColorHex = RGBAToHex(0.5, 1.0, 0.0, 1.0)
                    local newNameColorHex = PresentColorEditor("Name Color", defaultNameColorHex, nameColorHex)
                    if newNameColorHex ~= nameColorHex then
                        _configuration.clNameColorR, _configuration.clNameColorG,
                        _configuration.clNameColorB, _configuration.clNameColorA = HexToRGBA(newNameColorHex)
                        this.changed = true
                    end
                end

                if imgui.Checkbox("Show Section ID before name", _configuration.clShowSectionID) then
                    _configuration.clShowSectionID = not _configuration.clShowSectionID
                    this.changed = true
                end
                if _configuration.clShowSectionID then
                    if imgui.Checkbox("Compact Section ID (icon vs [Bluefull])", _configuration.clSectionIDCompact) then
                        _configuration.clSectionIDCompact = not _configuration.clSectionIDCompact
                        this.changed = true
                    end
                end

                imgui.TreePop()
            end

            if imgui.TreeNodeEx("Highlighting") then
                if imgui.Checkbox("Customize highlight color", _configuration.clCustomHighlight) then
                    _configuration.clCustomHighlight = not _configuration.clCustomHighlight
                    this.changed = true
                end
                if _configuration.clCustomHighlight then
                    imgui.Text("Highlight Color")
                    local highlightColorHex = RGBAToHex(
                        _configuration.clHighlightColorR,
                        _configuration.clHighlightColorG,
                        _configuration.clHighlightColorB,
                        _configuration.clHighlightColorA
                    )
                    local defaultHighlightColorHex = RGBAToHex(0.5, 1.0, 0.0, 1.0)
                    local newHighlightColorHex = PresentColorEditor("Highlight Color", defaultHighlightColorHex, highlightColorHex)
                    if newHighlightColorHex ~= highlightColorHex then
                        _configuration.clHighlightColorR, _configuration.clHighlightColorG,
                        _configuration.clHighlightColorB, _configuration.clHighlightColorA = HexToRGBA(newHighlightColorHex)
                        this.changed = true
                    end
                end

                imgui.Spacing()
                local hwSuccess, hwValue = imgui.InputText("Highlight words", _configuration.clHighlightWords or "", 256)
                if hwSuccess then
                    _configuration.clHighlightWords = hwValue
                    this.changed = true
                end
                imgui.Text("Comma-separated. Messages containing these are highlighted.")

                imgui.TreePop()
            end

            if imgui.TreeNodeEx("Channels") then
                if imgui.Checkbox("Show lobby chat", _configuration.clShowLobbyChat) then
                    _configuration.clShowLobbyChat = not _configuration.clShowLobbyChat
                    this.changed = true
                end
                if imgui.Checkbox("Show team chat", _configuration.clTeamChatEnable) then
                    _configuration.clTeamChatEnable = not _configuration.clTeamChatEnable
                    this.changed = true
                end
                if _configuration.clTeamChatEnable then
                    local teamColorHex = RGBAToHex(
                        _configuration.clTeamChatColorR,
                        _configuration.clTeamChatColorG,
                        _configuration.clTeamChatColorB,
                        _configuration.clTeamChatColorA
                    )
                    local defaultTeamChatColorHex = RGBAToHex(0.4, 0.7, 1.0, 1.0)
                    local newTeamColorHex = PresentColorEditor("Team Chat Color", defaultTeamChatColorHex, teamColorHex)
                    if newTeamColorHex ~= teamColorHex then
                        _configuration.clTeamChatColorR, _configuration.clTeamChatColorG,
                        _configuration.clTeamChatColorB, _configuration.clTeamChatColorA = HexToRGBA(newTeamColorHex)
                        this.changed = true
                    end
                end
                imgui.TreePop()
            end

            if imgui.TreeNodeEx("Mute") then
                local muteSuccess, muteValue = imgui.InputText("Muted names", _configuration.clMuteList or "", 256)
                if muteSuccess then
                    _configuration.clMuteList = muteValue
                    this.changed = true
                end
                imgui.Text("Comma-separated. Their messages won't be displayed.")
                imgui.TreePop()
            end

            imgui.TreePop()
        end

        -- ===== Logging =====
        if imgui.TreeNodeEx("Logging") then
            if imgui.Checkbox("Save chat to file (addons/Chatlog/log-YYYY-MM-DD.txt)", _configuration.clLogToFile) then
                _configuration.clLogToFile = not _configuration.clLogToFile
                this.changed = true
            end
            if imgui.Checkbox("Restore chat on startup", _configuration.clRestoreOnStartup) then
                _configuration.clRestoreOnStartup = not _configuration.clRestoreOnStartup
                this.changed = true
            end
            if _configuration.clRestoreOnStartup then
                imgui.PushItemWidth(100)
                success, _configuration.clRestoreLines = imgui.InputInt("Lines to restore", _configuration.clRestoreLines)
                imgui.PopItemWidth()
                if success then this.changed = true end
                imgui.Text("Reads the most recent log file (within 7 days).")
                imgui.Text("Requires 'Save chat to file' to have been on previously.")
            end
            imgui.TreePop()
        end

        -- ===== Actions (always visible at the bottom) =====
        imgui.Spacing()
        imgui.Separator()
        if imgui.Button("Clear Chat Log") then
            if _callbacks.clearLog then
                _callbacks.clearLog()
            end
        end
    end

    this.Update = function()
        if this.open == false then
            return
        end

        local success

        imgui.SetNextWindowSize(500, 400, 'FirstUseEver')
        success, this.open = imgui.Begin(this.title, this.open)
        imgui.SetWindowFontScale(this.fontScale)

        _showWindowSettings()

        imgui.End()
    end

    return this
end

return 
{
    ConfigurationWindow = ConfigurationWindow,
}
