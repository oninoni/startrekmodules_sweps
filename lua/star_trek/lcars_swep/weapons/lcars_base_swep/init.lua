---------------------------------------
---------------------------------------
--        Star Trek Utilities        --
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
--      LCARS Base SWEP | Server     --
---------------------------------------

function SWEP:InitializeCustom()
	self.NextScreenEnable = CurTime()

	self.ActiveMode = false
	self.ModeCache = {}
end

function SWEP:Deploy()
	if self.DefaultMode then
		timer.Simple(0, function()
			self:ActivateMode(self.DefaultMode)
		end)
	end
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	-- Ignore when SPEED Active (Interact Menu)
	if owner:KeyDown(IN_SPEED) then
		return
	end

	if self.NextScreenEnable < CurTime() then
		if owner:KeyDown(IN_WALK) then
			-- Enable / Disable mode Selection when pressing ALT.
			if self.ActiveMode then
				self:DeactivateMode(function()
					Star_Trek.LCARS:OpenInterface(self:GetOwner(), self, "mode_selection", self.Modes)
				end)
			else
				local interfaceData = Star_Trek.LCARS.ActiveInterfaces[self]
				if not istable(interfaceData) then
					Star_Trek.LCARS:OpenInterface(self:GetOwner(), self, "mode_selection", self.Modes)
				end
			end
		else
			-- Enable Screen Clicker.
			Star_Trek.LCARS_SWEP:ToggleScreenClicker()
		end
	end

	self.NextScreenEnable = CurTime() + 0.1
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if not self.ActiveMode then return end
	if not isfunction(self.ActiveMode.PrimaryAttack) then return end

	self.ActiveMode:PrimaryAttack(self)
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	if not self.ActiveMode then return end
	if not isfunction(self.ActiveMode.SecondaryAttack) then return end

	self.ActiveMode:SecondaryAttack(self)
end

function SWEP:ActivateMode(modeName)
	self:DeactivateMode(function()
		local mode = {}
		if istable(self.ModeCache[modeName]) then
			mode = self.ModeCache[modeName]
		else
			local modeFunctions = Star_Trek.LCARS_SWEP.Modes[modeName]
			if istable(modeFunctions) then
				setmetatable(mode, {__index = modeFunctions})
				self.ModeCache[modeName] = mode
			else
				return
			end
		end

		mode:Activate(self) -- TODO Process the Return Values

		self.ActiveMode = mode
	end)
end

function SWEP:DeactivateMode(callback)
	if istable(self.ActiveMode) then
		self.ActiveMode:Deactivate(self, callback) -- TODO Process the Return Values
		self.ActiveMode = false

		return
	end

	callback()
end