require "Hotbar/ISHotbar"

function ISHotbar:activateSlot(slotIndex) -- hotbar equip logic - called after hitting 1234(etc) and equips/activates the item in that slot
	local item = self.attachedItems[slotIndex]

	--- SwapIt --- check if there is an item equipped and assign it if possible --
	 if not item then
		if slotIndex==1 then
			local slot = self.availableSlot[slotIndex]
			item = self.chr:getPrimaryHandItem()
			if self:canBeAttached(slot, item) then
				self:attachItem(item, slot.def.attachments[item:getAttachmentType()], slotIndex, slot.def, true)
			end
		end
	return end
	------------------------------------------------------------------------------

	if item:getAttachedSlot() ~= slotIndex then
		error "item:getAttachedSlot() ~= slotIndex"
	end
	if item:canBeActivated() then
		item:setActivated(not item:isActivated())
		return
	end
	self:equipItem(item)
end



function ISHotbar:equipItem(item) -- hotbar equip logic - called after activating the slot
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

		---- SwapIt -- equipped weapon replaces hotslot called -----
		local i_slotinuse = item:getAttachedSlot()
		local slot = self.availableSlot[i_slotinuse]

		if i_slotinuse == 1 then
			if(primary and not self:isInHotbar(primary) and self:canBeAttached(slot, primary)) then
				self:removeItem(item, false)--false = don't run animation
				self:attachItem(primary, slot.def.attachments[primary:getAttachmentType()], i_slotinuse, slot.def, true)
			end
		end
		-------------------------------------------------------------

		ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))
	end

	self.chr:getInventory():setDrawDirty(true)
	getPlayerData(self.chr:getPlayerNum()).playerInventory:refreshBackpacks()
--	self:refresh()
end
