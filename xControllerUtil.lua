
-- ------------------------------------------
-- Controller Utilities
--   by: Xsear
-- ------------------------------------------

-- Lua
require "unicode"
require "math"
require "table"

-- Firefall
require "lib/lib_Debug"
require "lib/lib_Items"
require "lib/lib_Slash"
require "lib/lib_ChatLib"
require "lib/lib_Callback2"
require "lib/lib_Tabs"
require "lib/lib_MovablePanel"
require "lib/lib_PanelManager"
require "lib/lib_MultiArt"

require "lib/lib_RoundedPopupWindow"
require "lib/lib_UserKeybinds"
require "lib/lib_InputIcon"

-- Custom
require "./lib/lib_RedBand"

-- ------------------------------------------
-- Options UI
-- ------------------------------------------
local OptionsUI = {
        MAIN = Component.GetFrame("Options"),
        WINDOW = Component.GetWidget("Window"),
        MOVABLE_PARENT = Component.GetWidget("MovableParent"),
        CLOSE_BUTTON = Component.GetWidget("close"),
        TITLE_TEXT = Component.GetWidget("title"),
        PANES = Component.GetWidget("Panes"),
        PANE_MAIN,
            PANE_MAIN_LAYOUT,
            PANE_MAIN_LEFT_COLUMN,
            PANE_MAIN_MAIN_AREA,
            PANE_MAIN_MAIN_AREA_LIST,
        PANE_SECOND,
            PANE_SECOND_LAYOUT,
        POPUP,
    }

function ToggleOptionsUI(args)
    local show = args.show or false

    OptionsUI.MAIN:Show(show)
    Component.SetInputMode(show and "cursor" or "none");
    if (show) then
        PanelManager.OnShow(OptionsUI.MAIN)
    else
        PanelManager.OnHide(OptionsUI.MAIN)
    end
end

function OnClose(args)
    Debug.Event(args)
end

function SetupOptionsUI()
    
    -- Register with PanelManager
    PanelManager.RegisterFrame(OptionsUI.MAIN, ToggleOptionsUI, {show=false})
    
    -- Setup with MovablePanel
    MovablePanel.ConfigFrame({
        frame = OptionsUI.MAIN,
        MOVABLE_PARENT = OptionsUI.MOVABLE_PARENT
    })

    -- Setup close button
    local X = OptionsUI.CLOSE_BUTTON:GetChild("X");
    OptionsUI.CLOSE_BUTTON:BindEvent("OnMouseDown", function() ToggleOptionsUI({show=false}) end)
    OptionsUI.CLOSE_BUTTON:BindEvent("OnMouseEnter", function()
        X:ParamTo("tint", Component.LookupColor("red"), 0.15);
        X:ParamTo("glow", "#30991111", 0.15);
    end)
    OptionsUI.CLOSE_BUTTON:BindEvent("OnMouseLeave", function()
        X:ParamTo("tint", Component.LookupColor("white"), 0.15);
        X:ParamTo("glow", "#00000000", 0.15);
    end)

    -- Set the title
    OptionsUI.TITLE_TEXT:SetText("Controller Utility")

    -- Setup tabs
    OptionsUI.TABS = Tabs.Create(2, OptionsUI.PANES)
    OptionsUI.TABS:SetTab(1, {label="Main"})
    OptionsUI.TABS:SetTab(2, {label="Second"})

    -- Setup tab references
    OptionsUI.PANE_MAIN = OptionsUI.TABS:GetBody(1)
    OptionsUI.PANE_SECOND= OptionsUI.TABS:GetBody(2)

    -- Default to first tab
    OptionsUI.TABS:Select(1)

    -- Create layout for Main Pane
    OptionsUI.PANE_MAIN_LAYOUT = Component.CreateWidget("PaneLayoutMain", OptionsUI.PANE_MAIN)
    OptionsUI.PANE_MAIN_LEFT_COLUMN = OptionsUI.PANE_MAIN_LAYOUT:GetChild("LeftColumn")
    OptionsUI.PANE_MAIN_MAIN_AREA = OptionsUI.PANE_MAIN_LAYOUT:GetChild("MainArea")
    OptionsUI.PANE_MAIN_MAIN_AREA_LIST = OptionsUI.PANE_MAIN_MAIN_AREA:GetChild("List")

    -- Create (bare) layout for Second Pane
    OptionsUI.PANE_SECOND_LAYOUT = Component.CreateWidget("PaneLayoutMain", OptionsUI.PANE_SECOND)

    -- Test button
    function TestButtonAction(args)
        Debug.Table("TestButtonAction", args)
        --RedBand.GenericMessage("You pressed the Test Button :D")

        if not OptionsUI.POPUP then
            OptionsUI.POPUP = RoundedPopupWindow.Create(OptionsUI.PANE_MAIN_LEFT_COLUMN)
            OptionsUI.POPUP:EnableClose(true, function() OptionsUI.POPUP:Remove() OptionsUI.POPUP = nil end)

            OptionsUI.POPUP:SetTitle("Keybinder")
            OptionsUI.POPUP:SetDims("center-x:50%; center-y:50%; height:200; width:235")

            OptionsUI.POPUP:TintBack("#ff6000")

            local POPUP_BODY = OptionsUI.POPUP:GetBody()

            OptionsUI.POPUP_BODY_INPUT_ICON = InputIcon.CreateVisual(POPUP_BODY, "Bind")
            local previousKeyCode = KEYSET_AbilityPie:GetKeybind("ability_pie") or "blank"
            OptionsUI.POPUP_BODY_INPUT_ICON:SetBind({keycode=previousKeyCode, alt=false}, true)


            OptionsUI.POPUP_BODY_BIND_BUTTON = Component.CreateWidget('<Button id="SaveBindButton" key="{Save}" dimensions="center-x:15%; center-y:30%; height:20; width:60" style="font:Demi_11"/>', POPUP_BODY)
            OptionsUI.POPUP_BODY_BIND_BUTTON:BindEvent("OnMouseDown", OnBindSave)


            OptionsUI.POPUP_BODY_RETRY_BUTTON = Component.CreateWidget('<Button id="RetryBindButton" key="{Retry}" dimensions="center-x:45%; center-y:30%; height:20; width:60" style="font:Demi_11"/>', POPUP_BODY)
            OptionsUI.POPUP_BODY_RETRY_BUTTON:BindEvent("OnMouseDown", OnBindRetry)


            function OnKeyCaught(args)
                local keyCode = args.widget:GetKeyCode()

                Debug.Log("OnKeyCaught : keyCode " .. tostring(keyCode))

                OptionsUI.POPUP_BODY_INPUT_ICON:SetBind({keycode=keyCode, alt=false}, true)
            end

            function OnBindSave(args)
                Debug.Table("OnBindSave", args)


                local keyCode = OptionsUI.POPUP_BODY_KEYCATCHER:GetKeyCode()
                KEYSET_AbilityPie:BindKey("ability_pie", keyCode)
                Component.SaveSetting("ability_pie_keycode", keyCode)
            end

            function OnBindRetry(args)
                Debug.Table("OnBindRetry", args)
                if OptionsUI.POPUP_BODY_KEYCATCHER then OptionsUI.POPUP_BODY_KEYCATCHER:ListenForKey() end
            end

            OptionsUI.POPUP_BODY_KEYCATCHER = Component.CreateWidget("KeyCatcher", POPUP_BODY):GetChild("KeyCatch")
            OptionsUI.POPUP_BODY_KEYCATCHER:BindEvent("OnKeyCatch", OnKeyCaught)
            --OptionsUI.POPUP_BODY_KEYCATCHER:ListenForKey()
            --OptionsUI.POPUP_BODY_KEYCATCHER:SetTag()

        end




    end

    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON = Component.CreateWidget('<Button id="BindAbilityButton" key="{Bind Ability Pie}" dimensions="left:10.25; width:142; top:5%; height:25"/>', OptionsUI.PANE_MAIN_LEFT_COLUMN)
    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON:BindEvent("OnMouseDown", TestButtonAction)


end


-- ------------------------------------------
-- CONSTANTS
-- ------------------------------------------
CVAR_ALLOW_GAMEPAD = "control.allowGamepad"
REDETECTION_DELAY_SECONDS = 1


KEYCODE_GAMEPAD_START = 270
KEYCODE_GAMEPAD_BACK = 271
KEYCODE_GAMEPAD_LEFT_THUMBSTICK = 272
KEYCODE_GAMEPAD_RIGHT_THUMBSTICK = 273
KEYCODE_GAMEPAD_LEFT_BUMPER = 274
KEYCODE_GAMEPAD_RIGHT_BUMPER = 275
KEYCODE_GAMEPAD_LEFT_TRIGGER = 280
KEYCODE_GAMEPAD_RIGHT_TRIGGER = 281
KEYCODE_GAMEPAD_X = 278
KEYCODE_GAMEPAD_Y = 279
KEYCODE_GAMEPAD_B = 277
KEYCODE_GAMEPAD_A = 276
KEYCODE_GAMEPAD_DPAD_UP = 266
KEYCODE_GAMEPAD_DPAD_DOWN = 267
KEYCODE_GAMEPAD_DPAD_LEFT = 268
KEYCODE_GAMEPAD_DPAD_RIGHT = 269

ABILITY_PIE_KEYBINDINGS = {
    [KEYCODE_GAMEPAD_X] = "SelectAbility1",
    [KEYCODE_GAMEPAD_Y] = "SelectAbility2",
    [KEYCODE_GAMEPAD_B] = "SelectAbility3",
    [KEYCODE_GAMEPAD_A] = "SelectAbility4",
}
ABILITY_PIE_KEYBINDINGS_ORDER = {
    [1] = KEYCODE_GAMEPAD_X,
    [2] = KEYCODE_GAMEPAD_Y,
    [3] = KEYCODE_GAMEPAD_B,
    [4] = KEYCODE_GAMEPAD_A,
}
ABILITY_PIE_KEYBINDING_INDEX = 3 -- So since each key action can have multiple binds, but the UI options only utilize the first 2, we put our stuff on 3. Putting it on higher litters the savefile with empty slots.

ABILITY_PIE_CANCELLATION_KEYS = {
    KEYCODE_GAMEPAD_START, KEYCODE_GAMEPAD_BACK, KEYCODE_GAMEPAD_RIGHT_BUMPER
}


RT_SEG_WIDTH = 1024/3 -- Still used in pie creation!


-- ------------------------------------------
-- GLOBALS
-- ------------------------------------------
PIE_CONTAINER = Component.GetWidget("PieContainer")


KEYSET_AbilityPie = nil
PIE_Abilities = nil
IsAbilityPieActive = false
VERY_IMPORTANT_OVERRIDEN_KEYBINDS = nil

BAKERY_Calldowns = {} -- a bakery contains pies!

KEYSET_PieButtons = nil


HardCodedCalldownPies = {

    ["TransportPie"] = {
        [ABILITY_PIE_KEYBINDINGS_ORDER[1]] = 77402, -- Gliderpad
        [ABILITY_PIE_KEYBINDINGS_ORDER[2]] = 77402,
        [ABILITY_PIE_KEYBINDINGS_ORDER[3]] = 0, -- rip the dream
        [ABILITY_PIE_KEYBINDINGS_ORDER[4]] = 136981, -- Elite banner
    },

    ["OtherPie"] = {
        [ABILITY_PIE_KEYBINDINGS_ORDER[1]] = 30298, -- Ammopack
        [ABILITY_PIE_KEYBINDINGS_ORDER[2]] = 0,
        [ABILITY_PIE_KEYBINDINGS_ORDER[3]] = 54003,
        [ABILITY_PIE_KEYBINDINGS_ORDER[4]] = 0,
    },

}


IsCalldownPieActive = false
CurrentlyActiveCalldownPie = nil

-- ------------------------------------------
-- INTERFACE OPTIONS
-- ------------------------------------------


-- ------------------------------------------
-- EVENTS
-- ------------------------------------------

function OnComponentLoad(args)
    -- Debug
    Debug.EnableLogging(true)

    -- Slash
    LIB_SLASH.BindCallback({slash_list="xcontrollerutil,xconutil,xcu,cu", description="Controller Utilities", func=OnSlashGeneral})
    LIB_SLASH.BindCallback({slash_list="redetect,gamepad", description="Attempt to detect active gamepad", func=OnSlashGamepad})

    -- Options UI
    SetupOptionsUI()


    -- User Keybinds
    -- Keyset to trigger ability pie
    KEYSET_AbilityPie = UserKeybinds.Create()
    KEYSET_AbilityPie:RegisterAction("ability_pie", ActivateAbilityPie, "press")
    if Component.GetSetting("ability_pie_keycode") then
        local keyCode = Component.GetSetting("ability_pie_keycode")
        KEYSET_AbilityPie:BindKey("ability_pie", keyCode)
    end
    KEYSET_AbilityPie:Activate(false)

    -- Keyset for cancelling ability pie when active
    KEYSET_AbilityPieCancellation = UserKeybinds.Create()
    KEYSET_AbilityPieCancellation:RegisterAction("ability_pie_cancel", AbilityPieDeactivationTrigger, "press")
    for _, keyCode in ipairs(ABILITY_PIE_CANCELLATION_KEYS) do
        KEYSET_AbilityPieCancellation:BindKey("ability_pie_cancel", keyCode)
    end
    KEYSET_AbilityPieCancellation:Activate(false)

    

    --[[
    Early experimental stuff, save for calldowns

    PIE_Abilities_KeyCatcher = Component.CreateWidget("KeyCatcher", PIE_Abilities):GetChild("KeyCatch")
    PIE_Abilities_KeyCatcher:BindEvent("OnKeyCatch", OnAbilityPieKeyCaught)
    --]]



    KEYSET_CalldownPies = UserKeybinds.Create()
    KEYSET_CalldownPies:RegisterAction("calldown_pie_transport", ActivateCalldownPie, "press")
    KEYSET_CalldownPies:RegisterAction("calldown_pie_other", ActivateCalldownPie, "press")
    --if Component.GetSetting("ability_pie_keycode") then
    --    local keyCode = Component.GetSetting("ability_pie_keycode")
    --    KEYSET_CalldownPies:BindKey("ability_pie", keyCode)
    --end
    KEYSET_CalldownPies:BindKey("calldown_pie_transport", KEYCODE_GAMEPAD_DPAD_RIGHT)
    KEYSET_CalldownPies:BindKey("calldown_pie_other", KEYCODE_GAMEPAD_DPAD_DOWN)
    KEYSET_CalldownPies:Activate(false)
    


    KEYSET_CalldownPieButtons = UserKeybinds.Create()
    KEYSET_CalldownPieButtons:RegisterAction("press_calldown_pie_button", DeactivateCalldownPie, "release")
    for i, keyCode in ipairs(ABILITY_PIE_KEYBINDINGS_ORDER) do
        KEYSET_CalldownPieButtons:BindKey("press_calldown_pie_button", keyCode, i)
    end
    KEYSET_CalldownPieButtons:Activate(false)



    -- Ready
    KEYSET_AbilityPie:Activate(true)
    KEYSET_CalldownPies:Activate(true)
end

function OnSlashGeneral(args)
    Debug.Table("OnSlashGeneral", args)

    if args[1] then

        if args[1] == 'nuke' then
            KEYSET_AbilityPie:Destroy()
            Component.SaveSetting("ability_pie_keycode", nil)
        
        elseif args[1] == 'sin' then

            Component.GenerateEvent("ON_SIN_VIEW", {})

        end

    else
        ToggleOptionsUI({show=true})
    end
end

function OnSlashGamepad(args)
    Debug.Table("OnSlashGamepad", args)

    DetectActiveGamepad()
end


function OnPlayerReady(args)

    Debug.Event(args)

    local abilities = Player.GetAbilities().slotted
    Debug.Table("abilities", abilities)
    --[[

    
    Debug.Divider()
    for i, abilityId in ipairs(abilities) do
        local abilityInfo = Player.GetAbilityInfo(abilityId)
        Debug.Table("abilityInfo for " .. tostring(abilityId), abilityInfo)
        Debug.Divider()
    end
    --]]

    -- Setup pies! I don't even like pie.
    if true then
        local segmentData = {}
        for _, ability in ipairs(abilities) do
            local abilityInfo = Player.GetAbilityInfo(ability.abilityId)
            table.insert(segmentData, {icon_id = abilityInfo.iconId})
        end

        PIE_CONTAINER:Show(true)
        PIE_Abilities = CreatePie(PIE_CONTAINER, segmentData)
        PIE_Abilities:Show(false)
    end

    Debug.Log("Creating calldown pies")

    for name, content in pairs(HardCodedCalldownPies) do
        Debug.Table("Creating segmentData for " .. tostring(name), content)
        local segmentData = {}
        for i, keycode in ipairs(ABILITY_PIE_KEYBINDINGS_ORDER) do

            local calldownTypeId = content[keycode]

            Debug.Log("Lap keycode ", keycode, " calldownTypeId ", calldownTypeId, " in content.")
            local itemTypeInfo = Game.GetItemInfoByType(calldownTypeId)
            local icon_id = 0
            if itemTypeInfo then
                icon_id = itemTypeInfo.web_icon_id
            end
            table.insert(segmentData, {icon_id = icon_id, tech_id = calldownTypeId, keycode = keycode})
        end
        BAKERY_Calldowns[name] = {}
        BAKERY_Calldowns[name].PIE = CreatePie(PIE_CONTAINER, segmentData)
        BAKERY_Calldowns[name].data = segmentData
        BAKERY_Calldowns[name].PIE:Show(false)
    end

end

function OnAbilityUsed(args)
    AbilityPieDeactivationTrigger(args)
end

function OnAbilityFailed(args)
    AbilityPieDeactivationTrigger(args)
end

function OnPlaceCalldown(args)
    AbilityPieDeactivationTrigger(args)
end

function AbilityPieDeactivationTrigger(args)
    --Debug.Event(args)
    if IsAbilityPieActive then
        DeactivateAbilityPie(args)
    elseif IsCalldownPieActive then
        DeactivateCalldownPie(args)
    end
end

function ActivateAbilityPie(args)
    assert(not IsAbilityPieActive, "waddafak you do, you can't eat two pies at once")
    assert(not IsCalldownPieActive, "you buffon")
    assert(PIE_Abilities, "ehh we got problem")

    -- Diable activation keybind
    KEYSET_AbilityPie:Activate(false)
    KEYSET_AbilityPieCancellation:Activate(true)

    -- Do the crazy ability pie keybind overriding
    DoTheCrazyAbilityPieKeyBindOverriding()

    -- Make some fancy moves
    PIE_Abilities:SetParam("alpha", 0, 0.1)
    PIE_Abilities:QueueParam("alpha", 1, 0.25, "ease-in")
    PIE_Abilities:Show(true)

    -- Show the world!
    PIE_CONTAINER:Show(true)

    -- Baka almost forgot
    IsAbilityPieActive = true

    --Output("Activated Ability Pie")
end

function DeactivateAbilityPie(args)
    assert(IsAbilityPieActive, "pluto isn't a planet")

    -- Undo the crazy ability pie keybind overriding
    UndoTheCrazyAbilityPieKeyBindOverriding()

    -- Usagi chirichiri~
    PIE_Abilities:Show(false)
    PIE_CONTAINER:Show(false)

    -- Re-enable activation keybind
    KEYSET_AbilityPieCancellation:Activate(false)
    KEYSET_AbilityPie:Activate(true)

    -- Update that thing and RIP keybinds
    IsAbilityPieActive = false

    --Output("Deactivated Ability Pie")
end


function DoTheCrazyAbilityPieKeyBindOverriding(args)
    Debug.Log("Doing the crazy ability pie keybind overriding!")

    -- Get all keybinds
    local keybindCategories = {
        "Movement",
        "Combat",
        "Social",
        "Interface",
        "Vehicle",
        "ScopeMode",
    }
    local allKeybinds = {}
    for i, category in ipairs(keybindCategories) do
        allKeybinds[category] = System.GetKeyBindings(category, false) -- false here means get current keybinds apparently
    end

    --Debug.Table("allKeybinds", allKeybinds)

    -- Identify all keybinds that conflict with ability pie keybindings
    Debug.Log("Identifying conflicting keybinds")
    local conflictingKeybinds = {}
    for category, actions in pairs(allKeybinds) do
        for action, slots in pairs(actions) do
            for i, bind in ipairs(slots) do
                if ABILITY_PIE_KEYBINDINGS[bind.keycode] then
                    Debug.Log("found conflict!")
                    local conflict = {category=category, action=action, index=i, keycode=bind.keycode}
                    table.insert(conflictingKeybinds, conflict)
                end
            end
        end
    end

    Debug.Table("Let's hope we don't error because if we do we're gonna lose these conflicting keybinds: ", conflictingKeybinds)

    -- Save conflictingKeybinds
    VERY_IMPORTANT_OVERRIDEN_KEYBINDS = conflictingKeybinds

    -- NOW FUCK THEM >: D
    Debug.Log("Unbinding conflicting keybinds")
    for i, conflict in ipairs(conflictingKeybinds) do
        System.BindKey(conflict.category, conflict.action, 0, false, conflict.index) -- false here means the bind is without the modifier key pressed
    end

    -- Add our special <3 keybinds
    Debug.Log("Binding ability pie keybinds")
    for keycode, action in pairs(ABILITY_PIE_KEYBINDINGS) do
        System.BindKey("Combat", action, keycode, false, ABILITY_PIE_KEYBINDING_INDEX)
    end


    Debug.Log("Applying the modified keybinds, no turning back now!")
    System.ApplyKeyBindings()

    -- Well, that is it for the first part of the procedure!
    Debug.Log("Okay, we're now in the crazy ability pie keybinding override state.")
end


function UndoTheCrazyAbilityPieKeyBindOverriding(args)
    Debug.Log("Okay settle down, we're gonna undo the crazy ability pie keybind overriding now")

    -- Unbind the special ability pie keybindings
    Debug.Log("Unbinding ability pie keybindings")
    for keycode, action in pairs(ABILITY_PIE_KEYBINDINGS) do
        System.BindKey("Combat", action, 0, false, ABILITY_PIE_KEYBINDING_INDEX)
    end

    -- OKAY NOW RESTORE THE OLD BINDS BEFORE WE LOSE THEM!!!!
    Debug.Log("Restoring conflicting keybinds")
    for i, conflict in ipairs(VERY_IMPORTANT_OVERRIDEN_KEYBINDS) do
        System.BindKey(conflict.category, conflict.action, conflict.keycode, false, conflict.index)
    end

    -- We did good didn't we? Akanari sou na!
    Debug.Log("Applying the restored keybinds, hope you're doing awesome :)")
    System.ApplyKeyBindings()

    -- Phew! (?) Fura fura~
    Debug.Log("We're back to normal, no more crazy override state.")
end




function ActivateCalldownPie(args)
    Debug.Table("ActivateCalldownPie", args)


    if not IsCalldownPieActive and not IsAbilityPieActive then

        Debug.Log("Opening calldonw pie")

        KEYSET_CalldownPies:Activate(false)
        KEYSET_AbilityPieCancellation:Activate(true)
        KEYSET_CalldownPieButtons:Activate(true)

        CurrentlyActiveCalldownPie = ( (args.name == "calldown_pie_transport" and "TransportPie") or (args.name == "calldown_pie_other" and "OtherPie"))
        Debug.Log("CurrentlyActiveCalldownPie: ", CurrentlyActiveCalldownPie)
        IsCalldownPieActive = true

        BAKERY_Calldowns[CurrentlyActiveCalldownPie].PIE:SetParam("alpha", 0, 0.1)
        BAKERY_Calldowns[CurrentlyActiveCalldownPie].PIE:QueueParam("alpha", 1, 0.25, "ease-in")
        BAKERY_Calldowns[CurrentlyActiveCalldownPie].PIE:Show(true)
        PIE_CONTAINER:Show(true)

    end
end

function DeactivateCalldownPie(args)
    Debug.Table("DeactivateCalldownPie", args)


    if IsCalldownPieActive then


        Debug.Log("Closing calldown pie")


        if args.keycode then

            -- THis is it, do the thing!
            local segmentData = BAKERY_Calldowns[CurrentlyActiveCalldownPie].data


            Debug.Log("Begin attemp to activate calldown")
            Debug.Log("Our keycode is " .. tostring(args.keycode) .. " ( " .. System.GetKeycodeString(args.keycode) .. ") ")
            Debug.Table("segmentData", segmentData)

            local techId = 0

            for i, segment in ipairs(segmentData)  do

                if segment.keycode == args.keycode then

                    techId = segment.tech_id
                    Debug.Log("Found match! Tech id is " .. tostring(techId))
                    break
                end

            end



            if techId ~= 0 then

                Debug.Log("Now scannining consumables")

                local itemId = nil
                local consumables = Player.GetConsumableItems()

                Debug.Table("consumables", consumables)


                for i, consumable in ipairs(consumables) do

                    if tonumber(consumable.itemTypeId) == tonumber(techId) then

                        itemId = consumable.abilityId or consumable.itemId
                        Debug.Log("Found match! itemId is " .. tostring(itemId))
                        break

                    end


                end

                if itemId ~= nil then
                    Debug.Log("ActivateTech time!")

                    Debug.Log("but can we? : Game.CanUIActivateItem ", tostring(Game.CanUIActivateItem(itemId, techId)))
                    --Player.ActivateTech(itemId, techId)


                
                    if Game.CanUIActivateItem(itemId, techId) then

                        local FosterFrame = Component.GetFrame("FosterFrame")
                        local FosteredBackdrop = Component.CreateWidget('<group dimensions="dock:fill;"/>', FosterFrame)
                        Component.FosterWidget("CursorModeBackdrop:CursorModeBackdrop.{1}", FosteredBackdrop)
                        FosteredBackdrop:Show(false)

                        Component.SetInputMode("cursor")
                        Callback2.FireAndForget(Component.SetInputMode, nil, 0.3) -- saftey
                        Callback2.FireAndForget(function(args) Player.ActivateTech(args.itemId, args.techId) Component.SetInputMode(nil) FosteredBackdrop:Show(true) end, {itemId=itemId, techId=techId}, 0.1)
                    end

                end
            end

        end



        BAKERY_Calldowns[CurrentlyActiveCalldownPie].PIE:Show(false)
        PIE_CONTAINER:Show(false)


        KEYSET_CalldownPieButtons:Activate(false)
        KEYSET_AbilityPieCancellation:Activate(false)
        KEYSET_CalldownPies:Activate(true)

        CurrentlyActiveCalldownPie = nil
        IsCalldownPieActive = false
    end
end


-- ------------------------------------------
-- GENERAL FUNCTIONS
-- ------------------------------------------

function ActivateControllerKeyboard(args)
    X360.DisplayKeyboardUI()
end

function DetectActiveGamepad(args)
    -- Get cvar value
    local isGamepadEnabled = System.GetCvar(CVAR_ALLOW_GAMEPAD)

    -- If gamepad is enabled, toggle in order to cause redetection
    if isGamepadEnabled then
        Output("Redetecting Gamepad")
        System.SetCvar(CVAR_ALLOW_GAMEPAD, false)
        Callback2.FireAndForget(function() System.SetCvar(CVAR_ALLOW_GAMEPAD, true) end, nil, REDETECTION_DELAY_SECONDS)

    -- If gamepad was disabled, we just enable it right away
    else
        Output("Enabling Gamepad")
        System.SetCvar(CVAR_ALLOW_GAMEPAD, true)
    end
end



-- Based on CreateSegWheel from Arkii's Invii <3
function CreatePie(PARENT, segmentData)
    local cont = Component.CreateWidget('<Group blueprint="Pie" dimensions="width:50%; height:50%; center-y:50%; center-x:50%;"></Group>', PARENT)
    local numberOfSegments = 4
    local perSegPrecent = (100/numberOfSegments)

    Debug.Table("Creating pie with following segmentData: ", segmentData)

    for i=1,numberOfSegments do
        local angle = 360 * (perSegPrecent*i)/100 + 90
        local point = GetPointOnCricle(170, 170-24, RT_SEG_WIDTH*0.30, angle)
        local SEGMENT = Component.CreateWidget(unicode.format('<Group blueprint="KeyPieSegment" dimensions="width:80; height:80; left:%i; top:%i;"></Group>', point.x-20, point.y-20), cont)
        if (segmentData[i]) then
            SEGMENT:GetChild("icon"):SetIcon(segmentData[i].icon_id)

            if segmentData[i].icon_id ~= 0 then
                local inputIcon = InputIcon.CreateVisual(SEGMENT:GetChild("inputIconGroup"), "Bind")
                local keyCode = ABILITY_PIE_KEYBINDINGS_ORDER[i]
                inputIcon:SetBind({keycode=keyCode, alt=false}, true)
            end

        end
    end
    return cont
end

-- Arkii did the maths <3
function GetPointOnCricle(orginX, orignY, radius, angle)
    local res = { x = 0, y = 0 }
    res.x = (radius * math.cos(angle * math.pi / 180)) + orginX
    res.y = (radius * math.sin(angle * math.pi / 180)) + orignY

    return res
end


















-- ------------------------------------------
-- Messy early experimental code, use later for calldowns
-- ------------------------------------------




function OnReleaseAbilityPieButton(args)

    local keyCode = args.keycode

    KEYSET_AbilityPieButtons:Activate(false)
    KEYSET_AbilityPie:Activate(true)    

    Debug.Table("OnReleaseAbilityPieButton", args)



    Output("OnReleaseAbilityPieButton You pressed " .. System.GetKeycodeString(keyCode) .. " keyCode:" .. tostring(keyCode))
    PIE_CONTAINER:Show(false)


Callback2.FireAndForget(function()


    -- UNDO SPECIALZ
    
    Debug.Log("Doing the bind key thing")
    System.BindKey("Combat", "SelectAbility1", 0, false, 3)
    Debug.Log("unbound our button")


    -- OKAY NOW RESTORE BEFORE WE LOSE THME :D ya ya
    Debug.Log("bara baraa restore")
    for i, conflict in ipairs(VERY_IMPORTANT_OVERRIDEN_KEYBINDS) do
        System.BindKey(conflict.category, conflict.action, 278, false, conflict.index)
        Debug.Table("Restoring usagii tachii ", conflict)
    end

    Output("restoreing stiff")
    System.ApplyKeyBindings()
end, nil, 1)

end

function OnAbilityPieKeyCaught(args)
    
    PIE_Abilities_KeyCatcher:StopListening() -- Important! Prevents Gamepad input lockup issue
    
    local keyCode = args.widget:GetKeyCode()
    
    local leftTrigger = (keyCode == 280)
    local rightTrigger = (keyCode == 281)

    local gamepadX = (keyCode == 278)
    local gamepadY = (keyCode == 279)
    local gamepadB = (keyCode == 277)
    local gamepadA = (keyCode == 276)
    local dpadUp = (keyCode    == 266)
    local dpadRight = (keyCode == 269)
    local dpadDown = (keyCode  == 267)
    local dpadLeft = (keyCode  == 268)

    local skipCodes = {
        [280] = true, -- Left Trigger
        [281] = true, -- Right Trigger
    }

    local acceptCodes = {
        [278] = true, -- gamepadX
        [279] = true, -- gamepadY
        [277] = true, -- gamepadB
        [276] = true, -- gamepadA
        [266] = true, -- dpadUp
        [269] = true, -- dpadRight
        [267] = true, -- dpadDown
        [268] = true, -- dpadLeft
    }

    Debug.Log("OnKeyCaught " .. System.GetKeycodeString(keyCode) .. " keyCode:" .. tostring(keyCode))

    -- Ignore some input
    if skipCodes[keyCode] then
        PIE_Abilities_KeyCatcher:ListenForKey() -- Reactivate keycatcher (not related to above fix)

    -- Accept correct input
    elseif acceptCodes[keyCode] then

        Output("You pressed " .. System.GetKeycodeString(keyCode) .. " keyCode:" .. tostring(keyCode))



        Callback2.FireAndForget(function()


        -- UNDO SPECIALZ
        
        Debug.Log("Doing the bind key thing")
        System.BindKey("Combat", "SelectAbility1", 0, false, 3)
        Debug.Log("unbound our button")


        -- OKAY NOW RESTORE BEFORE WE LOSE THME :D ya ya
        Debug.Log("bara baraa restore")
        for i, conflict in ipairs(VERY_IMPORTANT_OVERRIDEN_KEYBINDS) do
            System.BindKey(conflict.category, conflict.action, 278, false, conflict.index)
            Debug.Table("Restoring usagii tachii ", conflict)
        end

        Output("restoreing stiff")
        System.ApplyKeyBindings()

        end, nil, 1)

        PIE_CONTAINER:Show(false)

    -- Cancel on other input
    else
            
        Output("Cancelled because you pressed " .. System.GetKeycodeString(keyCode) .. " keyCode:" .. tostring(keyCode))

        PIE_CONTAINER:Show(false)
    end
    



   
end


function OnPressAbilityPie(args)

    KEYSET_AbilityPie:Activate(false)        
    KEYSET_AbilityPieButtons:Activate(true)

    -- activate key catcher
    --PIE_Abilities_KeyCatcher:ListenForKey()

    Output("ON PRESS ABILITY PIE")

    


    --Debug.Table("keybndings", System.GetKeyBindings("Combat", false))
        
        --]]

    -- anim
    PIE_Abilities:SetParam("alpha", 0, 0.1)
    PIE_Abilities:QueueParam("alpha", 1, 0.25, "ease-in")

    KEYSET_AbilityPieButtons:Activate(true)
    PIE_CONTAINER:Show(true)
end






















-- ------------------------------------------
-- UTILITY/RETURN FUNCTIONS
-- ------------------------------------------

function Output(text)
    local args = {
        text = tostring(text),
    }

    ChatLib.SystemMessage(args);
end

function _table.empty(table)
    if not table or next(table) == nil then
       return true
    end
    return false
end