
-- ------------------------------------------
-- Daisy Wheel
--   by: Xsear
-- ------------------------------------------

require 'lib/lib_NavWheel'
require 'lib/lib_ContextWheel'

g_KeySet_Daisy_DPAD = nil
g_KeySet_Daisy_XYAB = nil
g_DaisyState = {
    active = false,
    mode = "default",
    modifiers = {
        caps = false,
        numbers = false
    },
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
local DAISY_INPUT_CONTAINER = nil
local DAISY_INPUT_CHANNEL = nil
local DAISY_INPUT = nil


C_ChatlineMaxCharLength = 255
local c_ChannelPadding = 5

local bp_InputBoxGroup =
    [[<Group dimensions="left:25%; right:75%-5; bottom:60%; height:20;">
        <Border dimensions="center-x:50%; center-y:50%; width:100%-2; height:100%-2" class="ButtonSolid" style="tint:#000000; alpha:0.75; padding:4"/> 
        <Border dimensions="dock:fill" class="ButtonBorder" style="alpha:0.1; exposure:1.0; padding:4"/>
        <Text name="Channel" dimensions="width:200; left:4; height:100%" class="Chat" style="halign:left; valign:center; alpha:1.0; clip:false; wrap:false" key="{For Initing Height}"/>
        <TextInput name="ChatInput" dimensions="height:100%; width:100%; left:0; top:0" class="Chat, #TextInput" style="alpha:1.0; valign:center; padding:3; wrap:false; maxlen:]]..C_ChatlineMaxCharLength..[[; texture:colors; region:transparent;">
            <Events>
                <OnGotFocus bind="ChatInput_OnGotFocus"/>
                <OnLostFocus bind="ChatInput_OnLostFocus"/>
                <OnTextChange bind="ChatInput_OnChatType"/>
                <OnSubmit bind="ChatInput_OnChatSubmit"/>
                <OnPrevious bind="ChatInput_OnUpArrow"/>
                <OnNext bind="ChatInput_OnDownArrow"/>
                <OnTab bind="ChatInput_OnTabKey"/>
            </Events>
        </TextInput>
        <DropTarget name="DropTarget" dimensions="dock:fill" style="visible:false">
            <Events>
                <OnDragDrop bind="ChatInput_OnDragDrop"/>
            </Events>
        </DropTarget>
    </Group>]]


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

local fullAlphabetTable = {
    ["default"] = {
            ["up"]         = {"a", "b", "c", "d"},
            ["right-up"]   = {"e", "f", "g", "h"},
            ["right"]      = {"i", "j", "k", "l"},
            ["right-down"] = {"m", "n", "o", "p"},
            ["down"]       = {"q", "r", "s", "t"},
            ["left-down"]  = {"u", "v", "w", "x"},
            ["left"]       = {"y", "z", ",", "."},
            ["left-up"]    = {":", "/", "@", "-"},
    },
    ["caps"] = {
            ["up"]         = {"A", "B", "C", "D"},
            ["right-up"]   = {"E", "F", "G", "H"},
            ["right"]      = {"I", "J", "K", "L"},
            ["right-down"] = {"M", "N", "O", "P"},
            ["down"]       = {"Q", "R", "S", "T"},
            ["left-down"]  = {"U", "V", "W", "X"},
            ["left"]       = {"Y", "Z", "?", "!"},
            ["left-up"]    = {";", "\\", "&", "_"},
    },
    ["numbers"] = {
            ["up"]         = {"1", "2", "3", "4"},
            ["right-up"]   = {"5", "6", "7", "8"},
            ["right"]      = {"9", "0", "*", "+"},
            ["right-down"] = {"£", "€", "$", "’"},
            ["down"]       = {"'", "\"", "~", "|"},
            ["left-down"]  = {"=", "#", "%", "^"},
            ["left"]       = {"<", ">", "[", "]"},
            ["left-up"]    = {"{", "}", "(", ")"},
    },
    ["special"] = {
            ["up"]         = {":D", ":(", ":)", "®"},
            ["right-up"]   = {"™", "©", "G", ":Ð"},
            ["right"]      = {":'D", "", "", ""},
            ["right-down"] = {"", "", "", ""},
            ["down"]       = {"", "", "", ""},
            ["left-down"]  = {"", "", "", ""},
            ["left"]       = {"", "", "", ""},
            ["left-up"]    = {"", "", "", ""},
    },
}

local fullAlphabetTableKeycodes = {
    ["default"] = {
            ["up"]         = {65, 66, 67, 68},
            ["right-up"]   = {69, 70, 71, 72},
            ["right"]      = {73, 74, 75, 76},
            ["right-down"] = {77, 78, 79, 80},
            ["down"]       = {81, 82, 83, 84},
            ["left-down"]  = {85, 86, 87, 88},
            ["left"]       = {89, 90, 0, 0},
            ["left-up"]    = {186, 191, 276, 189},
    },
    ["caps"] = {
            ["up"]         = {65, 66, 67, 68},
            ["right-up"]   = {69, 70, 71, 72},
            ["right"]      = {73, 74, 75, 76},
            ["right-down"] = {77, 78, 79, 80},
            ["down"]       = {81, 82, 83, 84},
            ["left-down"]  = {85, 86, 87, 88},
            ["left"]       = {89, 90, 0, 0},
            ["left-up"]    = {186, 226, 276, 189},
    },
    ["numbers"] = {
            ["up"]         = {49, 50, 51, 52},
            ["right-up"]   = {53, 54, 55, 56},
            ["right"]      = {57, 48, 106, 107},
            ["right-down"] = {0, 0, 0, 192},
            ["down"]       = {222, 226, 192, 0},
            ["left-down"]  = {187, 0, 0, 0},
            ["left"]       = {188, 190, 219, 221},
            ["left-up"]    = {186, 226, 276, 189},
    },
    ["special"] = {
            ["up"]         = {0, 0, 0, 0},
            ["right-up"]   = {0, 0, 0, 0},
            ["right"]      = {0, "", "", ""},
            ["right-down"] = {"", "", "", ""},
            ["down"]       = {"", "", "", ""},
            ["left-down"]  = {"", "", "", ""},
            ["left"]       = {"", "", "", ""},
            ["left-up"]    = {"", "", "", ""},
    },
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
        g_KeySet_Daisy_XYAB:RegisterAction("daisy_space", DaisyXYABInput)
        g_KeySet_Daisy_XYAB:RegisterAction("daisy_submit", DaisyXYABInput)
        g_KeySet_Daisy_XYAB:RegisterAction("daisy_backspace", DaisyXYABInput, "toggle")
        g_KeySet_Daisy_XYAB:RegisterAction("daisy_caps", DaisyXYABInput, "toggle")
        g_KeySet_Daisy_XYAB:RegisterAction("daisy_numbers", DaisyXYABInput, "toggle")
        for i, keyCode in ipairs(ABILITY_PIZZA_KEYBINDINGS_ORDER) do
            g_KeySet_Daisy_XYAB:BindKey("daisy_xyab", keyCode, i)
        end
        g_KeySet_Daisy_XYAB:BindKey("daisy_space", KEYCODE_GAMEPAD_RIGHT_BUMPER)
        g_KeySet_Daisy_XYAB:BindKey("daisy_submit", KEYCODE_GAMEPAD_START)
        g_KeySet_Daisy_XYAB:BindKey("daisy_backspace", KEYCODE_GAMEPAD_LEFT_BUMPER)
        g_KeySet_Daisy_XYAB:BindKey("daisy_caps", KEYCODE_GAMEPAD_LEFT_TRIGGER)
        g_KeySet_Daisy_XYAB:BindKey("daisy_numbers", KEYCODE_GAMEPAD_RIGHT_TRIGGER)
        g_KeySet_Daisy_XYAB:Activate(false)
end


function DaisyWheel_OnComponentLoad()

    -- Setup keybinds
    DaisyWheel_UserKeybinds()

    -- Setup widgets
    w_DaisyWheelTableWidgets = {}
    w_DaisyWheelCharacterWidgets = {}

    local masterCont = DAISY_CONTAINER

    local numberOfTables = 8
    local perTablePrecent = (100/numberOfTables)

    for i=1,8 do -- #alphabetTable (but that wont work since pairs)
        local tableAngle = 360 * (perTablePrecent*i)/100 - 135
        local tablePoint = GetPointOnCricle(400, 200, (RT_SEG_WIDTH*3)*0.30, tableAngle)


        local cont = Component.CreateWidget(unicode.format('<Group dimensions="width:160; height:160; left:%i; top:%i;"><StillArt name="Background" dimensions="dock:fill" style="texture:colors; region:white; tint:#00eebb; alpha:0.4;"/></Group>', tablePoint.x-20, tablePoint.y-20), masterCont)
        local characterTable = fullAlphabetTable["default"][alphabetTableIndex[i]]

        local numberOfSegments = 4 -- # characters per segment
        local perSegPrecent = (100/numberOfSegments)

        w_DaisyWheelCharacterWidgets[alphabetTableIndex[i]] = {}

        -- Inner Alphabet Character Segments
        for j=1,numberOfSegments do
            local angle = 360 * (perSegPrecent*j)/100 + 90
            local point = GetPointOnCricle(90, 80, (RT_SEG_WIDTH/2)*0.30, angle)
            local SEGMENT = Component.CreateWidget(unicode.format('<Group blueprint="KeyPizzaSegment" dimensions="width:20; height:20; left:%i; top:%i;"></Group>', point.x-20, point.y-20), cont)
            
            if (characterTable[j]) then

                local inputIcon = InputIcon.CreateVisual(SEGMENT:GetChild("inputIconGroup"), "Bind")
                local keyCode = fullAlphabetTableKeycodes["default"][alphabetTableIndex[i]][j]
                inputIcon:SetBind({keycode=keyCode, alt=false}, true)

                w_DaisyWheelCharacterWidgets[alphabetTableIndex[i]][j] = inputIcon

            end
        end

        w_DaisyWheelTableWidgets[alphabetTableIndex[i]] = cont

    end

    -- Create navwheel node
    local NAVWHEEL_NODE = NavWheel.CreateNode()
    NAVWHEEL_NODE:GetIcon():SetTexture("icons", "rotate");
    NAVWHEEL_NODE:SetTitle("Daisy Wheel")   
    NAVWHEEL_NODE:SetAction(function()
                                NavWheel.Close()
                                DaisyWheel_Activate()
                            end)
    NAVWHEEL_NODE:SetParent("hud_root")

    -- Create input box
    SetupChatInput()
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
        ChatInput_OnBeginChat({text=""})

        -- Ensure cursor mode so that Chat displays
        Component.SetInputMode("cursor")
        Debug.Log("Cursor mode engaged")

        -- Start DPAD State Cycle
        CB2_DaisyStateCycle = Callback2.CreateCycle(DaisyStateCycle)
        CB2_DaisyStateCycle:Run(0.25)

        -- Lock Pizza keysets because they are likely bound to dpad :(
        g_KeySet_PizzaActivators:Activate(false)

        -- Activate keysets
        g_KeySet_Daisy_DPAD:Activate(true)
        g_KeySet_Daisy_XYAB:Activate(true)
        Debug.Log("Daisy Keysets Enabled")

        --[[
        -- Override Keybinds: For the chat submit button
            Debug.Log("Overriding keys")
            -- Save overridden keys
            g_DaisyOverridenKeybinds = MassFreeKeycodes({keycodes={[KEYCODE_GAMEPAD_START] = true}})

            -- Bind submit
            System.BindKey("Social", "OpenChat", KEYCODE_GAMEPAD_START, false, 3)
            System.ApplyKeyBindings()
            Debug.Log("Submit bound")
        --]]

        -- Display Daisy Wheel
        FRAME:Show(true)

        -- Set state to active
        g_DaisyState.active = true

        -- Close on submit
        g_LeaveChatOnSubmit = true

        Callback2.FireAndForget(function() Component.GenerateEvent("XCU_ON_TOGGLE_UI", {visible = true}) end, nil, 0.3)
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

        -- Unlock pizza activator keysets
        g_KeySet_PizzaActivators:Activate(true) -- Todo: This is probably not good
        
        --[[
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
        --]]

        -- Hide Daisy Wheel
        FRAME:Show(false)

        -- Set state to not active
        g_DaisyState.active = false
    else
        Debug.Warn("DaisyWheel_Deactivate called but DaisyWheel was not active.")
    end
end

function DaisyStateCycle()
    --Debug.Log("DaisyStateCycle")

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
            local text = Component.CreateWidget('<Text dimensions="height:100; width:20%; top:'..tostring(50 + (30*temp_daisyCount))..'" />', FRAME)
            temp_daisyCount = temp_daisyCount + 1
            w_DaisyDPADTextWidgets[key] = text 
        end
        w_DaisyDPADTextWidgets["direction"] = Component.CreateWidget('<Text dimensions="height:100; width:20%; top:'..tostring(50 + (30*temp_daisyCount))..'" />', FRAME)
        temp_daisyCount = temp_daisyCount + 1
        w_DaisyDPADTextWidgets["mode"] = Component.CreateWidget('<Text dimensions="height:100; width:20%; top:'..tostring(50 + (30*temp_daisyCount))..'" />', FRAME)
        temp_daisyCount = temp_daisyCount + 1
    end

    for key, text in pairs(w_DaisyDPADTextWidgets) do
        local value = (key == "mode" and g_DaisyState.mode) or (key == "direction" and g_DaisyState.direction) or g_DaisyState.dpad[key]
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
        widget:Show(true)
        if key == g_DaisyState.direction then
            widget:ParamTo("alpha", 1, 0.25, "ease-out")
        elseif g_DaisyState.direction == "none" then
            widget:ParamTo("alpha", 0.7, 0.5, "ease-in")
        else
            --widget:Show(false)
            widget:ParamTo("alpha", 0.4, 0.5, "ease-in")
        end
    end

    for key, widgets in pairs(w_DaisyWheelCharacterWidgets) do
        for i, inputIcon in ipairs(widgets) do
            local keyCode = fullAlphabetTableKeycodes[g_DaisyState.mode][key][i]
            inputIcon:SetBind({keycode=keyCode, alt=false}, true)
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
            Output("Unpausing" .. oppositeAxis .. " axis callback as " .. key .. " is released")
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

    local action = args.name

--[[
daisy_xyab
daisy_space
daisy_backspace
daisy_caps
daisy_numbers
daisy_submit
--]]

    if action == "daisy_backspace" and args.is_pressed then
        ChatInput_DoBackspace()
        --[[
        if g_DaisyPreviouslyTyped ~= "" then
            g_DaisyPreviouslyTyped = unicode.sub(g_DaisyPreviouslyTyped, 1, -2)
            Component.GenerateEvent("MY_BEGIN_CHAT", {text = g_DaisyPreviouslyTyped})
        else
            Output("Nothing to remove!")
        end
        --]]
    elseif action == "daisy_submit" then
        ChatInput_DoSubmit()

    elseif action == "daisy_caps" or action == "daisy_numbers" then

        -- Get key
        local modifierKey = (action == "daisy_caps" and "caps") or "numbers"
        
        -- Update value
        g_DaisyState.modifiers[modifierKey] = args.is_pressed

        -- Determine mode
        if g_DaisyState.modifiers.caps and g_DaisyState.modifiers.numbers then
            g_DaisyState.mode = "special"
        elseif g_DaisyState.modifiers.caps then
            g_DaisyState.mode = "caps"
        elseif g_DaisyState.modifiers.numbers then
            g_DaisyState.mode = "numbers"
        else
            g_DaisyState.mode = "default"
        end


    -- Character Output: daisy_space or daisy_xyab
    else
        if args.is_pressed then
            if action ~= "daisy_space" and g_DaisyState.direction == "none" then
                Output("daisy xyab but no direction")
            else
                local character = ""

                if action == "daisy_space" then
                    character = " "
                else
                    local characterTable = fullAlphabetTable[g_DaisyState.mode][g_DaisyState.direction]
                    character = characterTable[PIZZA_KEYBINDINGS_KEYCODE_INDEX[args.keycode]]
                end

                --g_DaisyPreviouslyTyped = g_DaisyPreviouslyTyped .. character
                --ChatLib.AddTextToChatInput({text = character})
                ChatInput_OnAddChatInput({text = character})
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
        Debug.Log("Binding ", conflict.category, " : ", conflict.action, " : ", conflict.index)
        System.BindKey(conflict.category, conflict.action, conflict.keycode, false, conflict.index)
    end

    -- We did good didn't we? Akanari sou na!
    Debug.Log("Applying the restored keybinds, hope you're doing awesome :)")
    System.ApplyKeyBindings()
end



-- Chat Input
    
function SetupChatInput()
    DAISY_INPUT_CONTAINER = Component.CreateWidget(bp_InputBoxGroup, FRAME)
    DAISY_INPUT_CHANNEL = DAISY_INPUT_CONTAINER:GetChild("Channel")
    DAISY_INPUT = DAISY_INPUT_CONTAINER:GetChild("ChatInput")
    local font = "UbuntuRegular_9"
    DAISY_INPUT_CHANNEL:SetFont(font)
    DAISY_INPUT:SetFont(font)
    --DROPTARGET = DAISY_INPUT_CONTAINER:GetChild("DropTarget")
    --DROPTARGET:SetAcceptTypes("item_sdb_id")
    ChatInput_ChangeChannel("say")
end

function ChatInput_OnBeginChat(args)
    -- args = {command:Bool, reply:Bool, text:string}
    Debug.Event(args)
    if not g_CursorMode then
        g_LeaveChatOnSubmit = true
    end
    if g_GameMode or g_CursorMode then
        Component.SetInputMode("cursor")
    end
    g_MessageIdx = 0
    ChatInput_UpdateVisibility(true)
    Component.SetTextInput(DAISY_INPUT)
    --DAISY_INPUT:SetFocus()
    if args.command then
        ChatInput_ClearInputBox()
        DAISY_INPUT:SetText("/")
    elseif args.reply then
        if #d_WhisperHistory > 0 then
            g_WhisperIdx = 1
            ChatInput_ClearInputBox()
            DAISY_INPUT:SetText("/"..ChatSlash_GetChannelSlash("reply").." ")
        end
    elseif args.text then
        ChatInput_ClearInputBox()
        DAISY_INPUT:SetText(args.text)
    end
end



function ChatInput_OnGotFocus(args)
    Debug.Event(args)
    if not g_InputHasFocus then
        g_MessageIdx = 0
        g_InputHasFocus = true
    end
    g_ChatMode = true
end

function ChatInput_OnLostFocus(args)
    Debug.Event(args)
    if g_InputHasFocus then
        g_InputHasFocus = false
        Component.SetTextInput(nil)
        DAISY_INPUT:ReleaseFocus()
        --D_Frames[1].FRAME:ReleaseFocus()
        Component.SetInputMode(nil)
        --ChatAutoComplete_Show(false)
    end
    g_ChatMode = false
end

function ChatInput_OnEscape(args)
    Debug.Event(args)
    ChatInput_OnLostFocus(args)
    Component.PostMessage("DragDrop:main", "release_cursor")
    ChatInput_UpdateVisibility(false)
    DaisyWheel_Deactivate()
end

function ChatInput_OnAddChatInput(args)
    if true or g_CursorMode then
        if args.json then
            args = jsontotable(args.json)
        end
        local text = DAISY_INPUT:GetText()..args.text
        DAISY_INPUT:SetText(text)
        Component.SetTextInput(DAISY_INPUT)
        if type(args.replaces) == "table" then
            for _, replace in ipairs(args.replaces) do
                table.insert(d_CurrentReplaces, replace)
            end
        end
    end
end


function ChatInput_OnChatType(args)
    Debug.Event(args)
end
function ChatInput_OnChatSubmit(args)
    Debug.Event(args)
    local text = DAISY_INPUT:GetText()
    if text ~= "" and unicode.find(text, "%S") then
        -- see if it's a command
        if unicode.match(unicode.sub(text,1,2), "/[^%s]+") then
            local command = unicode.lower(unicode.match(text, "/(%S+)"))
            --local slash_chat = ChatSlash_SlashLookup(command, "chat", false)
            --local slash_coms = ChatSlash_SlashLookup(command, "coms")
            local slash_chat = false
            local slash_coms = false
            if unicode.sub(text,1,2) == "//" then-- let the player send a message that starts with a '/'
                ChatInput_SendMessage(unicode.sub(text, 2))
            elseif slash_chat then -- CHANNEL COMMANDS
                if g_Connection[slash_chat] then
                    ChatInput_ChangeChannel(slash_chat)
                end
            elseif slash_coms then -- SLASH COMMANDS
                local message = unicode.match(text, "^/"..command.."%s+(.+)")
                if message == nil then message = "" end
                ChatSlash_FireSlashReply(slash_coms, message)
            else -- INGAME EMOTES/ANIMATIONS
                -- Until we have a method to get the list of availible emotes, we will just have to fire and forget blindly
                Game.SlashCommand(text)
                
            end
        else
            ChatInput_SendMessage(text)
        end
        --lf.LogMessage(text, d_CurrentReplaces)
    end
    -- clean up the submission window
    if g_LeaveChatOnSubmit or text == "" then
        g_LeaveChatOnSubmit = false
        ChatInput_OnEscape({event="SUBMIT_EMPTY_STRING"})
    end
    ChatInput_ClearInputBox()
end
function ChatInput_OnUpArrow(args)
    Debug.Event(args)
end
function ChatInput_OnDownArrow(args)
    Debug.Event(args)
end
function ChatInput_OnTabKey(args)
    Debug.Event(args)
end

function ChatInput_OnDragDropBegin()
    DAISY_INPUT_DROPTARGET:Show()
end

function ChatInput_OnDragDropEnd()
    DAISY_INPUT_DROPTARGET:Hide()
end

function ChatInput_OnDragDrop()
    local info = DAISY_INPUT_DROPTARGET:GetDropInfo()
    info = jsontotable(info)
    local itemInfo = Player.GetItemInfo(info.itemId)
    ChatLib.AddItemLinkToChatInput(info.itemSdbId, itemInfo.hidden_modules, itemInfo.slotted_modules)
end

function ChatInput_ClearInputBox()
    DAISY_INPUT:SetText("")
end

function ChatInput_IsCursorMode()
    return g_CursorMode
end

function ChatInput_UpdateVisibility(bool)
    if bool then
        DAISY_INPUT_CONTAINER:ParamTo("alpha", 1, 0.15)
    else
        DAISY_INPUT_CONTAINER:ParamTo("alpha", 0.4, 0.15)
    end
end

function ChatInput_SendMessage(text, channel)
    --text = unicode.gsub(text, ChatLib.GetEndcapString(), "")
    --text = ChatAlias_ProcessAlias(text)
    --[[
    for _, tbl in ipairs(d_CurrentReplaces) do
        -- escape all lua pattern matching magic chars, stupid gsub not having the plain flag like find
        local match = unicode.gsub(tbl.match, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")
        
        text = unicode.gsub(text, match, tbl.replace, 1)
    end
    --]]
    text = unicode.gsub(text, "\n", "") --remove forced line breaks from outgoing messages
    if g_WhisperTo then
        ChatInput_SendWhisperMessage(g_WhisperTo, text)
    elseif channel then
        Chat.SendChannelText(channel, text)
    elseif g_Channel then
        Chat.SendChannelText(g_Channel, text)
    else
        --OnSystemMessage({key="CHAT_CHANNEL_ERROR"})
    end
end

function ChatInput_ChangeChannel(newChannel)
    assert(type(newChannel) == "string", "ChangeChannel: param1 is not a string")
    if newChannel == "whisper" then newChannel = "reply" end
    --[[
    if g_Connection[newChannel] == nil then
        warn("Unknown Chat Channel: "..tostring(newChannel))
        return nil
    end
    --]]
    --[[
    if newChannel ~= "reply" then
        if g_TeamId then
            g_Default.PVP = newChannel
        else
            g_Default.PVE = newChannel
        end
    end
    --]]
    g_Channel = newChannel
    g_WhisperTo = nil
    --ChatInput_SetTextColor(g_Channel)
    --ChatInput_SetChannelText(ChatOptions_GetChannelValue(g_Channel, "Tag"))
    ChatInput_SetTextColor("#ff0033")
    ChatInput_SetChannelText("Local")
end

function ChatInput_SetChannelText(text)
    if not text and g_ChannelColor and g_ChannelColor ~= "reply" and g_ChannelColor ~= "whisper" then
        --text = ChatOptions_GetChannelValue(g_ChannelColor, "Tag")
        text = "Local"
    end
    if text then
        --strip of trailing whitespace from the Channel Tag as the padding here will cover it
        text = unicode.gsub(text, "%s+$", "")
        DAISY_INPUT_CHANNEL:SetText(text)
        AlignInputText()
    end
end

function ChatInput_SetTextColor(channel)
    g_ChannelColor = channel or g_ChannelColor
    if g_ChannelColor then
        --local color = ChatOptions_GetChannelValue(g_ChannelColor, "Color")
        local color = channel
        DAISY_INPUT_CHANNEL:SetTextColor(color)
        DAISY_INPUT:SetTextColor(color)
    end
end

function ChatInput_SetFont(font)
    DAISY_INPUT_CHANNEL:SetFont(font)
    DAISY_INPUT:SetFont(font)
    AlignInputText()
end

function AlignInputText()
    local width = DAISY_INPUT_CHANNEL:GetTextDims().width + c_ChannelPadding
    DAISY_INPUT_CHANNEL:SetDims("left:0; right:"..width)
    DAISY_INPUT:SetDims("right:100%; left:"..width)
end

function ChatInput_DoBackspace()
    local previousText = DAISY_INPUT:GetText()
    if previousText ~= "" then
        local newText = unicode.sub(previousText, 1, -2)
        DAISY_INPUT:SetText(newText)
    else
        Output("Nothing to remove!")
    end
end

function ChatInput_DoSubmit()
    ChatInput_OnChatSubmit()
end