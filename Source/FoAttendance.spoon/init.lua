--- === FoAttendance ===
---
--- Very personal spoon to register my attendance.
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/FoAttendance.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/FoAttendance.spoon.zip)

local obj = {}

-- Metadata
obj.name = "FoAttendance"
obj.version = "1.1"
obj.author = "doiken"
obj.homepage = "https://github.com/doiken/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('FoAttendance')

--- FoAttendance.events
--- Variable
--- Table of events and actions.
--- Events are all provided by caffeinate watcher.
---     ref: https://www.hammerspoon.org/docs/hs.caffeinate.watcher.html
--- Actios are "attend" or "leave".
obj.events = {
   [tostring(hs.caffeinate.watcher.systemDidWake)] = "attend",
   [tostring(hs.caffeinate.watcher.systemWillSleep)] = "leave",
}
obj.autoStopAtAttend = true
obj._isStarted = false

-- MINAGINE_LOGIN, MINAGINE_PW required as environment variable defined in /Users/doi_kenji/.zshrc.d/work.zsh
-- 上から順に env var取得 → CSRF token取得 -> login -> CSRF token取得 -> 勤怠 -> 勤怠情報取得
local template = [[
. /Users/doi_kenji/.zshrc.d/work.zsh
login_token=`curl --silent --dump-header - https://tm.minagine.net/index.html | grep authenticity_token | perl -ne 'print /value="([^"]+==)"/'`
session=`curl --silent --dump-header - 'https://tm.minagine.net/user/login' -X POST --data "authenticity_token=${login_token}&stknck=&user%5Bcntrctr_dmn%5D=fout.jp&user%5Blogin%5D=${MINAGINE_LOGIN}&user%5Bpassword%5D=${MINAGINE_PW}&appID=&apps_dmn=" | grep _hurricane5_production_session | perl -nE 'print /_hurricane5_production_session=(.+?);/'`
attend_token=`curl --silent 'https://tm.minagine.net/' -H "Cookie: login=${MINAGINE_LOGIN}; _hurricane5_production_session=$session; " --compressed | grep -i authenticity | grep 'id=' | perl -pe 's/.+value="(.+)".*/$1/g'`
curl --silent 'https://tm.minagine.net/mypage/regist?scroll_top=192&window_token=' -H "Cookie: login=${MINAGINE_LOGIN}; _hurricane5_production_session=$session; " --data "utf8=%E2%9C%93&authenticity_token=${attend_token}&is_validate_input=0&model_wrk_time_rgst_dvsn_id=${id}&model%5Becm_id%5D=269&wtms%5Brfrnc%5D=&wrktimergst_model%5Bmax_list_size%5D=10" --compressed >/dev/null
curl --silent 'https://tm.minagine.net/mypage/list' -H "Cookie: login=doi_kenji%40fout.jp; _hurricane5_production_session=$session; " --compressed | grep -EA 3 'alt="勤務(開始|終了)"' | perl -nE '$a = /([0-9][0-9\/:]+)/; (length($1) == 10) ? print "$1 " : print "$1\n" if $a' | head -n 2
]]

local function regist(action)
   local ids = {
      -- ACTION = ID
      attend = 7,
      leave  = 8,
   }
   if (not ids[action]) then
      hs.showError("Action '" .. action .. "' is invalid.")
      return
   end
   obj.logger:i(action)
   local define_vars = string.format("id=%d;", ids[action])
   output, status = hs.execute(define_vars .. template)
   if (not status) then
      hs.showError(string.format("Failed to %s. Please check minagine", action))
   end
   if (action == "attend") then
      hs.notify.new({title = obj.name, informativeText = output, withdrawAfter = 0}):send()
      if obj.autoStopAtAttend then
         obj:stop()
      end
   end
end

local function on_fire(event)
   local action = obj.events[tostring(event)]
   if action then
      regist(action)
   end
end


--- FoAttendance:init()
--- Method
--- initializer
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:init()
   obj.watcher = hs.caffeinate.watcher.new(on_fire)
  return obj
end

--- FoAttendance:start()
--- Method
--- initializer
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:start()
  obj.watcher:start()
  hs.notify.show(obj.name, "", "Started")
  obj._isStarted = true
  return obj
end

--- FoAttendance:stop()
--- Method
--- initializer
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:stop()
  obj.watcher:stop()
  hs.notify.show(obj.name, "", "stopped")
  obj._isStarted = false
  return obj
end

--- FoAttendance:toggle()
--- Method
--- Toggle FoAttendance
---
--- Parameters:
---  * None
---
--- Returns:
---  * FoAttendance
function obj:toggle()
  if self._isStarted then
    self:stop()
  else
    self:start()
  end
  return self
end

--- FoAttendance:bindHotkeys(mapping)
--- Method
--- Binds hotkeys
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * start - Start this module
---   * stop - Stop this module
---   * toggle - Toggle this module
function obj:bindHotkeys(mapping)
   local def = {
      start = hs.fnutils.partial(self.start, self),
      stop = hs.fnutils.partial(self.stop, self),
      toggle = hs.fnutils.partial(self.toggle, self),
   }
   hs.spoons.bindHotkeysToSpec(def, mapping)
end

return obj
