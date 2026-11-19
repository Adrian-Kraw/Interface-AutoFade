local _, ns = ...

local TEMPLATE = ns.TEMPLATE
local ROW_EXTENT = ns.ROW_EXTENT

local ROUNDING_OFFSET = 0.5

-- GetChecked returns a boolean in current clients, older ones return 1 or nil.
local function IsChecked(checkButton)
    return checkButton:GetChecked() and true or false
end

local function RoundValue(value)
    return math.floor(value + ROUNDING_OFFSET)
end

-- A disabled module cannot be expanded, so switching it off also folds it.
local function InitHeader(button, node)
    local data = node:GetData()
    button.name:SetText(data.name)
    button.enableButton:SetChecked(data.getEnabled())

    button:SetScript("OnClick", function()
        if data.getEnabled() then
            node:ToggleCollapsed()
        else
            node:SetCollapsed(true)
        end
    end)

    button.enableButton:SetScript("OnClick", function(checkButton)
        local enabled = IsChecked(checkButton)
        data.setEnabled(enabled)
        if not enabled then
            node:SetCollapsed(true)
        end
    end)
end

local function InitToggle(row, node)
    local data = node:GetData()
    row.name:SetText(data.name)
    row.toggle:SetChecked(data.getValue())
    row.toggle:SetScript("OnClick", function(checkButton)
        data.setValue(IsChecked(checkButton))
        -- Mirror the stored value, so the check never shows a stale state.
        checkButton:SetChecked(data.getValue())
    end)
end

local function InitSlider(row, node)
    local data = node:GetData()
    local slider = row.slider
    row.label:SetText(data.label)

    -- Remove the old callback before range and value change. A recycled row would
    -- otherwise write the clamped value into the setting of its previous owner.
    slider:SetScript("OnValueChanged", nil)
    slider:SetMinMaxValues(data.min, data.max)
    slider:SetValueStep(data.step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(data.getValue())
    row.valueText:SetText(data.format(RoundValue(slider:GetValue())))

    slider:SetScript("OnValueChanged", function(_, value)
        local rounded = RoundValue(value)
        data.setValue(rounded)
        row.valueText:SetText(data.format(rounded))
    end)
end

local function InitInfo(row, node)
    row.info:SetText(node:GetData().text)
end

local function InitSeparator(row, node)
    row.label:SetText(node:GetData().label)
end

local INITIALIZERS = {
    [TEMPLATE.HEADER] = InitHeader,
    [TEMPLATE.TOGGLE] = InitToggle,
    [TEMPLATE.SLIDER] = InitSlider,
    [TEMPLATE.INFO] = InitInfo,
    [TEMPLATE.SEPARATOR] = InitSeparator,
}

local Rows = {}

function Rows.Factory(factory, node)
    local template = node:GetData().template
    factory(template, INITIALIZERS[template])
end

function Rows.GetExtent(_, node)
    return ROW_EXTENT[node:GetData().template]
end

ns.Rows = Rows
