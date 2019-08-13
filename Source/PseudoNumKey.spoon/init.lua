--- === PseudoNumKey ===
---
--- Pseudo numeric keypad with FN key for Mac
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/PseudoNumKey.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/PseudoNumKey.spoon.zip)

local obj = {}

-- Metadata
obj.name = "PseudoNumKey"
obj.version = "1.0"
obj.author = "doiken"
obj.homepage = "https://github.com/doiken/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- PseudoNumKey.hotkeys
--- Variable
--- Default key map
obj.hotkeys = {
  ["7"] = "7", ["8"] = "8", ["9"] = "9",
  ["u"] = "4", ["i"] = "5", ["o"] = "6",
  ["j"] = "1", ["k"] = "2", ["l"] = "3",
  ["m"] = "0", 
}

-- Replace key stroke
local function handler(e)
  local originalKey = hs.keycodes.map[e:getKeyCode()]
  local fn = e:getFlags()['fn']
  replaceKey = obj.hotkeys[originalKey]

  if (fn and replaceKey) then
    hs.eventtap.keyStroke({}, replaceKey, 1000)
    return ''
  end
end

obj.eventListener = hs.eventtap.new({hs.eventtap.event.types.keyDown}, handler)

--- PseudoNumKey:start()
--- Method
--- Start Event Listener
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:start()
  obj.eventListener:start()
end

--- PseudoNumKey:stop()
--- Method
--- Stop Event Listener
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:stop()
  obj.eventListener:stop()
end

return obj
