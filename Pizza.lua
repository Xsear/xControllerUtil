
-- ------------------------------------------
-- Pizza
-- Why "Pizza"? Originally I called them "Pies", since they are round and have segments.
-- Then I realized I don't even like Pie, whilst I do love Pizza.
--   by: Xsear
-- ------------------------------------------

-- ------------------------------------------
-- GLOBALS
-- ------------------------------------------

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

-- Pizza Keysets
g_KeySet_PizzaActivators = nil
g_KeySet_PizzaDeactivators = nil
g_KeySet_CustomPizzaButtons = nil -- Note: Non-custom pizzas will have the same buttons, its just that we need one of these for the custom ones since we don't directly override binds with them.

-- Other pizza related variables
g_ExtraPizzaIndex = 1 -- Used when creating new pizzas
g_CurrentlyActivePizza = nil -- Updated to store the currently active pizza key when a pizza is active
g_GetPizzaByKeybindAction = {} -- Indexed by keybind actions with values of pizza keys

VERY_IMPORTANT_OVERRIDEN_KEYBINDS = nil

-- Fostered chat backdrop widget reference
w_FosteredBackdrop = nil

-- ------------------------------------------
-- LOAD
-- ------------------------------------------

function Pizza_OnComponentLoad()
    Debug.Log("Pizza_OnComponentLoad")

    -- Setup keybinds
    Pizza_SetupUserKeybinds()

    -- Setup fostered backdrop
    local FosterFrame = Component.GetFrame("FosterFrame")
    w_FosteredBackdrop = Component.CreateWidget('<group dimensions="dock:fill;"/>', FosterFrame)
    Component.FosterWidget("CursorModeBackdrop:CursorModeBackdrop.{1}", w_FosteredBackdrop)
    w_FosteredBackdrop:Show(false)
end

function Pizza_SetupUserKeybinds()

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
        g_KeySet_PizzaDeactivators:RegisterAction("ability_pizza_cancel", Pizza_DeactivationTrigger)
        for _, keyCode in ipairs(ABILITY_PIZZA_CANCELLATION_KEYS) do
            g_KeySet_PizzaDeactivators:BindKey("ability_pizza_cancel", keyCode)
        end

        -- Disable while creating the rest of the keybinds
        g_KeySet_PizzaDeactivators:Activate(false)


    -- g_KeySet_CustomPizzaButtons
    -- This keyset is used for custom pizzas since we are not replacing default binds with those
    g_KeySet_CustomPizzaButtons = UserKeybinds.Create()

        -- These buttons are hardcoded for now
        g_KeySet_CustomPizzaButtons:RegisterAction("press_calldown_pizza_button", Pizza_DeactivationTrigger, "release")
        for i, keyCode in ipairs(ABILITY_PIZZA_KEYBINDINGS_ORDER) do
            g_KeySet_CustomPizzaButtons:BindKey("press_calldown_pizza_button", keyCode, i)
        end

        -- Disable while creating the rest of the keybinds
        g_KeySet_CustomPizzaButtons:Activate(false)


    -- Ready
    g_KeySet_PizzaActivators:Activate(true)

end


-- ------------------------------------------
-- Keyset and keybind helpers
-- ------------------------------------------

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
    local handler = Pizza_Activate

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


-- ------------------------------------------
-- Main Logic
-- ------------------------------------------

function Pizza_CreateNew(args)
    Debug.Table("Pizza_CreateNew", args)

    -- Copy the base table
    local pizza = _table.copy(c_Pizza_Base)
    
    -- Use provided name and create key
    if args and args.name then
        pizza.name = name
        pizza.key = name -- TODO: This is gonna need some proofing

    -- Generate a name and key
    else
        pizza.name = "Extra " .. tostring(g_ExtraPizzaIndex)
        pizza.key = "extra" .. tostring(g_ExtraPizzaIndex)
        g_ExtraPizzaIndex = g_ExtraPizzaIndex + 1
    end

    -- Store this new and glorious Pizza
    g_Pizzas[pizza.key] = pizza

    -- Serve it to the lucky bastard who ordered it
    return pizza
end

function Pizza_IsActive()
    return (g_CurrentlyActivePizza ~= nil)
end

function Pizza_Activate(args)
    -- Ensure we don't have a pizza active already
    if not Pizza_IsActive() then

        -- Get info
        local pizzaAction = args.name
        local pizzaKey = g_GetPizzaByKeybindAction[pizzaAction]
        local pizza = g_Pizzas[pizzaKey]
        Debug.Log("Pizza_Activate", pizzaKey)

        -- Toggle activation/deactivation keysets
        g_KeySet_PizzaActivators:Activate(false)
        g_KeySet_PizzaDeactivators:Activate(true)

        -- Extra activation keyset if calldown
        if pizza.activationType == "calldown" then
            g_KeySet_CustomPizzaButtons:Activate(true)

        -- Override ability keybinds
        elseif pizza.activationType == "ability_override" then
            -- Do the crazy ability pizza keybind overriding
            DoTheCrazyAbilityPizzaKeyBindOverriding()
        end

        -- Update state
        g_CurrentlyActivePizza = pizzaKey
        Debug.Log("g_CurrentlyActivePizza: ", g_CurrentlyActivePizza)

        -- Display pizza
        pizza.w_PIZZA:SetParam("alpha", 0, 0.1)
        pizza.w_PIZZA:QueueParam("alpha", 1, 0.25, "ease-in")
        pizza.w_PIZZA:Show(true)
        
        -- Allow Pizza graphics
        w_PIZZA_CONTAINER:Show(true)
    else
        Output("Cannot have more than one pizza at a time!")
    end

end

function Pizza_Deactivate(args)

    if Pizza_IsActive() then

        -- Get info
        local triggerKeycode = args.keycode or nil
        local pizzaKey = g_CurrentlyActivePizza
        local pizza = g_Pizzas[pizzaKey]
        Debug.Log("Pizza_Deactivate", pizzaKey)

        -- Trigger calldown if we should
        if pizza.activationType == "calldown" and triggerKeycode then
            Debug.Log("Calldown activation by keycode", triggerKeycode, System.GetKeycodeString(triggerKeycode))

            -- Lookup slotIndex for this keycode
            local slotIndex = PIZZA_KEYBINDINGS_KEYCODE_INDEX[triggerKeycode]

            -- Ensure we have slotIndex
            if slotIndex then

                -- Get data
                local techId = 0
                local slotData = pizza.slots[slotIndex]

                -- Check that slot is valid and get techId
                if slotData.slotType == "calldown" then
                    techId = slotData.techId
                end

                -- Proceed only with the techId
                if techId ~= 0 then
                    Debug.Log("Attempt to activate calldown with techId", techId)

                    -- Find consumable item
                    Debug.Log("Scanning consumables for itemId")
                    local itemId = nil
                    local consumables = Player.GetConsumableItems()
                    for i, consumable in ipairs(consumables) do
                        if tonumber(consumable.itemTypeId) == tonumber(techId) then
                            itemId = consumable.abilityId or consumable.itemId
                            break
                        end
                    end

                    -- Proceed only with an itemId
                    if itemId ~= nil then
                        Debug.Log("Attempt to activate calldown with techId", techId, "and itemId", itemId)
                        Debug.Log("Game.CanUIActivateItem(itemId, techId)", tostring(Game.CanUIActivateItem(itemId, techId)))

                        -- Check if the UI will let us activate this kind of item at all
                        if Game.CanUIActivateItem(itemId, techId) then
                            -- In order to activate calldowns, we must be in cursor mode... So lets do a driveby!
                            Debug.Log("Setting cursor mode in order to activate calldown")
                            w_FosteredBackdrop:Show(false) -- Smooth criminal
                            Component.SetInputMode("cursor")
                            Callback2.FireAndForget(Component.SetInputMode, nil, 0.3) -- Hoping that we exit cursor mode even if we error
                            Callback2.FireAndForget(function(args)
                                                        Debug.Log("Delayed calldown activation firing")
                                                        Player.ActivateTech(args.itemId, args.techId)
                                                        Debug.Log("Calldown activation success")
                                                        Component.SetInputMode(nil)
                                                        w_FosteredBackdrop:Show(true)
                                                    end, {itemId=itemId, techId=techId}, 0.1)

                        else
                            Output("Sorry, it seems the game does not let the UI activate this calldown at this point of time")
                        end
                    else
                        Output("You don't seem to have any of this consumable in your inventory, so there is nothing to activate")
                    end

                else
                    Debug.Log("TechId is 0, so either this keycode isnt in the segmentData (user cancelled the pizza?) or the slot for this keycode doesnt have a calldown in it at the moment. Eitherway we can't activate anything this time.")
                end

            else
                Debug.Log("This keycode doesn't refer to a pizza slot, so do nothing")
            end

        end

        -- Disable extra activation keyset if calldown
        if pizza.activationType == "calldown" then
            g_KeySet_CustomPizzaButtons:Activate(false)

        -- Restore overriden ability keybinds
        elseif pizza.activationType == "ability_override" then
            -- Undo the crazy ability pizza keybind overriding
            UndoTheCrazyAbilityPizzaKeyBindOverriding()
        end

        -- Toggle activation/deactivation keysets
        g_KeySet_PizzaDeactivators:Activate(false)
        g_KeySet_PizzaActivators:Activate(true)

        -- Update state
        g_CurrentlyActivePizza = nil
        Debug.Log("g_CurrentlyActivePizza: ", g_CurrentlyActivePizza)

        -- Hide pizza
        pizza.w_PIZZA:Show(false)

        -- Disable Pizza graphics
        w_PIZZA_CONTAINER:Show(false)
    else
        Output("Cannot deactivate a pizza if there isn't one activated!")
    end


end

function Pizza_DeactivationTrigger(args)
    if Pizza_IsActive() then
        Pizza_Deactivate(args)
    end
end

function Pizza_UpdateAll(args)
    Debug.Divider()
    Debug.Log("Pizza_UpdateAll Begin")
    Debug.Event(args)

    -- Make sure we don't have a pizza active when this code runs, that seems dangerous
    Pizza_DeactivationTrigger(args)

    -- Update each pizza
    for pizzaKey, pizza in pairs(g_Pizzas) do
        Debug.Log("Updating Pizza with key " .. pizzaKey)

        -- Update slots
        UpdatePizzaSlots(pizza)

        -- Recreate pizza widget
        if pizza.w_PIZZA then Component.RemoveWidget(pizza.w_PIZZA) end
        pizza.w_PIZZA = {}
        pizza.w_PIZZA = CreatePizza(w_PIZZA_CONTAINER, pizza.slots)
        pizza.w_PIZZA:Show(false)
            
        -- Update OptionsUI bar entry
        if pizza.barEntry then
            for i, slot in ipairs(pizza.slots) do
                UpdatePizzaBarSlotIcon(pizzaKey, i, pizza.barEntry.slotIcons[i])
            end
        end
    end 

    Debug.Log("Pizza_UpdateAll Complete")
    Debug.Divider()
end


function UpdatePizzaSlots(pizza)
    Debug.Log("UpdatePizzaSlots data for pizza with key ", pizza.key)

    -- Pizzas with customizable data
    if pizza.isCustom then
        assert(#pizza.slots == 4, "this custom pizza doesnt have 4 slots :s")
        -- Iterate each slot and update the data
        for slotIndex, slotData in ipairs(pizza.slots) do
            -- Try not to leave empty slots with dirty data
            if slotData.slotType == "empty" or not slotData.slotType then
                slotData.slotType = "empty"
                slotData.itemTypeId = nil
                slotData.iconId = nil
                slotData.techId = nil
            -- Calldown slot
            elseif slotData.slotType == "calldown" then
                local itemInfo = Game.GetItemInfoByType(slotData.itemTypeId)
                if slotData.itemTypeId == 0 or not itemInfo or not next(itemInfo) then
                    slotData.slotType = "empty"
                    slotData.itemTypeId = nil
                    slotData.iconId = nil
                    slotData.techId = nil
                else
                    slotData.slotType = "calldown"
                    slotData.itemTypeId = slotData.itemTypeId
                    slotData.iconId = itemInfo.web_icon_id
                    slotData.techId = slotData.itemTypeId
                end
            end
        end

    -- Pizzas that get their data some other way
    else
        -- Ability Pizza
        if pizza.activationType == "ability_override" then
            -- Get current abilities
            local abilities = Player.GetAbilities().slotted
            -- Let's hope we at least got something
            if abilities then
                -- Update each slot
                for slotIndex, slotData in ipairs(pizza.slots) do
                    -- Try to get ability data for this slot
                    local ability = abilities[slotIndex]
                    -- If no data, set slot empty
                    if not ability or not next(ability) then
                        slotData.slotType = "empty"
                        slotData.iconId = nil
                    -- Fill slot with data
                    else
                        local abilityInfo = Player.GetAbilityInfo(ability.abilityId)
                        slotData.slotType = "ability"
                        slotData.iconId = abilityInfo.iconId
                    end
                end
            -- Warn if we got aboslutely nothing
            else
                Debug.Warn("Could not get any abilities")
            end
        end
    end
end


-- ------------------------------------------
-- Widget code
-- ------------------------------------------

-- Based on CreateSegWheel from Arkii's Invii <3
function CreatePizza(PARENT, segmentData)
    Debug.Table("CreatePizza with segmentData", segmentData)
    local cont = Component.CreateWidget('<Group blueprint="Pizza" dimensions="width:50%; height:50%; center-y:50%; center-x:50%;"></Group>', PARENT)
    local numberOfSegments = 4
    local perSegPrecent = (100/numberOfSegments)

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
    return cont
end






-- Todo: Replace these outliers with standardized functions written on the Daisy branch
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

-- Todo: Replace these outliers with standardized functions written on the Daisy branch
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








