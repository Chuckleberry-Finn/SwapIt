require("Hotbar/ISHotbar")

local fancyHandwork = getActivatedMods():contains("FancyHandwork")
local options = PZAPI.ModOptions:getOptions("SwapIt")


--- TAKEN FROM VANILLA FILE, THESE ARE LOCAL THERE TOO
-- used to ensure heavy bags goto ground not inventory when equipping from hotbar
local dropItemNow = function(character, item)
	character:getInventory():Remove(item)
	local dropX,dropY,dropZ = ISTransferAction.GetDropItemOffset(character, character:getCurrentSquare(), item)
	character:getCurrentSquare():AddWorldInventoryItem(item, dropX, dropY, dropZ)
	character:removeFromHands(item)
	ISInventoryPage.renderDirty = true
end

-- used to ensure heavy bags goto ground not inventory when equipping from hotbar
local willBeOverMaxWeight = function(character, item)
	-- note this assumes the item is equipped. this check is not performed here
	if not character or not item then return end
	return not character:isUnlimitedCarry() and character:getInventory():getCapacityWeight() - item:getEquippedWeight() + item:getUnequippedWeight() > character:getInventory():getMaxWeight()
end


function ISHotbar:isAllowedToActivateSlot()
	if isGamePaused() then return false end
	local playerObj = self.character
	if playerObj:isDead() then return false end
	if playerObj:isAttacking() then return false end

	local radialMenu = getPlayerRadialMenu(self.playerNum)
	if radialMenu:isReallyVisible() then return false end

	-- don't do hotkey if you're doing action
	local queue = ISTimedActionQueue.queues[playerObj]
	if queue ~= nil and #queue.queue > 0 then
		return false
	end
	return true
end


function ISHotbar:activateSlot(slotIndex) -- hotbar equip logic - called after hitting 1234(etc) and equips/activates the item in that slot
	local item = self.attachedItems[slotIndex]

	--- SwapIt --- check if there is an item equipped and assign it if possible ---
	if not item then

		local optionValue = options and options:getOption("SwapItSlot_"..slotIndex.."_DirectAdd"):getValue()

		if optionValue==true or (not options) then
			local slot = self.availableSlot[slotIndex]
			if slot then

				--- FancyHandwork PATCH --- If the mod is enabled and its ModKey is pressed
				if fancyHandwork and isFHModKeyDown() then
					item = self.chr:getSecondaryHandItem() -- Get the secondary item
				else
					item = self.chr:getPrimaryHandItem() -- Otherwise default to Primary
				end
				-------------------------------------------------------

				if item and self:canBeAttached(slot, item) then
					self:attachItem(item, slot.def.attachments[item:getAttachmentType()], slotIndex, slot.def, true)
				end
			end
		end
		return
	end
	-------------------------------------------------------

	if item:getAttachedSlot() ~= slotIndex then error "item:getAttachedSlot() ~= slotIndex" end

	if item:canBeActivated() and (not instanceof(item, "HandWeapon")) then
		item:setActivated(not item:isActivated())
		item:playActivateDeactivateSound()
		return
	end

	self:equipItem(item)
end


function ISHotbar:equipItem(item) --hotbar equip logic - called after activating the slot
	ISInventoryPaneContextMenu.transferIfNeeded(self.chr, item)
	local primary = self.chr:getPrimaryHandItem()
	local secondary = self.chr:getSecondaryHandItem()

	--- FancyHandwork PATCH --- true if Mod is installed and its ModKey is pressed. false or nil otherwise ---
	local _fh = (fancyHandwork and isFHModKeyDown())

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

		local both_hands = item:isTwoHandWeapon()

		--- FancyHandwork PATCH --- "primary" will be the secondary hand item if ModKey is pressed ---
		if _fh then primary = self.chr:getSecondaryHandItem() end
		---------------------------------------------------------------------

		-- Drop corpse or generator
		if isForceDropHeavyItem(primary) then
			ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 50))
		else
			---local inventory = self.chr:getInventory()
			if primary and self:isInHotbar(primary) then --if primary item then unequip
				ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 20))
				if primary == secondary then secondary = nil end -- pretend it doesnt exist since we're putting it away

			elseif primary and instanceof(primary, "InventoryContainer") and willBeOverMaxWeight(self.chr, primary) then
				dropItemNow(self.chr, primary)
			end

			local heavy_secondary = (secondary and instanceof(secondary, "InventoryContainer") and willBeOverMaxWeight(self.chr, secondary))
			--if heavy_secondary and item:isRequiresEquippedBothHands() then
			if heavy_secondary and both_hands then
				dropItemNow(self.chr, secondary)
			end

			----- SwapIt start ----- equipped weapon replaces to hotslot called ----
			local i_slotinuse = item:getAttachedSlot()
			local slot = self.availableSlot[i_slotinuse]

			local optionValue = options and options:getOption("SwapItSlot_"..i_slotinuse.."_SwapWithHeld"):getValue()
			if slot and (optionValue==true or (not options)) then
				if primary and not self:isInHotbar(primary) and self:canBeAttached(slot, primary) then
					self:removeItem(item, false)--false = don't run animation
					self:attachItem(primary, slot.def.attachments[primary:getAttachmentType()], i_slotinuse, slot.def, true)
				end
			end
			---------------------------------------------------------------------
		end
		--- FancyHandwork PATCH --- Use the "mod" variable instead of always true
		ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, not _fh, both_hands))

	elseif instanceof(item, "HandWeapon") and item:canBeActivated() then
		item:setActivated(false)
	end

	self.chr:getInventory():setDrawDirty(true)
	getPlayerData(self.chr:getPlayerNum()).playerInventory:refreshBackpacks()
	--	self:refresh()
end