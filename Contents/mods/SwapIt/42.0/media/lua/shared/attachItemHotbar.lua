require("TimedActions/ISAttachItemHotbar")

local action_new = ISAttachItemHotbar.new
function ISAttachItemHotbar:new(character, item, slot, slotIndex, slotDef)
    local o = action_new(self, character, item, slot, slotIndex, slotDef)
    o.stopOnAim = false
    return o
end