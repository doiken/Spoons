--- === FoAttendance ===
---
--- Very personal spoon to register my attendance.
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/FoAttendance.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/FoAttendance.spoon.zip)

local obj = {}

-- Metadata
obj.name = "FoAttendance"
obj.version = "1.0"
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
obj.login = nil
obj.password = nil

-- 上から順に CSRF token取得 -> login -> CSRF token取得 -> 勤怠
local template = [[
login_token=`curl --silent --dump-header - https://tm.minagine.net/index.html | grep authenticity_token | perl -ne 'print /value="([^"]+==)"/'`
session=`curl --silent --dump-header - 'https://tm.minagine.net/user/login' -X POST --data "authenticity_token=${login_token}&stknck=&user%5Bcntrctr_dmn%5D=fout.jp&user%5Blogin%5D=${login}&user%5Bpassword%5D=${password}&appID=&apps_dmn=" | grep _hurricane5_production_session | perl -nE 'print /_hurricane5_production_session=(.+?);/'`
attend_token=`curl --silent 'https://tm.minagine.net/' -H "Cookie: login=${login}; _hurricane5_production_session=$session; " --compressed | grep -i authenticity | grep 'id=' | perl -pe 's/.+value="(.+)".*/$1/g'`
curl --silent 'https://tm.minagine.net/mypage/regist?scroll_top=192&window_token=' -H "Cookie: login=${login}; _hurricane5_production_session=$session; " --data "utf8=%E2%9C%93&authenticity_token=${attend_token}&is_validate_input=0&model_wrk_time_rgst_dvsn_id=${id}&model%5Becm_id%5D=269&wtms%5Brfrnc%5D=&wrktimergst_model%5Bmax_list_size%5D=10" --compressed 
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
   local define_vars = string.format("id=%d; login=%s; password=%s;", ids[action], obj.login, obj.password)
   output, status = hs.execute(define_vars .. template)
   if (not status) then
      hs.showError(string.format("Failed to %s. Please check minagine", action))
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
  if (not obj.login) then
    hs.showError("Please set FoAttenance.login")
    return
  end
  if (not obj.password) then
    return
    hs.showError("Please set FoAttenance.password")
  end
  obj.watcher:start()
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
  return obj
end


return obj
