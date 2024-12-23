--- Thank you to dhert

------ local options = PZAPI.ModOptions:getOptions("SwapIt")
------ local option = options:getOption("SwapItSlot_"..slot.."_SwapWithHeld")
------ local option = options:getOption("SwapItSlot_"..slot.."_DirectAdd")

local function Config()

	local maxSlots = 10
	if getActivatedMods():contains("GEARCORE") then maxSlots = 15 end

	local options = PZAPI.ModOptions:create("SwapIt", "SwapIt")

	options:addTitle(getText("UI_options_SwapIt_WithHeldTitle"))
	options:addDescription(getText("UI_options_SwapIt_WithHeldDesc"))

	for slot=1, maxSlots do
		options:addTickBox("SwapItSlot_"..slot.."_SwapWithHeld", getText("UI_options_SwapIt_Slot", tostring(slot)), true)
	end

	options:addSeparator()

	options:addTitle(getText("UI_options_SwapIt_DirectAddTitle"))
	options:addDescription(getText("UI_options_SwapIt_DirectAddDesc"))

	for slot=1, maxSlots do
		options:addTickBox("SwapItSlot_"..slot.."_DirectAdd", getText("UI_options_SwapIt_Slot", tostring(slot)), true)
	end
end
Config()