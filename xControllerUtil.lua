
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

-- Addon
require "./Pizza"
require "./OptionsUI"

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

g_ExtraPizzaIndex = 1

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


function RegisterPizzaActivator(pizzaKey)
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

function IsKeybindActionAlreadyRegistered(action)
     --g_KeySet_PizzaActivators:GetKeybinds(action) == nil -- GetPizzaActivatorAction(pizza.key) -- Doesn't work because stupid api function is missing a parameter
     local export = g_KeySet_PizzaActivators:ExportKeybinds() -- Looksl ike this doesnt do anything to the keybinds, so should be safe
     return export[action] ~= nil
end

function SetupUserKeybinds()

    -- g_KeySet_PizzaActivators
    -- This keyset has one action for each pizza it can activate
    g_KeySet_PizzaActivators = UserKeybinds.Create()
        
        -- Generate from data :D
        for pizzaKey, pizza in pairs(g_Pizzas) do
            RegisterPizzaActivator(pizzaKey)
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



-- Arkii did the maths <3
function GetPointOnCricle(orginX, orignY, radius, angle)
    local res = { x = 0, y = 0 }
    res.x = (radius * math.cos(angle * math.pi / 180)) + orginX
    res.y = (radius * math.sin(angle * math.pi / 180)) + orignY

    return res
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









