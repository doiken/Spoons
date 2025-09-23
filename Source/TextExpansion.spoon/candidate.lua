local Candidate = {}

function Candidate.new(keywords, limit)
  local instance = {
    _keywords = keywords,
    _baseAttributes = {
      font = {
        name = hs.alert.defaultStyle.textFont,
        size = hs.alert.defaultStyle.textSize,
      },
      color = hs.alert.defaultStyle.textColor,
      paragraphStyle = {
        textAlignment = hs.alert.defaultStyle.textAlignment,
      }
    },
    _canvas = nil,
    limit = limit,
  }

  setmetatable(instance, { __index = Candidate}) -- weak reference for circular reference

  return instance
end

local function _filterKeywords(prefix, keywords)
  local filteredKeys = {}
  for key, _ in pairs(keywords) do
    if key:find("^" .. prefix) then
      table.insert(filteredKeys, key)
    end
  end
  return filteredKeys
end

local function _show(message)
  -- calculate alert size and location
  local screen = hs.screen.mainScreen()
  local screenFrame = screen:frame()
  local textSize = hs.canvas.new({}):minimumTextSize(message)
  local padding = 10
  local alertWidth = math.ceil(textSize.w) + padding * 2
  local alertHeight = math.ceil(textSize.h) + padding * 2
  local x = screenFrame.x + screenFrame.w - alertWidth - padding
  local y = screenFrame.y + screenFrame.h - alertHeight - padding

  local alertCanvas = hs.canvas.new({
    x = x,
    y = y,
    w = alertWidth,
    h = alertHeight,
    screen = screen
  })
  alertCanvas:level("floating")
  alertCanvas:appendElements({
    {
      type = "rectangle",
      frame = { x = 0, y = 0, w = alertWidth, h = alertHeight },
      strokeWidth = hs.alert.defaultStyle.strokeWidth,
      strokeColor = hs.alert.defaultStyle.strokeColor,
      fillColor = hs.alert.defaultStyle.fillColor,
      roundedRectRadii = { xRadius = 20.0, yRadius = 20.0 }
    },
    {
      type = "text",
      text = message,
      textAlignment = hs.alert.defaultStyle.textAlignment,
      textColor = hs.alert.defaultStyle.textColor,
      padding = padding,
    }
  })
  alertCanvas:show()

  return alertCanvas
end

function Candidate:_createMessage(prefix, candidates)
  local message = hs.styledtext.new("", self._baseAttributes)
  local styledLB = hs.styledtext.new("\n", self._baseAttributes)
  local ulAttributes = {underlineStyle = hs.styledtext.lineStyles.single}
  
  for _, c in ipairs(candidates) do
    message = message
      .. hs.styledtext.new(c, self._baseAttributes):setStyle(ulAttributes, 1, #prefix) -- emphasize input chars
      .. styledLB
  end
  return message:sub(1, #message - 1) -- remove last line break
end

function Candidate:update(word)
  if self._canvas then
    hs.alert.closeSpecific(self._canvas:delete())
  end

  local candidates = _filterKeywords(word, self._keywords)
  if #candidates == 0 then
    return
  end

  table.sort(candidates)
  if #candidates > self.limit then
    candidates = {table.unpack(candidates, 1, self.limit)}
  end
  self._canvas = _show(self:_createMessage(word, candidates))
end

function Candidate:clear()
  if self._canvas then
    hs.alert.closeSpecific(self._canvas:delete())
  end
end

return Candidate