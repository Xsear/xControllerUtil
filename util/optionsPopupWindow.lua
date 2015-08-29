
-- ------------------------------------------
-- PopupWindow
--   by: Brian Blose
-- ------------------------------------------

--require "unicode"
--require "math"
--require "table"

-- ------------------------------------------
-- CONSTANTS
-- ------------------------------------------
local POPUP                 = Component.GetFrame("Popup")
local POPUP_ART             = POPUP:GetChild("Art")
local MOUSEBLOCKER          = Component.GetWidget("MouseBlocker")

local lf = {}           --table for local functions
--Question
local Q = {}
Q.GROUP         = POPUP:GetChild("Question")
Q.TEXT          = Q.GROUP:GetChild("Text")
Q.TEXTTIMER     = Q.GROUP:GetChild("TextTimer")

--Tooltip
local TT = {}
TT.GROUP        = POPUP:GetChild("Tooltip")
TT.TITLE        = TT.GROUP:GetChild("Title")
TT.DESC         = TT.GROUP:GetChild("Description")
TT.MOVEICON     = TT.GROUP:GetChild("MoveIcon")
TT.MOVETEXT     = TT.GROUP:GetChild("MoveText")
TT.SCALEICON    = TT.GROUP:GetChild("ScaleIcon")
TT.SCALETEXT    = TT.GROUP:GetChild("ScaleText")


-- ------------------------------------------
-- VARIABLES
-- ------------------------------------------
local g_TooltipVisible
local g_CurrentDisplay = nil
local g_QuestionDetails
local cb_timeout = nil
local cb_ShowTooltip
local cb_HideTooltip
local bp_Button = [[<Button dimensions="dock:fill" style="font:UbuntuMedium_9;"/>]]

-- ------------------------------------------
-- EVENT FUNCTIONS
-- ------------------------------------------
function Popup_OnMouseDown(args)
    if args.timeout then
        if type(g_QuestionDetails.OnTimeout) == "number" then
            g_QuestionDetails[g_QuestionDetails.OnTimeout].OnClick()
        else
            g_QuestionDetails.OnTimeout()
        end
    elseif args.target then
        local i = tonumber(args.target:GetTag())
        if g_QuestionDetails[i].OnClick then
            g_QuestionDetails[i].OnClick()
        end
    end
    if cb_timeout then
        cancel_callback(cb_timeout)
        cb_timeout = nil
    end
    Popup_CancelQuestion()
end

function Popup_OnMouseEnter(args)
    local i = tonumber(args.target:GetTag())
    if g_QuestionDetails and g_QuestionDetails[i] and g_QuestionDetails[i].OnEnter then
        g_QuestionDetails[i].OnEnter()
    end
end

function Popup_OnMouseLeave(args)
    local i = tonumber(args.target:GetTag())
    if g_QuestionDetails and g_QuestionDetails[i] and g_QuestionDetails[i].OnLeave then
        g_QuestionDetails[i].OnLeave()
    end
end

for i = 1, 3 do
    Q[i]        = {}
    Q[i].BUTTON = Component.CreateWidget(bp_Button, Q.GROUP)
    Q[i].BUTTON:SetTag(tostring(i))
    Q[i].BUTTON:BindEvent("OnSubmit", function() Popup_OnMouseDown({target=Q[i].BUTTON}) end)
    Q[i].BUTTON:BindEvent("OnMouseEnter", function() Popup_OnMouseEnter({target=Q[i].BUTTON}) end)
    Q[i].BUTTON:BindEvent("OnMouseLeave", function() Popup_OnMouseLeave({target=Q[i].BUTTON}) end)
end

function Popup_OnEscape()
    local method = type(g_QuestionDetails.OnEscape)
    if method == "number" then
        if g_QuestionDetails[g_QuestionDetails.OnEscape].OnClick then
            g_QuestionDetails[g_QuestionDetails.OnEscape].OnClick()
        end
    elseif method == "function" then
        g_QuestionDetails.OnEscape()
    end
    if cb_timeout then
        cancel_callback(cb_timeout)
        cb_timeout = nil
    end
    Popup_CancelQuestion()
end

-- ------------------------------------------
-- GENERAL FUNCTIONS
-- ------------------------------------------
function Popup_ShowQuestion(args)
    --[[Usage:
        Text = text to display as the prompt
        Timer = Timeout timer
        OnTimeout = if there is a timer then this is either the number of 1 or 2 that explains which OnClick to use on timeout or a unique function
        OnEscape = what function (1, 2 or a unique function) to run if the user presses the escape key, regardless of OnEscape a Popup_CancelQuestion will run
        [1-3] = array of 2 for the 2 button choices, 1= left, 2 = right/center, 3 = right
            Label = text of button
            TintPlate = tint for the button
            OnClick = func of button OnMouseDown
            OnEnter = Optional extra functionality for OnMouseEnter
            OnLeave = Optional extra functionality for OnMouseLeave
    --]]
    if g_CurrentDisplay ~= "Question" then
        g_CurrentDisplay = "Question"
        g_QuestionDetails = args
        POPUP:SetDims("center-y:50%; width:461")
        local height = 60
        if args.Timer and args.Timer > 0 and args.OnTimeout then
            Q.TEXTTIMER:SetFormat(args.Text)
            Q.TEXTTIMER:StartTimer(args.Timer, true)
            height = height + Q.TEXTTIMER:GetTextDims().height
            cb_timeout = callback(function()
                cb_timeout = nil
                Popup_OnMouseDown({timeout=true})
            end, nil, args.Timer)
        else
            Q.TEXT:SetText(args.Text)
            height = height + Q.TEXT:GetTextDims().height
        end
        
        local num_buttons = #args
        if num_buttons == 2 then
            Q[1].BUTTON:SetDims("width:24%; bottom:100%-12; height:24; center-x:30%")
            Q[2].BUTTON:SetDims("width:24%; bottom:100%-12; height:24; center-x:70%")
            Q[3].BUTTON:Hide()
        else
            Q[1].BUTTON:SetDims("width:24%; bottom:100%-12; height:24; center-x:19%")
            Q[2].BUTTON:SetDims("width:24%; bottom:100%-12; height:24; center-x:50%")
            Q[3].BUTTON:SetDims("width:24%; bottom:100%-12; height:24; center-x:81%")
            Q[3].BUTTON:Show()
        end
        for i = 1, num_buttons do
            Q[i].BUTTON:SetText(args[i].Label)
            Q[i].BUTTON:ParamTo("tint", args[i].TintPlate, 0)
        end
        
        Q.TEXT:Show(not args.Timer)
        Q.TEXTTIMER:Show(args.Timer)
        Q.GROUP:Show()
        TT.GROUP:Hide()
        MOUSEBLOCKER:Show()
        lf.SetPopupDims("center-x:50%; center-y:50%; ", 460, height, "screen")
        POPUP_ART:ParamTo("alpha", 1, 0.15)
        Q.GROUP:ParamTo("alpha", 1, 0.15)
        POPUP:Show()
    else
        error("Waiting on another question")
    end
end

function Popup_ShowOptionTooltip(ov)
    if g_CurrentDisplay ~= "Question" then
        if g_TooltipVisible == ov.id then
            if cb_HideTooltip then
                cancel_callback(cb_HideTooltip)
                cb_HideTooltip = nil
            end
            return
        elseif cb_HideTooltip then
            execute_callback(cb_HideTooltip)
        end
        g_CurrentDisplay = "OptionTooltip"
        g_TooltipVisible = ov.id
        cb_ShowTooltip = callback(function()
            POPUP:SetDims(POPUP:GetInitialDims())
            TT.TITLE:SetText(ov.label)
            TT.DESC:SetText(ov.tooltip)
            TT.DESC:Show()
            local title_dims = TT.TITLE:GetTextDims()
            local desc_dims = TT.DESC:GetTextDims()
            lf.SetPopupDims(lf.GetPopupDimString(), math.max(title_dims.width, desc_dims.width)+20, desc_dims.height+34, "cursor")
            POPUP_ART:ParamTo("alpha", 1, 0.05)
            TT.GROUP:ParamTo("alpha", 1, 0.05)
            TT.GROUP:Show()
            TT.MOVEICON:Hide()
            TT.MOVETEXT:Hide()
            TT.SCALEICON:Hide()
            TT.SCALETEXT:Hide()
            Q.GROUP:Hide()
            POPUP:Show()
            cb_ShowTooltip = nil
        end, nil, 0.7)
    end
end

function Popup_ShowFrameTooltip(args)
    if g_CurrentDisplay ~= "Question" then
        if g_TooltipVisible == args.title then
            if cb_HideTooltip then
                cancel_callback(cb_HideTooltip)
                cb_HideTooltip = nil
            end
            Popup_UpdateFrameToolitpContents(args)
            return
        elseif g_TooltipVisible and not cb_HideTooltip then
            Popup_HideTooltip()
        end
        if cb_HideTooltip then
            execute_callback(cb_HideTooltip)
        end
        g_CurrentDisplay = "FrameTooltip"
        g_TooltipVisible = args.title
        cb_ShowTooltip = callback(function()
            POPUP:SetDims(POPUP:GetInitialDims())
            Popup_UpdateFrameToolitpContents(args)
            POPUP_ART:ParamTo("alpha", 1, 0.05)
            TT.GROUP:ParamTo("alpha", 1, 0.05)
            TT.GROUP:Show()
            TT.DESC:Hide()
            Q.GROUP:Hide()
            POPUP:Show()
        end, nil, 0.45)
    end
end

function Popup_CancelQuestion()
    if g_CurrentDisplay == "Question" then
        g_CurrentDisplay = nil
        g_QuestionDetails = nil
        Q.TEXTTIMER:StopTimer()
        Q.GROUP:ParamTo("alpha", 0, 0.15)
        POPUP_ART:ParamTo("alpha", 0, 0.15)
        Q.GROUP:Hide(true, 0.15)
        POPUP:Hide(true, 0.15)
        MOUSEBLOCKER:Hide()
    end
end

function Popup_HideTooltip(id)
    if g_TooltipVisible and (g_TooltipVisible == id or id == nil) then
        if cb_HideTooltip then
            cancel_callback(cb_HideTooltip)
        end
        cb_HideTooltip = callback(function()
            if cb_ShowTooltip then
                cancel_callback(cb_ShowTooltip)
                cb_ShowTooltip = nil
                g_TooltipVisible = nil
            end
            g_TooltipVisible = false
            g_CurrentDisplay = nil
            local dur = 0.05
            POPUP_ART:ParamTo("alpha", 0, dur)
            TT.GROUP:ParamTo("alpha", 0, dur)
            TT.DESC:Hide(true, dur)
            TT.MOVEICON:Hide(true, dur)
            TT.MOVETEXT:Hide(true, dur)
            TT.SCALEICON:Hide(true, dur)
            TT.SCALETEXT:Hide(true, dur)
            TT.SCALEICON:Hide(true, dur)
            POPUP:Hide(true, dur)
            g_ActiveTooltip = nil
            cb_HideTooltip = nil
        end, nil, 0.05)
    end
end

-- ------------------------------------------
-- UTILITY/RETURN FUNCTIONS
-- ------------------------------------------
function lf.SetPopupDims(dim_string, width, height, relative)
    -- min dims height:58; width:101;
    POPUP:SetDims(dim_string.."width:"..width.."; height:"..height.."; relative:"..relative)
end

function lf.GetPopupDimString()
    local c_X, c_Y = Component.GetCursorPos()
    local s_width, s_height = Component.GetScreenSize(false)
    local offset = "15; "
    local dim_string
    if s_width/2 < c_X then
        dim_string = "right:-"..offset
    else
        dim_string = "left:"..offset
    end
    if s_height/2 < c_Y then
        dim_string = dim_string.."bottom:-"..offset
    else
        dim_string = dim_string.."top:"..offset
    end
    return dim_string
end

function Popup_UpdateFrameToolitpContents(args)
    TT.TITLE:SetText(args.title)
    local title_width = TT.TITLE:GetTextDims().width
    TT.MOVEICON:Show()
    TT.MOVETEXT:Show()
    local height = 50
    local move_width = TT.MOVETEXT:GetTextDims().width
    local scale_width = 0
    if args.scale then
        TT.SCALEICON:SetRegion("mwheel")
        TT.SCALETEXT:SetText(Component.LookupText("CURRENT_SCALE", args.scale))
        TT.SCALEICON:Show()
        TT.SCALETEXT:Show()
        scale_width = TT.SCALETEXT:GetTextDims().width
        height = 74
    elseif args.resizable then
        TT.SCALEICON:SetRegion("mouse1")
        TT.SCALETEXT:SetText(Component.LookupText("RESIZABLE"))
        TT.SCALEICON:Show()
        TT.SCALETEXT:Show()
        scale_width = TT.SCALETEXT:GetTextDims().width
        height = 74
    else
        TT.SCALEICON:Hide()
        TT.SCALETEXT:Hide()
    end
    local width = math.max(move_width, scale_width) + 18 --the larger entry plus space for the icon
    width = math.max(width, title_width) + 25 --the larger space plus space for a bit of margin
    lf.SetPopupDims(lf.GetPopupDimString(), width, height, "cursor")
end

function Popup_IsQuestionActive()
    if g_QuestionDetails then
        return true
    else
        return false
    end
end
