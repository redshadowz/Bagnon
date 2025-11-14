local DEFAULT_FRAME_LOCKED = 1
local DEFAULT_BAG_COLS = 12
local DEFAULT_BANK_COLS = 20
local DEFAULT_SPACING = 2
local minWidth = 120

local currentPlayer = UnitName("player")
local currentRealm = GetRealmName()
local bToggleBag = ToggleBag
local bToggleBackpack = ToggleBackpack
local bOpenBag = OpenBag
local bCloseBag = CloseBag
local bOpenBackpack = OpenBackpack
local bCloseBackpack = CloseBackpack
local bOpenAllBags = OpenAllBags
local bCloseAllBags = CloseAllBags
local bToggleKeyring = ToggleKeyRing
local UPDATE_DELAY = 0.3
local FRAMESTRATA = {"LOW","MEDIUM","HIGH"}
local firstRun,nameFilter,bgn_atBank
local bBagSlotButton_OnEnter,bMainBag_OnEnter,bKeyRingButton_OnEnter
local bBagSlotButton_OnClick,bKeyRingButton_OnClick,bMainBag_OnClick
local Blizz_GameTooltip_SetBagItem = GameTooltip.SetBagItem
local Bliz_GameTooltip_SetLootItem = GameTooltip.SetLootItem
local Bliz_SetHyperlink = GameTooltip.SetHyperlink
local Bliz_ItemRefTooltip_SetHyperlink = ItemRefTooltip.SetHyperlink
local Bliz_GameTooltip_SetLootRollItem = GameTooltip.SetLootRollItem
local Bliz_GameTooltip_SetAuctionItem = GameTooltip.SetAuctionItem

BagnonDB = {addon = "Bagnon_Forever"}

-- Utility
function Bagnon_IsInventoryBag(bagID)
	return bagID == KEYRING_CONTAINER or (bagID >= 0 and bagID < 5)
end
function Bagnon_IsBankBag(bagID)
	return bagID == -1 or (bagID and bagID > 4 and bagID < 11)
end
function Bagnon_FrameHasBag(frameName,bagID)
	if not BagnonSets and BagnonSets[frameName] and BagnonSets[frameName].bags then return false end
	for i in BagnonSets[frameName].bags do
		if BagnonSets[frameName].bags[i] == bagID then return true end
	end
	return
end
function Bagnon_IsAmmoBag(bagID,player)
	if bagID <= 0 then return end
	local id
	if player then
		if BagnonDB then _,id = BagnonDB.GetBagData(player,bagID) end
	else
		local link = GetInventoryItemLink("player",ContainerIDToInventoryID(bagID) )
		if link then _,_,id = string.find(link, "item:(%d+)") end
	end
	if id then
		local _,_,_,_,itemType,subType = GetItemInfo(id)
		return itemType == BAGNON_ITEMTYPE_QUIVER or subType == BAGNON_SUBTYPE_SOULBAG
	end
	return
end
function Bagnon_IsProfessionBag(bagID)
	if bagID <= 0 then return end
	local id
	if player then
		if BagnonDB then _,id = BagnonDB.GetBagData(player,bagID) end
	else
		local link = GetInventoryItemLink("player",ContainerIDToInventoryID(bagID) )
		if link then _,_,id = string.find(link, "item:(%d+)") end
	end
	if id then
		local _,_,_,_,itemType,subType = GetItemInfo(id)
		return itemType == BAGNON_ITEMTYPE_CONTAINER and not (subType == BAGNON_SUBTYPE_BAG or subType == BAGNON_SUBTYPE_SOULBAG)
	end
	return
end
function Bagnon_IsCachedFrame(frame) 
	if not BagnonDB then return false end
	return currentPlayer ~= frame.player or (not bgn_atBank and frame:GetName() == "Banknon")
end
function Bagnon_IsCachedBag(player,bagID) 
	if not BagnonDB then return false end
	return currentPlayer ~= player or (not bgn_atBank and Bagnon_IsBankBag(bagID))
end
function Bagnon_IsCachedItem(item)
	if not (BagnonDB and item) then return false end
	if currentPlayer ~= item:GetParent():GetParent().player then return true end
	if bgn_atBank then return false end
	return Bagnon_IsBankBag(item:GetParent():GetID())
end
function Bagnon_AnchorTooltip(frame)
	GameTooltip:ClearAllPoints()
	if frame:GetLeft() < (UIParent:GetRight() / 2) then
		if frame:GetTop() < (UIParent:GetTop() / 2) then GameTooltip:SetPoint("BOTTOMLEFT", frame, "TOPLEFT") else GameTooltip:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT") end
	else
		if frame:GetTop() < (UIParent:GetTop() / 2) then GameTooltip:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT") else GameTooltip:SetPoint("TOPRIGHT", frame, "BOTTOMLEFT") end
	end
end
function BagnonMsg(msg,r,g,b)
	if r and g and b then DEFAULT_CHAT_FRAME:AddMessage(msg or "error",r,g,b) else DEFAULT_CHAT_FRAME:AddMessage(msg or "error",0,0.7,1) end
end

-- Hooks
local function BagIsControlledByBagnon(id)
	return ((not BagnonSets["Bagnon"] and Bagnon_IsInventoryBag(id)) or Bagnon_FrameHasBag("Bagnon",id))
end
local function BagIsControlledByBanknon(id)
	return BagnonSets.showBankAtBank and Bagnon_FrameHasBag("Banknon",id)
end
ToggleBag = function(id)
	if BagIsControlledByBagnon(id) then
		BagnonFrame_Toggle("Bagnon")
	elseif BagIsControlledByBanknon(id) then
		return
	else
		bToggleBag(id)
	end
end
ToggleBackpack = function()
	BagnonFrame_Toggle("Bagnon")
end
OpenBag = function(id)
	if BagIsControlledByBagnon(id) then BagnonFrame_Open("Bagnon",1) else bOpenBag(id) end
end
CloseBag = function(id)
	if BagIsControlledByBagnon(id) then BagnonFrame_Close("Bagnon",1) else bCloseBag(id) end
end
OpenBackpack = function()
	BagnonFrame_Open("Bagnon",1)
end
CloseBackpack = function()
	BagnonFrame_Close("Bagnon",1)
end
OpenAllBags = function(forceOpen)
	BagnonFrame_Toggle("Bagnon")
end
CloseAllBags = function()
	BagnonFrame_Close("Bagnon")
end
ToggleKeyRing = function()
	if Bagnon_FrameHasBag("Bagnon",KEYRING_CONTAINER) then BagnonFrame_Toggle("Bagnon") else bToggleKeyring() end
end

-- Core Bagnon
local function ForAllBagSlots(bagFrame,action,arg1)
	local frameName = bagFrame:GetName()
	for i=1, 10 do
		local bag = getglobal(frameName..i)
		if bag then action(bag,arg1) end
	end
end
local function UpdateFrameSize(bagFrame)
	local size = 0
	for i = 1, 10 do
		local bag = getglobal(bagFrame:GetName()..i)
		if bag and GetInventoryItemTexture("player",ContainerIDToInventoryID(bag:GetID())) then size = size + GetContainerNumSlots(bag:GetID()) end
	end
	local change = (size or 0) - (bagFrame.size or 0)
	if change ~= 0 then
		bagFrame.size = size
		BagnonFrame_Generate(bagFrame:GetParent())
	end
end
function BagnonBagFrame_OnEvent()
	if not this:IsVisible() or Bagnon_IsCachedFrame(this:GetParent()) then return end

	if event == "BAG_UPDATE" or event == "PLAYERBANKSLOTS_CHANGED" or event == "PLAYERBANKBAGSLOTS_CHANGED" then
		if not arg1 or this:GetParent() == Banknon then
			ForAllBagSlots(this,BagnonBag_Update)
		elseif tonumber(arg1) and arg1 > 0 then
			local bag = getglobal(this:GetName()..arg1)
			if bag then BagnonBag_Update(bag) end
		end
		UpdateFrameSize(this)
	elseif event == "ITEM_LOCK_CHANGED" then
		ForAllBagSlots(this,BagnonBag_UpdateLock)
	elseif event == "CURSOR_UPDATE" then
		ForAllBagSlots(this,BagnonBag_UpdateCursor)
	end
end
function BagnonBagFrame_OnLoad()
	this:RegisterEvent("BAG_UPDATE")
	this:RegisterEvent("ITEM_LOCK_CHANGED")
	this:RegisterEvent("CURSOR_UPDATE")
	this:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	this:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
end
function BagnonBag_Update(bag)
	if not bag then return end
	local invID = ContainerIDToInventoryID(bag:GetID())
	local textureName = GetInventoryItemTexture("player",invID)
	if textureName then
		SetItemButtonTexture(bag,textureName)
		BagnonBag_SetCount(bag,GetInventoryItemCount("player",invID))
		if not IsInventoryItemLocked(invID) then
			SetItemButtonTextureVertexColor(bag,1.0,1.0,1.0)
			SetItemButtonNormalTextureVertexColor(bag,1.0,1.0,1.0)
		end
		bag.hasItem = 1
	else
		SetItemButtonTexture(bag,nil)
		BagnonBag_SetCount(bag,0)
		SetItemButtonTextureVertexColor(bag,1,1,1)
		SetItemButtonNormalTextureVertexColor(bag,1,1,1)
		bag.hasItem = nil
	end
	if GameTooltip:IsOwned(bag) then
		if textureName then
			BagnonBag_OnEnter(bag)
		else
			GameTooltip:Hide()
			ResetCursor()
		end
	end
	BagnonBag_UpdateLock(bag)
	if MerchantRepairAllIcon then
		local repairAllCost,canRepair = GetRepairAllCost()
		if canRepair then
			SetDesaturation(MerchantRepairAllIcon,nil)
			MerchantRepairAllButton:Enable()
		else
			SetDesaturation(MerchantRepairAllIcon,1)
			MerchantRepairAllButton:Disable()
		end
	end
end
function BagnonBag_UpdateLock(bag)
	if IsInventoryItemLocked(ContainerIDToInventoryID(bag:GetID())) then SetItemButtonDesaturated(bag,1,0.5,0.5,0.5) else SetItemButtonDesaturated(bag,nil) end
end
function BagnonBag_UpdateCursor(bag)
	if CursorCanGoInSlot(ContainerIDToInventoryID(bag:GetID())) then bag:LockHighlight() else bag:UnlockHighlight() end
end
function BagnonBag_UpdateTexture(frame,bagID)
	local bag = getglobal(frame:GetName().."Bags"..bagID)
	if not bag or bag:GetID() <= 0 then return end

	if Bagnon_IsCachedBag(frame.player,bagID) then
		local _,link,count = BagnonDB.GetBagData(frame.player,bagID)
		if link then
			local _,_,_,_,_,_,_,_,texture = GetItemInfo(link)
			SetItemButtonTexture(bag,texture)
		else
			SetItemButtonTexture(bag,nil)
		end
		if count then BagnonBag_SetCount(bag,count) end
	else
		local texture = GetInventoryItemTexture("player",ContainerIDToInventoryID(bagID))
		if texture then SetItemButtonTexture(bag,texture) else SetItemButtonTexture(bag,nil) end
		BagnonBag_SetCount(bag,GetInventoryItemCount("player",ContainerIDToInventoryID(bagID)))
	end
end
function BagnonBag_SetCount(button,count)
	if not button then return end
	if not count then count = 0 end
	button.count = count
	if count > 1 or (button.isBag and count > 0) then
		local countText = getglobal(button:GetName().."Count")
		if count > 9999 then
			countText:SetFont(NumberFontNormal:GetFont(),10,"OUTLINE")
		elseif count > 999 then
			countText:SetFont(NumberFontNormal:GetFont(),11,"OUTLINE")
		else
			countText:SetFont(NumberFontNormal:GetFont(),12,"OUTLINE")
		end
		countText:SetText(count)
		countText:Show()
	else
		getglobal(button:GetName().."Count"):Hide()
	end
end
function BagnonBag_OnLoad()
	this:RegisterForDrag("LeftButton")
	this:RegisterForClicks("LeftButtonUp","RightButtonUp")
end
function BagnonBag_OnShow()
	BagnonBag_UpdateTexture(this:GetParent():GetParent(),this:GetID())
end
function BagnonBag_OnClick()
	if Bagnon_IsCachedBag(this:GetParent():GetParent().player,this:GetID()) then return end
	if not IsShiftKeyDown() then
		if this:GetID() == KEYRING_CONTAINER then
			PutKeyInKeyRing()
		elseif this:GetID() == 0 then
			PutItemInBackpack()
		else
			PutItemInBag(ContainerIDToInventoryID(this:GetID()))
		end
	else
		BagnonFrame_ToggleBag(this:GetParent():GetParent(),this:GetID())
	end
end
function BagnonBag_OnDrag()
	if Bagnon_IsCachedBag(this:GetParent():GetParent().player,this:GetID()) then return end
	PickupBagFromSlot(ContainerIDToInventoryID(this:GetID()))
	PlaySound("BAGMENUBUTTONPRESS")
end
function BagnonBag_OnEnter()
	local frame = this:GetParent():GetParent()
	BagnonFrame_HighlightSlots(frame,this:GetID())
	if this:GetLeft() < (UIParent:GetRight() / 2) then GameTooltip:SetOwner(this,"ANCHOR_RIGHT") else GameTooltip:SetOwner(this,"ANCHOR_LEFT") end
	if this:GetID() == 0 then
		GameTooltip:SetText(TEXT(BACKPACK_TOOLTIP),1,1,1)
	elseif this:GetID() == KEYRING_CONTAINER then
		GameTooltip:SetText(KEYRING,HIGHLIGHT_FONT_COLOR.r,HIGHLIGHT_FONT_COLOR.g,HIGHLIGHT_FONT_COLOR.b)
	elseif Bagnon_IsCachedBag(frame.player,this:GetID()) then
		local _,link = BagnonDB.GetBagData(frame.player,this:GetID())
		if link then
			GameTooltip:SetHyperlink(link)
			GameTooltip:Show()
		else
			GameTooltip:SetText(TEXT(EQUIP_CONTAINER),1,1,1)
		end
	elseif not GameTooltip:SetInventoryItem("player",ContainerIDToInventoryID(this:GetID())) then
		GameTooltip:SetText(TEXT(EQUIP_CONTAINER),1,1,1)
	end
	if not Bagnon_IsCachedBag(frame.player,this:GetID()) then
		if BagnonSets.showTooltips then
			if Bagnon_FrameHasBag(frame:GetName(),this:GetID()) then
				GameTooltip:AddLine(BAGNON_BAGS_HIDE)
			else
				GameTooltip:AddLine(BAGNON_BAGS_SHOW)
			end
		end
	end
	GameTooltip:Show()
end
function BagnonBag_OnLeave()
	BagnonFrame_UnhighlightAll(this:GetParent():GetParent())
	GameTooltip:Hide()
end

-- Item
local function OnUpdate()
	if (not this.isLink) and GameTooltip:IsOwned(this) then
		if not this.elapsed or this.elapsed < 0 then
			BagnonItem_OnUpdate(this)
			this.elapsed = UPDATE_DELAY
		else
			this.elapsed = this.elapsed - arg1
		end
	end
end
local function OnClick()
	BagnonItem_OnClick(arg1)
end
local function OnEnter()
	this.elapsed = nil
	BagnonItem_OnEnter(this)
end
local function OnLeave()
	this.elapsed = nil
	BagnonItem_OnLeave(this)
end
local function OnDragStart()
	BagnonItem_OnClick("LeftButton",1)
end
local function OnReceiveDrag()
	BagnonItem_OnClick("LeftButton",1)
end
local function OnHide()
	BagnonItem_OnHide(this)
end
function BagnonItem_Create(name,parent)
	local item = CreateFrame("Button", name, parent, "BagnonItemTemplate")
	item:SetAlpha(parent:GetParent():GetAlpha())
	item:RegisterForClicks("LeftButtonUp","RightButtonUp")
	item:RegisterForDrag("LeftButton")
	if not (KC_Items or IsAddOnLoaded('LootLink')) then item:SetScript("OnUpdate",OnUpdate) end
	item:SetScript("OnClick",OnClick)
	item:SetScript("OnEnter",OnEnter)
	item:SetScript("OnLeave",OnLeave)
	item:SetScript("OnDragStart",OnDragStart)
	item:SetScript("OnReceiveDrag",OnReceiveDrag)
	item:SetScript("OnHide",OnHide)
	if AxuItemMenus_DropDown then
		item.SplitStack = function(item,split)
			SplitContainerItem(item:GetParent():GetID(),item:GetID(),split)
		end
	end
	return item
end
function BagnonItem_OnClick(mouseButton,ignoreModifiers)
	if this.isLink then
		if this.hasItem then
			if mouseButton == "LeftButton" then
				if IsControlKeyDown() then
					local itemSlot = this:GetID()
					local bagID = this:GetParent():GetID()
					local player = this:GetParent():GetParent().player
					DressUpItemLink((BagnonDB.GetItemData(player,bagID,itemSlot)))
				elseif IsShiftKeyDown() then
					local itemSlot = this:GetID()
					local bagID = this:GetParent():GetID()
					local player = this:GetParent():GetParent().player
					ChatFrameEditBox:Insert(BagnonDB.GetItemHyperlink(player,bagID,itemSlot))
				end
			end
		end
	else
		ContainerFrameItemButton_OnClick(mouseButton,ignoreModifiers)
	end
end
function BagnonItem_OnEnter(item)
	if item.isLink then
		if item.hasItem then
			GameTooltip:SetOwner(item)
			local itemSlot = item:GetID()
			local bagID = item:GetParent():GetID()
			local player = item:GetParent():GetParent().player
			local link,count = BagnonDB.GetItemData(player,bagID,itemSlot)
			GameTooltip:SetHyperlink( link,count )
			Bagnon_AnchorTooltip(item)
		end
	else
		if item:GetParent():GetID() == -1 then
			GameTooltip:SetOwner(item)
			GameTooltip:SetInventoryItem("player",BankButtonIDToInvSlotID(item:GetID()))
		else
			ContainerFrameItemButton_OnEnter(item)
		end
		if not EnhTooltip then Bagnon_AnchorTooltip(item) end
	end
end
function BagnonItem_OnLeave(item)
	item.updateTooltip = nil
	GameTooltip:Hide()
	ResetCursor()
end
function BagnonItem_OnUpdate(item)
	if GameTooltip:IsOwned(item) then BagnonItem_OnEnter(item) end
end
function BagnonItem_OnHide(item)
	if item.hasStackSplit and item.hasStackSplit == 1 then StackSplitFrame:Hide() end
end
function BagnonItem_Update(item)
	local itemLink,texture,itemCount,readable,locked
	if Bagnon_IsCachedItem(item) then
		item.isLink = 1
		local itemSlot = item:GetID()
		local bagID = item:GetParent():GetID()
		local player = item:GetParent():GetParent().player
		_,itemCount,texture,quality = BagnonDB.GetItemData(player,bagID,itemSlot)
		BagnonItem_UpdateLinkBorder(item,quality)
		if texture then item.hasItem = 1 else item.hasItem = nil end
		BagnonItem_UpdateCooldown(bagID,item)
	else
		item.isLink = nil
		texture,itemCount,locked,_,readable = GetContainerItemInfo(item:GetParent():GetID(),item:GetID())
		BagnonItem_UpdateBorder(item)
		if texture then
			BagnonItem_UpdateCooldown(item:GetParent():GetID(),item)
			item.hasItem = 1
		else
			getglobal(item:GetName().."Cooldown"):Hide()
			item.hasItem = nil
		end
		SetItemButtonDesaturated(item,locked,0.5,0.5,0.5)
		item.readable = readable
	end
	SetItemButtonTexture(item,texture)
	SetItemButtonCount(item,itemCount)
end
function BagnonItem_UpdateBorder(button)
	local bagID = button:GetParent():GetID()
	if BagnonSets.qualityBorders then
		local link = (GetContainerItemLink(bagID,button:GetID()))
		if link then
			local _,_,hexString = strfind(link ,"|cff([%l%d]+)|H")
			local red = tonumber(strsub(hexString,1,2),16)/256
			local green = tonumber(strsub(hexString,3,4),16)/256
			local blue = tonumber(strsub(hexString,5,6),16)/256
			if red ~= green and red ~= blue then
				getglobal(button:GetName().."Border"):SetVertexColor(red,green,blue,0.5)
				getglobal(button:GetName().."Border"):Show()
			else
				getglobal(button:GetName().."Border"):Hide()
			end
		else
			getglobal(button:GetName().."Border"):Hide()
		end
	else
		getglobal(button:GetName().."Border"):Hide()
	end
	if bagID == KEYRING_CONTAINER then
		getglobal(button:GetName().."NormalTexture"):SetVertexColor(1,0.7,0)
	elseif Bagnon_IsAmmoBag(bagID) then
		getglobal(button:GetName().."NormalTexture"):SetVertexColor(1,1,0)
	elseif Bagnon_IsProfessionBag(bagID) then
		getglobal(button:GetName().."NormalTexture"):SetVertexColor(0,1,0)
	else
		getglobal(button:GetName().."NormalTexture"):SetVertexColor(1,1,1)
	end
end
function BagnonItem_UpdateLinkBorder(item,quality)
	local itemSlot = item:GetID()
	local bagID = item:GetParent():GetID()
	local player = item:GetParent():GetParent().player
	if BagnonSets.qualityBorders then
		if not quality then
			local link = (BagnonDB.GetItemData(player,bagID,itemSlot))
			if link then _,_,quality = GetItemInfo(link) end
		end
		if quality and quality > 1 then
			local red,green,blue = GetItemQualityColor(quality)
			getglobal(item:GetName().."Border"):SetVertexColor(red,green,blue,0.5)
			getglobal(item:GetName().."Border"):Show()
		else
			getglobal(item:GetName().."Border"):Hide()
		end
	else
		getglobal(item:GetName().."Border"):Hide()
	end
	if bagID == KEYRING_CONTAINER then
		getglobal(item:GetName().."NormalTexture"):SetVertexColor(1,0.7,0)
	elseif Bagnon_IsAmmoBag(bagID,player) then
		getglobal(item:GetName().."NormalTexture"):SetVertexColor(1,1,0)
	elseif Bagnon_IsProfessionBag(bagID,player) then
		getglobal(item:GetName().."NormalTexture"):SetVertexColor(0,1,0)
	else
		getglobal(item:GetName().."NormalTexture"):SetVertexColor(1,1,1)
	end
end
function BagnonItem_UpdateCooldown(container,button)
	if button.isLink then
		CooldownFrame_SetTimer(getglobal(button:GetName().."Cooldown"),0,0,0)
	else
		local cooldown = getglobal(button:GetName().."Cooldown")
		local start,duration,enable = GetContainerItemCooldown( container,button:GetID() )
		CooldownFrame_SetTimer(cooldown,start,duration,enable)
		if duration > 0 and enable == 0 then SetItemButtonTextureVertexColor(button,0.4,0.4,0.4) end
	end
end

-- Frame Functions
function BagnonFrame_Load(frame,bags,title)
	local frameName = frame:GetName()
	tinsert(UISpecialFrames,frameName)
	if not BagnonSets[frameName] then
		BagnonSets[frameName] = { stayOnScreen = 1 }
		firstRun = 1
	end
	if not BagnonSets[frameName].bags then BagnonSets[frameName].bags = bags end
	if BagnonSets[frameName].alpha then frame:SetAlpha(BagnonSets[frameName].alpha) end
	if not BagnonSets[frameName].bg or tonumber(BagnonSets[frameName].bg) then BagnonSets[frameName].bg = {r = 0,g = 0,b = 0,a = 1} end
	local bgSets= BagnonSets[frameName].bg
	frame:SetBackdropColor(bgSets.r,bgSets.g,bgSets.b,bgSets.a)
	frame:SetBackdropBorderColor(1,1,1,bgSets.a)
	if BagnonSets[frameName].strata then BagnonFrame_SetStrata(frame,BagnonSets[frameName].strata) end
	local bagFrame = getglobal(frameName.."Bags")
	if bagFrame and BagnonSets[frameName].bagsShown then
		bagFrame:Show()
		getglobal(frameName.."ShowBags"):SetText(BAGNON_HIDEBAGS)
	end
	frame:SetClampedToScreen(BagnonSets[frameName].stayOnScreen)
	if BagnonDB then
		frame.player = UnitName("player")
		frame.defaultBags = bags
		local dropdownButton = CreateFrame("Button", frameName.."DropDown", frame, "BagnonDBUIDropDownButton")
		dropdownButton:SetAlpha(frame:GetAlpha())
		if frameName == "Bagnon" then
			local bankButton = CreateFrame("Button", frameName.."BankB", frame, "BagnonDBUIBankButton")
			bankButton:SetAlpha(frame:GetAlpha())
			getglobal(frameName.."BankB"):SetPoint("TOPLEFT", dropdownButton, "TOPRIGHT", 0, 0)
			getglobal(frameName.."Title"):SetPoint("TOPLEFT", dropdownButton, "TOPRIGHT", 22, 2)
		else
			getglobal(frameName.."Title"):SetPoint("TOPLEFT", dropdownButton, "TOPRIGHT", 2, 2)
		end
	end
	BagnonFrame_OrderBags(frame,BagnonSets[frameName].reverse)
	frame.title = title
	getglobal(frameName.."Title"):SetText( format(frame.title,UnitName("player") ) )
	frame:RegisterForClicks("LeftButtonDown","LeftButtonUp","RightButtonUp")
	BagnonFrame_Reposition(frame)
	BagnonFrame_Generate(frame)
	frame:Hide()
end
function BagnonFrame_Generate(frame)
	frame.size = 0
	local frameName = frame:GetName()
	if Bagnon_IsCachedFrame(frame) then
		MoneyFrame_Update(frameName.."MoneyFrame",BagnonDB.GetMoney(frame.player))
		for _,bagID in pairs(frame.defaultBags) do BagnonFrame_AddBag(frame,bagID) end
	else
		MoneyFrame_Update(frameName.."MoneyFrame",GetMoney())
		for _,bagID in pairs(BagnonSets[frameName].bags) do BagnonFrame_AddBag(frame,bagID) end
	end
	BagnonFrame_Layout(frame,BagnonSets[frame:GetName()].cols,BagnonSets[frame:GetName()].space)
	frame:Show()
end
local function CreateDummyBag(parent,bagID)
	local dummyBag = CreateFrame("Frame",parent:GetName().."DummyBag"..bagID,parent)
	dummyBag:SetID(bagID)
	return dummyBag
end
function BagnonFrame_AddBag(frame,bagID)
	local frameName = frame:GetName()
	local slot = frame.size
	local bagSize
	if Bagnon_IsCachedBag(frame.player,bagID) then
		bagSize = (BagnonDB.GetBagData(frame.player,bagID)) or 0
	else
		if bagID == KEYRING_CONTAINER then
			bagSize = GetKeyRingSize()
		elseif bagID <= 0 or GetInventoryItemTexture("player",ContainerIDToInventoryID(bagID)) then
			bagSize = GetContainerNumSlots(bagID)
		else
			bagSize = 0
		end
	end
	local dummyBag = getglobal(frameName.."DummyBag"..bagID) or CreateDummyBag(frame,bagID)
	for index = 1, bagSize, 1 do
		slot = slot + 1
		local item = getglobal(frameName.."Item".. slot) or BagnonItem_Create(frameName.."Item".. slot,dummyBag)
		item:SetID(index)
		item:SetParent(dummyBag)
		item:Show()
		BagnonItem_Update(item)
	end
	frame.size = frame.size + bagSize
end
function BagnonFrame_TrimToSize(frame)
	if not frame.space then return end
	local frameName = frame:GetName()
	local slot,height
	if frame.size then
		local slot = frame.size + 1
		local button = getglobal(frameName.."Item".. slot)
		while button do
			button:Hide()
			slot = slot + 1
			button = getglobal(frameName.."Item".. slot)
		end
	end
	if not frame.size or frame.size == 0 then
		height = 64
		frame:SetWidth(256)
	else
		if frame.size < frame.cols then frame:SetWidth((37 + frame.space) * frame.size + 16 - frame.space) else frame:SetWidth((37 + frame.space) * frame.cols + 16 - frame.space) end
		height = (37 + frame.space) * math.ceil(frame.size / frame.cols)  + 64 - frame.space
	end
	local bagFrame = getglobal(frame:GetName().."Bags")
	if bagFrame and bagFrame:IsShown() then
		frame:SetHeight(height + bagFrame:GetHeight())
		if frame:GetWidth() < bagFrame:GetWidth() then frame:SetWidth(bagFrame:GetWidth() + 8) end
	else
		frame:SetHeight(height)
	end
	BagnonFrame_SavePosition(frame)
end
function BagnonFrame_Update(frame,bagID)
	if not frame.size or Bagnon_IsCachedFrame(frame) then return end

	local frameName = frame:GetName()
	local startSlot = 1
	local endSlot
	if not bagID then
		endSlot = frame.size
	else
		for _,bag in pairs(BagnonSets[frameName].bags) do
			if bag == bagID then
				if bag == KEYRING_CONTAINER then
					endSlot = startSlot + GetKeyRingSize() - 1
				elseif bag == -1 then
					endSlot = startSlot + 23
				else
					endSlot = startSlot + GetContainerNumSlots(bag) - 1
				end
				break
			else
				if bag == KEYRING_CONTAINER then
					startSlot = startSlot + GetKeyRingSize()
				elseif bag == -1 then
					startSlot = startSlot + 24
				else
					startSlot = startSlot + GetContainerNumSlots(bag)
				end
			end
		end
	end
	for slot = startSlot,endSlot do
		local item = getglobal(frameName.."Item"..slot)
		if item then BagnonItem_Update(item) end
	end
end
function BagnonFrame_UpdateLock(frame)
	if not frame.size or Bagnon_IsCachedFrame(frame) then return end
	local frameName = frame:GetName()
	for slot = 1, frame.size do
		local item = getglobal(frameName.."Item"..slot)
		local _,_,locked = GetContainerItemInfo(item:GetParent():GetID(),item:GetID())
		SetItemButtonDesaturated(item,locked,0.5,0.5,0.5)
	end
end
function BagnonFrame_Layout(frame,cols,space)
	if not frame.size then return end

	local frameName = frame:GetName()
	if not BagnonSets[frameName].locked and firstRun then BagnonSets[frameName].locked = DEFAULT_FRAME_LOCKED end
	if not cols then
		if frameName == "Bagnon" then cols = DEFAULT_BAG_COLS
		elseif frameName == "Banknon" then cols = DEFAULT_BANK_COLS
		end
	end
	if cols == DEFAULT_BAG_COLS then BagnonSets[frameName].cols = nil else BagnonSets[frameName].cols = cols end
	if not space then space = DEFAULT_SPACING end
	if space == DEFAULT_SPACING then BagnonSets[frameName].space = nil else BagnonSets[frameName].space = space end
	local rows = math.ceil(frame.size / cols)
	local index = 1
	frame.cols = cols
	frame.space = space
	local button = getglobal(frameName.."Item1")
	if button then
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -31)
		for i = 1, rows, 1 do
			for j = 1, cols, 1 do
				index = index + 1
				button = getglobal(frameName.."Item"..index)
				if not button then break end
				button:ClearAllPoints()
				button:SetPoint("LEFT", frameName.."Item"..index - 1, "RIGHT", space, 0)
			end
			button = getglobal(frameName.."Item"..index)
			if not button then break end
			button:ClearAllPoints()
			button:SetPoint("TOP", frameName.."Item"..index - cols, "BOTTOM", 0, -space)
		end
	end
	BagnonFrame_TrimToSize(frame)
end
function BagnonFrame_Open(frameName,automatic)
	local frame = getglobal(frameName)
	if frame then BagnonFrame_Generate(frame) end
	if frame and not automatic then frame.manOpened = 1 end
	if frameName == "Bagnon" then BagnonDBUI_ChangePlayer(Bagnon,UnitName("player")) end
	if Banknon:IsVisible() then BagnonDBUI_ChangePlayer(Banknon,Bagnon.player) end
end
function BagnonFrame_Close(frameName,automatic)
	local frame = getglobal(frameName)
	if  frame then
		if not (automatic and frame.manOpened) then
			frame:Hide()
			frame.manOpened = nil
		end
	end
end
function BagnonFrame_Toggle(frameName)
	local frame = getglobal(frameName)
	if frame then
		if frame:IsVisible() then BagnonFrame_Close(frameName) else BagnonFrame_Open(frameName) end
	end
end
function BagnonFrame_HighlightSlots(frame,bagID)
	if not frame.size then return end

	local frameName = frame:GetName()
	local slot
	for slot = 1, frame.size, 1 do
		local item = getglobal(frameName.."Item"..slot)
		if item:GetParent():GetID() == bagID then item:LockHighlight() end
	end
end
function BagnonFrame_UnhighlightAll(frame)
	if not frame.size then return end

	local frameName = frame:GetName()
	local slot
	for slot = 1, frame.size, 1 do getglobal(frameName.."Item"..slot):UnlockHighlight() end
end
function BagnonFrame_ToggleBag(frame,bagID)
	if not frame then return end

	local frameName = frame:GetName()
	if not Bagnon_FrameHasBag(frameName,bagID) then
		table.insert(BagnonSets[frameName].bags,bagID)
	else
		for index in BagnonSets[frameName].bags do
			if BagnonSets[frameName].bags[index] and BagnonSets[frameName].bags[index] == bagID then table.remove(BagnonSets[frame:GetName()].bags,index) end
		end
	end
	BagnonFrame_OrderBags(frame,BagnonSets[frameName].reverse)
	if frame:IsShown() then BagnonFrame_Generate(frame) end
end
function BagnonFrame_StartMoving(frame)
	if not BagnonSets[frame:GetName()].locked then
		frame.isMoving = 1
		frame:StartMoving()
	end
end
function BagnonFrame_StopMoving(frame)
	frame.isMoving = nil
	frame:StopMovingOrSizing()
	BagnonFrame_SavePosition(frame)
end
function BagnonFrame_Reposition(frame)
	local frameName = frame:GetName()
	if not(BagnonSets[frameName] and BagnonSets[frameName].top) then return end

	local ratio
	if BagnonSets[frameName].parentScale then ratio = BagnonSets[frameName].parentScale / frame:GetParent():GetScale() else ratio = 1 end
	frame:ClearAllPoints()
	frame:SetScale(BagnonSets[frameName].scale)
	if frameName == "Bagnon" then
		frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMLEFT", BagnonSets[frameName].left * ratio, BagnonSets[frameName].top * ratio)
	elseif frameName == "Banknon" then 
		frame:SetPoint("TOPRIGHT", frame:GetParent(), "BOTTOMLEFT", BagnonSets[frameName].left * ratio, BagnonSets[frameName].top * ratio)
	end
end
function BagnonFrame_SavePosition(frame)
	local frameName = frame:GetName()

	if not BagnonSets[frameName] then BagnonSets[frameName] = {} end
	if frameName == "Bagnon" then
		BagnonSets[frameName].top = frame:GetBottom()
		BagnonSets[frameName].left = frame:GetRight()
	elseif frameName == "Banknon" then 
		BagnonSets[frameName].top = frame:GetTop()
		BagnonSets[frameName].left = frame:GetRight()
	end
	BagnonSets[frameName].scale = frame:GetScale()
	BagnonSets[frameName].parentScale = frame:GetParent():GetScale()
end
function BagnonFrame_SetStrata(frame,strata)
	BagnonSets[frame:GetName()].strata = strata
	frame:SetFrameStrata(FRAMESTRATA[strata])
end
function BagnonFrame_OnEnter()
	if BagnonSets.showTooltips then
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOMRIGHT", this, "BOTTOMLEFT", -2, 0)
		GameTooltip:SetOwner(this,"ANCHOR_PRESERVE")
		GameTooltip:SetText(this:GetText(),1,1,1)
		GameTooltip:AddLine(BAGNON_TITLE_TOOLTIP)
		GameTooltip:Show()
	end
end
function BagnonFrame_OnLeave()
	GameTooltip:Hide()
end
function BagnonFrameMoney_OnEnter()
	return
end
function BagnonFrameMoney_OnLeave()
	GameTooltip:Hide()
end
function BagnonFrameMoney_OnClick()
	local parentName = this:GetParent():GetName()
	local parent = this:GetParent()
	if MouseIsOver(getglobal(parentName.."GoldButton")) then
		OpenCoinPickupFrame(COPPER_PER_GOLD,MoneyTypeInfo[parent.moneyType].UpdateFunc(),parent)
		parent.hasPickup = 1
	elseif MouseIsOver(getglobal(parentName.."SilverButton")) then
		OpenCoinPickupFrame(COPPER_PER_SILVER,MoneyTypeInfo[parent.moneyType].UpdateFunc(),parent)
		parent.hasPickup = 1
	elseif MouseIsOver(getglobal(parentName.."CopperButton")) then
		OpenCoinPickupFrame(1,MoneyTypeInfo[parent.moneyType].UpdateFunc(),parent)
		parent.hasPickup = 1
	end
end
function BagnonFrame_OnHide()
	if BagnonMenu:IsVisible() and BagnonMenu.frame == this then BagnonMenu:Hide() end
end
function BagnonFrame_OnDoubleClick(frame)
	return
end
function BagnonFrame_OnClick(frame,mouseButton)
	if mouseButton == "RightButton" then BagnonMenu_Show(frame) end
end
local function ReverseSort(a,b)
	if a == KEYRING_CONTAINER then
		return true
	elseif b == KEYRING_CONTAINER then
		return false
	elseif a and b then
		return a > b
	end
end
local function NormalSort(a,b)
	if a == KEYRING_CONTAINER then
		return false
	elseif b == KEYRING_CONTAINER then
		return true
	elseif a and b then
		return a < b
	end
end
function BagnonFrame_OrderBags(frame,reverse)
	if reverse then
		if frame then
			table.sort(BagnonSets[frame:GetName()].bags,ReverseSort)
			if frame.defaultBags then table.sort(frame.defaultBags,ReverseSort) end
		end
	else
		if frame then
			table.sort(BagnonSets[frame:GetName()].bags,NormalSort)
			if frame.defaultBags then table.sort(frame.defaultBags,NormalSort) end
		end
	end
end

-- Menu Functions
function BagnonMenu_Show(frame)
	BagnonMenu.frame = frame
	BagnonMenu.onShow = 1
	BagnonMenuText:SetText(frame:GetName().." Settings")
	BagnonMenuLocked:SetChecked(BagnonSets[frame:GetName()].locked)
	BagnonMenuStayOnScreen:SetChecked(BagnonSets[frame:GetName()].stayOnScreen)
	local bgSets = BagnonSets[frame:GetName()].bg
	BagnonMenuBGSettingsNormalTexture:SetVertexColor(bgSets.r,bgSets.g,bgSets.b,bgSets.a)
	BagnonMenuReverse:SetChecked(BagnonSets[frame:GetName()].reverse)
	BagnonMenuColumns:SetValue(frame.cols)
	BagnonMenuSpacing:SetValue(frame.space)
	BagnonMenuScale:SetValue(frame:GetScale() * 100)
	BagnonMenuOpacity:SetValue(frame:GetAlpha() * 100)
	if BagnonSets[frame:GetName()].strata then BagnonMenuStrata:SetValue(BagnonSets[frame:GetName()].strata) else BagnonMenuStrata:SetValue(1) end
	local x,y = GetCursorPosition()
	x = x / UIParent:GetScale()
	y = y / UIParent:GetScale()
	BagnonMenu:ClearAllPoints()
	BagnonMenu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x - 32, y + 48)
	BagnonMenu:Show()
	BagnonMenu.onShow = nil
end
function BagnonMenu_SetAlpha(frame,alpha)
	if alpha ~= 1 then BagnonSets[frame:GetName()].alpha = alpha else BagnonSets[frame:GetName()].alpha = nil end
	frame:SetAlpha(alpha)
end
function BagnonMenu_SetScale(frame,scale)
	BagnonSets[frame:GetName()].scale = scale
	Bagnon_Infield.Scale(frame,scale)
	BagnonFrame_SavePosition(frame)
end
function BagnonMenuBG_OnClick(frame)
	if ColorPickerFrame:IsShown() then
		ColorPickerFrame:Hide()
	else
		local bgSets = BagnonSets[frame:GetName()].bg
		ColorPickerFrame.frame = frame
		ColorPickerFrame.func = BagnonMenuBG_ColorChange
		ColorPickerFrame.hasOpacity = 1
		ColorPickerFrame.opacityFunc = BagnonMenuBG_AlphaChange
		ColorPickerFrame.cancelFunc = BagnonMenuBG_CancelChanges
		BagnonMenuBGSettingsNormalTexture:SetVertexColor(bgSets.r,bgSets.g,bgSets.b,bgSets.a)
		ColorPickerFrame:SetColorRGB(bgSets.r,bgSets.g,bgSets.b)
		ColorPickerFrame.opacity = 1 - bgSets.a
		ColorPickerFrame.previousValues = {r = bgSets.r,g = bgSets.g,b = bgSets.b,opacity = bgSets.a}
		ShowUIPanel(ColorPickerFrame)
	end
end
function BagnonMenuBG_ColorChange()
	local r,g,b = ColorPickerFrame:GetColorRGB()
	local frame = ColorPickerFrame.frame
	local a = BagnonSets[frame:GetName()].bg.a
	frame:SetBackdropColor(r,g,b,a)
	frame:SetBackdropBorderColor(1,1,1,a)
	BagnonMenuBGSettingsNormalTexture:SetVertexColor(r,g,b,a)
	BagnonSets[frame:GetName()].bg.r = r
	BagnonSets[frame:GetName()].bg.g = g
	BagnonSets[frame:GetName()].bg.b = b
end
function BagnonMenuBG_AlphaChange()
	local frame = ColorPickerFrame.frame
	local bgSets = BagnonSets[frame:GetName()].bg
	local alpha = 1 - OpacitySliderFrame:GetValue()
	frame:SetBackdropColor(bgSets.r,bgSets.g,bgSets.b,alpha)
	frame:SetBackdropBorderColor(1,1,1,alpha)
	BagnonMenuBGSettingsNormalTexture:SetVertexColor(bgSets.r,bgSets.g,bgSets.b,alpha)
	BagnonSets[frame:GetName()].bg.a = alpha
end
function BagnonMenuBG_CancelChanges() 
	local prevValues = ColorPickerFrame.previousValues
	local frame = ColorPickerFrame.frame
	frame:SetBackdropColor(prevValues.r,prevValues.g,prevValues.b,prevValues.opacity)
	frame:SetBackdropBorderColor(1,1,1,prevValues.opacity)
	BagnonMenuBGSettingsNormalTexture:SetVertexColor(prevValues.r,prevValues.g,prevValues.b,prevValues.opacity)
	BagnonSets[frame:GetName()].bg.r = prevValues.r
	BagnonSets[frame:GetName()].bg.g = prevValues.g
	BagnonSets[frame:GetName()].bg.b = prevValues.b
	BagnonSets[frame:GetName()].bg.a = prevValues.opacity
end
function BagnonMenu_ToggleOrder(frame,checked)
	if checked then BagnonSets[frame:GetName()].reverse = 1 else BagnonSets[frame:GetName()].reverse = nil end
	BagnonFrame_OrderBags(frame,checked)
	BagnonFrame_Generate(frame)
end
function BagnonMenu_ToggleLock(frame,checked)
	local frameName = frame:GetName()
	if checked then BagnonSets[frameName].locked = 1 else BagnonSets[frameName].locked = nil end
end
function BagnonMenu_ToggleStayOnScreen(frame,checked)
	local frameName = frame:GetName()
	if checked then
		BagnonSets[frameName].stayOnScreen = 1
		frame:SetClampedToScreen(true)
	else
		BagnonSets[frameName].stayOnScreen = nil
		frame:SetClampedToScreen(false)
	end
end

-- Spot Functions
local oBagnonItem_Update = BagnonItem_Update
local oBagnonFrame_OnHide = BagnonFrame_OnHide
local oBagnonFrame_OnEnter = BagnonFrame_OnEnter
function BagnonSpot_Search(text)
	if text and text ~= "" then nameFilter = string.lower(text) else nameFilter = nil end
	if Bagnon and Bagnon:IsShown() then BagnonFrame_Generate(Bagnon) end
	if Banknon and Banknon:IsShown() then BagnonFrame_Generate(Banknon) end
end
function BagnonSpot_ClearSearch()
	nameFilter = nil
	if Bagnon and Bagnon:IsShown() then BagnonFrame_Generate(Bagnon) end
	if Banknon and Banknon:IsShown() then BagnonFrame_Generate(Banknon) end
end
BagnonFrame_OnDoubleClick = function(frame)
	if arg1 == "LeftButton" then
		BagnonSpot:Hide()
		BagnonSpot.frame = frame
		BagnonSpot:ClearAllPoints()
		BagnonSpot:SetPoint("TOPLEFT", frame:GetName().."Title", "TOPLEFT", -2, 1)
		BagnonSpot:SetPoint("BOTTOMRIGHT", frame:GetName().."Title", "BOTTOMRIGHT", 4, -1)
		BagnonSpot:Show()
	end
end
local function ToItemID(hyperLink)
	if hyperLink then
		local _,_,w = string.find(hyperLink,"item:(%d+)")
		return w
	end
end
BagnonItem_Update = function(item)
	oBagnonItem_Update(item)
	if nameFilter then		
		local link	
		if item.isLink then
			if BagnonDB then link = BagnonDB.GetItemData(item:GetParent():GetParent().player,item:GetParent():GetID(),item:GetID()) end
		else
			link = ToItemID(GetContainerItemLink(item:GetParent():GetID(),item:GetID()))
		end
		if link then
			local name = (GetItemInfo(link))		
			if name and not string.find(string.lower(name),nameFilter) then item:SetAlpha(item:GetParent():GetParent():GetAlpha()/3) else item:SetAlpha(item:GetParent():GetParent():GetAlpha()) end
		end
	else
		item:SetAlpha(item:GetParent():GetParent():GetAlpha())
	end
end
BagnonFrame_OnHide = function()
	oBagnonFrame_OnHide()
	if BagnonSpot:IsVisible() and BagnonSpot.frame == this then BagnonSpot:Hide() end
end
BagnonFrame_OnEnter = function()
	oBagnonFrame_OnEnter()
	if BagnonSets.showTooltips then
		GameTooltip:AddLine(BAGNON_SPOT_TOOLTIP)
		GameTooltip:Show()
	end
end

-- Slash
function BagnonSlash_DisplayHelp()
	BagnonMsg(BAGNON_HELP_TITLE)
	BagnonMsg(BAGNON_HELP_HELP)
	BagnonMsg(BAGNON_HELP_SHOWBAGS)
	BagnonMsg(BAGNON_HELP_SHOWBANK)
	BagnonMsg(BAGNON_FOREVER_HELP_DELETE_CHARACTER)
end
SlashCmdList["BagnonCOMMAND"] = function(msg)
	if not msg or msg == "" then
		BagnonOptions:Show()
	else
		local args = {}
		local word
		for word in string.gfind(msg,"[^%s]+") do table.insert(args,word) end
		local cmd = string.lower(args[1])
		if cmd == BAGNON_COMMAND_HELP then
			BagnonSlash_DisplayHelp()
		elseif cmd == BAGNON_COMMAND_SHOWBANK then
			BagnonFrame_Toggle("Banknon")
		elseif cmd == BAGNON_COMMAND_SHOWBAGS then
			BagnonFrame_Toggle("Bagnon")
		elseif cmd == BAGNON_COMMAND_DEBUG_ON then
			BagnonSets.noDebug = nil
			BagnonMsg(BAGNON_DEBUG_ENABLED)
		elseif cmd == BAGNON_COMMAND_DEBUG_OFF then
			BagnonSets.noDebug = 1
			BagnonMsg(BAGNON_DEBUG_DISABLED)
		elseif cmd == BAGNON_FOREVER_COMMAND_DELETE_CHARACTER then
			BagnonForever_RemovePlayer(args[2], args[3] or GetRealmName())
		end
	end
end
SLASH_BagnonCOMMAND1 = "/bagnon"
SLASH_BagnonCOMMAND2 = "/bgn"

-- Events
local function ShouldUpdateBag(frame,bag)
	return frame and frame:IsVisible() and Bagnon_FrameHasBag(frame:GetName(),bag)
end
local function OpenIF(frameName,condition)
	if condition then BagnonFrame_Open(frameName,1) return true end
end
local function CloseIF(frameName,condition)
	if condition then BagnonFrame_Close(frameName,1) return true end
end
local function ShowBlizBank()
	BankFrameTitleText:SetText(UnitName("npc"))
	SetPortraitTexture(BankPortraitTexture,"npc")
	ShowUIPanel(BankFrame)
	if not BankFrame:IsVisible() then CloseBankFrame() end
	UpdateBagSlotStatus()
end
local function LoadVariables()
	local currentVersion = GetAddOnMetadata("Bagnon_Core","Version")
	if not BagnonSets then
		BagnonSets = {
			showBagsAtBank = 1,
			showBagsAtAH = 1,
			showBankAtBank = 1,
			showTooltips = 1,
			qualityBorders = 1,
			showForeverTooltips = 1,
			version = currentVersion,
		}
		BagnonMsg(BAGNON_INITIALIZED)
	elseif BagnonSets.version ~= currentVersion then
		BagnonSets.version = currentVersion
		BagnonMsg(format(BAGNON_UPDATED,currentVersion))
	end
end
local function HaveLocalizedInfo()
	local locale = GetLocale()
	return (locale == "enUS" or
			locale == "deDE" or
			locale == "frFR" or
			locale == "zhCN" or
			locale == "zhTW" or
			locale == "esES" or
			BagnonSets.noDebug)
end
local function ObtainLocalizedNames()
	local haveInfo = HaveLocalizedInfo()
	if not haveInfo then
		BagnonMsg("Obtaining localized data.  Please report the following to where you downloaded Bagnon from.")
		BagnonMsg(GetLocale())
	end
	local name,_,_,_,iType,subType = GetItemInfo(4500)
	if name then
		if not haveInfo then BagnonMsg("Backpack:  "..(iType or "null")..", "..(subType or "null")) end
		if iType then
			BAGNON_ITEMTYPE_CONTAINER = iType
			BAGNON_SUBTYPE_BAG = subType
		end
	end
	name,_,_,_,iType,subType = GetItemInfo(8218) -- ammo
	if name then
		if not haveInfo then BagnonMsg("Ammo:  "..(iType or "null")..", "..(subType or "null")) end
		if iType then BAGNON_ITEMTYPE_QUIVER = iType end
	end
	name,_,_,_,iType,subType = GetItemInfo(21340) --soul pouch
	if name then
		if not haveInfo then BagnonMsg("Soul Bag:  "..(iType or "null")..", "..(subType or "null")) end
		if subType then BAGNON_SUBTYPE_SOULBAG = subType end
	end
end
local function Load(eventFrame)
	BankFrame:UnregisterEvent("BANKFRAME_OPENED")
	LoadVariables()
	BagnonForever_LoadVariables()
	ObtainLocalizedNames()
	Bagnon_Infield.AddRescaleAction(function()
		if Bagnon then BagnonFrame_Reposition(Bagnon) end
		if Banknon then BagnonFrame_Reposition(Banknon) end
	end)
	eventFrame:RegisterEvent("BAG_UPDATE")
	eventFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	eventFrame:RegisterEvent("ITEM_LOCK_CHANGED")
	eventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
	eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
	eventFrame:RegisterEvent("BANKFRAME_OPENED")
	eventFrame:RegisterEvent("BANKFRAME_CLOSED")
	eventFrame:RegisterEvent("TRADE_SHOW")
	eventFrame:RegisterEvent("TRADE_CLOSED")
	eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
	eventFrame:RegisterEvent("TRADE_SKILL_CLOSE")
	eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
	eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
	eventFrame:RegisterEvent("MAIL_SHOW")
	eventFrame:RegisterEvent("MAIL_CLOSED")
	eventFrame:RegisterEvent("MERCHANT_SHOW")
	eventFrame:RegisterEvent("MERCHANT_CLOSED")
	eventFrame:RegisterEvent("PLAYER_MONEY")
	eventFrame:RegisterEvent("PLAYER_LOGIN")
end
local function OnEvent()
	if event == "BAG_UPDATE" or event == "BAG_UPDATE_COOLDOWN" then
		if arg1 then
			if ShouldUpdateBag(Bagnon,arg1) then
				BagnonFrame_Update(Bagnon,arg1)
			elseif ShouldUpdateBag(Banknon,arg1) then
				BagnonFrame_Update(Banknon,arg1)
			end
			BagnonForever_SaveBagData(arg1)
		end
	elseif event == "PLAYER_MONEY" then
		BagnonForever_SavePlayerMoney()
	elseif event == "PLAYER_LOGIN" then
		BagnonForever_SavePlayerMoney()
		if not BagnonForeverData[currentRealm][UnitName("player")][0] then BagnonForever_SaveAllData() end
	elseif event == "PLAYERBANKSLOTS_CHANGED" then
		if ShouldUpdateBag(Banknon,-1) then BagnonFrame_Update(Banknon,-1) end
		BagnonForever_SaveBagData(-1)
	elseif event == "ITEM_LOCK_CHANGED" then
		if Bagnon and Bagnon:IsVisible() then BagnonFrame_UpdateLock(Bagnon) end
		if Banknon and Banknon:IsVisible() then BagnonFrame_UpdateLock(Banknon) end
	elseif event == "PLAYER_LEVEL_UP" then
		if ShouldUpdateBag(Bagnon,KEYRING_CONTAINER) then BagnonFrame_Generate(Bagnon) end
	elseif event == "BANKFRAME_OPENED" then
		bgn_atBank = true
		OpenIF("Bagnon",BagnonSets.showBagsAtBank)
		if not OpenIF("Banknon",BagnonSets.showBankAtBank) then ShowBlizBank() end
		BagnonForever_SaveBankData()
	elseif event == "BANKFRAME_CLOSED" then
		bgn_atBank = nil
		BagnonForever_SaveBankData()
		CloseIF("Bagnon",BagnonSets.showBagsAtBank)
		CloseIF("Banknon",BagnonSets.showBankAtBank)
	elseif event == "TRADE_SHOW" then
		OpenIF("Bagnon",BagnonSets.showBagsAtTrade)
		OpenIF("Banknon",BagnonSets.showBankAtTrade)
	elseif event == "TRADE_CLOSED" then
		CloseIF("Bagnon",BagnonSets.showBagsAtTrade)
		CloseIF("Banknon",BagnonSets.showBankAtTrade)
	elseif event == "TRADE_SKILL_SHOW" then
		OpenIF("Bagnon",BagnonSets.showBagsAtCraft)
		OpenIF("Banknon",BagnonSets.showBankAtCraft)
	elseif event == "TRADE_SKILL_CLOSE" then
		CloseIF("Bagnon",BagnonSets.showBagsAtCraft)
		CloseIF("Banknon",BagnonSets.showBankAtCraft)
	elseif event == "AUCTION_HOUSE_SHOW" then
		OpenIF("Bagnon",BagnonSets.showBagsAtAH)
		OpenIF("Banknon",BagnonSets.showBankAtAH)
	elseif event == "AUCTION_HOUSE_CLOSED" then
		CloseIF("Bagnon",BagnonSets.showBagsAtAH)
		CloseIF("Banknon",BagnonSets.showBankAtAH)
	elseif event == "MAIL_SHOW" then
		OpenIF("Banknon",BagnonSets.showBankAtMail)
	elseif event == "MAIL_CLOSED" then
		CloseIF("Bagnon",true)
		CloseIF("Banknon",BagnonSets.showBankAtMail)
	elseif event == "MERCHANT_SHOW" then
		OpenIF("Banknon",BagnonSets.showBankAtVendor)
	elseif event == "MERCHANT_CLOSED" then
		CloseIF("Banknon",BagnonSets.showBankAtVendor)
	elseif event == "ADDON_LOADED" and arg1 == "Bagnon" then
		this:UnregisterEvent("ADDON_LOADED")
		Load(this)
		Bagnon_Load()
		Banknon_Load(Banknon)
	end
end
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent",OnEvent)
eventFrame:Hide()

-- Options Menu Functions
function BagnonOptions_OnShow()
	local frameName = this:GetName()
	getglobal(frameName.."Tooltips"):SetChecked(BagnonSets.showTooltips)
	getglobal(frameName.."ForeverTooltips"):SetChecked(BagnonSets.showForeverTooltips)
	getglobal(frameName.."Quality"):SetChecked(BagnonSets.qualityBorders)
	getglobal(frameName.."ShowBagnon1"):SetChecked(BagnonSets.showBagsAtBank)
	--getglobal(frameName.."ShowBagnon2"):SetChecked(BagnonSets.showBagsAtVendor)
	getglobal(frameName.."ShowBagnon3"):SetChecked(BagnonSets.showBagsAtAH)
	--getglobal(frameName.."ShowBagnon4"):SetChecked(BagnonSets.showBagsAtMail)
	getglobal(frameName.."ShowBagnon5"):SetChecked(BagnonSets.showBagsAtTrade)
	getglobal(frameName.."ShowBagnon6"):SetChecked(BagnonSets.showBagsAtCraft)
	getglobal(frameName.."ShowBanknon1"):SetChecked(BagnonSets.showBankAtBank)
	getglobal(frameName.."ShowBanknon2"):SetChecked(BagnonSets.showBankAtVendor)
	getglobal(frameName.."ShowBanknon3"):SetChecked(BagnonSets.showBankAtAH)
	getglobal(frameName.."ShowBanknon4"):SetChecked(BagnonSets.showBankAtMail)
	getglobal(frameName.."ShowBanknon5"):SetChecked(BagnonSets.showBankAtTrade)
	getglobal(frameName.."ShowBanknon6"):SetChecked(BagnonSets.showBankAtCraft)
end
function BagnonOptions_ShowAtBank(enable,bank)
	if bank then
		if enable then BagnonSets.showBankAtBank = 1 else BagnonSets.showBankAtBank = nil end
	else
		if enable then BagnonSets.showBagsAtBank = 1 else BagnonSets.showBagsAtBank = nil end
	end
end
function BagnonOptions_ShowAtVendor(enable,bank)
	if bank then
		if enable then BagnonSets.showBankAtVendor = 1 else BagnonSets.showBankAtVendor = nil end
	else
		if enable then BagnonSets.showBagsAtVendor = 1 else BagnonSets.showBagsAtVendor = nil end
	end
end
function BagnonOptions_ShowAtAH(enable,bank)
	if bank then
		if enable then BagnonSets.showBankAtAH = 1 else BagnonSets.showBankAtAH = nil end
	else
		if enable then BagnonSets.showBagsAtAH = 1 else BagnonSets.showBagsAtAH = nil end
	end
end
function BagnonOptions_ShowAtMail(enable,bank)
	if bank then
		if enable then BagnonSets.showBankAtMail = 1 else BagnonSets.showBankAtMail = nil end
	else
		if enable then BagnonSets.showBagsAtMail = 1 else BagnonSets.showBagsAtMail = nil end
	end
end
function BagnonOptions_ShowAtTrade(enable,bank)
	if bank then
		if enable then BagnonSets.showBankAtTrade = 1 else BagnonSets.showBankAtTrade = nil end
	else
		if enable then BagnonSets.showBagsAtTrade = 1 else BagnonSets.showBagsAtTrade = nil end
	end
end
function BagnonOptions_ShowAtCrafting(enable,bank)
	if bank then
		if enable then BagnonSets.showBankAtCraft = 1 else BagnonSets.showBankAtCraft = nil end
	else
		if enable then BagnonSets.showBagsAtCraft = 1 else BagnonSets.showBagsAtCraft = nil end
	end
end
function BagnonOptions_ShowTooltips(enable)
	if enable then BagnonSets.showTooltips = 1 else BagnonSets.showTooltips = nil end
end
function BagnonOptions_ShowForeverTooltips(enable)
	if enable then BagnonSets.showForeverTooltips = 1 else BagnonSets.showForeverTooltips = nil end
end
function BagnonOptions_ShowQualityBorders(enable)
	if enable then BagnonSets.qualityBorders = 1 else BagnonSets.qualityBorders = nil end
	if Bagnon and Bagnon:IsShown() then BagnonFrame_Generate(Bagnon) end
	if Banknon and Banknon:IsShown() then BagnonFrame_Generate(Banknon) end
end

-- Database
function BagnonDB.GetPlayers()
	return pairs(BagnonForeverData[currentRealm])
end
function BagnonDB.GetBags(player)
	if player and BagnonForeverData[currentRealm][player] then return ipairs(BagnonForeverData[currentRealm][player]) end
end
function BagnonDB.GetItems(player,bagID)
	if player and bagID and BagnonForeverData[currentRealm][player] and BagnonForeverData[currentRealm][player][bagID] then return ipairs(BagnonForeverData[currentRealm][player][bagID]) end
end
function BagnonDB.GetMoney(player)
	if BagnonForeverData[currentRealm][player] then return BagnonForeverData[currentRealm][player].g or 0 end
	return 0
end
function BagnonDB.GetBagData(player,bagID)
	local playerData = BagnonForeverData[currentRealm][player]
	if playerData then
		local bagData = playerData[bagID]	
		if bagData then
			local _,_,size,count,link = string.find(bagData.s, "([%w_:]+),([%w_:]+),([%w_:]*)")
			if size ~= "" then
				if link ~="" then
					if tonumber(link) then link = link..":0:0:0" end
					link = "item:"..link
				else
					link = nil
				end
				return size,link,tonumber(count)
			end
		end
	end
end
function BagnonDB.GetItemData(player,bagID,itemSlot)
	local playerData = BagnonForeverData[currentRealm][player]
	if playerData then
		local bagData = playerData[bagID]
		if bagData then
			local itemData = bagData[itemSlot]
			if itemData then
				local _,_,itemLink,count = string.find(itemData, "([%d:]+),*(%d*)")
				if tonumber(itemLink) then itemLink = itemLink..":0:0:0" end
				itemLink = "item:"..itemLink
				local _,_,quality,_,_,_,_,_,texture = GetItemInfo(itemLink)
				return itemLink,tonumber(count),texture,quality
			end
		end
	end
end
function BagnonDB.GetItemTotal(id,player,bagID)
	local count = 0
	local playerData = BagnonForeverData[currentRealm][player]
	if playerData then
		local bagData = playerData[bagID]
		if bagData then
			for itemSlot in pairs(bagData) do
				if tonumber(itemSlot) then
					local itemLink,itemCount = BagnonDB.GetItemData(player,bagID,itemSlot)
					if itemLink then
						local itemID
						if not tonumber(itemLink) then _,_,itemID = string.find(itemLink, "(%d+):") end
						itemID = tonumber(itemID)
						if tonumber(id) == itemID then count = count + (itemCount or 1) end
					end
				end
			end
		end
	end
	return count
end
function BagnonDB.GetItemHyperlink(player,bagID,itemSlot)
	local playerData = BagnonForeverData[currentRealm][player]
	if playerData then
		local bagData = playerData[bagID]
		if bagData then
			local itemData = bagData[itemSlot]
			if itemData then
				local _,_,itemLink = string.find(itemData, "([%w_:]+)")
				if tonumber(itemLink) then itemLink = itemLink..":0:0:0" end
				itemLink = "item:"..itemLink
				if itemLink then
					local name,_,quality = GetItemInfo(itemLink)
					local _,_,_,hex = GetItemQualityColor(quality)
					return hex.."|H"..itemLink.."|h["..name.."]|h|r"
				end
			end
		end
	end
end

-- UI
function BagnonDBUI_ChangePlayer(frame,player)
	frame.player = player
	getglobal(frame:GetName().."Title"):SetText(string.format(frame.title,player))
	BagnonFrame_Generate(frame)
	local bagFrame = getglobal(frame:GetName().."Bags")
	if bagFrame and bagFrame:IsShown() then
		for i = 1, 10 do BagnonBag_UpdateTexture(frame,i) end
	end
	if frame == Banknon then Banknon_UpdatePurchaseButtonVis() end
end
local function CreatePlayerButton(id,parent)
	local button = CreateFrame("CheckButton", parent:GetName()..id, parent, "BagnonDBUIChangeNameButton")
	if id == 1 then button:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -4) else button:SetPoint("TOP", getglobal(parent:GetName()..(id - 1)), "BOTTOM", 0, 6) end
	return button
end
local function CreateDeletePlayerButton(id,parent)
	local deletebutton = CreateFrame("Button", parent:GetName().."DeleteButton", parent, "BagnonDBUIDeleteNameButton")
	return deletebutton
end
function BagnonDBUI_ShowCharacterList(parentFrame)
	BagnonDBUICharacterList.frame = parentFrame
	local width = 0
	local index = 0
	for player in BagnonDB.GetPlayers() do
		index = index + 1
		local button = getglobal("BagnonDBUICharacterList"..index) or CreatePlayerButton(index,BagnonDBUICharacterList)
		button:SetText(player)
		if button:GetTextWidth() + 40 > width then width = button:GetTextWidth() + 40 end
		if parentFrame.player == player then
			button:SetChecked(true)
			button:Show()
			if getglobal("BagnonDBUICharacterList"..index.."DeleteButton") then getglobal("BagnonDBUICharacterList"..index.."DeleteButton"):Hide() end
		else
			button:SetChecked(false)
			local deletebutton = getglobal("BagnonDBUICharacterList"..index.."DeleteButton") or CreateDeletePlayerButton(index,getglobal("BagnonDBUICharacterList"..index))
			deletebutton:Show()
		end
	end
	local i = index + 1
	while getglobal("BagnonDBUICharacterList"..i) do
		getglobal("BagnonDBUICharacterList"..i):Hide()
		i = i + 1
	end
	i = 0
	for player in BagnonDB.GetPlayers() do
		i = i + 1
		if parentFrame.player ~= player then getglobal("BagnonDBUICharacterList"..i.."DeleteButton"):SetPoint("LEFT", getglobal("BagnonDBUICharacterList"..i), "LEFT", width-12, 0) end
	end
	BagnonDBUICharacterList:SetHeight(12 + index * 19)
	BagnonDBUICharacterList:SetWidth(width)
	BagnonDBUICharacterList:ClearAllPoints()
	BagnonDBUICharacterList:SetPoint("TOPLEFT", parentFrame:GetName().."DropDown", "BOTTOMLEFT", 0, 4)
	BagnonDBUICharacterList:Show()
end
BagnonFrame_OnHide = function()
	oBagnonFrame_OnHide()
	if BagnonDBUICharacterList.frame == this then BagnonDBUICharacterList:Hide() end
end

-- Tooltips
local function LinkToID(link)
	if link then
		local _,_,id = string.find(link, "(%d+):")
		return tonumber(id)
	end
end
local function AddOwners(frame,id)
	if not (frame and id and BagnonSets.showForeverTooltips) then return end
	for player in BagnonDB.GetPlayers() do
		if player ~= currentPlayer or player == currentPlayer then
			local invCount = BagnonDB.GetItemTotal(id,player,-2)
			for bagID = 0, 4 do invCount = invCount + BagnonDB.GetItemTotal(id,player,bagID) end
			local bankCount = BagnonDB.GetItemTotal(id,player,-1)
			for bagID = 5, 10 do bankCount = bankCount + BagnonDB.GetItemTotal(id,player,bagID) end
			if (invCount + bankCount) > 0 then
				local tooltipString = player.." "..BAGNON_FOREVER_HAS
				if invCount > 0 then tooltipString = tooltipString.." "..invCount.." "..BAGNON_FOREVER_BAGS end
				if bankCount > 0 then tooltipString = tooltipString.." "..bankCount.." "..BAGNON_FOREVER_BANK end
				frame:AddLine(tooltipString,1,1,0)
			end
		end
	end
	frame:Show()
end
GameTooltip.SetBagItem = function(self,bag,slot)
	Blizz_GameTooltip_SetBagItem(self,bag,slot)
	AddOwners(self,LinkToID(GetContainerItemLink(bag,slot)))
end
GameTooltip.SetLootItem = function(self,slot)
	Bliz_GameTooltip_SetLootItem(self,slot)
	AddOwners(self,LinkToID(GetLootSlotLink(slot)))
end
GameTooltip.SetHyperlink = function(self,link,count)
	Bliz_SetHyperlink(self,link,count)
	AddOwners(self,LinkToID(link))
end
ItemRefTooltip.SetHyperlink = function(self,link,count)
	Bliz_ItemRefTooltip_SetHyperlink(self,link,count)
	AddOwners(self,LinkToID(link))
end
GameTooltip.SetLootRollItem = function(self,rollID)
	Bliz_GameTooltip_SetLootRollItem(self,rollID)
	AddOwners(self,LinkToID(GetLootRollItemLink(rollID)))
end
GameTooltip.SetAuctionItem = function(self,type,index)
	Bliz_GameTooltip_SetAuctionItem(self,type,index)
	AddOwners(self,LinkToID(GetAuctionItemLink(type,index)))
end
function BagnonFrameMoney_OnEnter()
	if this:GetLeft() > (UIParent:GetRight() / 2) then GameTooltip:SetOwner(this,"ANCHOR_LEFT") else GameTooltip:SetOwner(this,"ANCHOR_RIGHT") end
	GameTooltip:SetText(string.format(BAGNON_FOREVER_MONEY_ON_REALM, GetRealmName()))
	local money = 0
	for player in BagnonDB.GetPlayers() do money = money + BagnonDB.GetMoney(player) end
	SetTooltipMoney(GameTooltip,money)
	GameTooltip:Show()
end

-- Bagnon Forever
function BagnonForever_HyperlinkToShortLink(hyperLink)
	if hyperLink then
		local _,_,w,x,y,z = string.find(hyperLink, "item:(%d+):(%d+):(%d+):(%d+)")
		if tonumber(x) == 0 and tonumber(y) == 0 and tonumber(z) == 0 then return w else return w..":"..x..":"..y..":"..z end
	end
end
function BagnonForever_SaveItemData(bagID,itemSlot)
	local texture,count = GetContainerItemInfo(bagID,itemSlot)
	local data
	if texture then
		data = BagnonForever_HyperlinkToShortLink(GetContainerItemLink(bagID,itemSlot))
		if count > 1 then data = data..","..count end
	end
	BagnonForeverData[currentRealm][currentPlayer][bagID][itemSlot] = data
end
function BagnonForever_SaveBagData(bagID)
	if Bagnon_IsBankBag(bagID) and not bgn_atBank then return end
	local size
	if bagID == KEYRING_CONTAINER then size = GetKeyRingSize() else size = GetContainerNumSlots(bagID) end
	if size > 0 then
		local link,count
		if bagID > 0 then link = BagnonForever_HyperlinkToShortLink(GetInventoryItemLink("player",ContainerIDToInventoryID(bagID))) end
		count = GetInventoryItemCount("player",ContainerIDToInventoryID(bagID))
		BagnonForeverData[currentRealm][currentPlayer][bagID] = {}
		BagnonForeverData[currentRealm][currentPlayer][bagID].s = size..","..count..","
		if link then BagnonForeverData[currentRealm][currentPlayer][bagID].s = BagnonForeverData[currentRealm][currentPlayer][bagID].s..link end
		for index = 1, size, 1 do BagnonForever_SaveItemData(bagID,index) end
	else
		BagnonForeverData[currentRealm][currentPlayer][bagID] = nil
	end
end
function BagnonForever_SavePlayerMoney()
	BagnonForeverData[currentRealm][currentPlayer].g = GetMoney()
end
function BagnonForever_SaveBankData()
	BagnonForever_SaveBagData(-1)
	local bagID
	for bagID = 5, 10, 1 do BagnonForever_SaveBagData(bagID) end
end
function BagnonForever_SaveAllData()
	local i
	for i = -2, 10, 1 do BagnonForever_SaveBagData(i) end
	BagnonForever_SavePlayerMoney()
end
function BagnonForever_RemovePlayer(player,realm)
	if BagnonForeverData[realm] then BagnonForeverData[realm][player] = nil end
end
local function UpdateVersion()
	BagnonForeverData.version = BAGNON_FOREVER_VERSION
	BagnonMsg(BAGNON_FOREVER_UPDATED)
end
function BagnonForever_LoadVariables()
	if not (BagnonForeverData and BagnonForeverData.wowVersion and BagnonForeverData.wowVersion == GetBuildInfo()) then
		BagnonForeverData = { version = BAGNON_FOREVER_VERSION, wowVersion = GetBuildInfo() }
	end
	if BagnonDB and not (BagnonDB.GetPlayers or BagnonDB.GetPlayerList) then
		message("BagnonForever:  Updating from an old version.  Saved data will be available on your next login.")
		BagnonDB = nil
	end
	if not BagnonForeverData[currentRealm] then BagnonForeverData[currentRealm] = {} end
	if not BagnonForeverData[currentRealm][UnitName("player")] then BagnonForeverData[currentRealm][UnitName("player")] = {} end
	if BagnonForeverData.version ~= BAGNON_FOREVER_VERSION then UpdateVersion() end
end
CreateFrame("Frame","BagnonForever")
BagnonForever:RegisterEvent("BAG_UPDATE")
BagnonForever:RegisterEvent("PLAYER_LOGIN")
BagnonForever:RegisterEvent("BANKFRAME_CLOSED")
BagnonForever:RegisterEvent("BANKFRAME_OPENED")
BagnonForever:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
BagnonForever:RegisterEvent("PLAYER_MONEY")
BagnonForever:SetScript("OnEvent",function()
end)

-- Bagnon Functions
function Bagnon_Load()
	BagnonFrame_Load(Bagnon,{0,1,2,3,4},BAGNON_INVENTORY_TITLE)
	Bagnon_AddBagHooks()
	if Bagnon:GetBottom() > 80 and Bagnon:GetBottom() < 88 then Bagnon:SetPoint("BOTTOMRIGHT", 0, 84) end
end
function Bagnon_OnShow()
	MainMenuBarBackpackButton:SetChecked(1)
	PlaySound("igBackPackOpen")
end
function Bagnon_OnHide()
	MainMenuBarBackpackButton:SetChecked(0)
	PlaySound("igBackPackClose")
end
function Bagnon_ToggleBags()
	if not BagnonBags:IsShown() then
		BagnonBags:Show()
		BagnonSets["Bagnon"].bagsShown = 1
		this:SetText(BAGNON_HIDEBAGS)
	else
		BagnonBags:Hide()
		BagnonSets["Bagnon"].bagsShown = nil
		this:SetText(BAGNON_SHOWBAGS)
	end
	BagnonFrame_TrimToSize(Bagnon)
end
function Bagnon_AddBagHooks()
	bMainBag_OnEnter = MainMenuBarBackpackButton:GetScript("OnEnter")
	bMainBag_OnClick = MainMenuBarBackpackButton:GetScript("OnClick")
	MainMenuBarBackpackButton:SetScript("OnEnter",BagnonBlizMainBag_OnEnter)
	MainMenuBarBackpackButton:SetScript("OnLeave",BagnonBlizBag_OnLeave)
	MainMenuBarBackpackButton:SetScript("OnClick",BagnonBlizMainBag_OnClick)
	bBagSlotButton_OnEnter = BagSlotButton_OnEnter
	BagSlotButton_OnEnter = BagnonBlizBag_OnEnter
	bBagSlotButton_OnClick = getglobal("CharacterBag0Slot"):GetScript("OnClick")
	for i = 0, 3 do
		getglobal("CharacterBag"..i.."Slot"):SetScript("OnLeave",BagnonBlizBag_OnLeave)
		getglobal("CharacterBag"..i.."Slot"):SetScript("OnClick",BagnonBlizBag_OnClick)
	end
	bKeyRingButton_OnEnter = KeyRingButton:GetScript("OnEnter")
	bKeyRingButton_OnClick = KeyRingButton:GetScript("OnClick")
	KeyRingButton:SetScript("OnEnter",BagnonBlizKeyRing_OnEnter)
	KeyRingButton:SetScript("OnLeave",BagnonBlizBag_OnLeave)
	KeyRingButton:SetScript("OnClick",BagnonBlizKeyRing_OnClick)
end
function BagnonBlizMainBag_OnEnter()
	if Bagnon:IsShown() then BagnonFrame_HighlightSlots(Bagnon,this:GetID()) end
	bMainBag_OnEnter()
end
function BagnonBlizMainBag_OnClick()
	if IsShiftKeyDown() then BagnonFrame_ToggleBag(Bagnon,this:GetID()) else bMainBag_OnClick() end
end
function BagnonBlizBag_OnEnter()
	if Bagnon:IsShown() then BagnonFrame_HighlightSlots(Bagnon,this:GetID() - 19) end
	bBagSlotButton_OnEnter()
end
function BagnonBlizBag_OnClick()
	if IsShiftKeyDown() then BagnonFrame_ToggleBag(Bagnon,this:GetID() - 19) else bBagSlotButton_OnClick() end
end
function BagnonBlizBag_OnLeave()
	GameTooltip:Hide()
	BagnonFrame_UnhighlightAll(Bagnon)
end
function BagnonBlizKeyRing_OnEnter()
	if Bagnon:IsShown() then BagnonFrame_HighlightSlots(Bagnon,this:GetID()) end
	bKeyRingButton_OnEnter()
end
function BagnonBlizKeyRing_OnClick()
	if IsShiftKeyDown() then BagnonFrame_ToggleBag(Bagnon,this:GetID()) else bKeyRingButton_OnClick() end
end

--Banknon Functions
function Banknon_OnLoad()
	StaticPopupDialogs["CONFIRM_BUY_BANK_SLOT_BANKNON"] = {
		text = TEXT(CONFIRM_BUY_BANK_SLOT),
		button1 = TEXT(YES),
		button2 = TEXT(NO),
		OnAccept = function() PurchaseSlot() end,
		OnShow = function()
			MoneyFrame_Update(this:GetName().."MoneyFrame",GetBankSlotCost(GetNumBankSlots()))
		end,
		hasMoneyFrame = 1,
		timeout = 0,
		hideOnEscape = 1,
	}
end
function Banknon_OnEvent(event)
	if event == "PLAYER_MONEY" or event == "PLAYERBANKBAGSLOTS_CHANGED" then
		if this:IsShown() then Banknon_UpdateSlotCost() end
	elseif event == "BANKFRAME_OPENED" then
		if this:IsShown() then Banknon_UpdatePurchaseButtonVis() end
	elseif event == "BANKFRAME_CLOSED" then
		if this:IsShown() then
			BagnonFrame_Generate(this)
			Banknon_UpdatePurchaseButtonVis()
		end
	end
end
function Banknon_Load(frame)
	frame:RegisterEvent("PLAYER_MONEY")
	frame:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
	frame:RegisterEvent("BANKFRAME_OPENED")
	frame:RegisterEvent("BANKFRAME_CLOSED")
	BagnonFrame_Load(frame,{-1,5,6,7,8,9,10},BAGNON_BANK_TITLE)
	if CT_BankFrame_AcceptFrame then CT_BankFrame_AcceptFrame:SetParent(frame) end
	Banknon_UpdateSlotCost()
end
function Banknon_OnShow()
	Banknon_UpdatePurchaseButtonVis()
	PlaySound("igMainMenuOpen")
end
function Banknon_OnHide()
	PlaySound("igMainMenuClose")
	if bgn_atBank then CloseBankFrame() end
end
function Banknon_ToggleSlots()
	if not BanknonBags:IsShown() then
		BanknonBags:Show()
		BagnonSets["Banknon"].bagsShown = 1
		this:SetText(BAGNON_HIDEBAGS)
	else
		BanknonBags:Hide()
		BagnonSets["Banknon"].bagsShown = nil
		this:SetText(BAGNON_SHOWBAGS)
	end
	Banknon_UpdatePurchaseButtonVis(not BagnonSets["Banknon"].bagsShown)
end
function Banknon_UpdateSlotCost()
	local cost = GetBankSlotCost(GetNumBankSlots())
	if GetMoney() >= cost then SetMoneyFrameColor("BanknonCost",1.0,1.0,1.0) else SetMoneyFrameColor("BanknonCost",1.0,0.1,0.1) end
	MoneyFrame_Update("BanknonCost",cost)
	Banknon_UpdatePurchaseButtonVis()
end
function Banknon_UpdatePurchaseButtonVis(hide)
	if BanknonBags:IsVisible() or hide then
		local _,full = GetNumBankSlots()
		if bgn_atBank and not (full or hide) and (not Banknon.player or Banknon.player == UnitName("player")) then
			BanknonPurchase:Show()
			BanknonCost:Show()
			BanknonBags:SetHeight(68)
		else
			BanknonPurchase:Hide()
			BanknonCost:Hide()
			BanknonBags:SetHeight(42)
		end
	end
	BagnonFrame_TrimToSize(Banknon)
end

-- Infield Functions
local function RegisterScaleEvents()
	Bagnon_InfieldUpdater:SetScript("OnEvent",function()
		if this.currentScale ~= UIParent:GetScale() then
			for _,action in pairs(Bagnon_Infield.rescaleList) do action() end
			this.currentScale = UIParent:GetScale()
		end
	end)
	Bagnon_InfieldUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
	Bagnon_InfieldUpdater:RegisterEvent("CVAR_UPDATE")
end
local function GetAdjustedCoords(frame,nScale)
	if not frame:GetLeft() and frame:GetTop() then return end
	return frame:GetLeft() * frame:GetScale() / nScale, frame:GetTop() * frame:GetScale() / nScale
end
Bagnon_Infield = {rescaleList = {}}
Bagnon_Infield.AddRescaleAction = function(funct) table.insert(Bagnon_Infield.rescaleList,funct) end
Bagnon_Infield.Scale = function(frame,scale)
	local x,y = GetAdjustedCoords(frame,scale)
	frame:SetScale(scale)
	if x and y then Bagnon_Infield.Place(frame, "TOPLEFT", UIParent, "BOTTOMLEFT", x, y) end
end
Bagnon_Infield.Place = function(frame,point,parent,relPoint,x,y)
	frame:ClearAllPoints()
	frame:SetPoint(point,parent,relPoint,x,y)
	Bagnon_Infield.Reposition(frame,UIParent)
end
Bagnon_Infield.Reposition = function(frame,parent)
	if frame:GetBottom() and frame:GetTop() and frame:GetLeft() and frame:GetRight() then
		local xoff = 0
		local yoff = 0
		local ratio = frame:GetScale()
		if frame:GetBottom() < 0 then
			yoff = 0 - frame:GetBottom()
		elseif frame:GetTop()  > (parent:GetTop() / ratio) then
			yoff = (parent:GetTop() / ratio) - frame:GetTop()
		end
		if frame:GetLeft() < 0 then
			xoff = 0  - frame:GetLeft()
		elseif frame:GetRight()  > (parent:GetRight() / ratio) then
			xoff = (parent:GetRight() / ratio) - frame:GetRight()
		end
		if xoff ~= 0 or yoff ~= 0 then
			local x = frame:GetLeft() + xoff
			local y = frame:GetTop() + yoff
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", x , y)
		end
	end
end
CreateFrame("Frame","Bagnon_InfieldUpdater")
RegisterScaleEvents()