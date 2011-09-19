local M,L = unpack(DerpyData)
local DB -- After Player Login

local function menu(self)
	if(self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, 'cursor')
	end
end

local colors = oUF.colors	
local names = L['derpyraid']
local oUF = oUF

local check_bar = function(bar)
	if bar.highlight ~= true then 
		bar:SetAlpha(bar.curalpha)
	else 
		bar:SetAlpha(.111) 
	end
end

local _health = {
	"|cffEEEEEE|||||||||||||||||||||r", -- 0%
	"|||cffEEEEEE|||||||||||||||||||r", -- 10%
	"|||||cffEEEEEE|||||||||||||||||r", -- 20%
	"|||||||cffEEEEEE|||||||||||||||r", -- 30%
	"|||||||||cffEEEEEE|||||||||||||r", -- 40%
	"|||||||||||cffEEEEEE|||||||||||r", -- 50%
	"|||||||||||||cffEEEEEE|||||||||r", -- 60%
	"|||||||||||||||cffEEEEEE|||||||r", -- 70%
	"|||||||||||||||||cffEEEEEE|||||r", -- 80%
	"|||||||||||||||||||cffEEEEEE|||r", -- 90%
	"||||||||||||||||||||",				-- 100%
	"||||||||||||||||||||",				-- == 100%
}

local updateHealth
do
	local floor = math.floor
	local UnitIsDead = UnitIsDead
	local UnitIsGhost = UnitIsGhost
	local UnitClass = UnitClass
	local UnitIsConnected = UnitIsConnected
	local unpack = unpack	
	updateHealth =  function(bar, unit, min, max)
		
		local _, englass = UnitClass(unit)
		if colors.class[englass] then
			local r,g,b = unpack(colors.class[englass])
			bar.info:SetTextColor(r,g,b)
		end
		
		if (UnitIsDead(unit) or UnitIsGhost(unit)) then
			bar.offdeadtag:SetText("DEAD")
			bar.offdeadtag:SetTextColor(.7,.07,.07)
			bar.perc:SetText("")
			bar.value:SetText("|cffFFFFFF|||||||||||||||||||||r")
			bar.curalpha = .6
			check_bar(bar)
			return
		elseif not UnitIsConnected(unit) then
			bar.offdeadtag:SetText("OFF")
			bar.offdeadtag:SetTextColor(.7,.7,.7)
			bar.perc:SetText("")
			bar.value:SetText("|cffFFFFFF|||||||||||||||||||||r")
			bar.curalpha = .1
			check_bar(bar)
			return
		end
		
		d = floor(min/max*100)
		bar.curalpha = 1
		bar.perc:SetText(d.." %")
		bar.offdeadtag:SetText("")
		bar.value:SetText(bar._health[floor((d+1)/10)+1])
		
		if d > 75 then
			bar.value:SetTextColor(.07,.93,.07)
			bar.perc:SetTextColor(.07,.93,.07)
		elseif d>35 and d<=75 then 
			bar.value:SetTextColor(1,1,0)
			bar.perc:SetTextColor(1,1,0)
		elseif d>0 and d<=35 then
			bar.value:SetTextColor(.93,.07,.07)
			bar.perc:SetTextColor(.93,.07,.07)
		end
		
		check_bar(bar)
	end
end

local UpdateThreat = function(self, event, unit)
	if (self.unit ~= unit) then	return end
	local threat = UnitThreatSituation(self.unit)
	self.grad.a = false
	if (threat == 3) then
		self.grad:Show()
		self.grad:SetGradientAlpha("HORIZONTAL",1,0,0,.5,1,0,0,0)
	elseif (threat == 2) then
		self.grad:Show()
		self.grad:SetGradientAlpha("HORIZONTAL",.1,.5,0,.5,1,.5,0,0)
	elseif (threat == 1) then
		self.grad:Show()
		self.grad:SetGradientAlpha("HORIZONTAL",1,1,0,.5,1,1,0,0)
	else
		self.grad:Hide()
		self.grad:SetGradientAlpha("HORIZONTAL",.43,.43,.57,.5,.43,.43,.57,0)
		self.grad.a = true
	end 
end

local enter___ = function(self) UnitFrame_OnEnter(self) 
	self.grad:Show()
	self.tri:SetTextColor (.63,.63,.77)
	self.Health:SetAlpha(.111)
	self.Health.perc:SetAlpha(1)
	self.Health.highlight = true 
end

local leave__ = function(self)
	UnitFrame_OnLeave(self) 
	if self.grad.a == true then self.grad:Hide() end
	self.tri:SetTextColor (1,1,1)
	self.Health:SetAlpha(self.Health.curalpha)
	self.Health.perc:SetAlpha(0)
	self.Health.highlight = false
end

local function CreateRaid(self, unit)
	self.menu = menu
	self:RegisterForClicks('AnyDown')
	self:SetScale(1)
	
	self.Health = CreateFrame ("StatusBar",nil,self)
	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetShadowOffset(1, -1)
	self.Health.value:SetFont(M["media"].font_s, 14)
	self.Health.value:SetPoint("LEFT",self,11.8,1.3)
	self.Health.value:SetJustifyH("LEFT")
	self.Health.curalpha = 1
	self.Health.highlight = false
	self.Health._health = _health
	
	self.Health.info = self:CreateFontString(nil, "OVERLAY")
	self.Health.info:SetFont(M["media"].font, 14)
	self.Health.info:SetJustifyH("LEFT")
	self.Health.info:SetShadowOffset(1, -1)
	self:Tag(self.Health.info," [name] |cffFFFFFF[leader]|r")
	
	self.Health.info:SetJustifyH("LEFT")
	
	self.Health.perc = self:CreateFontString(nil, "HIGHLIGHT")
	self.Health.perc:SetShadowOffset(1, -1)
	self.Health.perc:SetFont(M["media"].font, 13)
	self.Health.perc:SetPoint("CENTER",self.Health.value,-.3,-.3)
	self.Health.perc:SetJustifyH("CENTER")
	self.Health.perc:SetAlpha(0)
	
	table.insert(self.__elements, UpdateThreat)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UpdateThreat)
	
	self.Health.info:SetPoint("LEFT",self.Health.value,"RIGHT",-1.8,-.3)
	
	self.Health.offdeadtag = self:CreateFontString(nil, "HIGHLIGHT")
	self.Health.offdeadtag:SetShadowOffset(1, -1)
	self.Health.offdeadtag:SetFont(M["media"].font, 13)
	self.Health.offdeadtag:SetPoint("CENTER",self.Health.value,-.3,-.3)
	self.Health.offdeadtag:SetJustifyH("CENTER")
	
	self.grad = self:CreateTexture(nil,"BORDER")
	self.grad:SetTexture(1,1,1,1)
	self.grad:SetGradientAlpha("HORIZONTAL",.43,.43,.57,.5,.43,.43,.57,0)
	self.grad:SetAllPoints(self)
	self.grad:Hide()
	self.grad.a = false
	
	self.tri = self:CreateFontString(nil,"ARTWORK")
	self.tri:SetFont(M["media"].font_s, 17)
	self.tri:SetShadowOffset(1, -1)
	self.tri:SetText(">")
	self.tri:SetPoint("LEFT",.6,-.3)
	
	self.ReadyCheck = self:CreateTexture(nil,"OVERLAY")
	self.ReadyCheck:SetSize(20,20)
	self.ReadyCheck:SetPoint("CENTER",self,"LEFT",1,0)
	
	self:SetScript('OnEnter',enter___)
	self:SetScript('OnLeave',leave__)
	
	local ri  = self:CreateTexture(nil, "OVERLAY")
	ri:SetHeight(18)
	ri:SetWidth(18)
	ri:SetPoint("RIGHT",self,-12,0)
	ri:SetTexture(M["media"].ricon)
	self.RaidIcon = ri
	
	self.Health.PostUpdate = updateHealth
	
	-- не нужны
	self.Health.SetValue = M.null
	self.Health.SetMinMaxValues = M.null
	
	return self
end

oUF:RegisterStyle('DerpyRaid', CreateRaid)	
	
local mainframe = CreateFrame("Frame",nil,UIParent)

	mainframe:SetHeight(15)
	mainframe:SetPoint("TOPLEFT",5,-27)
	mainframe:EnableMouse(true)
	
	mainframe.tri = mainframe:CreateFontString(nil,"OVERLAY")
	mainframe.tri:SetFont(M["media"].font_s,18)
	mainframe.tri:SetShadowOffset(1, -.8)
	mainframe.tri:SetText(">")
	mainframe.tri:SetPoint("TOPLEFT",.4,2)
	
	mainframe.name = mainframe:CreateFontString(nil,"OVERLAY")
	mainframe.name:SetFont(M["media"].font,15)
	mainframe.name:SetShadowOffset(1, -1)
	mainframe.name:SetJustifyH("LEFT")
	mainframe.name:SetPoint("TOPLEFT",10.3,1.3)
	mainframe:SetWidth(144)
	
	mainframe.grad = mainframe:CreateTexture(nil,"BORDER")
	mainframe.grad:SetTexture(1,1,1,1)
	mainframe.grad:SetGradientAlpha("HORIZONTAL",.43,.43,.57,1,.43,.43,.57,0)
	mainframe.grad:SetAllPoints(mainframe)
	mainframe.grad:Hide()
	
local raid = {}
local isparty
local on_pos = {'TOPLEFT',UIParent,8,-44}
local off_pos = {'TOPLEFT',UIParent,"TOPRIGHT",30,-2}

if IsAddOnLoaded('oUF_Wiskas') and WiskasStuff.enableparty == true and WiskasStuff.partyraid == true then
	isparty = true
end

local check_group = M.null
local current_pos

if isparty == true then
	check_group = function(mark)
		if mark == true then
			if current_pos == true then return end
			current_pos = true
			oUF_AlleyParty:SetPoint("TOPLEFT", UIParent, "RIGHT", 2, 121)
		else
			if current_pos == false then return end
			current_pos = false
			oUF_AlleyParty:SetPoint("TOPLEFT", UIParent, "LEFT", 2, 121)
		end
	end
end

M.addenter(function()
	oUF:SetActiveStyle('DerpyRaid')
	
	if not _G.DerpyRaidVars then 
		-- define table here
		_G.DerpyRaidVars = {
			show = 1,
			clickstype = "AnyDown",
			customgroup = {
				[1] = true,
				[2] = true,
				[3] = true,
				[4] = true,
				[5] = true,
				[6] = false,
				[7] = false,
				[8] = false,
			}
		}
	end
	DB = DerpyRaidVars
	
	if DB.show ~= 10 then
		mainframe.name:SetText(names.rgroup..DB.show)
		mainframe.name:SetDrawLayer("OVERLAY")
		mainframe.tri:SetDrawLayer("OVERLAY")
	else
		mainframe.name:SetText(names.rgroup.."X")
		mainframe.name:SetDrawLayer("HIGHLIGHT")
		mainframe.tri:SetDrawLayer("HIGHLIGHT")
	end

	for i = 1, 8 do
		raid[i] = oUF:SpawnHeader("oUF_HissyRaid"..i, nil, "raid", 'showRaid', true, "groupFilter", tostring(i), "yOffSet", -2,'oUF-initialConfigFunction', 
				([[
				self:SetWidth(160)
				self:SetHeight(14)
				self:SetAttribute('*type2', 'menu')
				]]))
		raid[i]:SetFrameStrata('BACKGROUND')
		if i == DB.show then
			raid[i]:SetPoint(unpack(on_pos))
		end
	end

	local show_allfive = function()
		raid[1]:SetPoint(unpack(on_pos))
		mainframe.name:SetText(names.rgroup.."1-8")
		mainframe.name:SetDrawLayer("OVERLAY")
		mainframe.tri:SetDrawLayer("OVERLAY")
		for i = 2,8 do
			raid[i]:SetPoint("TOPLEFT",raid[i-1],"BOTTOMLEFT",0,-2)
		end
	end

	local reset_all = function()
		for i = 1,8 do
			raid[i]:SetPoint(unpack(off_pos))
		end
	end

	mainframe:SetScript("OnMouseDown",function(self,button)
		if InCombatLockdown() then print(names.rcombat) return end
		if button == "RightButton" or button == "LeftButton" then
			local int = DB.show
			reset_all()
			if button == "RightButton" then
				int = int - 1
			else 
				int = int + 1
			end
			if int == 11 then int = 1 end
			if int == 0 then int = 10 end
			DB.show = int
			if int == 9 then
				show_allfive()
				check_group(true)
				return
			end
			check_group(false)
			if int == 10 then
				self.name:SetText(names.rgroup.."X")
				self.name:SetDrawLayer("HIGHLIGHT")
				self.tri:SetDrawLayer("HIGHLIGHT")
				return
			end
			raid[int]:SetPoint(unpack(on_pos))
			self.name:SetText(names.rgroup..int)
			self.name:SetDrawLayer("OVERLAY")
			self.tri:SetDrawLayer("OVERLAY")
		end
	end)

	local numraid = 0

	local mainframeupd = function(self,event)
		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			return
		end
		numraid = GetNumRaidMembers()
		if numraid == 0 then
			mainframe:Hide()
		else
			mainframe:Show()
		end
		if event == "PLAYER_REGEN_ENABLED" then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end

	mainframe:SetScript("OnShow",function()
		if DB.show == 9 then
			check_group(true)		
		end
	end)

	mainframe:SetScript("OnHide",function()
		check_group(false)
	end)

	local numget = CreateFrame ("Frame")
		numget:RegisterEvent("PLAYER_LOGIN")
		numget:RegisterEvent("RAID_ROSTER_UPDATE")
		numget:RegisterEvent("PARTY_LEADER_CHANGED")
		numget:RegisterEvent("PARTY_MEMBERS_CHANGED")
		numget:SetScript("OnEvent",mainframeupd)

	local showraidtooltip = function(self)
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPLEFT",self,"BOTTOMRIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(names.rmemcount,numraid,1,1,1,1,1,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(names.rinst)
		GameTooltip:Show()
	end

	mainframe:SetScript('OnEnter', function(self) 
		self.grad:Show() 
		self.tri:SetTextColor(.63,.63,.77) 
		showraidtooltip(self) 
	end)

	mainframe:SetScript('OnLeave', function(self) 
		self.grad:Hide()
		self.tri:SetTextColor(1,1,1)
		GameTooltip:Hide() 
	end)

	if DB.show == 9 then
		show_allfive()
		check_group(true)	
	else
		check_group(false)
	end
	mainframeupd()
end)

M.raidframe = mainframe
M.kill(CompactRaidFrameManager)

M.addafter(function()
	UnitPopupMenus["RAID_PLAYER"] = {
		"MUTE",
		"UNMUTE", 
		"RAID_SILENCE", 
		"RAID_UNSILENCE",
		"BATTLEGROUND_SILENCE",
		"BATTLEGROUND_UNSILENCE",
		"WHISPER", 
		"INSPECT",
		"ACHIEVEMENTS",
		"TRADE", 
		"FOLLOW", 
		"DUEL",
		"RAID_TARGET_ICON", 
		"SELECT_ROLE",
		"RAID_LEADER", 
		"RAID_PROMOTE",
		"RAID_DEMOTE",
		"LOOT_PROMOTE", 
		"RAID_REMOVE", 
		"PVP_REPORT_AFK",
		"RAF_SUMMON",
		"RAF_GRANT_LEVEL",
		"CANCEL"}
	UnitPopupMenus["RAID"] = {
		"MUTE", 
		"UNMUTE", 
		"RAID_SILENCE",
		"RAID_UNSILENCE",
		"BATTLEGROUND_SILENCE",
		"BATTLEGROUND_UNSILENCE", 
		"RAID_LEADER",
		"RAID_PROMOTE",
		"RAID_MAINTANK",
		"RAID_MAINASSIST",
		"LOOT_PROMOTE", 
		"RAID_DEMOTE",
		"RAID_REMOVE",
		"PVP_REPORT_AFK",
		"MOVE_PLAYER_FRAME", 
		"MOVE_TARGET_FRAME",
		"CANCEL"}
end)
