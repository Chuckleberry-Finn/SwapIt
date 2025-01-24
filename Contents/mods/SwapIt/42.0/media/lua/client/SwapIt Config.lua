--- Thank you to dhert
------ local options = PZAPI.ModOptions:getOptions("SwapIt")
------ local option = options:getOption("SwapItSlot_"..slot.."_SwapWithHeld"):getValue()
------ local option = options:getOption("SwapItSlot_"..slot.."_DirectAdd"):getValue()

local ConfigureIt = {}

ConfigureIt.maxSlots = 10

function ConfigureIt.addConfig()

	local options = PZAPI.ModOptions:create("SwapIt", "SwapIt")

	local file = getFileReader("modOptions.ini", true)
	local line = nil
	if file then
		while true do
			line = file:readLine()
			if line == nil then file:close() break end
			if line:match("^textentry|SwapIt|SwapItSlot_MAX|") then
				local value = line:match("|(%d+)$")
				if value then ConfigureIt.maxSlots = value end
			end
		end
	end

	ConfigureIt.maxSlots = tonumber(ConfigureIt.maxSlots)
	if not ConfigureIt.maxSlots then return end

	ConfigureIt.maxSlots = math.min(ConfigureIt.maxSlots, 100)

	ConfigureIt.maxSlots = options:getOption("SwapItSlot_MAX") and options:getOption("SwapItSlot_MAX"):getValue() or ConfigureIt.maxSlots

	if not options then return end

	options:addTextEntry("SwapItSlot_MAX", getText("UI_options_SwapIt_SlotMAX"), tostring(ConfigureIt.maxSlots), getText("UI_options_SwapIt_SlotMAXDesc"))

	for i=1, tonumber(ConfigureIt.maxSlots) do
		options:addTickBox("SwapItSlot_"..i.."_SwapWithHeld", getText("UI_options_SwapIt_WithHeldTitle").." - "..getText("UI_options_SwapIt_Slot", tostring(i)), true, getText("UI_options_SwapIt_WithHeldDesc"))
		options:addTickBox("SwapItSlot_"..i.."_DirectAdd", getText("UI_options_SwapIt_DirectAddTitle").." - "..getText("UI_options_SwapIt_Slot", tostring(i)), true, getText("UI_options_SwapIt_DirectAddDesc"))
	end
end

return ConfigureIt