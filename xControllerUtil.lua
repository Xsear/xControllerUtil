
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

-- SIN Notification Timestamp
g_NotificationsSINTriggerTimestamp = nil




-- ------------------------------------------
-- INTERFACE OPTIONS
-- ------------------------------------------



-- ------------------------------------------
-- LOAD
-- ------------------------------------------

function OnComponentLoad(args)
    -- Debug
    Debug.EnableLogging(true)

    -- Pizza
    Pizza_OnComponentLoad()

    -- Options UI
    OptionsUI_OnComponentLoad()

    -- Slash
    LIB_SLASH.BindCallback({slash_list="xcontrollerutil,xconutil,xcu,cu", description="Controller Utilities", func=OnSlashGeneral})
    LIB_SLASH.BindCallback({slash_list="redetect,gamepad", description="Attempt to detect active gamepad", func=OnSlashGamepad})
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
        Pizza_DeactivationTrigger(args)

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
    Pizza_UpdateAll(args)
    if not OptionsUI.haveSetupBars then
        SetupOptionsUIBarList()
        OptionsUI.haveSetupBars = true
    end
end

function OnBattleframeChanged(args)
    Pizza_UpdateAll(args)
end

function OnAbilitiesChanged(args) -- Fired when you swap abilities on the 3dactionbar (without changing slot)
    Pizza_UpdateAll(args)
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
        Pizza_DeactivationTrigger(args)
    end

end

function OnAbilityFailed(args)
    Pizza_DeactivationTrigger(args)
end

function OnPlaceCalldown(args)
    Pizza_DeactivationTrigger(args)
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









