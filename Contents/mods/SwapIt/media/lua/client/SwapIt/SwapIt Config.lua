require "_EasyConfig_Chucked"
require "OptionScreens/ServerSettingsScreen"
require "OptionScreens/SandBoxOptions"

SwapItActiveMods = {}
function PATCH_FOR_MODS()
	print("SwapIt Checking For Patches:")
	local activeModIDs = getActivatedMods()
	for i=1,activeModIDs:size() do
		local modID = activeModIDs:get(i-1)
		print("- Mod: "..modID)
		SwapItActiveMods[modID] = true
	end
end
PATCH_FOR_MODS()


SwapItConfig = {}
SwapItConfig.config = {}
SwapItConfig.modId = "SwapIt" -- needs to the same as in your mod.info
SwapItConfig.name = "SwapIt" -- the name that will be shown in the MOD tab
SwapItConfig.menu = {}

function loadHotSlotsToMenu()
	SwapItConfig.menu["generalTitle"] = {type = "Text", text = "Hotbar Slots"}

	print("SwapItConfig:")
	local maxSlots = 5

	if SwapItActiveMods["GEARCORE"] then
		maxSlots = 15
	end

	for slot=1, maxSlots do
		local readOut = "Hotbar "..slot
		print("--- loading: "..readOut)
		SwapItConfig.menu[readOut] = {type = "Tickbox", title = readOut, tooltip = "", }
		SwapItConfig.config[readOut] = true
	end
	SwapItConfig.menu["generalSpace"] = {type = "Space"}
end
--run on Lua load
loadHotSlotsToMenu()

print("EasyConfig_Chucked: "..SwapItConfig.modId.." "..SwapItConfig.name.." "..tostring(SwapItConfig.config).." "..tostring(SwapItConfig.menu))
--load mod into EasyConfig
if EasyConfig_Chucked then
	EasyConfig_Chucked.addMod(SwapItConfig.modId, SwapItConfig.name, SwapItConfig.config, SwapItConfig.menu, "SWAPIT")
end