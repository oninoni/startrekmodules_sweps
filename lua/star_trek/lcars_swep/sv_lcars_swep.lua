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
--        LCARS SWEP | Server        --
---------------------------------------

hook.Add("Star_Trek.LCARS.OpenInterface", "Star_Trek.LCARS_SWEP.UpdateScreenClicker",  function(interfaceData, ply)
	local ent = interfaceData.Ent

	if ent.IsLCARS then
		if interfaceData.AutoClicker then
			Star_Trek.LCARS:SetScreenClicker(ent:GetOwner(), false)
		end

		interfaceData.Solid = ent.MenuSolid
	end

end)

hook.Add("Star_Trek.LCARS.PostCloseInterface", "Star_Trek.LCARS_SWEP.UpdateScreenClicker", function(ent)
	if ent.IsLCARS then
		Star_Trek.LCARS:SetScreenClicker(ent:GetOwner(), false)
	end
end)

hook.Add("PlayerDroppedWeapon", "Star_Trek.LCARS_SWEP.ResetScreenClicker", function(ply, weapon)
	if weapon.IsLCARS then
		Star_Trek.LCARS:SetScreenClicker(ply, false)
	end
end)

hook.Add("PlayerSwitchWeapon", "Star_Trek.LCARS_SWEP.ResetScreenClicker", function(ply, weapon)
	if weapon.IsLCARS then
		Star_Trek.LCARS:SetScreenClicker(ply, false)
	end
end)

hook.Add("KeyPress", "Star_Trek.LCARS_SWEP.ResetScreenClicker", function(ply, key)
	if key == IN_SCORE then
		local weapon = ply:GetActiveWeapon()
		if weapon.IsLCARS then
			Star_Trek.LCARS:SetScreenClicker(ply, false)
		end
	end
end)

hook.Add("KeyRelease", "Star_Trek.LCARS_SWEP.ResetScreenClicker", function(ply, key)
	if key == IN_SCORE then
		local weapon = ply:GetActiveWeapon()
		if weapon.IsLCARS then
			Star_Trek.LCARS:SetScreenClicker(ply, false)
		end
	end
end)

-- Load a given mode.
--
-- @param String moduleName
-- @param String modeDirectory
-- @param String modeName
-- @return Boolean success
-- @return String error
function Star_Trek.LCARS_SWEP:LoadMode(moduleName, modeDirectory, modeName)
	MODE = {}

	local success = pcall(function()
		include(modeDirectory .. "/" .. modeName .. "/init.lua")
	end)
	if not success then
		return false, "Cannot load LCARS Mode Type \"" .. modeName .. "\" from module " .. moduleName
	end

	local baseMode = MODE.BaseMode
	if isstring(baseMode) then
		timer.Simple(0, function()
			local baseModeData = self.Modes[baseMode]
			if istable(baseModeData) then
				self.Modes[modeName].Base = baseModeData
				setmetatable(self.Modes[modeName], {__index = baseModeData})
			else
				Star_Trek:Message("Failed, to load Base Mode \"" .. baseMode .. "\"")
			end
		end)
	end

	self.Modes[modeName] = MODE
	MODE = nil

	return true
end

hook.Add("Star_Trek.ModuleLoaded", "Star_Trek.LCARS_SWEP.LoadModes", function(moduleName, moduleDirectory)
	Star_Trek.LCARS_SWEP.Modes = Star_Trek.LCARS_SWEP.Modes or {}

	local modeDirectory = moduleDirectory .. "modes/"
	local _, modeDirectories = file.Find(modeDirectory .. "*", "LUA")
	for _, modeName in pairs(modeDirectories) do
		local success, error = Star_Trek.LCARS_SWEP:LoadMode(moduleName, modeDirectory, modeName)
		if success then
			Star_Trek:Message("Loaded LCARS Mode Type \"" .. modeName .. "\" from module " .. moduleName)
		else
			Star_Trek:Message(error)
		end
	end
end)