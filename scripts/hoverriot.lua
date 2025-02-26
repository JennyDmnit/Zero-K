local base = piece 'base'
local flare = piece 'flare'
local ground1 = piece 'ground1'
local barrel = piece 'barrel'
local barrel = piece 'barrel'
local rthrustpoint = piece 'rthrustpoint'
local lthrustpoint = piece 'lthrustpoint'

local wakes = {}
for i = 1, 8 do
	wakes[i] = piece ('wake' .. i)
end
include "constants.lua"

-- Signal definitions
local SIG_HIT = 2
local SIG_AIM = 4

local RESTORE_DELAY = 3000

local SPEEDUP_FACTOR = tonumber (UnitDef.customParams.boost_speed_mult)
local SPEEDUP_RELOAD_FACTOR = tonumber (UnitDef.customParams.boost_reload_speed_mult)
local SPEEDUP_DURATION = tonumber (UnitDef.customParams.boost_duration)
local TURN_SPEED_FACTOR = 0.5 -- So it doesn't rotate right around in a silly looking way.
local MOVE_THRESHOLD = 8

----------------------------------------------------------

local CMD_ONECLICK_WEAPON = Spring.Utilities.CMD.ONECLICK_WEAPON

local function RetreatThread()
	Sleep(600)
	local specialReloadState = Spring.GetUnitRulesParam(unitID,"specialReloadFrame")
	if (not specialReloadState or (specialReloadState <= Spring.GetGameFrame())) then
		Spring.GiveOrderToUnit(unitID, CMD.INSERT, {0, CMD_ONECLICK_WEAPON, CMD.OPT_INTERNAL,}, CMD.OPT_ALT)
	end
end

function RetreatFunction()
	StartThread(RetreatThread)
end

----------------------------------------------------------

local function WobbleUnit()
	while true do
		Move(base, y_axis, 0.8, 1.2)
		Sleep(750)
		Move(base, y_axis, -0.80, 1.2)
		Sleep(750)
	end
end

function HitByWeaponThread(x, z)
	Signal(SIG_HIT)
	SetSignalMask(SIG_HIT)
	Turn(base, z_axis, math.rad(-z), math.rad(105))
	Turn(base, x_axis, math.rad(x), math.rad(105))
	WaitForTurn(base, z_axis)
	WaitForTurn(base, x_axis)
	Turn(base, z_axis, 0, math.rad(30))
	Turn(base, x_axis, 0, math.rad(30))
end

local sfxNum = 0
function script.setSFXoccupy(num)
	sfxNum = num
end

local function MoveScript()
	while Spring.GetUnitIsStunned(unitID) do
		Sleep(2000)
	end
	while true do
		if not Spring.GetUnitIsCloaked(unitID) then
			if (sfxNum == 1 or sfxNum == 2) and select(2, Spring.GetUnitPosition(unitID)) == 0 then
				for i = 1, 8 do
					EmitSfx(wakes[i], 3)
				end
			else
				EmitSfx(ground1, 1024)
			end
		end
		Sleep(150)
	end
end

function SprintThread()
	local _,_,_, sx, sy, sz = Spring.GetUnitPosition(unitID, true)
	for i = 1, SPEEDUP_DURATION do
		EmitSfx(lthrustpoint, 1026)
		EmitSfx(rthrustpoint, 1026)
		Sleep(33)
		GG.ForceUpdateWantedMaxSpeed(unitID, unitDefID, true)
	end
	while (Spring.MoveCtrl.GetTag(unitID) ~= nil) do --is true when unit_refuel_pad_handler.lua is MoveCtrl-ing unit, wait until MoveCtrl disabled before restore speed.
		Sleep(33)
	end
	
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", SPEEDUP_RELOAD_FACTOR)
	Spring.SetUnitRulesParam(unitID, "selfTurnSpeedChange", 1/SPEEDUP_RELOAD_FACTOR)
	GG.SetAllowUnitCoast(unitID, true)
	GG.UpdateUnitAttributes(unitID)
	
	-- Refund reload time if the unit didn't move.
	local _,_,_, ex, ey, ez = Spring.GetUnitPosition(unitID, true)
	if math.abs(ex - sx) < MOVE_THRESHOLD and math.abs(ey - sy) < MOVE_THRESHOLD and math.abs(ez - sz) < MOVE_THRESHOLD then
		Spring.SetUnitRulesParam(unitID, "specialReloadFrame", Spring.GetGameFrame(), {inlos = true})
		return
	end
	
	Sleep(1300) -- Give the unit some time to coast, as attribute speed below zero sets high deccelleration.
	while (Spring.MoveCtrl.GetTag(unitID) ~= nil) do
		Sleep(33)
	end
	-- Disable coast once Mace slows down.
	GG.SetAllowUnitCoast(unitID, false)
	GG.UpdateUnitAttributes(unitID)
	
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", SPEEDUP_RELOAD_FACTOR)
	Spring.SetUnitRulesParam(unitID, "selfTurnSpeedChange", 1/SPEEDUP_RELOAD_FACTOR)
	GG.UpdateUnitAttributes(unitID)
	
	while ((Spring.GetUnitRulesParam(unitID, "specialReloadFrame") > Spring.GetGameFrame()) or (Spring.MoveCtrl.GetTag(unitID) ~= nil)) do
		Sleep(1000)
	end
	
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	Spring.SetUnitRulesParam(unitID, "selfTurnSpeedChange", 1)
	GG.UpdateUnitAttributes(unitID)
end

function Sprint()
	--Turn(rwing, y_axis, math.rad(65), math.rad(300))
	--Turn(lwing, y_axis, math.rad(-65), math.rad(300))

	StartThread(SprintThread)
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", SPEEDUP_FACTOR)
	Spring.SetUnitRulesParam(unitID, "selfTurnSpeedChange", TURN_SPEED_FACTOR)
	-- Spring.MoveCtrl.SetAirMoveTypeData(unitID, "maxAcc", 3)
	GG.UpdateUnitAttributes(unitID)
end

function script.Create()
	Hide(flare)
	Hide(ground1)
	Move(ground1, x_axis, 24.2)
	Move(ground1, y_axis, -8)
	StartThread(GG.Script.SmokeUnit, unitID, {base})
	StartThread(WobbleUnit)
	StartThread(MoveScript)
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	Turn(barrel, y_axis, heading, math.rad(900))
	Turn(barrel, x_axis, -pitch, math.rad(700))
	WaitForTurn(barrel, y_axis)
	WaitForTurn(barrel, x_axis)
	return true
end

function script.QueryWeapon()
	return flare
end

function script.AimFromWeapon()
	return barrel
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	if severity <= 0.25 then
		Explode(base, SFX.NONE)
		return 1
	elseif severity <= 0.50 then
		Explode(base, SFX.NONE)
		return 1
	end
	Explode(base, SFX.SHATTER)
	return 2
end
