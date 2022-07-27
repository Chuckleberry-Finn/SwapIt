require "EasyConfigChucked1_Main"
require "OptionScreens/ServerSettingsScreen"
require "OptionScreens/SandBoxOptions"

SwapItActiveMods = {}
function PATCH_FOR_MODS()
	local activeModIDs = getActivatedMods()
	for i=1,activeModIDs:size() do
		local modID = activeModIDs:get(i-1)
		SwapItActiveMods[modID] = true
	end
end
PATCH_FOR_MODS()


SwapItConfig = {}
SwapItConfig.config = {}
SwapItConfig.modId = "SwapIt" -- needs to the same as in your mod.info
SwapItConfig.menu = {}

function loadHotSlotsToMenu()
	local maxSlots = 5
	if SwapItActiveMods["Authentic Z - Current"] then
		maxSlots = 10
	end
	if SwapItActiveMods["GEARCORE"] then
		maxSlots = 15
	end
	SwapItConfig.menu.modTooltipSwap = {type = "Text", a=0.55, customX=-90}
	SwapItConfig.menu.modTooltipDirect = {type = "Text", a=0.55, customX=-90}
	SwapItConfig.menu.modTooltipSpace = {type = "Space"}
	for slot=1, maxSlots do
		local readOut = "Hotbar"..slot
		SwapItConfig.menu["swap_"..readOut] = {type = "Tickbox", tooltip = "", a=0.6}
		SwapItConfig.config["swap_"..readOut] = true
		SwapItConfig.menu["direct_"..readOut] = {type = "Tickbox", tooltip = "", a=0.6}
		SwapItConfig.config["direct_"..readOut] = true
		SwapItConfig.menu["space"..readOut] = {type = "Space"}
	end
	SwapItConfig.menu["generalSpace"] = {type = "Space"}
end
--run on Lua load
loadHotSlotsToMenu()

EasyConfig_Chucked = EasyConfig_Chucked or {}
EasyConfig_Chucked.mods = EasyConfig_Chucked.mods or {}
EasyConfig_Chucked.mods[SwapItConfig.modId] = SwapItConfig