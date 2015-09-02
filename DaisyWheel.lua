
-- ------------------------------------------
-- Daisy Wheel
--   by: Xsear
-- ------------------------------------------



g_KeySet_Daisy_DPAD = nil
g_KeySet_Daisy_XYAB = nil
g_DaisyState = {
    active = false,
    dpad = {
        left = false,
        up = false,
        right = false,
        down = false,
    },
}
g_DaisyOverridenKeybinds = {}
g_DaisyPausedOppositeAxis = false
g_DaisyPreviouslyTyped = ""

w_DaisyWheelTableWidgets = {}
w_DaisyDPADTextWidgets = {}


local FRAME = Component.GetFrame("DaisyWheel")
FRAME:Show(false)
local DAISY_CONTAINER = Component.GetWidget("DaisyContainer")

local CB2_DaisyDPADInput = {
    ["horizontal"] = nil,
    ["vertical"] = nil,
}

local daisyActionToKey = {
    ["daisy_dpad_left"] = "left",
    ["daisy_dpad_up"] = "up",
    ["daisy_dpad_right"] = "right",
    ["daisy_dpad_down"] = "down",
}

local daisyKeyToAxis = {
    ["up"] = "vertical",
    ["down"] = "vertical",
    ["right"] = "horizontal",
    ["left"] = "horizontal",
}

local daisyGetOppositeAxis = {
    ["vertical"] = "horizontal",
    ["horizontal"] = "vertical"
}

local alphabetTable = {
    ["up"]         = {"a", "b", "c", "d"},
    ["right-up"]   = {"e", "f", "g", "h"},
    ["right"]      = {"i", "j", "k", "l"},
    ["right-down"] = {"m", "n", "o", "p"},
    ["down"]       = {"q", "r", "s", "t"},
    ["left-down"]  = {"u", "v", "w", "x"},
    ["left"]       = {"y", "z", ",", "."},
    ["left-up"]    = {":", "/", "@", "-"},
}

local alphabetTableKeycodes = {
    ["up"]         = {65, 66, 67, 68},
    ["right-up"]   = {69, 70, 71, 72},
    ["right"]      = {73, 74, 75, 76},
    ["right-down"] = {77, 78, 79, 80},
    ["down"]       = {81, 82, 83, 84},
    ["left-down"]  = {85, 86, 87, 88},
    ["left"]       = {89, 90, 188, 190},
    ["left-up"]    = {185, 191, 160, 189}, -- uncertanties here
}


local alphabetTableIndex = {
    [1] = "up",
    [2] = "right-up",
    [3] = "right",
    [4] = "right-down",
    [5] = "down",
    [6] = "left-down",
    [7] = "left",
    [8] = "left-up",
}


function DaisyWheel_UserKeybinds()
    g_KeySet_Daisy_DPAD = UserKeybinds.Create()
        g_KeySet_Daisy_DPAD:RegisterAction("daisy_dpad_left", DaisyDPADInput, "toggle")
        g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_left", KEYCODE_GAMEPAD_DPAD_LEFT)
        g_KeySet_Daisy_DPAD:RegisterAction("daisy_dpad_up", DaisyDPADInput, "toggle")
        g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_up", KEYCODE_GAMEPAD_DPAD_UP)
        g_KeySet_Daisy_DPAD:RegisterAction("daisy_dpad_right", DaisyDPADInput, "toggle")
        g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_right", KEYCODE_GAMEPAD_DPAD_RIGHT)
        g_KeySet_Daisy_DPAD:RegisterAction("daisy_dpad_down", DaisyDPADInput, "toggle")
        g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_down", KEYCODE_GAMEPAD_DPAD_DOWN)
        g_KeySet_Daisy_DPAD:Activate(false)

    g_KeySet_Daisy_XYAB = UserKeybinds.Create()
        g_KeySet_Daisy_XYAB:RegisterAction("daisy_xyab", DaisyXYABInput)
        for i, keyCode in ipairs(ABILITY_PIZZA_KEYBINDINGS_ORDER) do
            g_KeySet_Daisy_XYAB:BindKey("daisy_xyab", keyCode, i)
        end
        g_KeySet_Daisy_XYAB:BindKey("daisy_xyab", KEYCODE_GAMEPAD_RIGHT_BUMPER, 5)
        --g_KeySet_Daisy_XYAB:BindKey("daisy_xyab", KEYCODE_GAMEPAD_START, 6)

        g_KeySet_Daisy_XYAB:Activate(false)
end


function DaisyWheel_OnComponentLoad()

    w_DaisyWheelTableWidgets = {}

    local masterCont = DAISY_CONTAINER

    local numberOfTables = 8
    local perTablePrecent = (100/numberOfTables)

    for i=1,8 do -- #alphabetTable (but that wont work since pairs)
        local tableAngle = 360 * (perTablePrecent*i)/100 - 135
        local tablePoint = GetPointOnCricle(400, 200, (RT_SEG_WIDTH*3)*0.30, tableAngle)


        local cont = Component.CreateWidget(unicode.format('<Group dimensions="width:160; height:160; left:%i; top:%i;"><StillArt name="Background" dimensions="dock:fill" style="texture:colors; region:white; tint:#00eebb; alpha:0.4;"/></Group>', tablePoint.x-20, tablePoint.y-20), masterCont)
        local characterTable = alphabetTable[alphabetTableIndex[i]]

        local numberOfSegments = 4 -- # characters per segment
        local perSegPrecent = (100/numberOfSegments)

        -- Inner Alphabet Character Segments
        for j=1,numberOfSegments do
            local angle = 360 * (perSegPrecent*j)/100 + 90
            local point = GetPointOnCricle(90, 80, (RT_SEG_WIDTH/2)*0.30, angle)
            local SEGMENT = Component.CreateWidget(unicode.format('<Group blueprint="KeyPizzaSegment" dimensions="width:20; height:20; left:%i; top:%i;"></Group>', point.x-20, point.y-20), cont)
            
            if (characterTable[j]) then

                local inputIcon = InputIcon.CreateVisual(SEGMENT:GetChild("inputIconGroup"), "Bind")
                local keyCode = alphabetTableKeycodes[alphabetTableIndex[i]][j]
                inputIcon:SetBind({keycode=keyCode, alt=false}, true)

            end
        end

        w_DaisyWheelTableWidgets[alphabetTableIndex[i]] = cont

    end

end


function OnSlashDaisy(args)
    Debug.Log("OnSlashDaisy")
    if DaisyWheel_IsActive() then
        DaisyWheel_Deactivate()
    else
        DaisyWheel_Activate()
    end
end

function DaisyWheel_IsActive()
    return g_DaisyState.active
end

function DaisyWheel_Activate()
    Debug.Log("DaisyWheel_Activate")
    if not g_DaisyState.active then
        -- Ensure cursor mode so that Chat displays
        Component.SetInputMode("cursor")
        Debug.Log("Cursor mode engaged")

        -- Start DPAD State Cycle
        CB2_DaisyStateCycle = Callback2.CreateCycle(DaisyStateCycle)
        CB2_DaisyStateCycle:Run(0.25)

        -- Activate keysets
        g_KeySet_Daisy_DPAD:Activate(true)
        g_KeySet_Daisy_XYAB:Activate(true)
        Debug.Log("Daisy Keysets Enabled")

        -- Override Keybinds: For the chat submit button
            Debug.Log("Overriding keys")
            -- Save overridden keys
            g_DaisyOverridenKeybinds = MassFreeKeycodes({keycodes={[KEYCODE_GAMEPAD_START] = true}})

            -- Bind submit
            System.BindKey("Social", "OpenChat", KEYCODE_GAMEPAD_START, false, 3)
            System.ApplyKeyBindings()
            Debug.Log("Submit bound")

        -- Display Daisy Wheel
        FRAME:Show(true)

        -- Set state to active
        g_DaisyState.active = true
    else
        Debug.Warn("DaisyWheel_Activate called but DaisyWheel was already active.")
    end
end

function DaisyWheel_Deactivate()
    Debug.Log("DaisyWheel_Deactivate")
    if g_DaisyState.active then
        -- Reset input mode
        Component.SetInputMode(nil)
        Debug.Log("Cursor mode disengaged")

        -- Stop DPAD State Cycle
        if CB2_DaisyStateCycle then
            CB2_DaisyStateCycle:Release()
            CB2_DaisyStateCycle = nil
        end

        -- Deactivate keysets
        g_KeySet_Daisy_DPAD:Activate(false)
        g_KeySet_Daisy_XYAB:Activate(false)
        Debug.Log("Daisy Keysets Disabled")

        
        -- Restore Keybinds: For the chat submit button
            -- Unbind submit
            System.BindKey("Social", "OpenChat", nil, false, 3)
            System.ApplyKeyBindings()
            Debug.Log("Submit unbound")

            -- Restore keycodes
            Debug.Log("Restoring keys")
            MassRestoreKeycodes({conflictingKeybinds=g_DaisyOverridenKeybinds})
            g_DaisyOverridenKeybinds = nil
            Debug.Log("Keys restored")

        -- Hide Daisy Wheel
        FRAME:Show(false)

        -- Set state to not active
        g_DaisyState.active = false
    else
        Debug.Warn("DaisyWheel_Deactivate called but DaisyWheel was not active.")
    end
end

function DaisyStateCycle()
    Debug.Log("DaisyStateCycle")

    local previousDirection = g_DaisyState.direction

    g_DaisyState.direction = DecideDaisyDirection()

    if g_DaisyState.direction ~= previousDirection then
        Output("Daisy Direction: " .. g_DaisyState.direction)
    end

    UpdateDaisyDpadText()
    UpdateDaisyWidgetVisibility()
end


function UpdateDaisyDpadText()
    if not next(w_DaisyDPADTextWidgets) then
        local temp_daisyCount = 0
        for key, value in pairs(g_DaisyState.dpad) do
            local text = Component.CreateWidget('<Text dimensions="height:100; width:20%; top:200+'..tostring((30*temp_daisyCount))..'" />', FRAME)
            temp_daisyCount = temp_daisyCount + 1
            w_DaisyDPADTextWidgets[key] = text 
        end
    end

    for key, text in pairs(w_DaisyDPADTextWidgets) do
        local value = g_DaisyState.dpad[key]
        text:SetText(key .. " : " .. tostring(value))
        if value then
            text:SetTextColor("#00ff00")
        else
            text:SetTextColor("#ff0000")
        end
        
    end
end

function UpdateDaisyWidgetVisibility()
    for key, widget in pairs(w_DaisyWheelTableWidgets) do
        if key == g_DaisyState.direction then
            widget:Show(true)
        else
            widget:Show(false)
        end
    end
end

function DecideDaisyDirection()
    
    local pressedKeys = {}
    
    for key, pressed in pairs(g_DaisyState.dpad) do
        if pressed then table.insert(pressedKeys, key) end
    end

    local direction = "none"

    if #pressedKeys == 1 then
        --Output(" ***** Daisy Direction: " .. pressedKeys[1])

        direction = pressedKeys[1]

    elseif #pressedKeys == 2 then

        --Output(" ***** Daisy Direction: " .. pressedKeys[1] .. " + " .. pressedKeys[2])

        local acceptedCombos = {
            ["left-down"] = {"left", "down"},
            ["right-down"] = {"right", "down"},
            ["left-up"] = {"left", "up"},
            ["right-up"] = {"right", "up"},
        }


        for diag, comboKeys in pairs(acceptedCombos) do

            local matches = 0
            for i, key in ipairs(pressedKeys) do
                for j, diagKey in ipairs(comboKeys) do
                    if key == diagKey then
                        matches = matches + 1
                    end
                end
            end
            if matches == 2 then
                direction = diag
                break
            end
        end

    else
        --Output(" ***** Daisy Direction: none")

    end

    return direction

end


function DaisyDPADInput(args)
    Debug.Log("DaisyDPADInput " .. args.name)
    --Debug.Event(args)

    assert(g_DaisyState)
    assert(g_DaisyState.active)

    local action = args.name
    local key = daisyActionToKey[action]
    local axis = daisyKeyToAxis[key]
    local oppositeAxis = daisyGetOppositeAxis[axis]

    -- Press
    if args.is_pressed then

        -- Immidieately set the state
        g_DaisyState.dpad[key] = true
        Output("Pressed " .. args.name)

        -- Now is the time to try and catch diagonal input.
        -- If there is a callback pending for the opposite axis of this key, then we want to hold that callback until we let go of this key, so that the diagonal state can be preserved.
        if CB2_DaisyDPADInput[oppositeAxis] ~= nil then
            Output("Pausing" .. oppositeAxis .. " axis callback while " .. key .. " is pressed")
            CB2_DaisyDPADInput[oppositeAxis]:Pause()
            g_DaisyPausedOppositeAxis = true
        end

    -- Release
    elseif args.is_released then
        
        -- We need some flex in order to get diagonal input, so we don't set the state to false right away.
        --We will use a callback specific to this axis to do so later.
        Output("Released " .. args.name)

        -- If there is already a callback pending for this axis, we execute it right away so that it isn't lost when we create one for this key.
        if CB2_DaisyDPADInput[axis] ~= nil then
            Output("Cancelling " .. axis .. " axis callback")
            CB2_DaisyDPADInput[axis]:Execute()
            CB2_DaisyDPADInput[axis] = nil
        end 

        -- We create an axis specific callback to clear this input
        CB2_DaisyDPADInput[axis] = Callback2.Create()
        CB2_DaisyDPADInput[axis]:Bind(function(args)
            g_DaisyState.dpad[args.key] = false
            CB2_DaisyDPADInput[args.axis]:Release()
            CB2_DaisyDPADInput[args.axis] = nil
            Output("Reset " .. args.key)
        end, {key=key, axis=axis})
        CB2_DaisyDPADInput[axis]:Schedule(0.25)

        -- Now, if when we pressed this key, we paused the opposite axis, we need to undo that
        if g_DaisyPausedOppositeAxis then
            CB2_DaisyDPADInput[oppositeAxis]:Unpause()
            g_DaisyPausedOppositeAxis = false
        end

    end

end



function DaisyXYABInput(args)
    Debug.Log("DaisyXYABInput")
    Debug.Event(args)

    assert(g_DaisyState)
    assert(g_DaisyState.active)

    if args.keycode == KEYCODE_GAMEPAD_RIGHT_BUMPER then

        if g_DaisyPreviouslyTyped ~= "" then
            g_DaisyPreviouslyTyped = unicode.sub(g_DaisyPreviouslyTyped, 1, -2)
            Component.GenerateEvent("MY_BEGIN_CHAT", {text = g_DaisyPreviouslyTyped})
        else
            Output("Nothing to remove!")
        end
    elseif args.keycode == KEYCODE_GAMEPAD_BACK then -- Todo: Bind this or it wont work
        -- Exit Daisy mode?
    else

        if args.is_pressed then
            if g_DaisyState.direction == "none" then
                Output("daisy xyab but no direction")
            else
                local characterTable = alphabetTable[g_DaisyState.direction]

                local character = characterTable[PIZZA_KEYBINDINGS_KEYCODE_INDEX[args.keycode]]

                g_DaisyPreviouslyTyped = g_DaisyPreviouslyTyped .. character
                ChatLib.AddTextToChatInput({text = character})
            end
        end
    end
 end




function MassFreeKeycodes(args)
    Debug.Table("MassFreeKeycodes", args)

    --[[

        args.keycodes = {
            [<keycode>] = true,
        }


    --]]


    -- Get all keybinds
    Debug.Log("Getting all keybinds")
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

    -- Identify all keybinds that conflict
    Debug.Log("Identifying conflicting keybinds")
    local conflictingKeybinds = {}
    for category, actions in pairs(allKeybinds) do
        for action, slots in pairs(actions) do
            for i, bind in ipairs(slots) do
                if args.keycodes[bind.keycode] then
                    local conflict = {category=category, action=action, index=i, keycode=bind.keycode}
                    table.insert(conflictingKeybinds, conflict)
                end
            end
        end
    end

    -- Debugers are safe!~
    Debug.Table("Let's hope we don't error because if we do we're gonna lose these conflicting keybinds: ", conflictingKeybinds)

    -- Now lets wipe those keybinds
    Debug.Log("Unbinding conflicting keybinds")
    for i, conflict in ipairs(conflictingKeybinds) do
        Debug.Log("Unbinding ", conflict.category, " : ", conflict.action, " : ", conflict.index)
        System.BindKey(conflict.category, conflict.action, 0, false, conflict.index) -- false here means the bind is without the modifier key pressed
    end

    Debug.Log("Applying the changes, no turning back now!")
    System.ApplyKeyBindings()

    Debug.Log("Returning conflicting keybinds, keep them safe")
    return conflictingKeybinds
end

function MassRestoreKeycodes(args)
    --[[
        args.conflictingKeybinds -- from MassFreeKeycodes
    --]]

    Debug.Table("MassRestoreKeycodes", args)

    Debug.Log("Restoring conflicting keybinds")
    for i, conflict in ipairs(args.conflictingKeybinds) do
        System.BindKey(conflict.category, conflict.action, conflict.keycode, false, conflict.index)
    end

    -- We did good didn't we? Akanari sou na!
    Debug.Log("Applying the restored keybinds, hope you're doing awesome :)")
    System.ApplyKeyBindings()
end

