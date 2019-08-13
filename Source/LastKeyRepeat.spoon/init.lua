--- === LastKeyRepeat ===
---
--- tmux bind-key -r option-like function
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/LastKeyRepeat.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/LastKeyRepeat.spoon.zip)
--- thanks to this issue
--- https://github.com/Hammerspoon/hammerspoon/issues/1128

local obj = {}

-- Metadata
obj.name = "LastKeyRepeat"
obj.version = "1.0"
obj.author = "doiken"
obj.homepage = "https://github.com/doiken/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"


-- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('LastKeyRepeat')

--- LastKeyRepeat.mapping
--- Variable
--- e.g.
--- spoon.LastKeyRepeat.mapping = {
---   { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'h' } },
---   { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'l' } },
--- }
obj.mapping = {}

--- LastKeyRepeat.mapping
--- Variable
--- when to timeout 2nd stroke
obj.timeout = 0.5

--- LastKeyRepeat.appsDisable
--- Variable
--- Table of apps which you want to temporary disable LastKeyRepeat functions.
--- e.g. 
--- spoon.LastKeyRepeat.appsDisable = { "iTerm2" }
obj.appsDisable = {}

--- LastKeyRepeat._appsDisable
--- Variable
--- Internal Table for looking up disabled apps.
obj._appsDisable = {}

local function foldLeft(tbl, func, val)
  for _, v in pairs(tbl) do
    val = func(val, v)
  end
  return val
end

local function keys(tbl)
  local keys = {}
  for k, _ in pairs(tbl) do
    table.insert(keys, k)
  end
  return keys
end

local function doHash(t)
  hs.fnutils.sortByKeyValues(t.mods)
  return hs.hash.MD5(t.key .. "::" .. hs.inspect(t.mods))
end

local function getInvertedMap(mapping)
  return foldLeft(mapping, function (invMaps, map)
    hs.fnutils.each({"first", "second"}, function (key)
      if map[key].mods then
        hs.fnutils.sortByKeyValues(map[key].mods)
      else
        map[key].mods = {} -- default is {}
      end
    end)

    local firstHash = doHash(map.first)
    local secondHash = doHash(map.second)
    invMaps[firstHash] = invMaps[firstHash] or {}
    invMaps[firstHash][secondHash] = map
    return invMaps
  end, {})
end

local function startTimer()
  obj.timer = hs.timer.doAfter(obj.timeout, function() obj.clear() end)
end

local function stopTimer()
  if obj.timer then
    obj.timer:stop()
  end
end

local function continueTimer()
  stopTimer()
  startTimer()
end

local function find(evt, map)
  local evtHash = doHash({
    key = hs.keycodes.map[evt:getKeyCode()],
    mods = keys(evt:getFlags())
  })
  return map[evtHash]
end

local function strokeFirst(evt)
  if obj.debbuging then obj.logger:e("1st stroke") end
  local target = find(evt, obj._invertedMap)
  if target then
    obj._waitStroke = target
    startTimer()
  else
    obj._waitStroke = nil
  end
end

local function strokeSecond(evt)
  if obj.debbuging then obj.logger:e("2nd stroke") end
  local target = find(evt, obj._waitStroke)
  if target and (not obj._isBurst) then
    obj._isBurst = true
    continueTimer()
    return false
  elseif target then
    local replaceEvent = {
      hs.eventtap.event.newKeyEvent(target.first.mods,  target.first.key, true),
      hs.eventtap.event.newKeyEvent(target.first.mods,  target.first.key, false),
      hs.eventtap.event.newKeyEvent(target.second.mods, target.second.key, true),
      hs.eventtap.event.newKeyEvent(target.second.mods, target.second.key, false),
    }
    continueTimer()
    return true, replaceEvent
  else
    obj._waitStroke = nil
    obj._isBurst = false
    stopTimer()
    return false
  end
end

local function keyHandler(event)
  if obj._waitStroke then
    return strokeSecond(event)
  else
    strokeFirst(event)
    return false
  end
end

obj.applicationListener = hs.application.watcher.new(function (name, event, app)
  if event == hs.application.watcher.activated then
    if obj._appsDisable[name] then
      obj.disabled = true
      obj.stop()
    elseif obj.disabled then
      obj.start()
      obj.disabled = false
    end
  end
end)

obj.keyListener = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, keyHandler)

--- LastKeyRepeat:start()
--- Method
--- Start waching eventtap and application
---
--- Parameters:
---  * None
---
--- Returns:
---  * LastKeyRepeat
function obj:start()
  obj.applicationListener:start()
  obj.keyListener:start()
  return obj
end

--- LastKeyRepeat:stop()
--- Method
--- stop waching eventtap and application
---
--- Parameters:
---  * None
---
--- Returns:
---  * LastKeyRepeat
function obj:stop()
  obj.applicationListener:stop()
  obj.keyListener:stop()
  return obj
end

--- LastKeyRepeat:init()
--- Method
--- initializer
---
--- Parameters:
---  * None
---
--- Returns:
---  * LastKeyRepeat
function obj:init()
  obj._invertedMap = getInvertedMap(obj.mapping)
  obj._appsDisable = {}
  for app in pairs(obj.appsDisable) do
    obj._appsDisable[app] = true
  end
  obj:clear()
  return obj
end

function obj:clear()
  obj._waitStroke = nil
  obj._isBurst = false
  return obj
end

return obj
