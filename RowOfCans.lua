
local cauldronLoc = {}
local cauldron = {
	[58085] = 1, -- Flask of Steelskin
	[58086] = 1, -- Flask of Draconic Mind
	[58087] = 1, -- Flask of the Winds
	[58088] = 1, -- Flask of Titanic Strength
	[58142] = 8, -- Deathblood Venom
}

local feastLoc = {}
local feast = {
	[53064] = 2, -- Highland Guppy
	[53068] = 2, -- Lavascale Catfish
	[53070] = 2, -- Fathom Eel
}

local function WithdrawCauldron(self)
	local missing
	for item in pairs(cauldron) do
		if(not cauldronLoc[item]) then
			missing = true
			UIErrorsFrame:AddMessage('Missing ' .. GetItemInfo(item))
		end
	end

	if(missing) then return end

	self:Disable()
	for item, info in pairs(cauldronLoc) do
		SplitGuildBankItem(info.tab, info.slot, cauldron[item])
		LibStub('LibBagUtils-1.0'):PutItem('BAGS', false, cauldron[item])
	end
	self:Enable()
end

local function WithdrawFeast(self)
	local missing
	for item in pairs(feast) do
		if(not feastLoc[item]) then
			missing = true
			UIErrorsFrame:AddMessage('Missing ' .. GetItemInfo(item))
		end
	end

	if(missing) then return end

	self:Disable()
	for item, info in pairs(feastLoc) do
		SplitGuildBankItem(info.tab, info.slot, feast[item])
		LibStub('LibBagUtils-1.0'):PutItem('BAGS')
	end
	self:Enable()
end

local function Check()
	table.wipe(cauldronLoc)
	table.wipe(feastLoc)

	for tab = 1, GetNumGuildBankTabs() do
		for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			local link = GetGuildBankItemLink(tab, slot)
			if(link) then
				local _, id = string.match(link, '(%w+):(%d+)')
				id = tonumber(id)

				if(cauldron[id]) then
					cauldronLoc[id] = {
						tab = tab,
						slot = slot
					}
				elseif(feast[id]) then
					feastLoc[id] = {
						tab = tab,
						slot = slot
					}
				end
			end
		end
	end
end

local addon = CreateFrame('Frame')
addon:RegisterEvent('ADDON_LOADED')
addon:SetScript('OnEvent', function(self, event, name)
	if(name ~= 'Blizzard_GuildBankUI') then return end

	local Cauldron = CreateFrame('Button', nil, GuildBankFrame, 'UIPanelButtonTemplate')
	Cauldron:SetSize(85, 22)
	Cauldron:RegisterForClicks('AnyUp')
	Cauldron:SetScript('OnClick', WithdrawCauldron)
	Cauldron:SetPoint('BOTTOMLEFT', 24, 36)
	Cauldron:SetText('Cauldron')

	local Feast = CreateFrame('Button', nil, GuildBankFrame, 'UIPanelButtonTemplate')
	Feast:SetSize(85, 22)
	Feast:RegisterForClicks('AnyUp')
	Feast:SetScript('OnClick', WithdrawFeast)
	Feast:SetPoint('LEFT', Cauldron, 'RIGHT', 3, 0)
	Feast:SetText('Feast')


	self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED')
	self:SetScript('OnEvent', Check)

	GuildBankFrame:HookScript('OnShow', Check)
end)
