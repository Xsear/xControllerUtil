
-- ------------------------------------------
-- Daisy Wheel
--   by: Xsear
-- ------------------------------------------

require 'lib/lib_NavWheel'
require 'lib/lib_ContextWheel'




-- chat input stuff
----------------------
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
----------------------

CVAR_GAMEPAD_SENSITIVITY_POW = "aim.sensitivity_pow_gamepad"
CVAR_GAMEPAD_SENSITIVITY_VERTMUL = "aim.sensitivity_vertmul_gamepad"


DaisyConstants = {}
DaisyConstants["DirectionMethod"] = {}
DaisyConstants.DirectionMethod.DPAD = "dpad"
DaisyConstants.DirectionMethod.Thumbstick = "thumbstick"
DaisyConstants.DirectionMethod.Either = "both"

DaisyConstants["Direction"] = {}
DaisyConstants.Direction.Up = "up"
DaisyConstants.Direction.RightUp = "right-up"
DaisyConstants.Direction.Right = "right"
DaisyConstants.Direction.RightDown = "right-down"
DaisyConstants.Direction.Down = "down"
DaisyConstants.Direction.LeftDown = "left-down"
DaisyConstants.Direction.Left = "left"
DaisyConstants.Direction.LeftUp = "left-up"

DaisyConstants["AlphabetMode"] = {}
DaisyConstants.AlphabetMode.Default = "default"
DaisyConstants.AlphabetMode.Caps = "caps"
DaisyConstants.AlphabetMode.Numbers = "numbers"
DaisyConstants.AlphabetMode.Special = "special"

g_Options["Daisy"] = {}
local DaisyOptions = g_Options["Daisy"]

DaisyOptions["Alphabet"] = {
    [DaisyConstants.AlphabetMode.Default] = {
        [DaisyConstants.Direction.Up]         = {"a", "b", "c", "d"},
        [DaisyConstants.Direction.RightUp]    = {"e", "f", "g", "h"},
        [DaisyConstants.Direction.Right]      = {"i", "j", "k", "l"},
        [DaisyConstants.Direction.RightDown]  = {"m", "n", "o", "p"},
        [DaisyConstants.Direction.Down]       = {"q", "r", "s", "t"},
        [DaisyConstants.Direction.LeftDown]   = {"u", "v", "w", "x"},
        [DaisyConstants.Direction.Left]       = {"y", "z", ",", "."},
        [DaisyConstants.Direction.LeftUp]     = {":", "/", "@", "-"},
    },
    [DaisyConstants.AlphabetMode.Caps] = {
        [DaisyConstants.Direction.Up]         = {"A", "B", "C", "D"},
        [DaisyConstants.Direction.RightUp]    = {"E", "F", "G", "H"},
        [DaisyConstants.Direction.Right]      = {"I", "J", "K", "L"},
        [DaisyConstants.Direction.RightDown]  = {"M", "N", "O", "P"},
        [DaisyConstants.Direction.Down]       = {"Q", "R", "S", "T"},
        [DaisyConstants.Direction.LeftDown]   = {"U", "V", "W", "X"},
        [DaisyConstants.Direction.Left]       = {"Y", "Z", "?", "!"},
        [DaisyConstants.Direction.LeftUp]     = {";", "\\", "&", "_"},
    },
    [DaisyConstants.AlphabetMode.Numbers] = {
        [DaisyConstants.Direction.Up]         = {"1", "2", "3", "4"},
        [DaisyConstants.Direction.RightUp]    = {"5", "6", "7", "8"},
        [DaisyConstants.Direction.Right]      = {"9", "0", "*", "+"},
        [DaisyConstants.Direction.RightDown]  = {"£", "€", "$", "’"},
        [DaisyConstants.Direction.Down]       = {"'", "\"", "~", "|"},
        [DaisyConstants.Direction.LeftDown]   = {"=", "#", "%", "^"},
        [DaisyConstants.Direction.Left]       = {"<", ">", "[", "]"},
        [DaisyConstants.Direction.LeftUp]     = {"{", "}", "(", ")"},
    },
    [DaisyConstants.AlphabetMode.Special] = {
        [DaisyConstants.Direction.Up]         = {":D", ":(", ":)", "®"},
        [DaisyConstants.Direction.RightUp]    = {"™", "©", "G", ":Ð"},
        [DaisyConstants.Direction.Right]      = {":'D", "", "", ""},
        [DaisyConstants.Direction.RightDown]  = {"", "", "", ""},
        [DaisyConstants.Direction.Down]       = {"", "", "", ""},
        [DaisyConstants.Direction.LeftDown]   = {"", "", "", ""},
        [DaisyConstants.Direction.Left]       = {"", "", "", ""},
        [DaisyConstants.Direction.LeftUp]     = {"", "", "", ""},
    },
}
DaisyOptions["Sizes"] = {}
DaisyOptions.Sizes.WheelScale = 1
DaisyOptions.Sizes.PetalWidth = 160
DaisyOptions.Sizes.PetalHeight = 160
DaisyOptions.Sizes.EntryWidth = 40
DaisyOptions.Sizes.EntryHeight = 40

DaisyOptions["Config"] = {}
DaisyOptions.Config.DirectionMethod = DaisyConstants.DirectionMethod.Thumbstick
DaisyOptions.Config.SwapThumbsticks = true
DaisyOptions.Config.ThumbstickMovementPreventionHack = false
DaisyOptions.Config.ThumbstickCoordinateTolerance = 2

DaisyOptions["Debug"] = {}
DaisyOptions.Config.DisplayStateOverlay = false
DaisyOptions.Config.CoverUpTheHack = false

g_KeySet_Daisy_DPAD = nil
g_KeySet_Daisy_XYAB = nil
g_DaisyState = {
    active = false,
    mode = DaisyConstants.AlphabetMode.Default,
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
    thumbstick = {
        initialCoordinates = nil,
        previousCoordinates = nil,
        horizontal = nil,
        vertical = nil,
        originalCvars = {
        },
    },
}
g_DaisyOverridenKeybinds = {}
g_DaisyPausedOppositeAxis = false

w_DaisyWheelTableWidgets = {}
w_DaisyDPADTextWidgets = {}

local CB2_DaisyBackspace = nil
local CB2_DaisyThumbstickUpdate = nil

local FRAME = Component.GetFrame("DaisyWheel")
FRAME:Show(false)
local DAISY_CONTAINER = Component.GetWidget("DaisyContainer")
local DAISY_INPUT_CONTAINER = nil
local DAISY_INPUT_CHANNEL = nil
local DAISY_INPUT = nil

FRAME_FullscreenCover = Component.GetFrame("FullscreenCover")
FRAME_FullscreenCover:Show(false)
local SHINE_RAYS      = Component.GetWidget("Rays");
local SHINE_ANIMATION_1 = Component.GetWidget("shine1");
local SHINE_ANIMATION_2 = Component.GetWidget("shine2");

local CB2_DaisyDPADInput = {
    ["horizontal"] = nil,
    ["vertical"] = nil,
}

local daisyActionToKey = {
    ["daisy_dpad_left"] = DaisyConstants.Direction.Left,
    ["daisy_dpad_up"] = DaisyConstants.Direction.Up,
    ["daisy_dpad_right"] = DaisyConstants.Direction.Right,
    ["daisy_dpad_down"] = DaisyConstants.Direction.Down,
}

local daisyKeyToAxis = {
    [DaisyConstants.Direction.Up] = "vertical",
    [DaisyConstants.Direction.Down] = "vertical",
    [DaisyConstants.Direction.Right] = "horizontal",
    [DaisyConstants.Direction.Left] = "horizontal",
}

local daisyGetOppositeAxis = {
    ["vertical"] = "horizontal",
    ["horizontal"] = "vertical"
}

local alphabetTableIndex = {
    [1] = DaisyConstants.Direction.Up,
    [2] = DaisyConstants.Direction.RightUp,
    [3] = DaisyConstants.Direction.Right,
    [4] = DaisyConstants.Direction.RightDown,
    [5] = DaisyConstants.Direction.Down,
    [6] = DaisyConstants.Direction.LeftDown,
    [7] = DaisyConstants.Direction.Left,
    [8] = DaisyConstants.Direction.LeftUp,
}


local petalEntryTintIndex = {
    [1] = "0000CC",
    [2] = "CCCC00",
    [3] = "CC0000",
    [4] = "00CC00",
}

function DaisyWheel_UserKeybinds()
    -- The keyset that handles DPAD button presses
    g_KeySet_Daisy_DPAD = UserKeybinds.Create()
        g_KeySet_Daisy_DPAD:RegisterAction("daisy_dpad_left", DaisyDPADInput, "toggle")
        g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_left", KEYCODE_GAMEPAD_DPAD_LEFT)
        g_KeySet_Daisy_DPAD:RegisterAction("daisy_dpad_up", DaisyDPADInput, "toggle")
        g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_up", KEYCODE_GAMEPAD_DPAD_UP)
        g_KeySet_Daisy_DPAD:RegisterAction("daisy_dpad_right", DaisyDPADInput, "toggle")
        g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_right", KEYCODE_GAMEPAD_DPAD_RIGHT)
        g_KeySet_Daisy_DPAD:RegisterAction("daisy_dpad_down", DaisyDPADInput, "toggle")
        g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_down", KEYCODE_GAMEPAD_DPAD_DOWN)

        --[[
        if false or g_Debug then
            -- Keyboard arrow keys
            g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_left", 37)
            g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_up", 38)
            g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_right", 39)
            g_KeySet_Daisy_DPAD:BindKey("daisy_dpad_down", 40)
        end
        --]]

        g_KeySet_Daisy_DPAD:Activate(false)

    -- The keyset that handles XYAB button presses as well as other general actions (ugh)
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

    -- A keyset that handles thumbstick presses, could be useful.
    g_KeySet_Daisy_ThumbStickTest = UserKeybinds.Create()
        g_KeySet_Daisy_ThumbStickTest:RegisterAction("left_thumb", ThumbstickTest, "toggle")
        g_KeySet_Daisy_ThumbStickTest:RegisterAction("right_thumb", ThumbstickTest, "toggle")
        g_KeySet_Daisy_ThumbStickTest:BindKey("left_thumb", KEYCODE_GAMEPAD_LEFT_THUMBSTICK, "toggle")
        g_KeySet_Daisy_ThumbStickTest:BindKey("right_thumb", KEYCODE_GAMEPAD_RIGHT_THUMBSTICK, "toggle")


end

function DaisyWheel_OnComponentLoad()

    -- Setup keybinds
    DaisyWheel_UserKeybinds()

    -- Setup daisy wheel
    BuildDaisyWheel()

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

    -- Create "Backspace hold" Callback2 instance
    CB2_DaisyBackspace = Callback2.Create()
    CB2_DaisyBackspace:Bind(ChatInput_DoBackspace, {callback=true})

end


function OnSlashDaisy(args)
    Debug.Log("OnSlashDaisy")
    if DaisyWheel_IsActive() then
        DaisyWheel_Deactivate()
    else
        DaisyWheel_Activate()
    end
end


function BuildDaisyWheel(args)
    -- Setup widgets
    if w_DaisyWheelPetalWidgets then
        for index, value in ipairs(w_DaisyWheelPetalWidgets) do
            if Component.IsWidget(value) then
                Component.RemoveWidget(value)
            end
        end
    end

    w_DaisyWheelPetalWidgets = {}
    w_DaisyWheelTableWidgets = {}
    w_DaisyWheelCharacterWidgets = {}

    local masterCont = DAISY_CONTAINER
    if DAISY_CONTAINER:GetChildCount() > 1 then
        for idx = 2,DAISY_CONTAINER:GetChildCount() do
            local child = DAISY_CONTAINER:GetChild(idx)
            if Component.IsWidget(child) then
                Component.RemoveWidget(child)
            end
        end
    end

    Debug.Log("The Daisy Wheel Scale is " .. tostring(DaisyOptions.Sizes.WheelScale))

    FRAME:SetParam("scalex", DaisyOptions.Sizes.WheelScale)
    FRAME:SetParam("scaley", DaisyOptions.Sizes.WheelScale)

    local numberOfTables = 8
    local perTablePrecent = (100/numberOfTables)

    local masterBounds = masterCont:GetBounds()
    local masterCenterX = math.floor(masterBounds.width  / 2)
    local masterCenterY = math.floor(masterBounds.height / 2)

    local daisyRadius = math.floor(masterBounds.width  / 3)   --(RT_SEG_WIDTH*3)*0.30

    local daisyOriginX = masterCenterX
    local daisyOriginY = masterCenterY

    Debug.Divider()
    Debug.Log("BuildDaisyWheel")

    Debug.Table("bounds", masterCont:GetBounds())

    Debug.Table("maths", {
                    masterCenterX = masterCenterX,
                    masterCenterY = masterCenterY,
                    daisyRadius = daisyRadius,
                    daisyOriginX = daisyOriginX,
                    daisyOriginY = daisyOriginY,
                })
    Debug.Divider()


    -- Create a Petal for each table of character
    for i=1,numberOfTables do

        -- Petal size and offset
        local petalWidth = DaisyOptions.Sizes.PetalWidth
        local petalHeight = DaisyOptions.Sizes.PetalHeight
        local petalOriginXOffset = math.floor(petalWidth/2)
        local petalOriginYOffset = math.floor(petalHeight/2)

        -- Petal position in the Wheel
        local tableAngleCorrection = -135 -- This is the value that puts the "a-b-c-d" group at the top, like I want it :)
        local tableAngle = (360 * (perTablePrecent*i)/100) + tableAngleCorrection
        local tablePoint = GetPointOnCricle(daisyOriginX, daisyOriginY, daisyRadius, tableAngle)

        -- Petal container
        local PETAL = Component.CreateWidget(unicode.format('<Group blueprint="DaisyWheel_Petal" dimensions="width:%i; height:%i; left:%i; top:%i;"/>', petalWidth, petalHeight, tablePoint.x-petalOriginXOffset, tablePoint.y-petalOriginYOffset), masterCont)
            
        w_DaisyWheelPetalWidgets[#w_DaisyWheelPetalWidgets + 1] = PETAL

        -- Character table for this petal
        local characterTable = DaisyOptions["Alphabet"][DaisyConstants.AlphabetMode.Default][alphabetTableIndex[i]]

        local numberOfSegments = 4 -- # characters/segments per petal
        local perSegmentPrecent = (100/numberOfSegments)

        -- Some random initialization /shoga
        w_DaisyWheelCharacterWidgets[alphabetTableIndex[i]] = {}

        -- Inner Alphabet Character Segments
        for j=1,numberOfSegments do

            -- Character Entry size and offset
            local entryWidth = DaisyOptions.Sizes.EntryWidth
            local entryHeight = DaisyOptions.Sizes.EntryHeight
            local entryOriginXOffset = math.floor(entryWidth/2)
            local entryOriginYOffset = math.floor(entryHeight/2)

            -- Character entry position in the "XYAB" pie
            local segmentCircleRadius = entryWidth -- This is producing the results I want currently but I don't think it follows the train of calculation
            local angleCorrection = 90
            local angle = 360 * (perSegmentPrecent*j)/100 + angleCorrection
            local point = GetPointOnCricle(petalOriginXOffset, petalOriginYOffset, segmentCircleRadius, angle)

            -- Create character entry segment
            local SEGMENT = Component.CreateWidget(unicode.format('<Group blueprint="DaisyWheel_Petal_Entry" dimensions="width:%i; height:%i; left:%i; top:%i;"></Group>', entryWidth, entryHeight, point.x - entryOriginXOffset, point.y - entryOriginYOffset), PETAL)
            
            -- Fill in the character
            if (characterTable[j]) then

                local characterText = SEGMENT:GetChild("characterText")
                characterText:SetText(characterTable[j])

                local circleBackground = SEGMENT:GetChild("circleBackground")
                circleBackground:SetParam("tint", petalEntryTintIndex[j])
                circleBackground:SetParam("alpha", 0.7)

                w_DaisyWheelCharacterWidgets[alphabetTableIndex[i]][j] = {characterText=characterText, circleBackground=circleBackground}
            end
        end

        w_DaisyWheelTableWidgets[alphabetTableIndex[i]] = PETAL

    end
end

function DaisyWheel_IsActive()
    return g_DaisyState.active
end

function DaisyWheel_Activate()
    Debug.Log("DaisyWheel_Activate")
    if not g_DaisyState.active then

        -- Prepare chat input
        ChatInput_OnBeginChat({text=""})

        -- Ensure cursor mode, prevents movement, etc.
        Component.SetInputMode("cursor")
        Debug.Log("Cursor mode engaged")
        
        -- Start Daisy State Cycle
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

        -- Activate thumbstick mode
        if     DaisyOptions.Config.DirectionMethod == DaisyConstants.DirectionMethod.Thumbstick
            or DaisyOptions.Config.DirectionMethod == DaisyConstants.DirectionMethod.Either then
            ToggleThumbstickMode(true)
        end

        -- Display Daisy Wheel
        FRAME:Show(true)

        -- Set state to active
        g_DaisyState.active = true

        -- Close on submit
        g_LeaveChatOnSubmit = true

        -- FIXME: Some kind of hack for my own? Not sure what I'm up to.
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

        -- Deactivate thumbstick mode
        ToggleThumbstickMode(false)

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

function ToggleThumbstickMode(enabled)
    if enabled then
        -- Swap thumbsticks, more comfortable to input this way
        if DaisyOptions.Config.SwapThumbsticks then
            System.SwapGamepadThumbsticks(true)
        end

        -- Backup user cvar settings
        g_DaisyState.thumbstick.originalCvars[CVAR_GAMEPAD_SENSITIVITY_POW] = System.GetCvar(CVAR_GAMEPAD_SENSITIVITY_POW)
        g_DaisyState.thumbstick.originalCvars[CVAR_GAMEPAD_SENSITIVITY_VERTMUL] = System.GetCvar(CVAR_GAMEPAD_SENSITIVITY_VERTMUL)

        -- These values help ensure good responsiveness, the values are the client maximums (?)
        System.SetCvar(CVAR_GAMEPAD_SENSITIVITY_POW, 3.5)
        System.SetCvar(CVAR_GAMEPAD_SENSITIVITY_VERTMUL, 1)

        -- Set initial state
        g_DaisyState.thumbstick.initialCoordinates = Game.GetMapCoordinates()
        g_DaisyState.thumbstick.previousCoordinates = Game.GetMapCoordinates()

        -- Start thumbstick update cycle
        CB2_DaisyThumbstickUpdate = Callback2.CreateCycle(DaisyThumbstickUpdate)
        CB2_DaisyThumbstickUpdate:Run(0.25)

        -- Cover all default UI
        FRAME_FullscreenCover:Show(DaisyOptions.Config.CoverUpTheHack)
        SHINE_RAYS:SetParam("alpha", 0.25);
        SHINE_ANIMATION_1:Play(0, 1, 60, true);
        SHINE_ANIMATION_2:Play(1, 0, 60, true);


        -- Open the game's world map so that this all works
        Game.ShowWorldMap(true)
        Game.ZoomWorldMap(0.1) -- Zoom out to near maximum to improve responsivness
    else
        -- Restore thumbsticks
        if DaisyOptions.Config.SwapThumbsticks then
            System.SwapGamepadThumbsticks(false)
        end

        -- Restore user cvar settings
        System.SetCvar(CVAR_GAMEPAD_SENSITIVITY_POW, g_DaisyState.thumbstick.originalCvars[CVAR_GAMEPAD_SENSITIVITY_POW]) -- -1
        System.SetCvar(CVAR_GAMEPAD_SENSITIVITY_VERTMUL, g_DaisyState.thumbstick.originalCvars[CVAR_GAMEPAD_SENSITIVITY_VERTMUL]) -- 0.66

        -- Stop and cleanup thumbstick update cycle
        CB2_DaisyThumbstickUpdate:Release()
        CB2_DaisyThumbstickUpdate = nil

        -- Cleanup state
        g_DaisyState.thumbstick.initialCoordinates = nil
        g_DaisyState.thumbstick.previousCoordinates = nil

        -- Exit world map
        Game.ShowWorldMap(false)

        -- Uncover UI
        SHINE_RAYS:ParamTo("alpha", 0, 1);
        FRAME_FullscreenCover:Show(false)
    end
end


function DaisyStateCycle()
    --Debug.Log("DaisyStateCycle")

    local previousDirection = g_DaisyState.direction

    -- Update direction
    g_DaisyState.direction = DecideDaisyDirection()

    --[[
    if g_DaisyState.direction ~= previousDirection then
        Output("Daisy Direction: " .. g_DaisyState.direction)
    end
    --]]

    -- Trigger UI updates
    UpdateDaisyDpadText()
    UpdateDaisyWidgetVisibility()
end

function UpdateDaisyDpadText()

    if DaisyOptions.Config.DisplayStateOverlay then
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
        for i, segmentWidgets in ipairs(widgets) do


            if key == g_DaisyState.direction then
                segmentWidgets.circleBackground:SetParam("tint", petalEntryTintIndex[i])
                segmentWidgets.circleBackground:SetParam("alpha", 0.7)
            else
                segmentWidgets.circleBackground:SetParam("alpha", 0)
            end

           

            local character = DaisyOptions["Alphabet"][g_DaisyState.mode][key][i]
            segmentWidgets.characterText:SetText(character)
        end
    end
end


function IsCoordinateEqualWithinTolerance(coord1, coord2, tolerance)
    return (IsValueEqualWithinTolerance(coord1.x, coord2.x, tolerance) and IsValueEqualWithinTolerance(coord1.y, coord2.y, tolerance))
end

function IsValueEqualWithinTolerance(value1, value2, tolerance)
    return IsNumberWithinRange(value1, value2-tolerance, value2+tolerance)
end

function IsNumberWithinRange(number, min, max)
    return (number >= min and number <= max)
end


function DaisyThumbstickUpdate()

    -- Get current coordinates
    local currentCoordinates = Game.GetMapCoordinates()
    --Output("Map Pos: " .. tostring(currentCoordinates))

    -- should we reset?
    -- yes if coordinates unchanged and not equal to initial
    if not IsCoordinateEqualWithinTolerance(currentCoordinates, g_DaisyState.thumbstick.initialCoordinates, DaisyOptions.Config.ThumbstickCoordinateTolerance) then
        Game.ShowWorldMap(false)
        callback(Game.ShowWorldMap, true, 0.1)
    end

    -- Reset axis state
    g_DaisyState.thumbstick.horizontal = nil
    g_DaisyState.thumbstick.vertical = nil

    -- Determine horizontal state
    if not IsValueEqualWithinTolerance(currentCoordinates.x, g_DaisyState.thumbstick.initialCoordinates.x, DaisyOptions.Config.ThumbstickCoordinateTolerance) then
        g_DaisyState.thumbstick.horizontal = (currentCoordinates.x > g_DaisyState.thumbstick.initialCoordinates.x) and DaisyConstants.Direction.Right or DaisyConstants.Direction.Left
    end

    -- Determine vertical state
    if not IsValueEqualWithinTolerance(currentCoordinates.y, g_DaisyState.thumbstick.initialCoordinates.y, DaisyOptions.Config.ThumbstickCoordinateTolerance)  then
        g_DaisyState.thumbstick.vertical = (currentCoordinates.y > g_DaisyState.thumbstick.initialCoordinates.y) and DaisyConstants.Direction.Up or DaisyConstants.Direction.Down
    end

    --Output("Hor: " .. tostring(g_DaisyState.thumbstick.horizontal) .. ", Ver: " .. tostring(g_DaisyState.thumbstick.vertical))

    -- Spam events to prevent movement
    if DaisyOptions.Config.ThumbstickMovementPreventionHack then
        Component.GenerateEvent("MY_BEGIN_CHAT", {text = ""})
    end

    -- Save Previous Coordinates
    g_DaisyState.thumbstick.previousCoordinates = currentCoordinates
end


function DecideDaisyDirection()
    
    
    local pressedKeys = {}
    
    if DaisyOptions.Config.DirectionMethod == DaisyConstants.DirectionMethod.Thumbstick
    or DaisyOptions.Config.DirectionMethod == DaisyConstants.DirectionMethod.Either
    then
        if g_DaisyState.thumbstick.horizontal then table.insert(pressedKeys, g_DaisyState.thumbstick.horizontal) end
        if g_DaisyState.thumbstick.vertical then table.insert(pressedKeys, g_DaisyState.thumbstick.vertical) end
    end

    if DaisyOptions.Config.DirectionMethod == DaisyConstants.DirectionMethod.DPAD
    or DaisyOptions.Config.DirectionMethod == DaisyConstants.DirectionMethod.Either
    then
        for key, pressed in pairs(g_DaisyState.dpad) do
            -- Extra logic to avoid duplicates when we get presses from both thumbstick and dpad
            local duplicate = false
            if DaisyOptions.Config.DirectionMethod == DaisyConstants.DirectionMethod.Either then 
                for index, existing in pairs(pressedKeys) do
                    if key == existing then duplicate = true break end
                end
            end

            if pressed and not duplicate then table.insert(pressedKeys, key) end
        end
    end
    
    local direction = "none"

    if #pressedKeys == 1 then
        --Output(" ***** Daisy Direction: " .. pressedKeys[1])

        direction = pressedKeys[1]

    elseif #pressedKeys == 2 then

        --Output(" ***** Daisy Direction: " .. pressedKeys[1] .. " + " .. pressedKeys[2])

        local acceptedCombos = {
            [DaisyConstants.Direction.LeftDown] = {DaisyConstants.Direction.Left, DaisyConstants.Direction.Down},
            [DaisyConstants.Direction.RightDown] = {DaisyConstants.Direction.Right, DaisyConstants.Direction.Down},
            [DaisyConstants.Direction.LeftUp] = {DaisyConstants.Direction.Left, DaisyConstants.Direction.Up},
            [DaisyConstants.Direction.RightUp] = {DaisyConstants.Direction.Right, DaisyConstants.Direction.Up},
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

    if action == "daisy_backspace" then

        if args.is_pressed then

            -- 1-to-1 press to backspace
            ChatInput_DoBackspace()

            -- Reschedule the hold callback with each press
            if CB2_DaisyBackspace:Pending() then
                CB2_DaisyBackspace:Reschedule(0.5)
            -- Schedule a callback
            else
                CB2_DaisyBackspace:Schedule(0.5)
            end

        elseif args.is_released then

            if CB2_DaisyBackspace:Pending() then
                CB2_DaisyBackspace:Cancel()
            end

        end

    elseif action == "daisy_submit" then
        ChatInput_DoSubmit()

    elseif action == "daisy_caps" or action == "daisy_numbers" then

        -- Get key
        local modifierKey = (action == "daisy_caps" and DaisyConstants.AlphabetMode.Caps) or DaisyConstants.AlphabetMode.Numbers
        
        -- Update value
        g_DaisyState.modifiers[modifierKey] = args.is_pressed

        -- Determine mode
        if g_DaisyState.modifiers.caps and g_DaisyState.modifiers.numbers then
            g_DaisyState.mode = DaisyConstants.AlphabetMode.Special
        elseif g_DaisyState.modifiers.caps then
            g_DaisyState.mode = DaisyConstants.AlphabetMode.Caps
        elseif g_DaisyState.modifiers.numbers then
            g_DaisyState.mode = DaisyConstants.AlphabetMode.Numbers
        else
            g_DaisyState.mode = DaisyConstants.AlphabetMode.Default
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
                    local characterTable = DaisyOptions["Alphabet"][g_DaisyState.mode][g_DaisyState.direction]
                    character = characterTable[PIZZA_KEYBINDINGS_KEYCODE_INDEX[args.keycode]]
                end

                ChatInput_OnAddChatInput({text = character})
            end
        end
    end
 end


function ThumbstickTest(args)

    args.event = "ThumbstickTest " .. args.name

    Debug.Event(args)

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

function ChatInput_DoBackspace(args)
    
    local previousText = DAISY_INPUT:GetText()
    if previousText ~= "" then
        local newText = unicode.sub(previousText, 1, -2)
        DAISY_INPUT:SetText(newText)
        --if args and args.callback then CB2_DaisyBackspace:Schedule(0.05) end
    else
        Output("Nothing to remove!")
    end

end

function ChatInput_DoSubmit()
    ChatInput_OnChatSubmit()
end