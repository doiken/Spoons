--- === SwitchableHotkey ===
---
--- 
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/SwitchableHotkey.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/SwitchableHotkey.spoon.zip)

local obj = {}

-- Metadata
obj.name = "SwitchableHotkey"
obj.version = "1.0"
obj.author = "doiken"
obj.homepage = "https://github.com/doiken/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- idx()
-- Function
-- Return an idx of hotkey
-- Note: as an example, the idx of "ctrl + g" is "^g"
--
-- Parameters:
--  * mods - List of modifiers
--  * key - String of a key
--
-- Returns:
--  * String
local function idx(mods, key)
  local dummy_fn = function () end
  return hs.hotkey.new(mods, key, dummy_fn, dummy_fn, dummy_fn).idx
end

-- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('SwitchableHotkey')

--- SwitchableHotkey.acceptOnly
--- Variable
--- Table of app name and enabled hot keys.
--- Default is all enabled.
--- Should be set before SwitchableHotkey:init() called.
--- e.g. 
--- spoon.SwitchableHotkey.acceptOnly = {
---   ["Emacs"] = {}, -- accept NONE
---   ["iTerm2"] = {  -- accept partially
---     {{'ctrl'}, ']'},
---   }
---   -- Hotkeys of apps not listed above are fully enabled
--- }
obj.acceptOnly = {}

--- SwitchableHotkey._acceptOnly
--- Variable
--- Internal Table for looking up accepted hotkeys.
obj._acceptOnly = {}

-- Internal variable
obj._binds = {}

local function disableHotkeys(idxs)
  -- To check if keys exist in enable keys list,
  -- I use idx of hotkey as a key for convenience.
  local fn = next(idxs)
    and (function (v)
      if (not idxs[v.idx]) then v['_hk']:disable() end
    end)
    or (function (v)
      v['_hk']:disable()
    end)

  hs.fnutils.each(obj._binds, fn)
end

local function enableHotkeys()
  hs.fnutils.each(obj._binds, function (v)
    v['_hk']:enable()
  end)
end

local function handleGlobalAppEvent(name)
  if obj._acceptOnly[name] then
    obj.disabled = true
    enableHotkeys() -- workaround for partial disable settings
    disableHotkeys(obj._acceptOnly[name])
  elseif obj.disabled then
    enableHotkeys()
    obj.disabled = false
  end
end

local function keyCode(key, modifiers, delay)
  local modifiers = modifiers or {}
  local delay = delay or 1000
  return function()
    hs.eventtap.keyStroke(modifiers, key, delay)
  end
end

--- SwitchableHotkey:bindSpec()
--- Method
--- Binds hotkey
---
--- Parameters:
---  * keyspec
---
--- Returns:
---  * SwitchableHotkey
function obj:bindSpec(keyspec, ...)
  local keyCodes = hs.fnutils.map({...}, function (code)
    return type(code) == "table"
      and keyCode(code[1], code[2])
      or  code
  end)
  local fn = function () hs.fnutils.ieach(keyCodes, function (f) f() end) end
  if #keyspec == 2 then
    table.insert(obj._binds, hs.hotkey.bindSpec(keyspec, fn, nil, fn))
  else
    -- now only support single type binding
    -- local mod2nd, key2nd = (a_and_b())
    -- hs.hotkey.modal(keyspec[1], keyspec[2], ...)
  end
end

obj.applicationListener = hs.application.watcher.new(function (name, event, app)
  if event == hs.application.watcher.activated then
    handleGlobalAppEvent(name)
  end
end)


--- SwitchableHotkey:start()
--- Method
--- Start Listener
---
--- Parameters:
---  * None
---
--- Returns:
---  * SwitchableHotkey
function obj:start()
  handleGlobalAppEvent(hs.window.frontmostWindow():application():name())
  obj.applicationListener:start()
  return obj
end

--- SwitchableHotkey:stop()
--- Method
--- Stop Listener
---
--- Parameters:
---  * None
---
--- Returns:
---  * SwitchableHotkey
function obj:stop()
  disableHotkeys({})
  obj.applicationListener:stop()
  return obj
end

--- SwitchableHotkey:init()
--- Method
--- initializer
---
--- Parameters:
---  * None
---
--- Returns:
---  * SwitchableHotkey
function obj:init()
  obj._acceptOnly = hs.fnutils.map(obj.acceptOnly, function (hotkeys)
    tbl = {}
    for _,hotkey in ipairs(hotkeys) do
      tbl[idx(hotkey[1], hotkey[2])] = true
    end
    return tbl
  end)

  return obj
end

return obj
