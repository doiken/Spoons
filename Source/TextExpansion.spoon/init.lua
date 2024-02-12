--- === TextExpansion ===
---
--- Typing prefix and keyword expands pre-set words or function.
---
--- Based on: https://github.com/Hammerspoon/hammerspoon/issues/1042
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/TextExpansion.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/TextExpansion.spoon.zip)
---
--- HOW TO USE:
---   1. SETUP(see SETUP section)
---   2. type prefix and keyword you set. e.g.
---      - `;greeting`
---      - `;date`
---   3. enjoy :)
---
--- SETUP:
---   install manually
---   ```
---   te = hs.loadSpoon("TextExpansion")
---   te.keywords ={
---      greeting = "hello",
---      greeting_with_macro = "hello @clipboard",
---      date = function() return os.date("%B %d, %Y") end,
---   }
---   te.prefix = ';'
---   te:start()
---   ```
---
---   install using SpoonInstall
---   ```
---   hs.loadSpoon("SpoonInstall")
---   spoon.SpoonInstall.repos.doiken = {
---      url = "https://github.com/doiken/Spoons",
---      desc = "doiken's spoon repository",
---   }
---   spoon.SpoonInstall:andUse("TextExpansion", {
---     repo = 'doiken',
---     loglevel = "warning",
---     config = {
---       keywords = {
---         ...
---       },
---       prefix = ','
---     },
---     start = true
---   })
---   ```
---
--- MACROS:
---   You can use following macros in your return string.
---   - `@clipboard`: replace with string in clipboard
---   - note: If you want to change macro prefix "@", set character into variable `macroStartBy`.
---
---   You can enable macro replacement to type preset charactor, default: "+".
---
---   Without preset character, macro is just removed.
---   e.g.
---   - `;greeting_with_macro`  -> hello 
---   - `;+greeting_with_macro` -> hello NAME_ON_YOUR_CLIPBOARD
---
---   You can change preset character by setting `secondPrefixEnablingMacro`.
---
---   You can enable macro always without typing preset charactor by setting empty string.
---
--- NOTE: TextExpansion expands text via clipboard

local obj = {}
-- Metadata
obj.name = "TextExpansion"
obj.version = "1.1"
obj.author = "Multiple Authors"
obj.homepage = "https://github.com/doiken/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- TextExpansion.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new(debug.getinfo(1,'S').source)

--- TextExpansion.keywords
--- Variable
--- Map of keywords to strings or functions that return a string to be replaced.
obj.keywords = {
  greeting = "hello",
  greeting_with_macro = "hello @clipboard",
  date = function() return os.date("%B %d, %Y") end,
}

--- TextExpansion.prefix
--- Variable
--- Trigger character for TextExpansion to start watching keywords.
obj.prefix = ';'

--- TextExpansion.secondPrefixEnablingMacro
--- Variable
--- Second Prefix to enable replacing macro. If empty, macro always replaced.
obj.secondPrefixEnablingMacro = '+'

--- TextExpansion.macroStartBy
--- Variable
--- Prefix for Macro Keyword.
obj.macroStartBy = '@'

--- TextExpansion.addHelp
--- Variable
--- Add `help` keyword to show the list of available keywords.
obj.addHelp = true

obj._word = "" -- keyword stacked here
obj._isWaitingKeywords = false -- true when prefix input

local keyMap = hs.keycodes.map

obj._macros = {
  clipboard = function ()
    return hs.pasteboard.getContents()
  end,
}

function obj:_replaceMacro(replacement, shouldExpandMacro)
  for macro, f in pairs(obj._macros) do
    if not shouldExpandMacro then f = "" end
    -- try gsub with (...) ahead in order not to remove only macro word
    replacement = replacement:gsub(obj.macroStartBy .. macro, f)
  end
  return replacement
end

function obj:_expand(replacement, word)
  if type(replacement) == "function" then -- expand if function
    local _, o = pcall(replacement)
    if not _ then
      self.logger.ef("~~ expansion for '%s' gave an error of %s", word, o)
      -- could also set o to nil here so that the expansion doesn't occur below, but I think
      -- seeing the error as the replacement will be a little more obvious that a print to the
      -- console which I may or may not have open at the time...
      -- maybe show an alert with hs.alert instead?
    end
    replacement = o
  end
  replacement = obj:_replaceMacro(replacement, self:_shouldExpandMacro(word))

  -- since directly type "delete" seems to conflict with following keyStrokes,
  -- just select word to replace it by following keyStrokes
  for i = 1, #word do
    hs.eventtap.keyStroke({'shift'}, "left", 0)
  end
  
  if replacement == '' then
    hs.eventtap.keyStroke({}, "Delete") -- just remove keyword
  else
    -- instead of keyStrokes, paste replacement to input new line
    hs.pasteboard.writeObjects(replacement)
    hs.eventtap.keyStroke("cmd", "v")
  end
end

function obj:_shouldClear(keyCode)
  -- if one of these "navigational" keys is pressed
  if keyCode == keyMap["return"]
    or keyCode == keyMap["space"]
    or keyCode == keyMap["up"]
    or keyCode == keyMap["down"]
    or keyCode == keyMap["left"]
    or keyCode == keyMap["right"] then
    return true
  end
  return false
end

function obj:_findKeyword(word)
  local _word = self.secondPrefixEnablingMacro
                 and word:gsub("^" .. self.secondPrefixEnablingMacro, "")
                 or word
  return self.keywords[_word]
end

function obj:_shouldExpandMacro(word)
  return self.secondPrefixEnablingMacro == ""
    or self.secondPrefixEnablingMacro == word:sub(1, 1)
end

function obj:_waitKeywords(word, keyCode, char)
  -- if "delete" key is pressed, remove last character
  if keyCode == keyMap["delete"] then
      if #word > 0 then
          word = word:sub(1, -2)
      end
      return word, false -- pass the "delete" keystroke on to the application
  end

  word = word .. char
  self.logger.df("Word after appending:%s", word)

  if self:_shouldClear(keyCode) then
      self._isWaitingKeywords = false
      return word, false
  end

  self.logger.df("Word to check if keyword: %s", word)

  -- finally, if "word" is a hotstring
  local replacement = self:_findKeyword(word)
  if replacement then
    -- disable listener not to capture keystroke
    self._isWaitingKeywords = false
    self:_expand(replacement, word)
    return word, true -- prevent the event not to type last charcter
  end

  return word, false -- pass the event on to the application
end

function obj:_handler(e)
  local keyCode = e:getKeyCode()
  local char = e:getCharacters()

  -- 再入力に備えて常に prefix の判定を優先
  if char == obj.prefix then
    self._isWaitingKeywords = true
    self._word = ''
  elseif obj._isWaitingKeywords then
    local word, isHit = self:_waitKeywords(self._word, keyCode, char)
    self._word = word
    -- when word hit, prevent the event not to type last charcter
    return isHit
  end
  return false
end

obj._eventListener = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function (e) return obj:_handler(e) end)

local function help()
  local keyset={}
  local n=0

  for k,v in pairs(obj.keywords) do
    n=n+1
    keyset[n]=obj.prefix .. k
  end
  return table.concat(keyset, "\n")
end

--- TextExpansion:start()
--- Method
--- Start TextExpansion
---
--- Parameters:
---  * None
---
--- Returns:
---  * TextExpansion
function obj:start()
  if obj.addHelp then
      obj.keywords["help"] = help
  end
  obj._eventListener:start()
  return obj
end

--- TextExpansion:stop()
--- Method
--- Stop TextExpansion
---
--- Parameters:
---  * None
---
--- Returns:
---  * TextExpansion
function obj:stop()
  obj._eventListener:stop()
  return obj
end

return obj
