-- $Id: unitdefs_post.lua 4656 2009-05-23 23:41:24Z carrepairer $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utility
--

local function tobool(val)
  local t = type(val)
  if (t == 'nil') then
    return false
  elseif (t == 'boolean') then
    return val
  elseif (t == 'number') then
    return (val ~= 0)
  elseif (t == 'string') then
    return ((val ~= '0') and (val ~= 'false'))
  end
  return false
end


local function disableunits(unitlist)
  for name, ud in pairs(UnitDefs) do
    if (ud.buildoptions) then
      for _, toremovename in ipairs(unitlist) do
        for index, unitname in pairs(ud.buildoptions) do
          if (unitname == toremovename) then
            table.remove(ud.buildoptions, index)
          end
        end
      end
    end
  end
end

--deep not safe with circular tables! defaults To false
function CopyTable(tableToCopy, deep)
  local copy = {}
  for key, value in pairs(tableToCopy) do
    if (deep and type(value) == "table") then
      copy[key] = CopyTable(value, true)
    else
      copy[key] = value
    end
  end
  return copy
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- ud.customparams IS NEVER NIL

for _, ud in pairs(UnitDefs) do
    if not ud.customparams then
        ud.customparams = {}
    end
 end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- because the way lua access to unitdefs and weapondefs is setup is insane
--
--[[
for _, ud in pairs(UnitDefs) do
    if ud.collisionVolumeOffsets then
		if not ud.customparams then
			ud.customparams = {}
		end
		ud.customparams.collisionVolumeOffsets = ud.collisionVolumeOffsets  -- For ghost site
    end
 end--]]

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Convert all CustomParams to strings
--

for name, ud in pairs(UnitDefs) do
  if (ud.customparams) then
    for tag,v in pairs(ud.customparams) do
      if (type(v) == "table") then
	    local str = "{"
		for i=1,#v do
			str = str .. [["]] .. v[i] .. [[", ]]
		end
		str = str .. "}"
        ud.customparams[tag] = str
      elseif (type(v) ~= "string") then
        ud.customparams[tag] = tostring(v)
      end
    end
  end
end 

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- no smoothmesh

for _, ud in pairs(UnitDefs) do
    if ud.canfly then
		ud.usesmoothmesh = false
	end
 end