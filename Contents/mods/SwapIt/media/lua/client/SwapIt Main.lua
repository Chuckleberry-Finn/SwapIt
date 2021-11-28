require("Hotbar/ISHotbar")

function ISHotbar:activateSlot(slotIndex) -- hotbar equip logic - called after hitting 1234(etc) and equips/activates the item in that slot
	local item = self.attachedItems[slotIndex]

	--- SwapIt --- check if there is an item equipped and assign it if possible ---
	if not item then
		local slotIndexID = "direct_Hotbar "..slotIndex
		if SwapItConfig.config[slotIndexID] == true then
			local slot = self.availableSlot[slotIndex]
			item = self.chr:getPrimaryHandItem()
			if item and self:canBeAttached(slot, item) then
				self:attachItem(item, slot.def.attachments[item:getAttachmentType()], slotIndex, slot.def, true)
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
		local slotIndexID = "swap_Hotbar "..i_slotinuse
		if SwapItConfig.config[slotIndexID] == true then
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
