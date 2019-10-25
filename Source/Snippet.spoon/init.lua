--- === Snippet ===
---
--- Manage snippets.
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/Snippet.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/Snippet.spoon.zip)

local obj = {}

-- Metadata
obj.name = "Snippet"
obj.version = "1.0"
obj.author = "doiken"
obj.homepage = "https://github.com/doiken/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('Snippet')
-- Internal variable
obj._chooser = nil
-- Internal variable - Cache for focused window to work around the current window losing focus after the chooser comes up
obj._prevFocusedWindow = nil

--- Snippet.snippets
--- Variable
--- Table of snippet name and its contents.
--- The format is bellow.
--- [SNIPPET_NAME] = { action = "ACTION_NAME", contents = "CONTENTS" }
--- SNIPPET_NAME is index to choose snippet.
--- Action is "text" or "shell".
--- When action is text, CONTENTS is directly used.
--- When action is shell, CONTENTS is evaluated as shell script.
--- e.g. 
--- spoon.Snippet.snippets = {
---   ["temlate for greeting"] = {
---     action = "text",
---     contents = "Hello!",
---   },
---   ["echo greeting"] = {
---     action = "shell",
---     contents = "echo 'Hello!'",
---   }
--- }
obj.snippets = {}

--- Snippet:init()
--- Method
--- initializer
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:init()
  self._chooser = hs.chooser.new(hs.fnutils.partial(self._processSelectedItem, self))
  self._chooser:choices(hs.fnutils.partial(self._populateChooser, self))
  return obj
end

function obj:_processSelectedItem(value)
   local actions = {
      none = function() end,
      text = function(v) return v.contents end,
      shell = function(v) return hs.execute(v.contents) end,
   }
   if self._prevFocusedWindow ~= nil then
      self._prevFocusedWindow:focus()
   end
   if value and type(value) == "table" then
      if value.action and actions[value.action] then
        contents = actions[value.action](value)
        if contents then
          hs.pasteboard.setContents(contents)
          hs.eventtap.keyStroke({"cmd"}, "v")
        end
      else
        hs.notify.show("Snippet", "Unexpected action " .. value.action .. "registered", "")
      end
   end
end

function obj:_populateChooser()
   menuData = {}
   for k,v in pairs(self.snippets) do
      table.insert(menuData, {text=k, subText=v.action, action=v.action, contents=v.contents})
   end
   if #menuData == 0 then
      table.insert(menuData, { text="",
                               subText="《Snippet is empty》",
                               action = 'none',
                               image = hs.image.imageFromName('NSCaution')})
   end
   self.logger.df("Returning menuData = %s", hs.inspect(menuData))
   return menuData
end

--- Snippet:showSnippet()
--- Method
--- Display the snippet list in a chooser
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
