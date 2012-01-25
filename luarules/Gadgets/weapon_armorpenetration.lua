function gadget:GetInfo()
	return {
		name = "Armor Penetration",
		desc = "Reduces damage against hard targets",
		author = "KingRaptor (L.J. Lim)",
		date = "2008-02-10",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

if (not gadgetHandler:IsSyncedCode()) then
	return false
end

--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local DEFAULT_PENETRATION = 10
local DEFAULT_ARMOR = 1

local unitArmor = {}
local weaponAP = {}

for i=1,#UnitDefs do
	unitArmor[i] = tonumber(UnitDefs[i].customParams.armor) or DEFAULT_ARMOR
end

for i=1,#WeaponDefs do
	weaponAP[i] = tonumber(WeaponDefs[i].customParams and WeaponDefs[i].customParams.ap) or DEFAULT_PENETRATION
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID,
                            attackerID, attackerDefID, attackerTeam)
	if not (weaponID and unitDefID and unitArmor[unitDefID] and weaponAP[weaponID]) then
		return damage
	end
	if unitArmor[unitDefID] > weaponAP[weaponID] then
		damage = damage * weaponAP[weaponID]/unitArmor[unitDefID]
		--Spring.Echo(weaponAP[weaponID]/unitArmor[unitDefID])
	end
	return damage
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
