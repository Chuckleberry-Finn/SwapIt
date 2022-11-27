require("Hotbar/ISHotbar")

function ISHotbar:activateSlot(slotIndex) -- hotbar equip logic - called after hitting 1234(etc) and equips/activates the item in that slot
	local item = self.attachedItems[slotIndex]

	--- SwapIt --- check if there is an item equipped and assign it if possible ---
	if not item then
		local slotIndexID = "direct_Hotbar"..slotIndex
		if SwapItConfig.config[slotIndexID] == true then
			local slot = self.availableSlot[slotIndex]
			if slot then
				item = self.chr:getPrimaryHandItem()
				if item and self:canBeAttached(slot, item) then
					self:attachItem(item, slot.def.attachments[item:getAttachmentType()], slotIndex, slot.def, true)
				end
			end
		end
		return
	end
	-------------------------------------------------------

	------ GEAR PATCH -------------------------------------
	if SwapItActiveMods["GEARCORE"] then

		if item:getCategory() == "Clothing" then
			if item:isEquipped() then
				ISTimedActionQueue.add(ISUnequipAction:new(self.chr, item, 50))
			else
				ISTimedActionQueue.add(ISWearClothing:new(self.chr, item, 50))
			end
			return
		end

		if item:IsFood() and item:getHungerChange() < 0 then
			if self.chr:getMoodles():getMoodleLevel(MoodleType.FoodEaten) < 3 or self.chr:getNutrition():getCalories() < 1000 then
				ISTimedActionQueue.add(ISEatFoodAction:new(self.chr, item, 0.25));
				return
			end
		end
	end
	----------------------------------------------------------

	if item:getAttachedSlot() ~= slotIndex then
		error "item:getAttachedSlot() ~= slotIndex"
	end
	if item:canBeActivated() then
		item:setActivated(not item:isActivated())
		return
	end

	if item:getContainer() then
		self:equipItem(item)
	end
end



function ISHotbar:equipItem(item) --hotbar equip logic - called after activating the slot
	ISInventoryPaneContextMenu.transferIfNeeded(self.chr, item)

	local equip = true
	if self.chr:getPrimaryHandItem() == item then
		ISTimedActionQueue.add(ISUnequipAction:new(self.chr, item, 20))
		equip = false
	end
	if equip and self.chr:getSecondaryHandItem() == item then
		ISTimedActionQueue.add(ISUnequipAction:new(self.chr, item, 20))
		equip = false
	end

	if equip then
		local primary = self.chr:getPrimaryHandItem()

		if primary and self:isInHotbar(primary) then --if primary item then unequip
			ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 20))
		end
		-- Drop corpse or generator
		if isForceDropHeavyItem(primary) then
			ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 50))
		end

		----- SwapIt start ----- equipped weapon replaces to hotslot called ----
		local i_slotinuse = item:getAttachedSlot()
		local slot = self.availableSlot[i_slotinuse]
		local slotIndexID = "swap_Hotbar"..i_slotinuse
		if slot and SwapItConfig.config[slotIndexID] == true then
			if primary and not self:isInHotbar(primary) and self:canBeAttached(slot, primary) then
				self:removeItem(item, false)--false = don't run animation
				self:attachItem(primary, slot.def.attachments[primary:getAttachmentType()], i_slotinuse, slot.def, true)
			end
		end
		---------------------------------------------------------------------

		ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))

	end

	self.chr:getInventory():setDrawDirty(true)
	getPlayerData(self.chr:getPlayerNum()).playerInventory:refreshBackpacks()
	--	self:refresh()
end




-------- Override for weird SuperbSurvivors spammy error ----------
--...................,,,,,,,,,,,,,,,,,,,,,,,,,,,,..................
--,...             ,...., ♡ Love you Nolan ♡ .......   %%@&@%    ..
--..,.. #%#%%%%%%%, .,,,,,,,,,,,,,,,,,,,..........  /(&&&&&@@%@@@
--,,. #%%%%%(%%#%%&% .,,,,,,,,,,,,,..............  (#&&%%#%%%&@@@.
--,,.(&%%%%#%,%#%%%## ......,,................,.. ,(((((#(%%&%&@@,
--,,. (//(((#(*.**,//(  %%%%*,/,#%%*/    ........ */(/(((#%%%&&@@
--,,.  //(//*,,/**,,,   &%%(%%%&&&&&&&&&&*  ....   (/(#*/(((###&  .
--,...,.  */*,,**///,   %&&#&&%%%%%%%%%&&&&&(   &  %#((//***/(# %
--..,,,,,.  .*./*((@@@   %%%&&&&&&&&&&%%%&&& (%&#&@@&*#,*,*     @@
--.,,,,,,,,,../    @@@&  &&%&&&&&&&&%&&&&  #&&#&&&%@#        @&@@@@
--,,,,,,,,,,. #%%%(%@%/  .%%%%&%%%&&&%&  #%%&&&&&&&&     %&&&&& &@@
--,,,,,,,,,..  &%%(&%%%   #&&&&%&&%%  *%#%     &#&@%& *&&&&@( @@@@@
--,,,,,,,,.....  %%%&%%    &%%%&&&, %%% *..* ** %(& %@&&@& @@@@&@@&
--,,,,,,,......, .%#%###&   &%%&  ##%%@ **...,*,  %&@@& @@@@@&@@@@&
--,,,,,,,....,,.. (%&#%(#%%  %  #%&&&&#& *,.,,.*/ @&((&&@@@@&@@@@@@
--,,,,,,....,..... *%&&#%%%% %(%&&&%&&&@  /,*,.  % @@@@&&@@&@@&&@@@
--,,,,,,.....,,....  %&&&% (#%&&&&@&@@   @&   &&&%&# &@@@@&@@@@@@&@
--.,,,,,......,,,.,..  %  %%%%%&%@@, &% @&(,@&&%%&&&@@ @@@%@&&&&&@@
--..,,,,,....,,..,,,,.  ,,*   &&@  &&&% @  ,&@&@&@%@%%&@ ,%@%@%@&@@
--...,,,,,....,,,,   .*,..,( @  &&&&&& @@@&&&  @@@@@&%%&&@(@@&@@@@@
--,....,,,,...   /.,*,,**//( (&&&&&%%%& @@@%&%&@  #@@@&&@&&@@&&@@@@
--,,,...,,,,.    ..,,/./#(*# &&&&%&&%%%& @@&&&&&&&@%  @@@&@@@&@@@#@
--,,,,,....,,. ,(. *.&   /% &&%&&&&#%####  &&%@@@%@@&@@  @@@@@@,@@&
--...,,,,....,,      .  &&&&&%&&%%#%%#%%#/ %@&@@&&&&@&%&@&    #@@@@
--,,,...,,,,....,,....  &&&%&%&%%%##%%%%%#%% &&@&&@&&@@@@@@@@@@@@@@
--,,,,,,....,,,....,,.  &%%&&&%%#%%%& %%%#%#% @@&@@@@@&@@@@@@@&@@@@

local swapItUtils = {}
swapItUtils.text = "SwapIt doesn't work with SuperiorSurvivors, please disable SwapIt! To disable this Message, check warning message option in SuperiorSurvivors."
function swapItUtils.applyPatchOverride()
	local class, methodName = zombie.characters.IsoPlayer.class, "Say"
	local createPatch = function(original_fn) return function(self, arg1, ...) if string.find(arg1, swapItUtils.text) then return end return original_fn(self, arg1, ...) end end
	local metatable = __classmetatables[class]
	local metatable__index = metatable.__index
	local originalMethod = metatable__index[methodName]
	metatable__index[methodName] = createPatch(originalMethod)
end
swapItUtils.applyPatchOverride()



local errorCount = -1
local function parseErrors()
	print("TESTING: parseErrors:")
	local text = ""
	local errors = getLuaDebuggerErrors()
	for i = 1,errors:size() do
		local str = errors:get(i-1)
		str = str:gsub("\t", "    ")
		text = text .. str .. "\n"
	end
	errorCount = getLuaDebuggerErrorCount()
	print("@@@@@@@@@@\n",text,"\n@@@@@@@@@@")
end

local function test() DebugLogStream.printException() end
Events.EveryTenMinutes.Add(test)
local function compareErrorCount()
	print("errorCount: "..errorCount.."  getLuaDebuggerErrorCount():"..getLuaDebuggerErrorCount())
	if errorCount ~= getLuaDebuggerErrorCount() then
		parseErrors()
	end
end
Events.EveryTenMinutes.Add(compareErrorCount)

--[[
local exception_original = Exception
function Exception(...)

	print("TESTING")

	exception_original(...)
end--]]

