--InterfaceOptions.lua

require "lib/lib_InterfaceOptions"

g_Options = {}
g_DefaultOptions = nil

function InterfaceOptions_OnComponentLoad(args)
    -- Notifications
    InterfaceOptions.NotifyOnLoaded(true) -- Notify us when all options have been loaded (we don't play sounds before that)
    InterfaceOptions.NotifyOnDefaults(true) -- Notify us when user resets the options
    InterfaceOptions.NotifyOnDisplay(true) -- Notify us when the user opens the interface options

    -- Callback
    InterfaceOptions.SetCallbackFunc(InterfaceOptions_OnOptionUpdate, 'Controller Utilities') -- Callback for when user changes settings

    -- Save version
    InterfaceOptions.SaveVersion(1) -- Settings save-version, increment if behavior changes


    BuildDaisyWheelOptions()
end

function InterfaceOptions_OnOptionUpdate(id, value)

    if not g_DefaultOptions then g_DefaultOptions = _table.copy(g_Options) end

    -- Handle Notifications
    if id == "__LOADED" then
        OnOptionsLoaded()

    elseif id == '__DEFAULT' then
        -- Note: NYI
        Debug.Log("trying default")
        g_Options = _table.copy(g_DefaultOptions)
        BuildDaisyWheel() -- TODO: Temp :D

    elseif id == '__DISPLAY' then
        -- Note: NYI
    
    -- Handle Option Changed
    else
        InterfaceOptions_OnOptionChanged(id, value)
    end
end

function InterfaceOptions_OnOptionChanged(id, value)
    InterfaceOptions_UpdateOptionById(id, value)
    InterfaceOptions_SetOptionsAvailability()

    if g_OptionsLoaded then
        BuildDaisyWheel() -- TODO: Temp :D
    end
end

function InterfaceOptions_UpdateOptionById(id, newValue)

    -- From loot tracker
    function digOptions(table, args, refs, depth, key)
        if depth == nil then
            depth = 1 -- start at 1
        else
            depth = depth + 1
        end

        if type(table) == 'table' then
            for tableKey, tableValue in pairs(table) do
                -- If there's a key in this table that matches the option id at the current depth, we're on the right track
                if tableKey == refs[depth] then
                    -- If the value of this key we found is not a table, then we're at the end of the digging. This should be the option we were looking for.
                    if type(tableValue) ~= 'table' then
                        table[tableKey] = args.val

                    -- If the value of the option we are updating is a table - and the option id we are working with ends at this depth, that's all right too.
                    elseif type(args.val) == 'table' and #refs == depth then
                        table[tableKey] = args.val

                    -- Otherwise, we still have some more digging to do.
                    else 
                        digOptions(tableValue, args, refs, depth, tableKey)
                    end
                    return
                end
            end
        end
    end

    -- from: http://lua-users.org/wiki/SplitJoin
    require "string"
    function splitExplode(d,p)
      local t, ll
      t={}
      ll=0
      if(#p == 1) then return {p} end
        while true do
          l=string.find(p,d,ll,true) -- find the next d in the string
          if l~=nil then -- if 'not not' found then..
            table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
            ll=l+1 -- save just after where we found it for searching next time.
          else
            table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
            break -- Break at end, as it should be, according to the lua manual.
          end
        end
      return t
    end


    digOptions(g_Options, {id=id, val=newValue}, splitExplode('_', id))
end

function InterfaceOptions_SetOptionsAvailability(args)
end



function BuildDaisyWheelOptions()
    InterfaceOptions_RegisterOption({
                                    id = InterfaceOptions_GenerateOptionId(g_Options.Daisy.Sizes, "WheelScale"),
                                    default = g_Options.Daisy.Sizes.WheelScale,
                                    type = "slider",
                                    min = 0.1,
                                    max = 10,
                                    inc = 0.01,
                                    multi = 100,
                                    suffix = "%",
                                    })
    InterfaceOptions_RegisterOption({
                                    id = InterfaceOptions_GenerateOptionId(g_Options.Daisy.Sizes, "PetalWidth"),
                                    default = g_Options.Daisy.Sizes.PetalWidth,
                                    type = "slider",
                                    min = 1,
                                    max = 3000,
                                    inc = 1,
                                    suffix = "px",
                                    })
    InterfaceOptions_RegisterOption({
                                    id = InterfaceOptions_GenerateOptionId(g_Options.Daisy.Sizes, "PetalHeight"),
                                    default = g_Options.Daisy.Sizes.PetalHeight,
                                    type = "slider",
                                    min = 1,
                                    max = 3000,
                                    inc = 1,
                                    suffix = "px",
                                    })
    InterfaceOptions_RegisterOption({
                                    id = InterfaceOptions_GenerateOptionId(g_Options.Daisy.Sizes, "EntryWidth"),
                                    default = g_Options.Daisy.Sizes.EntryWidth,
                                    type = "slider",
                                    min = 1,
                                    max = 3000,
                                    inc = 1,
                                    suffix = "px",
                                    })
    InterfaceOptions_RegisterOption({
                                    id = InterfaceOptions_GenerateOptionId(g_Options.Daisy.Sizes, "EntryHeight"),
                                    default = g_Options.Daisy.Sizes.EntryHeight,
                                    type = "slider",
                                    min = 1,
                                    max = 3000,
                                    inc = 1,
                                    suffix = "px",
                                    })
end


-- Over engineered prototypes below

function InterfaceOptions_GetValueById(id)
end


function InterfaceOptions_GetReferenceById(id)
end


function InterfaceOptions_AddModuleOption()
end

function InterfaceOptions_RegisterOption(args)

    -- Validate
    assert(args.id)
    assert(type(args.id) == "string")
    assert(args.type)
    assert(type(args.type) == "string")
    assert(args.default)


    local c_OptionTypeToAddFunction = {
        ["slider"] = InterfaceOptions.AddSlider,
        ["checkbox"] = InterfaceOptions.AddCheckBox,
        ["input"] = InterfaceOptions.AddCheckBox,
        ["color"] = InterfaceOptions.AddColorPicker,
        ["select"] = InterfaceOptions.AddChoiceMenu,
    }


    assert(c_OptionTypeToAddFunction[args.type])

    if args.type == "slider" then
        assert(type(args.default) == "number")
        assert(args.min)
        assert(type(args.min) == "number")
        assert(args.max)
        assert(type(args.max) == "number")
        assert(args.inc)
        assert(type(args.inc) == "number")

    elseif args.type == "checkbox" then

        assert(type(args.default) == "boolean")

    elseif args.type == "input" then

        assert(type(args.default) == "string")

    elseif args.type == "color" then

        assert(type(args.default) == "table")
        assert(args.default.tint)
        assert(type(args.default.tint) == "string")

    end

    args.label = 'io_' .. args.id .. "_label"
    args.tooltip = 'io_' .. args.id .. "_tooltip"

    local AddFunc = c_OptionTypeToAddFunction[args.type]
    args.type = nil
    AddFunc(args)
end


function InterfaceOptions_GenerateOptionId(tableReference, keyName)

    function DiggingFunction(tableWeAreSearching, tableWeAreLookingFor, currentDepth, currentPathTable)

        --local args = {event = "DiggingFunction", tableWeAreSearching = tableWeAreSearching, tableWeAreLookingFor = tableWeAreLookingFor, currentDepth = currentDepth, currentPathTable = currentPathTable}
        --Debug.Event(args)

        -- Care! This means we must increment the depth when we call.
        currentDepth = currentDepth or 1
        currentPathTable = currentPathTable or {[1] = "InterfaceOptionsId"}

        -- Scan this table
        local additionalTableKeysToScan = {}
        for key, value in pairs(tableWeAreSearching) do
            --Debug.Log("Loop - tableWeAreSearching")
            --Debug.Table({key=key, value=value})
            if type(value) == "table" then
                if value == tableWeAreLookingFor then
                    -- Found Lowest Table!
                    --Debug.Warn("Found Lowest Table - Returning From Digging Function")
                    currentPathTable[currentDepth + 1] = key
                    return currentPathTable
                else
                    additionalTableKeysToScan[key] = true
                end
            end
        end

        -- Scan depths
        local nextDepth = currentDepth + 1
        for key, table in pairs(additionalTableKeysToScan) do
            currentPathTable[nextDepth] = key
            
            if DiggingFunction(tableWeAreSearching[key], tableWeAreLookingFor, nextDepth, currentPathTable) then
                return currentPathTable
            end
        end

    end

    local pathTable = DiggingFunction(g_Options, tableReference)

    --Debug.Warn("We have returned from the Digging Function!")
    --Debug.Table("Returned Path Table is the following ", pathTable)

    pathTable[#pathTable + 1] = keyName

    local generatedId = table.concat(pathTable, "_", 2)

    return generatedId
end