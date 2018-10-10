-- This function returns a formatted string with the current battery status. It
-- can be used to populate a text widget in the awesome window manager. Based
-- on the "Gigamo Battery Widget" found in the wiki at awesome.naquadah.org

local naughty = require("naughty")
local beautiful = require("beautiful")

local battery = {}

local function readBatFile(adapter, ...)
  local basepath = "/sys/class/power_supply/"..adapter.."/"
  for i, name in pairs({...}) do
    file = io.open(basepath..name, "r")
    if file then
      local str = file:read()
      file:close()
      return str
    end
  end
end

local function batteryInfo(adapter)
  local fh = io.open("/sys/class/power_supply/"..adapter.."/present", "r")
  if fh == nil then
    return ""
  else
    local cur = readBatFile(adapter, "charge_now", "energy_now")
    local cap = readBatFile(adapter, "charge_full", "energy_full")
    local sta = readBatFile(adapter, "status")
    _battery = math.floor(cur * 100 / cap)

    if sta:match("Charging") then
      _icon = "⚡"
      _percent = "%"
    elseif sta:match("Discharging") then
      _icon = ""
      _percent = "%"
      if tonumber(_battery) < 5 then
        naughty.notify({ title    = "Battery Warning"
               , text     = "Battery low!".."  ".._battery.._percent.."  ".."left!"
               -- , timeout  = 30
               , position = "top_right"
               , fg       = beautiful.fg_focus
               , bg       = beautiful.bg_focus
        })
      end
    else
      -- If we are neither charging nor discharging, assume that we are on A/C
      _battery = "Unknown"
      _icon = ""
      _percent = ""
    end
  end
  return " ".._icon.._battery.._percent.." "
end

function battery.info()
  local _batteries = {"BAT0", "BAT1"}
  for i = 1, #_batteries do
    local _str = batteryInfo(_batteries[i])
    if _str:match("Unknown") then
    else
      return _str
    end
  end
  return ""
end

return battery
