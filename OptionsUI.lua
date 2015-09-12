
-- ------------------------------------------
-- OptionsUI
--   by: Xsear
-- ------------------------------------------

-- ------------------------------------------
-- CONSTANTS
-- ------------------------------------------

DRAG_ORIGIN_CU = "xcontrollerutil"
DRAG_ORIGIN_ACTIONBAR = "3dactionbar"


-- ------------------------------------------
-- GLOBALS
-- ------------------------------------------

-- References
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
-- LOAD
-- ------------------------------------------

function OptionsUI_OnComponentLoad()
    Debug.Log("OptionsUI_OnComponentLoad")

    -- Register with PanelManager
    PanelManager.RegisterFrame(OptionsUI.MAIN, ToggleOptionsUI, {show=false})
    
    -- Setup with MovablePanel
    MovablePanel.ConfigFrame({
        frame = OptionsUI.MAIN,
        MOVABLE_PARENT = OptionsUI.MOVABLE_PARENT
    })

    -- Setup the Window
    SetupWindow()

    -- Setup the Pizza Config Pane
    SetupPizzaConfigPane()
 
    -- Create layout for Second Pane
    OptionsUI.PANE_SECOND_LAYOUT = Component.CreateWidget("PaneLayoutMain", OptionsUI.PANE_SECOND)
end

function SetupWindow()
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
end


function SetupPizzaConfigPane()
    -- Create layout for Main Pane and setup early references
    OptionsUI.PANE_MAIN_LAYOUT = Component.CreateWidget("PaneLayoutMain", OptionsUI.PANE_MAIN)
    OptionsUI.PANE_MAIN_LEFT_COLUMN = OptionsUI.PANE_MAIN_LAYOUT:GetChild("LeftColumn")
    OptionsUI.PANE_MAIN_MAIN_AREA = OptionsUI.PANE_MAIN_LAYOUT:GetChild("MainArea")
    OptionsUI.PANE_MAIN_MAIN_AREA_LIST = OptionsUI.PANE_MAIN_MAIN_AREA:GetChild("List")

    -- Create left column menu buttons
    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON = Component.CreateWidget('<Button id="CreatePizzaButton" key="{Add Pizza}" dimensions="left:10.25; width:100%-20.5; top:2.5%; height:75"/>', OptionsUI.PANE_MAIN_LEFT_COLUMN)
    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON:BindEvent("OnMouseDown", AddPizzaButton)

    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON5 = Component.CreateWidget('<Button id="RedetectButton" key="{Redetect Controllers}" dimensions="left:10.25; width:100%-20.5; bottom:97.5%; height:75"/>', OptionsUI.PANE_MAIN_LEFT_COLUMN)
    OptionsUI.PANE_MAIN_LEFT_COLUMN_BUTTON5:BindEvent("OnMouseDown", DetectActiveGamepad)

    -- Create Pizza Bar list
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
end

-- Button to create a new Pizza
function AddPizzaButton(args)
    Debug.Table("AddPizzaButton", args)
    Debug.Log("Is args.widget widget? : ", tostring(Component.IsWidget(args.widget)))
    Debug.Log("This was button with name : ", args.widget:GetName())

    -- Todo: Popup Prompt to decide Name (and possibly type)
    local pizza = Pizza_CreateNew() -- Should include name
    pizza.barEntry = CreatePizzaBarEntry(pizza)
    Pizza_UpdateAll() -- Dunno
end


function SetupOptionsUIBarList()
    -- Create bar entries
    for pizzaKey, pizza in pairs(g_Pizzas) do
        pizza.barEntry = CreatePizzaBarEntry(pizza)
        Debug.Log("barEntry for " .. pizzaKey .. " has been created")
    end
end



-- ------------------------------------------
-- Drag and Drop
-- ------------------------------------------

-- No idea what this event function is for
function OnDragDropEnd(args)
    if (args and args.canceled and args.dragdata and type(args.dragdata) == "string") then
        local dragdata = jsontotable(args.dragdata);
        
        if (dragdata and dragdata.from == DRAG_ORIGIN_ACTIONBAR) then
            Debug.Event(args)
        end
    end
end

-- Sets up the focusbox associated with the drop area of a pizza slot icon
function SetupDropFocus(w, pizzaKey, segmentIndex)
    local dropFocus = w:GetChild("focus")
    dropFocus:BindEvent("OnMouseDown", function()
        if (not PizzaSegmentEmpty(pizzaKey, segmentIndex)) then
            Component.BeginDragDrop("item_sdb_id", GetDragInfoForPizzaSegment(pizzaKey, segmentIndex), nil)
        end
    end)
    dropFocus:SetCursor("sys_hand");
end

-- Sets up the droptarget associated with the drop area of a pizza slot icon
-- Also defines the handlers for the Drag and Drop events
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


-- ------------------------------------------
-- Slotting functions
-- ------------------------------------------

-- Basic Getter for the information in a slot
function GetPizzaSegment(pizzaKey, segmentIndex)
    local pizza = g_Pizzas[pizzaKey]
    assert(pizza, "who ate my pizza D:")
    local segment = pizza.slots[segmentIndex]
    return segment
end

-- The correct method to check if a slot is "empty"
function PizzaSegmentEmpty(pizzaKey, segmentIndex)
    local segment = GetPizzaSegment(pizzaKey, segmentIndex)
    return (segment.slotType == "empty")
end

-- Generates the text string to be provided to Component.BeginDragDrop with info on our Pizza Segment
function GetDragInfoForPizzaSegment(pizzaKey, segmentIndex)
    local slot = GetPizzaSegment(pizzaKey, segmentIndex)
    assert(slot.slotType == "calldown", "dont know how to get drag info for this slot type (" .. tostring(slot.slotType) .. ")")
    return tostring({pizza = pizzaKey, index = segmentIndex, itemSdbId = slot.itemTypeId, from = DRAG_ORIGIN_CU})
end

-- Logic function for moving the data of one slot to another (and, if the destination is occupied, moving that information to where we came from)
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

-- Inserts data into a slot
function InsertPizzaSegment(pizzaKey, itemTypeId, segmentIndex)
    -- Retrieve current data
    local slotData = GetPizzaSegment(pizzaKey, segmentIndex)

    -- Set the new itemTypeId
    slotData.itemTypeId = itemTypeId
    
    -- Set the new slotType
    if tonumber(itemTypeId) == 0 then -- :s not sure about types here
        slotData.slotType = "empty"
    else
        slotData.slotType = "calldown"
    end

    -- Save
    g_Pizzas[pizzaKey].slots[segmentIndex] = slotData

    -- Trigger pizzas to be updated
    Pizza_UpdateAll({event="InsertPizzaSegment"})
        
    -- Update OptionsUI icon
    UpdatePizzaBarSlotIcon(pizzaKey, segmentIndex)
end

-- Remove data from a slot
function EatPizzaSegment(pizzaKey, segmentIndex)
    InsertPizzaSegment(pizzaKey, 0, segmentIndex)
end


-- ------------------------------------------
-- Widget functions
-- ------------------------------------------

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
    local KEYCATCHER = Component.CreateWidget([=[<KeyCatcher dimensions="left:0; right:1; top:0; bottom:1;"/>]=], Component.GetWidget("Window")) -- Todo: This seems kinda bad, creating tons of them?

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
    if not IsKeysetActionRegistered(g_KeySet_PizzaActivators, GetPizzaActivatorAction(pizza.key)) then -- This is a check to see if the action is registered, other api functions do "assert(action)" so this is how its gonna be
        RegisterPizzaActivator(pizza.key) -- When adding custom pizzas :)
    end
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

