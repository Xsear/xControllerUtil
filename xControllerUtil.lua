
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
require "./util/optionsPopupWindow"

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
PIZZA_KEYBINDINGS_KEYCODE_INDEX = {
    [KEYCODE_GAMEPAD_X] = 1,
    [KEYCODE_GAMEPAD_Y] = 2,
    [KEYCODE_GAMEPAD_B] = 3,
    [KEYCODE_GAMEPAD_A] = 4,
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

-- Pizza Data
g_Pizzas = {
    ["AbilityPizza"] = {
        name = "Abilities",
        key = "AbilityPizza",
        enabled = true,
        isCustom = false,
        activationType = "ability_override",
        slots = {
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
        },
        w_PIZZA = nil,
    },
    ["TransportPizza"] = {
        name = "Transport",
        key = "TransportPizza",
        enabled = true,
        isCustom = true,
        activationType = "calldown",
        slots = {
            [1] = {
                slotType = "calldown",
                itemTypeId = 77402, -- Gliderpad
            },
            [2] = {
                slotType = "calldown",
                itemTypeId = 77402, -- Gliderpad
            },
            [3] = {
                slotType = "empty",
            },
            [4] = {
                slotType = "calldown",
                itemTypeId = 136981, -- Elite banner
            },
        },
        w_PIZZA = nil,
    },
    ["OtherPizza"] = {
        name = "Other",
        key = "OtherPizza",
        enabled = true,
        isCustom = true,
        activationType = "calldown",
        slots = {
            [1] = {
                slotType = "calldown",
                itemTypeId = 30298, -- Gliderpad
            },
            [2] = {
                slotType = "empty",
            },
            [3] = {
                slotType = "calldown",
                itemTypeId = 54003, -- Detonator
            },
            [4] = {
                slotType = "empty",
            },
        },
        w_PIZZA = nil,
    },
}

c_Pizza_Base = {
    name = "???",
    key = "better-set-this",
    enabled = true,
    isCustom = true,
    activationType = "calldown",
    slots = {
        [1] = {
                slotType = "empty",
        },
        [2] = {
                slotType = "empty",
        },
        [3] = {
                slotType = "empty",
        },
        [4] = {
                slotType = "empty",
        },
    },
    w_PIZZA = nil
}

-- Pizza Widget References
w_PIZZA_CONTAINER = Component.GetWidget("PizzaContainer")
w_PIZZA_Abilities = g_Pizzas["AbilityPizza"].w_PIZZA -- Shortcut (temp?)

-- Pizza Keysets
g_KeySet_PizzaActivators = nil
g_KeySet_PizzaDeactivators = nil
g_KeySet_CustomPizzaButtons = nil -- Note: Non-custom pizzas will have the same buttons, its just that we need one of these for the custom ones since we don't directly override binds with them.

g_GetPizzaByKeybindAction = {}

-- Other pizza related variables
VERY_IMPORTANT_OVERRIDEN_KEYBINDS = nil
g_IsAbilityPizzaActive = false
g_IsCalldownPizzaActive = false
g_CurrentlyActiveCalldownPizza = nil

-- SIN Notification Timestamp
g_NotificationsSINTriggerTimestamp = nil


-- Options UI References
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
    haveSetupBars = false,
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

    -- User Keybinds
    SetupUserKeybinds()

    -- Options UI
    SetupOptionsUI()

    -- Slash
    LIB_SLASH.BindCallback({slash_list="xcontrollerutil,xconutil,xcu,cu", description="Controller Utilities", func=OnSlashGeneral})
    LIB_SLASH.BindCallback({slash_list="redetect,gamepad", description="Attempt to detect active gamepad", func=OnSlashGamepad})
end

function GetPizzaActivatorAction(pizzaKey)
    return "activate_" .. pizzaKey
end

function GetPizzaActivatorSetting(pizzaKey)
    return "activate_" .. pizzaKey .. "_keycode"
end

function SetupUserKeybinds()

    -- g_KeySet_PizzaActivators
    -- This keyset has one action for each pizza it can activate
    g_KeySet_PizzaActivators = UserKeybinds.Create()
        
        -- Generate from data :D
        for pizzaKey, pizza in pairs(g_Pizzas) do
            -- Vars
            local action = GetPizzaActivatorAction(pizzaKey)
            local setting = GetPizzaActivatorSetting(pizzaKey)
            local handler = (pizzaKey == "AbilityPizza") and ActivateAbilityPizza or ActivateCalldownPizza -- Note: Ugh :D

            -- Make life easier
            g_GetPizzaByKeybindAction[action] = pizzaKey

            -- Register
            g_KeySet_PizzaActivators:RegisterAction(action, handler)
            
            -- Bind
            if Component.GetSetting(setting) then
                local keyCode = Component.GetSetting(setting)
                g_KeySet_PizzaActivators:BindKey(action, keyCode)
            end
        end

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
    function AddPizzaButton(args)
        Debug.Table("AddPizzaButton", args)
        Debug.Log("Is args.widget widget? : ", tostring(Component.IsWidget(args.widget)))
        Debug.Log("This was button with name : ", args.widget:GetName())

        -- feck the popups yo!
        local pizza = _table.copy(c_Pizza_Base)
        pizza.name = "Extra "
        pizza.key = "extra1"
        pizza.barEntry = CreatePizzaBarEntry(pizza)
        UpdateAbilities()
    end

    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON = Component.CreateWidget('<Button id="CreatePizzaButton" key="{Add Pizza}" dimensions="left:10.25; width:100%-20.5; top:2.5%; height:75"/>', OptionsUI.PANE_MAIN_LEFT_COLUMN)
    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON:BindEvent("OnMouseDown", AddPizzaButton)

    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON5 = Component.CreateWidget('<Button id="RedetectButton" key="{Redetect Controllers}" dimensions="left:10.25; width:100%-20.5; bottom:97.5%; height:75"/>', OptionsUI.PANE_MAIN_LEFT_COLUMN)
    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON5:BindEvent("OnMouseDown", DetectActiveGamepad)



    -- List

    local DimensionOptions = {
        ScrollerSpacing = 8,
        ScrollerSliderMarginVisible = 15,
        ScrollerSliderMarginHidden = 15,
    }

    OptionsUI.PANE_MAIN_MAIN_AREA_LIST_ROWSCROLLER = RowScroller.Create(OptionsUI.PANE_MAIN_MAIN_AREA_LIST)
    OptionsUI.PANE_MAIN_MAIN_AREA_LIST_ROWSCROLLER:SetSlider(Component.CreateWidget('<Slider name="Slider" dimensions="width:3; right:100%; top:0; bottom:100%"/>', OptionsUI.PANE_MAIN_MAIN_AREA_LIST))
    OptionsUI.PANE_MAIN_MAIN_AREA_LIST_ROWSCROLLER:SetSliderMargin(DimensionOptions.ScrollerSliderMarginVisible, DimensionOptions.ScrollerSliderMarginHidden)
    OptionsUI.PANE_MAIN_MAIN_AREA_LIST_ROWSCROLLER:SetSpacing(DimensionOptions.ScrollerSpacing)
    OptionsUI.PANE_MAIN_MAIN_AREA_LIST_ROWSCROLLER:ShowSlider('auto')
    OptionsUI.PANE_MAIN_MAIN_AREA_LIST_ROWSCROLLER:UpdateSize()


    

    --OptionsUI.PANE_MAIN_MAIN_AREA_LIST_CHILD_  


    -- Create layout for Second Pane
    OptionsUI.PANE_SECOND_LAYOUT = Component.CreateWidget("PaneLayoutMain", OptionsUI.PANE_SECOND)


end


  -- New Options bar widget
    function CreatePizzaBarEntry(pizza) -- from g_Pizzas

        -- Get reference
        local w_barEntry = Component.CreateWidget('OptionsPizzaBarEntry', OptionsUI.PANE_MAIN_MAIN_AREA_LIST)
        local w_barContainer = w_barEntry:GetChild("container")
        local w_barGroup = w_barContainer:GetChild("bar")
        local w_barHandle = w_barGroup:GetChild("bar_handle")
        local w_handleFocus = w_barHandle:GetChild("focus")
        local w_handleLabel = w_barHandle:GetChild("bar_handle_label")
        local w_handleInputIconGroup = w_barHandle:GetChild("bar_handle_input_icon")
        local w_barSlots = w_barGroup:GetChild("bar_slots")

        -- Set handle focus
        local KEYCATCHER = Component.CreateWidget([=[<KeyCatcher dimensions="left:0; right:1; top:0; bottom:1;"/>]=], Component.GetWidget("Window"))

        function OnKeyCatch(args)
            Popup_CancelQuestion()
            KEYCATCHER:StopListening()
            local pizza = args.widget:GetTag()
            local key = args.widget:GetKeyCode()
            local alt = args.widget:GetAlt()
            if key ~= 27 then                   -- 27 = Escape: Ignore the escape key
                ProcessKeyCatch(pizza, key, alt)
            else
                CancelKeyCatch()
            end
        end

        KEYCATCHER:BindEvent("OnKeyCatch", OnKeyCatch)

        function ProcessKeyCatch(pizzaKey, key, alt)
            Debug.Log("ProcessKeyCatch", pizzaKey, key, alt)

            local action = GetPizzaActivatorAction(pizzaKey)
            local setting = GetPizzaActivatorSetting(pizzaKey)
            g_KeySet_PizzaActivators:BindKey(action, key)
            Component.SaveSetting(setting, key)
            g_Pizzas[pizzaKey].barEntry.w_handleInputIcon:SetBind({keycode=key, alt=false}, true)
        end

        function CancelKeyCatch()
            Debug.Log("CancelKeyCatch")
            KEYCATCHER:StopListening()
        end

        w_handleFocus:BindEvent("OnMouseDown", function() Debug.Log("OnMouseDown")

                KEYCATCHER:ListenForKey()

                KEYCATCHER:SetTag(pizza.key)

                local c_BindingPopup = {
                    [1] = {
                        Label = Component.LookupText("DELETE"),
                        TintPlate = "#8E0909",
                        OnClick = function() ProcessKeyCatch(pizza.key, 0, false) end,
                        OnEnter = function() KEYCATCHER:StopListening() end,
                        OnLeave = function() KEYCATCHER:ListenForKey() end,
                    },
                    [2] = {
                        Label = Component.LookupText("CANCEL"),
                        TintPlate = "#9C9C9C",
                        OnClick = function() CancelKeyCatch() end,
                        OnEnter = function() KEYCATCHER:StopListening() end,
                        OnLeave = function() KEYCATCHER:ListenForKey() end,
                    },
                    OnEscape = 2,
                }

                c_BindingPopup.Text = Component.LookupText("KEYBINDER_ENTER_BINDING").."\n"..pizza.name
                Popup_ShowQuestion(c_BindingPopup)
                



                                end)
        w_handleFocus:BindEvent("OnMouseEnter", function(args)
            -- Do somethin here
            local group = args.widget:GetParent():GetParent()
            local barHandleSideGradient = group:GetChild("bar_handle_gradient_side")
            widgetInfo(barHandleSideGradient)
            local divDur = 2
            barHandleSideGradient:ParamTo("alpha", 1, divDur*.15)
        end)
        w_handleFocus:BindEvent("OnMouseLeave", function(args)
            -- Do somethin here
            local group = args.widget:GetParent():GetParent()
            local barHandleSideGradient = group:GetChild("bar_handle_gradient_side")
            local divDur = 2
            barHandleSideGradient:ParamTo("alpha", 0.3, divDur*.25)
        end)



        -- Set handle label
        w_handleLabel:SetText(tostring(pizza.name))
    
        -- Set handle input icon
        w_handleInputIcon = InputIcon.CreateVisual(w_handleInputIconGroup, "Bind")
        local previousKeyCode = g_KeySet_PizzaActivators:GetKeybind(GetPizzaActivatorAction(pizza.key)) or "blank"
        w_handleInputIcon:SetBind({keycode=previousKeyCode, alt=false}, true)

        -- Create slots
        local slotIcons = {}
        for i=1,4 do
            local slotIcon = CreateAbilityIcon(i, i, w_barSlots)
            slotIcons[i] = slotIcon

            if pizza.isCustom then
                SetupDropFocus(slotIcon.HOLDER, pizza.key, i)
                SetupDropTarget(slotIcon.HOLDER, pizza.key, i)
            end
            Debug.Table("Calling UpdatePizzaBarSlotIcon", {pizzaKey = pizza.key, i = i})
            UpdatePizzaBarSlotIcon(pizza.key, i, slotIcon)
        end

        local abilityFirstIndexHack = (pizza.key == "AbilityPizza" and 1 or nil)
        OptionsUI.PANE_MAIN_MAIN_AREA_LIST_ROWSCROLLER:AddRow(w_barContainer, abilityFirstIndexHack)
    
        return {
            w_barEntry = w_barEntry,
            w_barGroup = w_barGroup,
            w_barHandle = w_barHandle,
            w_handleLabel = w_handleLabel,
            w_handleInputIcon = w_handleInputIcon,
            w_handleInputIconGroup = w_handleInputIconGroup,
            w_barSlots = w_barSlots,
            slotIcons = slotIcons,
        }

       

    end


    function GetPizzaAbilityIconWidget(pizzaIndex, slotIndex) 
        local pizza = g_Pizzas[pizzaIndex]
        local slotIcon = pizza.barEntry.slotIcons[slotIndex]
        local w_ICON = slotIcon.ICONHOLDER:GetChild("icon")
        return w_ICON
    end

    function CreateAbilityIcon(slotIndex, pizzaIndex, PARENT)
        local icon = {ICON=Component.CreateWidget("AbilityIcon", PARENT)};
        
        icon.HOLDER = icon.ICON:GetChild("holder");
        icon.ICONHOLDER = icon.HOLDER:GetChild("icons");
        icon.NAMEHOLDER = icon.HOLDER:GetChild("abilityname_holder");
        icon.FOCUS = icon.HOLDER:GetChild("focus");
        icon.DROPTARGET = icon.FOCUS:GetChild("droptarget");
        icon.slotIndex = slotIndex;
        icon.pizzaIndex = pizzaIndex;
        icon.CONSUMABLE_COUNTER = icon.HOLDER:GetChild("consumable_counter");
        icon.SELECTION = icon.ICONHOLDER:GetChild("selection");
        icon.COOLDOWN_COUNTER = icon.ICONHOLDER:GetChild("cooldown_counter");
        icon.STATE_COUNTER = icon.ICONHOLDER:GetChild("state_counter");
        icon.COOLDOWN_ARC = icon.ICONHOLDER:GetChild("cooldown");
        icon.COOLDOWN_BP = icon.ICONHOLDER:GetChild("cooldown_bp");
        icon.HKM_ARC_BP = icon.ICONHOLDER:GetChild("hkm_arc_bp");
        icon.HKM_FAIL_BP = icon.ICONHOLDER:GetChild("hkm_fail_bp");
        icon.HKM_ARC = icon.ICONHOLDER:GetChild("hkm_arc");
        icon.HKM_GLOW = icon.ICONHOLDER:GetChild("hkm_glow");
        icon.SCANLINE = icon.ICONHOLDER:GetChild("scanline");
        icon.ACTIVATION = icon.ICONHOLDER:GetChild("activation");
        icon.ACTIVATION2 = icon.ICONHOLDER:GetChild("activation2");
        icon.ITEM_CIRCLE = icon.ICONHOLDER:GetChild("Circle");
        icon.AHB            = icon.HOLDER:GetChild("attractHookBack");
        icon.AHF            = icon.HOLDER:GetChild("attractHookFront");
        icon.LOCK           = icon.HOLDER:GetChild("lock_info")
        icon.DEPLOY_LIST    = icon.HOLDER:GetChild("deployable_list")

        icon.LOCK:GetChild("lock_text"):SetText("LOCKED")
        
        --if (not IsConsumableSlot(globalIndex)) then
        --    icon.ITEM_CIRCLE:Show(false);
        --end
        
        icon.hideables = {};
        table.insert(icon.hideables, icon.ICONHOLDER);
        table.insert(icon.hideables, icon.NAMEHOLDER);
        table.insert(icon.hideables, icon.CONSUMABLE_COUNTER);
        table.insert(icon.hideables, icon.FAILURE);
        
        icon.hkmOnlyParts = {};
        table.insert(icon.hkmOnlyParts, icon.HKM_ARC_BP);
        table.insert(icon.hkmOnlyParts, icon.HKM_FAIL_BP);
        table.insert(icon.hkmOnlyParts, icon.HKM_ARC);
        table.insert(icon.hkmOnlyParts, icon.HKM_GLOW);
        
        --SetupAbilityIconFocus(icon, globalIndex);
        --SetupAbilityIconDropTarget(icon, globalIndex);
        
        --parent.ICONS[slotIndex] = icon;
        --w_Slots[globalIndex] = icon;
        local c_AbiIconOffset = -85
        local c_AbiIconIncrement = 100
        local left = c_AbiIconOffset + slotIndex * c_AbiIconIncrement;
        icon.ICON:SetDims("left:"..tostring(left));


    --[[

        local keybindGroup = icon.HOLDER:GetChild("keybind_holder");
        local shortcut = {keycode=KEYCODE_GAMEPAD_X}
        if (shortcut) then
            keybindGroup:Show(true);
            local keybind = keybindGroup:GetChild("keybind");
            keybind:SetText(System.GetKeycodeString(shortcut.keycode));
        else
            keybindGroup:Show(false);
        end
    --]]

        return icon
    end

    function SetupOptionsUIBarList()
        -- Create bar entries
        for pizzaKey, pizza in pairs(g_Pizzas) do
            pizza.barEntry = CreatePizzaBarEntry(pizza)
            Debug.Log("barEntry for " .. pizzaKey .. " has been created")
        end
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
    if not OptionsUI.haveSetupBars then
        SetupOptionsUIBarList()
        OptionsUI.haveSetupBars = true
    end
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






function UpdatePizzaSlots(pizza)

    if pizza.isCustom then
        assert(#pizza.slots == 4, "this custom pizza doesnt have 4 slots :s")
        for slotIndex, slotData in ipairs(pizza.slots) do
            if not slotData.slotType then
                slotData.slotType = "empty"
            elseif slotData.slotType == "calldown" then
                local itemInfo = Game.GetItemInfoByType(slotData.itemTypeId)
                if slotData.itemTypeId == 0 or not itemInfo or not next(itemInfo) then
                    slotData.slotType = "empty"
                    slotData.itemTypeId = nil
                    slotData.iconId = nil
                    slotData.techId = nil
                else
                    slotData.iconId = itemInfo.web_icon_id
                    slotData.techId = slotData.itemTypeId
                end
            end
        end
    else

        if pizza.activationType == "ability_override" then

            -- Get current abilities
            local abilities = Player.GetAbilities().slotted

            if not abilities or not next(abilities) then
                Debug.Warn("Could not get abilities")
            else

                for slotIndex, slotData in ipairs(pizza.slots) do

                    local ability = abilities[slotIndex]
                    
                    if not ability or not next(ability) then
                        slotData.slotType = "empty"
                        slotData.iconId = nil
                    else
                        local abilityInfo = Player.GetAbilityInfo(ability.abilityId)
                        slotData.slotType = "ability"
                        slotData.iconId = abilityInfo.iconId
                    end

                end
            end

        end

    end

end

-- Practically UpdatePizzas
function UpdateAbilities(args)
    Debug.Divider()
    Debug.Log("UpdateAbilities Begin")
    Debug.Event(args)

    -- Clear exisiting data
    -- err?


    -- New method
    Debug.Log("It's pizza time!")
    for pizzaKey, pizza in pairs(g_Pizzas) do

        Debug.Log("Updating " .. pizzaKey)

        UpdatePizzaSlots(pizza)

        pizza.w_PIZZA = {}
        pizza.w_PIZZA = CreatePizza(w_PIZZA_CONTAINER, pizza.slots)
        pizza.w_PIZZA:Show(false)
        
        if pizza.barEntry then
            for i, slot in ipairs(pizza.slots) do
                UpdatePizzaBarSlotIcon(pizzaKey, i, pizza.barEntry.slotIcons[i])
            end
        end

    end 

    -- Update UI


    -- Chill hack :D
    w_PIZZA_Abilities = g_Pizzas["AbilityPizza"].w_PIZZA

    -- Dunno if this is neccessary but w/e
    w_PIZZA_CONTAINER:Show(true)

    Debug.Log("UpdateAbilities Complete")
    Debug.Divider()
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

        g_CurrentlyActiveCalldownPizza = g_GetPizzaByKeybindAction[args.name]
        Debug.Log("g_CurrentlyActiveCalldownPizza: ", g_CurrentlyActiveCalldownPizza)
        g_IsCalldownPizzaActive = true

        g_Pizzas[g_CurrentlyActiveCalldownPizza].w_PIZZA:SetParam("alpha", 0, 0.1)
        g_Pizzas[g_CurrentlyActiveCalldownPizza].w_PIZZA:QueueParam("alpha", 1, 0.25, "ease-in")
        g_Pizzas[g_CurrentlyActiveCalldownPizza].w_PIZZA:Show(true)
        w_PIZZA_CONTAINER:Show(true)

    end
end

function DeactivateCalldownPizza(args)
    Debug.Table("DeactivateCalldownPizza", args)


    if g_IsCalldownPizzaActive then

        Debug.Log("Closing calldown pizza")

        if args.keycode then

            -- This is it, do the thing!
            Debug.Log("We have a keycode, check if its one of the buttons")
            Debug.Log("Our keycode is " .. tostring(args.keycode) .. " ( " .. System.GetKeycodeString(args.keycode) .. ") ")

            local slotIndex = PIZZA_KEYBINDINGS_KEYCODE_INDEX[args.keycode]

            if slotIndex then

                local techId = 0
                local slotData = g_Pizzas[g_CurrentlyActiveCalldownPizza].slots[slotIndex]
                if slotData.slotType == "calldown" then
                    techId = slotData.techId
                    Debug.Log("Found match! Tech id is " .. tostring(techId))
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
                            -- TODO: Fix this shit
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

            else

                Debug.Log("This keycode wasnt one of the calldown buttons, so do nothing")

            end

        end



        g_Pizzas[g_CurrentlyActiveCalldownPizza].w_PIZZA:Show(false)
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
            if segmentData[i].type ~= "empty" then
                SEGMENT:GetChild("icon"):SetIcon(segmentData[i].iconId)
            else
                SEGMENT:GetChild("icon"):ClearIcon()
            end

            if segmentData[i].type ~= "empty" then
                local inputIcon = InputIcon.CreateVisual(SEGMENT:GetChild("inputIconGroup"), "Bind")
                local keyCode = ABILITY_PIZZA_KEYBINDINGS_ORDER[i]
                inputIcon:SetBind({keycode=keyCode, alt=false}, true)
            end

        end
    end

    Debug.Log("Pizza created")

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





function GetPizzaSegment(pizzaKey, segmentIndex)
    --Debug.Table("GetPizzaSegment", {pizzaKey = pizzaKey, segmentIndex = segmentIndex})
    local pizza = g_Pizzas[pizzaKey]
    assert(pizza, "who ate my pizza D:")
    --Debug.Table("pizza", pizza)
    local segment = pizza.slots[segmentIndex]
    --Debug.Table("GetPizzaSegment returnining segment", segment)
    return segment
end


function GetDragInfoForPizzaSegment(pizzaKey, segmentIndex)
    local slot = GetPizzaSegment(pizzaKey, segmentIndex)
    assert(slot.slotType == "calldown", "dont know how to get drag info for this slot type (" .. tostring(slot.slotType) .. ")")
    return tostring({pizza = pizzaKey, index = segmentIndex, itemSdbId = slot.itemTypeId, from = DRAG_ORIGIN_CU})
end

function PizzaSegmentEmpty(pizzaKey, segmentIndex)
    --Debug.Table("PizzaSegmentEmpty", {pizzaKey = pizzaKey, segmentIndex = segmentIndex})
    local segment = GetPizzaSegment(pizzaKey, segmentIndex)
    return (segment.slotType == "empty")
end

function SetupDropFocus(w, pizzaKey, segmentIndex)
    local dropFocus = w:GetChild("focus")
    dropFocus:BindEvent("OnMouseDown", function()
        if (not PizzaSegmentEmpty(pizzaKey, segmentIndex)) then
            Component.BeginDragDrop("item_sdb_id", GetDragInfoForPizzaSegment(pizzaKey, segmentIndex), nil)
        end
    end)
    dropFocus:SetCursor("sys_hand");
end


function SetupDropTarget(w, pizzaKey, segmentIndex)
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
                
                SwapPizzaSegment(dropInfo.pizza, dropInfo.index, segmentIndex, pizzaKey)

            -- From actionbar
            elseif dropInfo.from == DRAG_ORIGIN_ACTIONBAR then
                Debug.Log("Drop from actionbar!")
                InsertPizzaSegment(pizzaKey, dropInfo.itemSdbId, segmentIndex)
            
            -- From unknown!
            else
                Debug.Warn("Something was dropped into a droptarget from an unknown source:", dropInfo.from)
                InsertSegment(dropInfo.itemSdbId, pizzaKey, segmentIndex)
            end
        end

        -- OnDragLeave
        local widget = args.widget
        Debug.Table("OnDragLeave Widget Info", widgetInfo(widget))
        local stillArt = widget:GetParent():GetParent():GetChild("iconBackground")
        stillArt:SetParam("tint", "#000000")
        -- -----------

        end);

    -- Use args.widget in these :D
    dropTarget:BindEvent("OnDragEnter", function(args)
                local widget = args.widget
                
                widgetInfo(widget)

                local stillArt = widget:GetParent():GetParent():GetChild("iconBackground")
                widgetInfo(stillArt)

                stillArt:SetParam("tint", "#00ff00")

        end);
    dropTarget:BindEvent("OnDragLeave", function(args)
                local widget = args.widget
                local stillArt = widget:GetParent():GetParent():GetChild("iconBackground")
                stillArt:SetParam("tint", "#000000")
        end);
end



--[[
function GetDragInfoForSlot(index)
    local dragData = {};
    
    dragData = GetDragDataForItemSlot(index);
    
    return dragData;
end


function GetDragDataForItemSlot(index)
    -- for dragging consumable slots we need the item sdbid, index, and if it's local (to swap rather than replace)
    return tostring({index = index, itemSdbId = g_abilityInfo[index].itemInfo.itemTypeId, from = c_ActionbarDragOrigin});
end
--]]


function SwapPizzaSegment(fromPizza, fromSegment, toSegment, toPizza)

    Debug.Table("SwapPizzaSegment", {fromPizza = fromPizza, fromSegment = fromSegment, toSegment = toSegment, toPizza = toPizza})

    if (fromSegment and toSegment) then
        local item1 = GetPizzaSegment(fromPizza, fromSegment).itemTypeId
        local item2 = GetPizzaSegment(toPizza, toSegment).itemTypeId


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

function InsertPizzaSegment(pizzaKey, itemTypeId, segmentIndex)
    Debug.Log("InsertPizzaSegment")

    -- Get segment
    --local segment = GetPizzaSegment(pizzaKey, segmentIndex)
    
    -- Update pizzas data
    local slotData = g_Pizzas[pizzaKey].slots[segmentIndex]
    Debug.Table("pre update slotData", slotData)

    slotData.itemTypeId = itemTypeId
    
    if tonumber(itemTypeId) == 0 then -- :s not sure about types here
        slotData.slotType = "empty"
    else
        slotData.slotType = "calldown"
    end

    -- Save
    g_Pizzas[pizzaKey].slots[segmentIndex] = slotData
    Debug.Table("post update slotData", slotData)

    -- Trigger pizzas to be updated
    UpdateAbilities({event="InsertPizzaSegment"})
        
    -- Update OptionsUI icon
    UpdatePizzaBarSlotIcon(pizzaKey, segmentIndex)
end

function EatPizzaSegment(pizzaKey, segmentIndex)
    Debug.Log("EatPizzaSegment")
    InsertPizzaSegment(pizzaKey, 0, segmentIndex)
end


function UpdatePizzaBarSlotIcon(pizzaKey, segmentIndex, slotIcon)

    if not PizzaSegmentEmpty(pizzaKey, segmentIndex) then
        local segment = GetPizzaSegment(pizzaKey, segmentIndex)

        if not segment.iconId then
            Debug.Warn("For some reason UpdatePizzaBarSlotIcon does not have all segment data", {pizzaKey=pizzaKey, segmentIndex=segmentIndex, segment=segment})
        end
        local iconId = segment.iconId

        w_ICON = slotIcon and slotIcon.ICONHOLDER:GetChild("icon") or GetPizzaAbilityIconWidget(pizzaKey, segmentIndex)
        w_ICON:SetIcon(iconId)

        -- fancy extras for the abilities
        if segment.slotType == "ability" then
            slotIcon.ITEM_CIRCLE:Show(false)


            slotIcon.LOCK:SetParam("alpha", 1)
            slotIcon.ICONHOLDER:SetParam("alpha", 0.4)
            
            local c_HintFadeDur = 0.5
            slotIcon.LOCK:GetChild("lock"):ParamTo("alpha", .5, c_HintFadeDur, "smooth")
            slotIcon.LOCK:GetChild("lock"):MoveTo("center-y:35%", c_HintFadeDur, "smooth")
            slotIcon.LOCK:GetChild("lock_text"):ParamTo("alpha", .8, c_HintFadeDur+.1, "smooth")

        end

    else
        w_ICON = slotIcon and slotIcon.ICONHOLDER:GetChild("icon") or GetPizzaAbilityIconWidget(pizzaKey, segmentIndex)
        w_ICON:ClearIcon()
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









