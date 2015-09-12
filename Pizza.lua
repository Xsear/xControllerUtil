--Pizza.lua


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


function UpdatePizzaSlots(pizza)

    if pizza.isCustom then
        assert(#pizza.slots == 4, "this custom pizza doesnt have 4 slots :s")
        for slotIndex, slotData in ipairs(pizza.slots) do
            if not slotData.slotType then
                slotData.slotType = "empty"
            elseif slotData.slotType == "empty" then
                slotData.itemTypeId = nil
                slotData.iconId = nil
                slotData.techId = nil
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
