
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




-- ------------------------------------------
-- CONSTANTS
-- ------------------------------------------
CVAR_ALLOW_GAMEPAD = "control.allowGamepad"
REDETECTION_DELAY_SECONDS = 1

SIN_ABILITY_ID = "43"

DRAG_ORIGIN_CU = "xcontrollerutil"
DRAG_ORIGIN_ACTIONBAR = "3dactionbar"

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



SUPER_CALLDOWN_PIZZA_KEYBINDINGS = {
    [KEYCODE_GAMEPAD_X] = "SelectAbility5",
    [KEYCODE_GAMEPAD_Y] = "SelectAbility6",
    [KEYCODE_GAMEPAD_B] = "SelectAbility7",
    [KEYCODE_GAMEPAD_A] = "SelectAbility8",
}


-- ------------------------------------------
-- GLOBALS
-- ------------------------------------------

-- Pizza stuff
w_PIZZA_CONTAINER = Component.GetWidget("PizzaContainer")
w_PIZZA_Abilities = nil


-- Pizza keysets
g_KeySet_PizzaActivators = nil
g_KeySet_PizzaDeactivators = nil
g_KeySet_CustomPizzaButtons = nil -- Note: Non-custom pizzas will have the same buttons, its just that we need one of these for the custom ones since we don't directly override binds with them.






VERY_IMPORTANT_OVERRIDEN_KEYBINDS = nil
g_IsAbilityPizzaActive = false
g_IsCalldownPizzaActive = false
g_CurrentlyActiveCalldownPizza = nil



BAKERY_Calldowns = {} -- a bakery contains pizzas!

g_pizzaUIReferences = {} -- this is some super bad stupid hack


-- Data to be stored elsewhere
g_CustomPizzas = {

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

-- Other
g_NotificationsSINTriggerTimestamp = nil


OptionsUI = {
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


-- ------------------------------------------
-- INTERFACE OPTIONS
-- ------------------------------------------



-- ------------------------------------------
-- LOAD
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
    SetupUserKeybinds()

end

function SetupUserKeybinds()

    -- g_KeySet_PizzaActivators
    -- This keyset has one action for each pizza it can activate
    g_KeySet_PizzaActivators = UserKeybinds.Create()
    
        -- Ability Pizza Bind
        g_KeySet_PizzaActivators:RegisterAction("activate_ability_pizza", ActivateAbilityPizza)
        if Component.GetSetting("ability_pizza_keycode") then
            local keyCode = Component.GetSetting("ability_pizza_keycode")
            g_KeySet_PizzaActivators:BindKey("activate_ability_pizza", keyCode)
        end

        -- Ported from g_KeySet_PizzaActivators, to be custom pizzas
        g_KeySet_PizzaActivators:RegisterAction("calldown_pizza_transport", ActivateCalldownPizza)
        g_KeySet_PizzaActivators:RegisterAction("calldown_pizza_other", ActivateCalldownPizza)
        g_KeySet_PizzaActivators:BindKey("calldown_pizza_transport", KEYCODE_GAMEPAD_DPAD_RIGHT)
        g_KeySet_PizzaActivators:BindKey("calldown_pizza_other", KEYCODE_GAMEPAD_DPAD_DOWN)

        -- Disable while creating the rest of the keybinds
        g_KeySet_PizzaActivators:Activate(false)


    -- g_KeySet_PizzaDeactivators
    -- This keyset is for special buttons that can be pressed when a pizza is active to de-activate it.
    g_KeySet_PizzaDeactivators = UserKeybinds.Create()

        -- These buttons are hardcoded for now
        g_KeySet_PizzaDeactivators:RegisterAction("ability_pizza_cancel", AbilityPizzaDeactivationTrigger)
        for _, keyCode in ipairs(ABILITY_PIZZA_CANCELLATION_KEYS) do
            g_KeySet_PizzaDeactivators:BindKey("ability_pizza_cancel", keyCode)
        end

        -- Disable while creating the rest of the keybinds
        g_KeySet_PizzaDeactivators:Activate(false)


    -- g_KeySet_CustomPizzaButtons
    -- This keyset is used for custom pizzas since we are not replacing default binds with those
    g_KeySet_CustomPizzaButtons = UserKeybinds.Create()

        -- These buttons are hardcoded for now
        g_KeySet_CustomPizzaButtons:RegisterAction("press_calldown_pizza_button", DeactivateCalldownPizza, "release")
        for i, keyCode in ipairs(ABILITY_PIZZA_KEYBINDINGS_ORDER) do
            g_KeySet_CustomPizzaButtons:BindKey("press_calldown_pizza_button", keyCode, i)
        end

        -- Disable while creating the rest of the keybinds
        g_KeySet_CustomPizzaButtons:Activate(false)


    -- Ready
    g_KeySet_PizzaActivators:Activate(true)

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
            local previousKeyCode = g_KeySet_PizzaActivators:GetKeybind("activate_ability_pizza") or "blank"
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
                g_KeySet_PizzaActivators:BindKey("activate_ability_pizza", keyCode)
                Component.SaveSetting("ability_pizza_keycode", keyCode)

                OptionsUI.POPUP:Remove() OptionsUI.POPUP = nil
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


    for pizzaKey, pizzaContents in pairs(g_CustomPizzas) do

        local pizzaWidgets = {}
        local ENTRY_GROUP = Component.CreateWidget(unicode.format('<Group dimensions="left:20.5; width:100%%-41; top:10%%+%d; height:100"/>', countEntries * 120), OptionsUI.PANE_MAIN_MAIN_AREA_LIST)
        local innerCount = 0
        for keyCode, itemId in pairs(pizzaContents) do
            local w = Component.CreateWidget('<Group dimensions="left:10%+'..(innerCount * 25)..'%; width:20%; height:80%; top:20%;"><StillArt name="bg" dimensions="dock:fill" style="texture:colors; region:white; tint:#ff0000; alpha:0.8;"/><Icon name="icon" dimensions="dock:fill" style="fixed-bounds:true; alpha:1;" /><FocusBox name="focus" dimensions="dock:fill"><DropTarget name="droptarget" dimensions="dock:fill"/></FocusBox></Group>', ENTRY_GROUP)
            innerCount = innerCount + 1

            SetupPizzaSegmentIcon(pizzaKey, innerCount, w:GetChild("icon"))

            SetupDropFocus(w, pizzaKey, innerCount)
            SetupDropTarget(w, pizzaKey, innerCount)

            pizzaWidgets[innerCount] = {w=w, icon=w:GetChild("icon")}
        end
        countEntries = countEntries + 1
        g_pizzaUIReferences[pizzaKey] = pizzaWidgets
    end

    --OptionsUI.PANE_MAIN_MAIN_AREA_LIST_CHILD_  


    -- Create layout for Second Pane
    OptionsUI.PANE_SECOND_LAYOUT = Component.CreateWidget("PaneLayoutMain", OptionsUI.PANE_SECOND)


end


-- ------------------------------------------
-- EVENTS
-- ------------------------------------------

function OnSlashGeneral(args)
    Debug.Table("OnSlashGeneral", args)

    if args[1] then

        if args[1] == "something" then

        end

    else
        ToggleOptionsUI({show=true})
    end
end

function OnSlashGamepad(args)
    Debug.Table("OnSlashGamepad", args)

    DetectActiveGamepad()
end

function OnClose(args)
    ToggleOptionsUI({show=false})
end

function OnToggleDefaultUI(args)
    Debug.Table("OnToggleDefaultUI", args)

    -- Determine whether UI is being shown
    local show = args.visible or args.show or false

    -- If UI is being shown, we must disable ability pizzas
    if show then

        -- In case pizzas are shown, deactivate them
        AbilityPizzaDeactivationTrigger(args)

        -- Disable activation keybinds
        g_KeySet_PizzaActivators:Activate(false)

        --Output("Pizza Buttons Disabled")

    -- If UI is being hidden, we should re-enable ability pizzas
    else

        -- If pizza action was disabled
        if not g_KeySet_PizzaActivators:IsActive() then
            
            -- Activate activaiton keybinds
            g_KeySet_PizzaActivators:Activate(true)

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
    if tostring(args.id) == SIN_ABILITY_ID then

        -- Only with gamepad
        if Player.IsUsingGamepad() then
            
            -- If we have a timestamp
            if g_NotificationsSINTriggerTimestamp ~= nil then
                
                -- Compare the elapsed time to check for double tap
                if System.GetElapsedUnixTime(g_NotificationsSINTriggerTimestamp) == 0 then
                    TriggerNotificationUI()
                end
            end

            -- Set timestamp
            g_NotificationsSINTriggerTimestamp = System.GetLocalUnixTime()
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

    w_PIZZA_CONTAINER:Show(true)
    w_PIZZA_Abilities = CreatePizza(w_PIZZA_CONTAINER, segmentData)
    w_PIZZA_Abilities:Show(false)

    Debug.Log("Creating Calldown Pizzas")

    for name, content in pairs(g_CustomPizzas) do
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
            table.insert(segmentData, {icon_id = icon_id, tech_id = calldownTypeId, keycode = keycode, pizzaName = name})
        end
        BAKERY_Calldowns[name] = {}
        BAKERY_Calldowns[name].PIZZA = CreatePizza(w_PIZZA_CONTAINER, segmentData)
        BAKERY_Calldowns[name].data = segmentData
        BAKERY_Calldowns[name].PIZZA:Show(false)
    end

    Debug.Log("Calldown Pizzas Baked")
end

function AbilityPizzaDeactivationTrigger(args)
    --Debug.Event(args)
    if g_IsAbilityPizzaActive then
        DeactivateAbilityPizza(args)
    elseif g_IsCalldownPizzaActive then
        DeactivateCalldownPizza(args)
    end
end




-- ------------------------------------------
-- GENERAL FUNCTIONS
-- ------------------------------------------

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

function ActivateAbilityPizza(args)
    assert(not g_IsAbilityPizzaActive, "waddafak you do, you can't eat two pizzas at once")
    assert(not g_IsCalldownPizzaActive, "you buffon")
    assert(w_PIZZA_Abilities, "ehh we got problem")

    -- Diable activation keybind
    g_KeySet_PizzaActivators:Activate(false)

    -- Activate deactivation keybind
    g_KeySet_PizzaDeactivators:Activate(true)

    -- Do the crazy ability pizza keybind overriding
    DoTheCrazyAbilityPizzaKeyBindOverriding()

    -- Make some fancy moves
    w_PIZZA_Abilities:SetParam("alpha", 0, 0.1)
    w_PIZZA_Abilities:QueueParam("alpha", 1, 0.25, "ease-in")
    w_PIZZA_Abilities:Show(true)

    -- Show the world!
    w_PIZZA_CONTAINER:Show(true)

    -- Baka almost forgot
    g_IsAbilityPizzaActive = true

    --Output("Activated Ability Pizza")
end

function DeactivateAbilityPizza(args)
    assert(g_IsAbilityPizzaActive, "pluto isn't a planet")

    -- Undo the crazy ability pizza keybind overriding
    UndoTheCrazyAbilityPizzaKeyBindOverriding()

    -- Usagi chirichiri~
    w_PIZZA_Abilities:Show(false)
    w_PIZZA_CONTAINER:Show(false)

    -- Disable deactivation keyset
    g_KeySet_PizzaDeactivators:Activate(false)
    
    -- Enable activation keyset
    g_KeySet_PizzaActivators:Activate(true)

    -- Update that thing and RIP keybinds
    g_IsAbilityPizzaActive = false

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


    if not g_IsCalldownPizzaActive and not g_IsAbilityPizzaActive then

        Debug.Log("Opening calldown pizza")

        g_KeySet_PizzaActivators:Activate(false)
        g_KeySet_PizzaDeactivators:Activate(true)
        g_KeySet_CustomPizzaButtons:Activate(true)

        g_CurrentlyActiveCalldownPizza = ( (args.name == "calldown_pizza_transport" and "TransportPizza") or (args.name == "calldown_pizza_other" and "OtherPizza"))
        Debug.Log("g_CurrentlyActiveCalldownPizza: ", g_CurrentlyActiveCalldownPizza)
        g_IsCalldownPizzaActive = true

        BAKERY_Calldowns[g_CurrentlyActiveCalldownPizza].PIZZA:SetParam("alpha", 0, 0.1)
        BAKERY_Calldowns[g_CurrentlyActiveCalldownPizza].PIZZA:QueueParam("alpha", 1, 0.25, "ease-in")
        BAKERY_Calldowns[g_CurrentlyActiveCalldownPizza].PIZZA:Show(true)
        w_PIZZA_CONTAINER:Show(true)

    end
end

function DeactivateCalldownPizza(args)
    Debug.Table("DeactivateCalldownPizza", args)


    if g_IsCalldownPizzaActive then


        Debug.Log("Closing calldown pizza")


        if args.keycode then

            -- THis is it, do the thing!
            local segmentData = BAKERY_Calldowns[g_CurrentlyActiveCalldownPizza].data


            Debug.Log("Begin attempt to activate calldown")
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

            else
                Debug.Log("TechId is 0, so either this keycode isnt in the segmentData (user cancelled the pizza) or the slot for this keycode doesnt have a calldown in it at the moment. Eitherway we cant activate anything this time.")
            end

        end



        BAKERY_Calldowns[g_CurrentlyActiveCalldownPizza].PIZZA:Show(false)
        w_PIZZA_CONTAINER:Show(false)


        g_KeySet_CustomPizzaButtons:Activate(false)
        g_KeySet_PizzaDeactivators:Activate(false)
        g_KeySet_PizzaActivators:Activate(true)

        g_CurrentlyActiveCalldownPizza = nil
        g_IsCalldownPizzaActive = false
    end
end







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
-- Drag and Drop
-- ------------------------------------------



function OnDragDropEnd(args)
    if (args and args.canceled and args.dragdata and type(args.dragdata) == "string") then
        local dragdata = jsontotable(args.dragdata);
        
        if (dragdata and dragdata.from == DRAG_ORIGIN_ACTIONBAR) then
            Debug.Event(args)
        end
    end
end





function GetPizzaSegment(pizzaName, segmentIndex)
    local pizza = g_CustomPizzas[pizzaName]
    assert(pizza, "who ate my pizza D:")
    local segment = pizza[ABILITY_PIZZA_KEYBINDINGS_ORDER[segmentIndex]]
    return segment
end


function GetDragInfoForPizzaSegment(pizzaName, segmentIndex)
    return tostring({pizza = pizzaName, index = segmentIndex, itemSdbId = GetPizzaSegment(pizzaName, segmentIndex), from = DRAG_ORIGIN_CU})
end

function PizzaSegmentEmpty(pizzaName, segmentIndex)
    return (GetPizzaSegment(pizzaName, segmentIndex) == 0)
end

function SetupDropFocus(w, pizzaName, segmentIndex)
    local dropFocus = w:GetChild("focus")
    dropFocus:BindEvent("OnMouseDown", function()
        if (not PizzaSegmentEmpty(pizzaName, segmentIndex)) then
            Component.BeginDragDrop("item_sdb_id", GetDragInfoForPizzaSegment(pizzaName, segmentIndex), nil);
        end
    end);
end


function SetupDropTarget(w, pizzaName, segmentIndex)
    Debug.Log("SetupDropTarget")

    local dropTarget = w:GetChild("focus"):GetChild("droptarget")
    --Debug.Table({isW = Component.IsWidget(w), isDropTarget = Component.IsWidget(dropTarget)})


    dropTarget:SetAcceptTypes("item_sdb_id");
    dropTarget:BindEvent("OnDragDrop", function(args)
        local dropInfoString = dropTarget:GetDropInfo();
        local dropInfo = jsontotable(dropInfoString);
        args.z_dropInfo = dropInfo
        Debug.Event(args)
        
        if dropInfo then
            -- From self
            if dropInfo.from == DRAG_ORIGIN_CU then
                
                SwapPizzaSegment(dropInfo.pizza, dropInfo.index, segmentIndex, pizzaName)

            -- From actionbar
            elseif dropInfo.from == DRAG_ORIGIN_ACTIONBAR then
                Debug.Log("Drop from actionbar!")
                InsertPizzaSegment(pizzaName, dropInfo.itemSdbId, segmentIndex)
            
            -- From unknown!
            else
                Debug.Warn("Something was dropped into a droptarget from an unknown source:", dropInfo.from)
                InsertSegment(dropInfo.itemSdbId, pizzaName, segmentIndex)
            end
        end

        -- OnDragLeave
        local widget = args.widget
        local stillArt = widget:GetParent():GetParent():GetChild("bg")
        stillArt:SetParam("tint", "#ff0000")
        -- -----------

        end);

    -- Use args.widget in these :D
    dropTarget:BindEvent("OnDragEnter", function(args)
                local widget = args.widget
                
                widgetInfo(widget)

                local stillArt = widget:GetParent():GetParent():GetChild("bg")
                widgetInfo(stillArt)

                stillArt:SetParam("tint", "#00ff00")

        end);
    dropTarget:BindEvent("OnDragLeave", function(args)
                local widget = args.widget
                local stillArt = widget:GetParent():GetParent():GetChild("bg")
                stillArt:SetParam("tint", "#ff0000")
        end);
end




function GetDragInfoForSlot(index)
    local dragData = {};
    
    dragData = GetDragDataForItemSlot(index);
    
    return dragData;
end


function GetDragDataForItemSlot(index)
    -- for dragging consumable slots we need the item sdbid, index, and if it's local (to swap rather than replace)
    return tostring({index = index, itemSdbId = g_abilityInfo[index].itemInfo.itemTypeId, from = c_ActionbarDragOrigin});
end


function SwapPizzaSegment(fromPizza, fromSegment, toSegment, toPizza)

    Debug.Table("SwapPizzaSegment", {fromPizza = fromPizza, fromSegment = fromSegment, toSegment = toSegment, toPizza = toPizza})

    if (fromSegment and toSegment) then
        local item1 = GetPizzaSegment(fromPizza, fromSegment)
        local item2 = GetPizzaSegment(toPizza, toSegment)


        if not PizzaSegmentEmpty(fromPizza, fromSegment) and not PizzaSegmentEmpty(toPizza, toSegment) then
            Debug.Log("item1 and item2")
            InsertPizzaSegment(toPizza, item1, toSegment)
            InsertPizzaSegment(fromPizza, item2, fromSegment)
        elseif not PizzaSegmentEmpty(fromPizza, fromSegment) then
            Debug.Log("item1")
            InsertPizzaSegment(toPizza, item1, toSegment)
            EatPizzaSegment(fromPizza, fromSegment)
        elseif not PizzaSegmentEmpty(toPizza, toSegment) then
            Debug.Log("item2")
            InsertPizzaSegment(fromPizza, item2, fromSegment)
            EatPizzaSegment(toPizza, toSegment)
        end

    end
end

function InsertPizzaSegment(pizzaName, itemTypeId, segmentIndex)
    Debug.Log("InsertPizzaSegment")

    -- Get segment
    local segment = GetPizzaSegment(pizzaName, segmentIndex)
    
    -- Update pizzas data
    g_CustomPizzas[pizzaName][ABILITY_PIZZA_KEYBINDINGS_ORDER[segmentIndex]] = itemTypeId

    -- Trigger pizzas to be updated
    UpdateAbilities()
        
    -- Update OptionsUI icon
    SetupPizzaSegmentIcon(pizzaName, segmentIndex)

    Debug.Table("g_CustomPizzas", g_CustomPizzas)
end

function EatPizzaSegment(pizzaName, segmentIndex)
    Debug.Log("EatPizzaSegment")
    InsertPizzaSegment(pizzaName, 0, segmentIndex)
end


function SetupPizzaSegmentIcon(pizzaName, segmentIndex, icon)
    if not PizzaSegmentEmpty(pizzaName, segmentIndex) then
        local segment = GetPizzaSegment(pizzaName, segmentIndex)
        local itemTypeInfo = Game.GetItemInfoByType(segment)
        local iconId = itemTypeInfo.web_icon_id or 0
        
        icon = icon or g_pizzaUIReferences[pizzaName][segmentIndex].icon
        
        icon:SetIcon(iconId)
    else
        icon = icon or g_pizzaUIReferences[pizzaName][segmentIndex].icon
        icon:ClearIcon()
    end
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


function widgetInfo(widget)
    assert(widget)
    Debug.Log("Widget ", (Component.IsWidget(widget) and "is a widget") or "is not a widget")
    local name, kind = widget:GetInfo()
    Debug.Log("WidgetGetInfo", "name", tostring(name), "type", tostring(kind))
end









