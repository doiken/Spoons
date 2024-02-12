--- === Snippet ===
---
--- Manage various kinds of snippets.
---
--- ![demo](snippet.gif)
---
--- You can register snippets on Snippet.snippets.
--- The format is bellow:
--- ```
--- {
---     text = "TEXT",
---     action = "ACTION_NAME",
---     contents = "CONTENTS",
--- }
--- ```
--- - text: index to choose snippet.
--- - action: "text" or "shell" or "hs" or "nest".
--- - contents: depends on ACTION_NAME.
---   - text: directly used.
---   - shell: evaluated as shell script.
---   - hs: called as hammerspoon function.
---   - nest: table of nested snippets.
---
--- e.g.
--- ```
--- spoon.Snippet.snippets = {
---   {
---     text = "text: simple text",
---     action = "text",
---     contents = "simple text\n",
---   },
---   {
---     text = "shell: echo Hello",
---     action = "shell",
---     contents = "echo Hello",
---   },
---   {
---     text = "hs: hs.hash.MD5('string')",
---     action = "hs",
---     contents = function () return hs.hash.MD5("notify", "", "") end,
---   },
---   {
---     text = "nest",
---     action = "nest",
---     contents = {
---       {
---         text = "text: nested text",
---         action = "text",
---         contents = "nested text",
---       },
---     },
---   },
--- }
--- ```
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/Snippet.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/Snippet.spoon.zip)

local obj = {}

-- Metadata
obj.name = "Snippet"
obj.version = "1.1"
obj.author = "doiken"
obj.homepage = "https://github.com/doiken/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('Snippet')
-- Internal variable
obj._chooser = nil
-- Internal variable - Table of "hs" action function
obj._contentsMap = {}
-- Internal variable - Cache for focused window to work around the current window losing focus after the chooser comes up
obj._prevFocusedWindow = nil

--- Snippet.snippets
--- Variable
--- See description on top to see format and example.
obj.snippets = {}

--- Snippet.lang_in_shell
--- Variable
--- Specify if you want to use it to solve multibyte character problems, etc. 
obj.lang_in_shell = nil

local actions = {
   none = function() end,
   text = function(v) return v.contents end,
   shell = function(v)
      local lang = obj.lang_in_shell and ("env LANG='%s' "):format(obj.lang_in_shell) or ""
      return hs.execute(lang .. v.contents)
   end,
   hs = function(v)
      local res = obj._contentsMap[v.contents]()
      if type(res) == "string" then
         return res
      else
         return
      end
   end,
   nest = function(v) obj._contentsMap[v.contents]:show() end,
}

local function processSelectedItem(value)
   if obj._prevFocusedWindow ~= nil then
      obj._prevFocusedWindow:focus()
   end
   if value and type(value) == "table" then
      if value.action and actions[value.action] then
        local contents = actions[value.action](value)
        if contents then
          hs.pasteboard.setContents(contents)
          hs.eventtap.keyStroke({"cmd"}, "v")
        end
      else
        hs.notify.show("Snippet", "Unexpected action " .. value.action .. "registered", "")
      end
   end
end

local prefix_no = 1
local function prepareSnippets(snippets)
   local prepareContentsByAction = {
      hs = function (v) return v.contents end,
      nest = function (v)
         local chooser = hs.chooser.new(hs.fnutils.partial(processSelectedItem))
         chooser:choices(prepareSnippets(v.contents))
         return chooser
      end,
   }
   local menuData = {}
   for _,v in ipairs(snippets) do
      local f = prepareContentsByAction[v.action]
      -- action, which needs prepare, stores processed contents into _contentsMap,
      -- and overwrite original contents by hash to indicate key of _contentsMap.
      if f then
         local hash = hs.hash.MD5(prefix_no .. v.text)
         local contents = f(v)
         obj._contentsMap[hash] = contents
         v.contents = hash
         prefix_no = prefix_no + 1
      end
      table.insert(menuData, v)
   end
   return menuData
end

local function populateChooser()
   local menuData = prepareSnippets(obj.snippets)
   if #menuData == 0 then
      table.insert(menuData, { text="",
                               subText="《Snippet is empty》",
                               action = 'none',
                               image = hs.image.imageFromName('NSCaution')})
   end
   obj.logger.df("Returning menuData = %s", hs.inspect(menuData))
   return menuData
end

--- Snippet:init()
--- Method
--- initializer
---
--- Parameters:
---  * None
---
--- Returns:
---  * Snippet
function obj:init()
  self._chooser = hs.chooser.new(hs.fnutils.partial(processSelectedItem))
  self._chooser:choices(populateChooser())
  return obj
end

--- Snippet:showSnippet()
--- Method
--- Display the snippet in a chooser
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:showSnippet()
   if self._chooser ~= nil then
      self._prevFocusedWindow = hs.window.focusedWindow()
      self._chooser:show()
   else
      hs.notify.show("Snippet not properly initialized", "Did you call Snippet:init()?", "")
   end
end

--- Snippet:toggleSnippet()
--- Method
--- Show/hide the snippet list, depending on its current state
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:toggleSnippet()
   if self._chooser:isVisible() then
      self._chooser:hide()
   else
      self:showSnippet()
   end
end

--- Snippet:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for Snippet
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * show_snippet - Display the snippet chooser
---   * toggle_snippet - Show/hide the snippet chooser
function obj:bindHotkeys(mapping)
   local def = {
      show_snippet = hs.fnutils.partial(self.showSnippet, self),
      toggle_snippet = hs.fnutils.partial(self.toggleSnippet, self),
   }
   hs.spoons.bindHotkeysToSpec(def, mapping)
end

return obj
