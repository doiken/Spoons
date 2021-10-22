--- === TextClipboardHistoryWithImage ===
---
--- TextClipboardHistory with images
---
--- Download: [https://github.com/doiken/Spoons/raw/master/Spoons/TextClipboardHistoryWithImage.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/TextClipboardHistoryWithImage.spoon.zip)
---
--- REQUIREMENTS:
---   TextClipboardHistory is loaded ahead and can be accessed by spoon.TextClipboardHistory.
---   By default, spoon.TextClipboardHistory is set via hs.loadSpoon.
---
--- SETUP:
---   just load after TextClipboardHistory, and that's all :)
---   install manually
---   ```
---   hs.spoons.use("TextClipboardHistory", { ... })
---   hs.spoons.use("TextClipboardHistoryWithImage")
---   ```
---
---   install using SpoonInstall
---   ```
---   hs.loadSpoon("SpoonInstall")
---   spoon.SpoonInstall.repos.doiken = {
---      url = "https://github.com/doiken/Spoons",
---      desc = "doiken's spoon repository",
---   }
---   spoon.SpoonInstall:andUse("TextClipboardHistory", { ... })
---   spoon.SpoonInstall:andUse("TextClipboardHistoryWithImage")
---   ```
---
--- HOWITWORKS:
---   TextClipboardHistoryWithImage treat images as base64 encoded url internally.
---   To switch images and texts seamlessly, TextClipboardHistoryWithImage overwrite TextClipboardHistory destructively.

local obj = spoon.TextClipboardHistory

--- TextClipboardHistory.image_prefix
--- Variable
--- Prefix to tell image text from others. default: %CH%
obj.image_prefix = "%CH%"

obj._checkAndStorePasteboard = obj.checkAndStorePasteboard
function obj:checkAndStorePasteboard()
  local image = hs.pasteboard.readImage()
  if (image ~= nil) then
    -- convert hs.image into base64 encoded url
    self:pasteboardToClipboard(obj.image_prefix .. image:encodeAsURLString())
  else
    self:_checkAndStorePasteboard()
  end
end

obj.__processSelectedItem = obj._processSelectedItem
function obj:_processSelectedItem(v)
  if (v and v.original_image ~= nil) then
    v.text = nil -- disable .text property to skip default process
  end

  -- process default flow ahead except the action for image
  self:__processSelectedItem(v)

  if (v and v.original_image ~= nil) then
    hs.pasteboard.writeObjects(v.original_image)
    self:pasteboardToClipboard(obj.image_prefix .. v.original_image:encodeAsURLString())
    if (self.paste_on_select) then
      hs.eventtap.keyStroke({"cmd"}, "v")
    end
  end
end

obj.__populateChooser = obj._populateChooser
function obj:_populateChooser()
  local origData = self:__populateChooser()
  local menuData = {}
  for i,v in ipairs(origData) do
    -- in case of image text, convert text into image data
    local pos = v.text:find(obj.image_prefix, 1, true)
    if (pos == 1) then
      local image_url = v.text:sub(#obj.image_prefix + 1)
      v.original_image = hs.image.imageFromURL(image_url)
      v.text = hs.styledtext.getStyledTextFromData(("<img src='%s' />"):format(image_url), "html")
    end
    table.insert(menuData, v)
  end
  return menuData
end

-- start again to reset timer and so on if already started
if (obj.timer ~= nil) then
  obj:start()
end

return obj