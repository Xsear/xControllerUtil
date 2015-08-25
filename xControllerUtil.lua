
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
    OptionsUI.TABS:SetTab(1, {label="Pizza Config"})
    OptionsUI.TABS:SetTab(2, {label="Bindings"})

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


    -- Test button
    function TestButtonAction(args)
        Debug.Table("TestButtonAction", args)
        Debug.Log("Is args.widget widget? : ", tostring(Component.IsWidget(args.widget)))

        Debug.Log("This was button with id : ", args.widget:GetName())


        if not OptionsUI.POPUP then
            OptionsUI.POPUP = RoundedPopupWindow.Create(OptionsUI.PANE_MAIN_LEFT_COLUMN)
            OptionsUI.POPUP:EnableClose(true, function() OptionsUI.POPUP:Remove() OptionsUI.POPUP = nil end)

            OptionsUI.POPUP:SetTitle("Keybinder")
            OptionsUI.POPUP:SetDims("center-x:50%; center-y:50%; height:200; width:235")

            OptionsUI.POPUP:TintBack("#ff6000")

            local POPUP_BODY = OptionsUI.POPUP:GetBody()

            OptionsUI.POPUP_BODY_INPUT_ICON = InputIcon.CreateVisual(POPUP_BODY, "Bind")
            local previousKeyCode = KEYSET_AbilityPizza:GetKeybind("ability_pizza") or "blank"
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
                KEYSET_AbilityPizza:BindKey("ability_pizza", keyCode)
                Component.SaveSetting("ability_pizza_keycode", keyCode)
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

    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON = Component.CreateWidget('<Button id="BindAbilityButton" key="{Bind Ability Pizza}" dimensions="left:10.25; width:100%-20.5; top:5%; height:75"/>', OptionsUI.PANE_MAIN_LEFT_COLUMN)
    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON:BindEvent("OnMouseDown", TestButtonAction)

    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON2 = Component.CreateWidget('<Button id="CreatePizzaButton" key="{Create Pizza}" dimensions="left:10.25; width:100%-20.5; top:5%+100; height:75"/>', OptionsUI.PANE_MAIN_LEFT_COLUMN)
    --OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON2:BindEvent("OnMouseDown", TestButtonAction)

    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON3 = Component.CreateWidget('<Button id="EditPizzaButton" key="{Edit Pizza}" dimensions="left:10.25; width:100%-20.5; top:5%+200; height:75"/>', OptionsUI.PANE_MAIN_LEFT_COLUMN)
    --OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON3:BindEvent("OnMouseDown", TestButtonAction)

    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON4 = Component.CreateWidget('<Button id="DeletePizzaButton" key="{Delete Pizza}" dimensions="left:10.25; width:100%-20.5; top:5%+300; height:75"/>', OptionsUI.PANE_MAIN_LEFT_COLUMN)
    --OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON4:BindEvent("OnMouseDown", TestButtonAction)


    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON5 = Component.CreateWidget('<Button id="RescanButton" key="{Rescan Controllers}" dimensions="left:10.25; width:100%-20.5; top:5%+400; height:75"/>', OptionsUI.PANE_MAIN_LEFT_COLUMN)
    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON5:BindEvent("OnMouseDown", DetectActiveGamepad)


    local listItems = {}
    local countEntries = 0
    for pizzaKey, pizzaContents in pairs(HardCodedCalldownPizzas) do

        local ENTRY_GROUP = Component.CreateWidget(unicode.format('<Group dimensions="left:20.5; width:100%%-41; top:10%%+%d; height:100"/>', countEntries * 120), OptionsUI.PANE_MAIN_MAIN_AREA_LIST)
        local innerCount = 0
        for keyCode, itemId in pairs(pizzaContents) do
            local w = Component.CreateWidget('<StillArt dimensions="left:10%+'..(innerCount * 25)..'%; width:20%; height:80%; top:20%;" style="texture:colors; region:white; tint:#ff0000; alpha:0.8;"/>', ENTRY_GROUP)
            innerCount = innerCount + 1
        end
        countEntries = countEntries + 1
    end

    --OptionsUI.PANE_MAIN_MAIN_AREA_LIST_CHILD_  


    -- Create layout for Second Pane
    OptionsUI.PANE_SECOND_LAYOUT = Component.CreateWidget("PaneLayoutMain", OptionsUI.PANE_SECOND)


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

ABILITY_PIZZA_KEYBINDINGS = {
    [KEYCODE_GAMEPAD_X] = "SelectAbility1",
    [KEYCODE_GAMEPAD_Y] = "SelectAbility2",
    [KEYCODE_GAMEPAD_B] = "SelectAbility3",
    [KEYCODE_GAMEPAD_A] = "SelectAbility4",
}
ABILITY_PIZZA_KEYBINDINGS_ORDER = {
    [1] = KEYCODE_GAMEPAD_X,
    [2] = KEYCODE_GAMEPAD_Y,
    [3] = KEYCODE_GAMEPAD_B,
    [4] = KEYCODE_GAMEPAD_A,
}
ABILITY_PIZZA_KEYBINDING_INDEX = 3 -- So since each key action can have multiple binds, but the UI options only utilize the first 2, we put our stuff on 3. Putting it on higher litters the savefile with empty slots.

ABILITY_PIZZA_CANCELLATION_KEYS = {
    KEYCODE_GAMEPAD_START, KEYCODE_GAMEPAD_BACK, KEYCODE_GAMEPAD_RIGHT_BUMPER
}


RT_SEG_WIDTH = 1024/3 -- Still used in pizza creation!


-- ------------------------------------------
-- GLOBALS
-- ------------------------------------------
PIZZA_CONTAINER = Component.GetWidget("PizzaContainer")


KEYSET_AbilityPizza = nil
PIZZA_Abilities = nil
IsAbilityPizzaActive = false
VERY_IMPORTANT_OVERRIDEN_KEYBINDS = nil

BAKERY_Calldowns = {} -- a bakery contains pizzas!

KEYSET_PizzaButtons = nil


HardCodedCalldownPizzas = {

    ["TransportPizza"] = {
        [ABILITY_PIZZA_KEYBINDINGS_ORDER[1]] = 77402, -- Gliderpad
        [ABILITY_PIZZA_KEYBINDINGS_ORDER[2]] = 77402,
        [ABILITY_PIZZA_KEYBINDINGS_ORDER[3]] = 0, -- rip the dream
        [ABILITY_PIZZA_KEYBINDINGS_ORDER[4]] = 136981, -- Elite banner
    },

    ["OtherPizza"] = {
        [ABILITY_PIZZA_KEYBINDINGS_ORDER[1]] = 30298, -- Ammopack
        [ABILITY_PIZZA_KEYBINDINGS_ORDER[2]] = 0,
        [ABILITY_PIZZA_KEYBINDINGS_ORDER[3]] = 54003,
        [ABILITY_PIZZA_KEYBINDINGS_ORDER[4]] = 0,
    },

}


IsCalldownPizzaActive = false
CurrentlyActiveCalldownPizza = nil


NotificationsSINTriggerTimestamp = nil

PizzaButtonsDisabled = false


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
    -- Keyset to trigger ability pizza
    KEYSET_AbilityPizza = UserKeybinds.Create()
    KEYSET_AbilityPizza:RegisterAction("ability_pizza", ActivateAbilityPizza, "press")
    if Component.GetSetting("ability_pizza_keycode") then
        local keyCode = Component.GetSetting("ability_pizza_keycode")
        KEYSET_AbilityPizza:BindKey("ability_pizza", keyCode)
    end
    KEYSET_AbilityPizza:Activate(false)

    -- Keyset for cancelling ability pizza when active
    KEYSET_AbilityPizzaCancellation = UserKeybinds.Create()
    KEYSET_AbilityPizzaCancellation:RegisterAction("ability_pizza_cancel", AbilityPizzaDeactivationTrigger, "press")
    for _, keyCode in ipairs(ABILITY_PIZZA_CANCELLATION_KEYS) do
        KEYSET_AbilityPizzaCancellation:BindKey("ability_pizza_cancel", keyCode)
    end
    KEYSET_AbilityPizzaCancellation:Activate(false)

    

    --[[
    Early experimental stuff, save for calldowns

    PIZZA_Abilities_KeyCatcher = Component.CreateWidget("KeyCatcher", PIZZA_Abilities):GetChild("KeyCatch")
    PIZZA_Abilities_KeyCatcher:BindEvent("OnKeyCatch", OnAbilityPizzaKeyCaught)
    --]]



    KEYSET_CalldownPizzas = UserKeybinds.Create()
    KEYSET_CalldownPizzas:RegisterAction("calldown_pizza_transport", ActivateCalldownPizza, "press")
    KEYSET_CalldownPizzas:RegisterAction("calldown_pizza_other", ActivateCalldownPizza, "press")
    --if Component.GetSetting("ability_pizza_keycode") then
    --    local keyCode = Component.GetSetting("ability_pizza_keycode")
    --    KEYSET_CalldownPizzas:BindKey("ability_pizza", keyCode)
    --end
    KEYSET_CalldownPizzas:BindKey("calldown_pizza_transport", KEYCODE_GAMEPAD_DPAD_RIGHT)
    KEYSET_CalldownPizzas:BindKey("calldown_pizza_other", KEYCODE_GAMEPAD_DPAD_DOWN)
    KEYSET_CalldownPizzas:Activate(false)
    


    KEYSET_CalldownPizzaButtons = UserKeybinds.Create()
    KEYSET_CalldownPizzaButtons:RegisterAction("press_calldown_pizza_button", DeactivateCalldownPizza, "release")
    for i, keyCode in ipairs(ABILITY_PIZZA_KEYBINDINGS_ORDER) do
        KEYSET_CalldownPizzaButtons:BindKey("press_calldown_pizza_button", keyCode, i)
    end
    KEYSET_CalldownPizzaButtons:Activate(false)



    -- Ready
    KEYSET_AbilityPizza:Activate(true)
    KEYSET_CalldownPizzas:Activate(true)
end

function OnSlashGeneral(args)
    Debug.Table("OnSlashGeneral", args)

    if args[1] then

        if args[1] == 'nuke' then
            KEYSET_AbilityPizza:Destroy()
            Component.SaveSetting("ability_pizza_keycode", nil)
        
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



function OnToggleDefaultUI(args)
    Debug.Table("OnToggleDefaultUI", args)

    -- Determine whether UI is being shown
    local show = args.visible or args.show or false

    -- If UI is being shown, we must disable ability pizzas
    if show then

        -- If pizzas are shown, deactivate them
        AbilityPizzaDeactivationTrigger(args)

        -- Disable activation keybinds
        KEYSET_AbilityPizza:Activate(false)
        KEYSET_CalldownPizzas:Activate(false)

        -- Save a reminder
        PizzaButtonsDisabled = true

        --Output("Pizza Buttons Disabled")

    -- If UI is being hidden, we should re-enable ability pizzas
    else

        if PizzaButtonsDisabled then
            KEYSET_AbilityPizza:Activate(true)
            KEYSET_CalldownPizzas:Activate(true)
            PizzaButtonsDisabled = false

            --Output("Pizza Buttons Enabled")
        end

    end



end





function OnPlayerReady(args)
    UpdateAbilities(args)
end

function OnBattleframeChanged(args)
    UpdateAbilities(args)
end

function OnAbilityUsed(args)

    -- Catch SIN activation
    if tostring(args.id) == "43" then
        -- Only with gamepad
        if Player.IsUsingGamepad() then
            -- Ensure timestam set
            if NotificationsSINTriggerTimestamp ~= nil then
                if System.GetElapsedUnixTime(NotificationsSINTriggerTimestamp) == 0 then
                    TriggerNotificationUI()
                end
            end
            NotificationsSINTriggerTimestamp = System.GetLocalUnixTime()
        end

    -- Normal logic
    else
        AbilityPizzaDeactivationTrigger(args)
    end

end

function OnAbilityFailed(args)
    AbilityPizzaDeactivationTrigger(args)
end

function OnPlaceCalldown(args)
    AbilityPizzaDeactivationTrigger(args)
end

function UpdateAbilities(args)
    Debug.Event(args)

    -- Clear exisiting data
    abilities = nil

    -- Get current abilities
    local abilities = Player.GetAbilities().slotted

    -- Setup pizzas! I don't even like pizza.
    local segmentData = {}
    for _, ability in ipairs(abilities) do
        local abilityInfo = Player.GetAbilityInfo(ability.abilityId)
        table.insert(segmentData, {icon_id = abilityInfo.iconId})
    end

    PIZZA_CONTAINER:Show(true)
    PIZZA_Abilities = CreatePizza(PIZZA_CONTAINER, segmentData)
    PIZZA_Abilities:Show(false)

    Debug.Log("Creating Calldown Pizzas")

    for name, content in pairs(HardCodedCalldownPizzas) do
        --Debug.Table("Creating segmentData for " .. tostring(name), content)
        local segmentData = {}
        for i, keycode in ipairs(ABILITY_PIZZA_KEYBINDINGS_ORDER) do

            local calldownTypeId = content[keycode]

            --Debug.Log("Lap keycode ", keycode, " calldownTypeId ", calldownTypeId, " in content.")
            local itemTypeInfo = Game.GetItemInfoByType(calldownTypeId)
            local icon_id = 0
            if itemTypeInfo then
                icon_id = itemTypeInfo.web_icon_id
            end
            table.insert(segmentData, {icon_id = icon_id, tech_id = calldownTypeId, keycode = keycode})
        end
        BAKERY_Calldowns[name] = {}
        BAKERY_Calldowns[name].PIZZA = CreatePizza(PIZZA_CONTAINER, segmentData)
        BAKERY_Calldowns[name].data = segmentData
        BAKERY_Calldowns[name].PIZZA:Show(false)
    end

    Debug.Log("Calldown Pizzas Baked")
end

function AbilityPizzaDeactivationTrigger(args)
    --Debug.Event(args)
    if IsAbilityPizzaActive then
        DeactivateAbilityPizza(args)
    elseif IsCalldownPizzaActive then
        DeactivateCalldownPizza(args)
    end
end

function ActivateAbilityPizza(args)
    assert(not IsAbilityPizzaActive, "waddafak you do, you can't eat two pizzas at once")
    assert(not IsCalldownPizzaActive, "you buffon")
    assert(PIZZA_Abilities, "ehh we got problem")

    -- Diable activation keybind
    KEYSET_AbilityPizza:Activate(false)
    KEYSET_AbilityPizzaCancellation:Activate(true)

    -- Do the crazy ability pizza keybind overriding
    DoTheCrazyAbilityPizzaKeyBindOverriding()

    -- Make some fancy moves
    PIZZA_Abilities:SetParam("alpha", 0, 0.1)
    PIZZA_Abilities:QueueParam("alpha", 1, 0.25, "ease-in")
    PIZZA_Abilities:Show(true)

    -- Show the world!
    PIZZA_CONTAINER:Show(true)

    -- Baka almost forgot
    IsAbilityPizzaActive = true

    --Output("Activated Ability Pizza")
end

function DeactivateAbilityPizza(args)
    assert(IsAbilityPizzaActive, "pluto isn't a planet")

    -- Undo the crazy ability pizza keybind overriding
    UndoTheCrazyAbilityPizzaKeyBindOverriding()

    -- Usagi chirichiri~
    PIZZA_Abilities:Show(false)
    PIZZA_CONTAINER:Show(false)

    -- Re-enable activation keybind
    KEYSET_AbilityPizzaCancellation:Activate(false)
    KEYSET_AbilityPizza:Activate(true)

    -- Update that thing and RIP keybinds
    IsAbilityPizzaActive = false

    --Output("Deactivated Ability Pizza")
end


function DoTheCrazyAbilityPizzaKeyBindOverriding(args)
    Debug.Log("Doing the crazy ability pizza keybind overriding!")

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

    -- Identify all keybinds that conflict with ability pizza keybindings
    Debug.Log("Identifying conflicting keybinds")
    local conflictingKeybinds = {}
    for category, actions in pairs(allKeybinds) do
        for action, slots in pairs(actions) do
            for i, bind in ipairs(slots) do
                if ABILITY_PIZZA_KEYBINDINGS[bind.keycode] then
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
    Debug.Log("Binding ability pizza keybinds")
    for keycode, action in pairs(ABILITY_PIZZA_KEYBINDINGS) do
        System.BindKey("Combat", action, keycode, false, ABILITY_PIZZA_KEYBINDING_INDEX)
    end


    Debug.Log("Applying the modified keybinds, no turning back now!")
    System.ApplyKeyBindings()

    -- Well, that is it for the first part of the procedure!
    Debug.Log("Okay, we're now in the crazy ability pizza keybinding override state.")
end


function UndoTheCrazyAbilityPizzaKeyBindOverriding(args)
    Debug.Log("Okay settle down, we're gonna undo the crazy ability pizza keybind overriding now")

    -- Unbind the special ability pizza keybindings
    Debug.Log("Unbinding ability pizza keybindings")
    for keycode, action in pairs(ABILITY_PIZZA_KEYBINDINGS) do
        System.BindKey("Combat", action, 0, false, ABILITY_PIZZA_KEYBINDING_INDEX)
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




function ActivateCalldownPizza(args)
    Debug.Table("ActivateCalldownPizza", args)


    if not IsCalldownPizzaActive and not IsAbilityPizzaActive then

        Debug.Log("Opening calldonw pizza")

        KEYSET_CalldownPizzas:Activate(false)
        KEYSET_AbilityPizzaCancellation:Activate(true)
        KEYSET_CalldownPizzaButtons:Activate(true)

        CurrentlyActiveCalldownPizza = ( (args.name == "calldown_pizza_transport" and "TransportPizza") or (args.name == "calldown_pizza_other" and "OtherPizza"))
        Debug.Log("CurrentlyActiveCalldownPizza: ", CurrentlyActiveCalldownPizza)
        IsCalldownPizzaActive = true

        BAKERY_Calldowns[CurrentlyActiveCalldownPizza].PIZZA:SetParam("alpha", 0, 0.1)
        BAKERY_Calldowns[CurrentlyActiveCalldownPizza].PIZZA:QueueParam("alpha", 1, 0.25, "ease-in")
        BAKERY_Calldowns[CurrentlyActiveCalldownPizza].PIZZA:Show(true)
        PIZZA_CONTAINER:Show(true)

    end
end

function DeactivateCalldownPizza(args)
    Debug.Table("DeactivateCalldownPizza", args)


    if IsCalldownPizzaActive then


        Debug.Log("Closing calldown pizza")


        if args.keycode then

            -- THis is it, do the thing!
            local segmentData = BAKERY_Calldowns[CurrentlyActiveCalldownPizza].data


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



        BAKERY_Calldowns[CurrentlyActiveCalldownPizza].PIZZA:Show(false)
        PIZZA_CONTAINER:Show(false)


        KEYSET_CalldownPizzaButtons:Activate(false)
        KEYSET_AbilityPizzaCancellation:Activate(false)
        KEYSET_CalldownPizzas:Activate(true)

        CurrentlyActiveCalldownPizza = nil
        IsCalldownPizzaActive = false
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

function TriggerNotificationUI(args)
    Component.GenerateEvent("MY_NOTIFICATION_TOGGLE", {show=true})
end



-- Based on CreateSegWheel from Arkii's Invii <3
function CreatePizza(PARENT, segmentData)
    Debug.Log("Creating Container")
    local cont = Component.CreateWidget('<Group blueprint="Pizza" dimensions="width:50%; height:50%; center-y:50%; center-x:50%;"></Group>', PARENT)
    local numberOfSegments = 4
    local perSegPrecent = (100/numberOfSegments)

    Debug.Table("Creating pizza with following segmentData: ", segmentData)

    for i=1,numberOfSegments do
        local angle = 360 * (perSegPrecent*i)/100 + 90
        local point = GetPointOnCricle(170, 170-24, RT_SEG_WIDTH*0.30, angle)
        local SEGMENT = Component.CreateWidget(unicode.format('<Group blueprint="KeyPizzaSegment" dimensions="width:80; height:80; left:%i; top:%i;"></Group>', point.x-20, point.y-20), cont)
        if (segmentData[i]) then
            SEGMENT:GetChild("icon"):SetIcon(segmentData[i].icon_id)

            if segmentData[i].icon_id ~= 0 then
                local inputIcon = InputIcon.CreateVisual(SEGMENT:GetChild("inputIconGroup"), "Bind")
                local keyCode = ABILITY_PIZZA_KEYBINDINGS_ORDER[i]
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




function OnReleaseAbilityPizzaButton(args)

    local keyCode = args.keycode

    KEYSET_AbilityPizzaButtons:Activate(false)
    KEYSET_AbilityPizza:Activate(true)    

    Debug.Table("OnReleaseAbilityPizzaButton", args)



    Output("OnReleaseAbilityPizzaButton You pressed " .. System.GetKeycodeString(keyCode) .. " keyCode:" .. tostring(keyCode))
    PIZZA_CONTAINER:Show(false)


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

function OnAbilityPizzaKeyCaught(args)
    
    PIZZA_Abilities_KeyCatcher:StopListening() -- Important! Prevents Gamepad input lockup issue
    
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
        PIZZA_Abilities_KeyCatcher:ListenForKey() -- Reactivate keycatcher (not related to above fix)

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

        PIZZA_CONTAINER:Show(false)

    -- Cancel on other input
    else
            
        Output("Cancelled because you pressed " .. System.GetKeycodeString(keyCode) .. " keyCode:" .. tostring(keyCode))

        PIZZA_CONTAINER:Show(false)
    end
    



   
end


function OnPressAbilityPizza(args)

    KEYSET_AbilityPizza:Activate(false)        
    KEYSET_AbilityPizzaButtons:Activate(true)

    -- activate key catcher
    --PIZZA_Abilities_KeyCatcher:ListenForKey()

    Output("ON PRESS ABILITY PIZZA")

    


    --Debug.Table("keybndings", System.GetKeyBindings("Combat", false))
        
        --]]

    -- anim
    PIZZA_Abilities:SetParam("alpha", 0, 0.1)
    PIZZA_Abilities:QueueParam("alpha", 1, 0.25, "ease-in")

    KEYSET_AbilityPizzaButtons:Activate(true)
    PIZZA_CONTAINER:Show(true)
end






















-- ------------------------------------------
-- UTILITY/RETURN FUNCTIONS
-- ------------------------------------------

function Output(text)
    local args = {
        text = "[xCU] " .. tostring(text),
    }

    ChatLib.SystemMessage(args);
end

function _table.empty(table)
    if not table or next(table) == nil then
       return true
    end
    return false
end