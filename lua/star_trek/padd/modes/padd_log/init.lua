---------------------------------------
---------------------------------------
--         Star Trek Modules         --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2021 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--         Logs Mode | Server        --
---------------------------------------

if not istable(MODE) then Star_Trek:LoadAllModules() return end

MODE.BaseMode = "base"

MODE.Name = "Logs"
MODE.MenuColor = Star_Trek.LCARS.ColorBlue

function MODE:Activate(ply, ent)
	Star_Trek.LCARS:OpenInterface(ply, ent, "padd_log", self.LogData)
end

function MODE:Deactivate(ent)
	local interface = ent.Interface
	if istable(interface) then
		self.LogData = interface:GetSessionData()
	end
end

function MODE:PrimaryAttack(ent)
	local interface = ent.Interface
	if not istable(interface) then
		ent:EmitSound("star_trek.lcars_error")
		return
	end

	local logWindow = interface.Windows[1]
	if not istable(logWindow) then
		ent:EmitSound("star_trek.lcars_error")
		return
	end

	local ply = ent:GetOwner()
	if not IsValid(ply) then
		ent:EmitSound("star_trek.lcars_error")
		return
	end

	local eyeTrace = ply:GetEyeTrace()
	local targetEnt = eyeTrace.Entity
	if not IsValid(targetEnt) then
		local closestDistance = math.huge
		local closest

		local hitPos = eyeTrace.HitPos
		for _, foundEnt in pairs(ents.FindInSphere(hitPos, 50)) do
			local distance = foundEnt:GetPos():Distance(hitPos)
			if distance < closestDistance then
				closestDistance = distance
				closest = foundEnt
			end
		end

		if not IsValid(closest) then
			ent:EmitSound("star_trek.lcars_error")
			return
		end

		targetEnt = closest
	end

	local targetInterface = targetEnt.Interface
	if not istable(targetInterface) then
		ent:EmitSound("star_trek.lcars_error")
		return
	end

	if targetInterface.Class == "wallpanel" then
		local sessionData = logWindow.SessionData

		local wallPanelLogWindow = targetInterface.Windows[2]
		if not istable(wallPanelLogWindow) then
			ent:EmitSound("star_trek.lcars_error")
			return
		end

		if not istable(sessionData) or ply:KeyDown(IN_SPEED) then
			if interface.Locked then
				ent:EmitSound("star_trek.lcars_error")
				return
			end

			local wallPanelSessionData = wallPanelLogWindow.SessionData
			if not istable(wallPanelSessionData) then
				ent:EmitSound("star_trek.lcars_error")
				return
			end

			logWindow:SetSessionData(wallPanelSessionData)
			logWindow:Update()

			ent:EmitSound("star_trek.lcars_beep")
			return
		else
			wallPanelLogWindow:SetSessionData(sessionData)
			wallPanelLogWindow:Update()

			ent:EmitSound("star_trek.lcars_beep")
			return
		end
	end

	if interface.Locked then
		ent:EmitSound("star_trek.lcars_error")
		return
	end

	local sessionData
	if targetInterface.Class == "eng_logs" then
		local engLogsLogWindow = targetInterface.Windows[4]
		if not istable(engLogsLogWindow) then
			ent:EmitSound("star_trek.lcars_error")
			return
		end

		sessionData = engLogsLogWindow.SessionData
	else
		sessionData = Star_Trek.Logs:GetSession(targetEnt)
	end

	if not sessionData then return end

	logWindow:SetSessionData(sessionData)
	logWindow:Update()

	ent:EmitSound("star_trek.lcars_beep")
end

function MODE:SecondaryAttack(ent)
	local interface = ent.Interface
	if not istable(interface) then
		ent:EmitSound("star_trek.lcars_error")
		return
	end

	local logWindow = interface.Windows[1]
	if not istable(logWindow) then
		ent:EmitSound("star_trek.lcars_error")
		return
	end

	local locked = not interface.Locked

	if locked then
		logWindow.Title = "Logs (LOCKED)"
	else
		logWindow.Title = "Logs"
	end

	interface.Locked = locked
	logWindow:Update()

	ent:EmitSound("star_trek.lcars_beep")
end

function MODE:Think(ent)
end