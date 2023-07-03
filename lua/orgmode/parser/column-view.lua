local parsing = require('orgmode.utils.parsing')

local M = {}

--- @class ColumnViewConfig
--- @field columns ColumnViewColumnConfig[]
local ColumnViewConfig = {}
ColumnViewConfig.__index = ColumnViewConfig

---@private
---@param columns ColumnViewColumnConfig[]
---@return ColumnViewConfig
function ColumnViewConfig:_new(columns)
  --- @type ColumnViewConfig
  local instance = {}
  instance.columns = columns

  return instance
end

---@return ColumnViewConfig
function ColumnViewConfig:parse()
  --- @type ColumnViewColumnConfig[]
  local columns = {}

  -- TODO: Parse each of the columns

  return ColumnViewConfig:_new(columns)
end

--- @class ColumnViewColumnConfig
--- @field width? integer
--- @field property string
--- @field title? string
--- @field summaryType? ColumnViewSummaryType?
local ColumnViewColumnConfig = {}
ColumnViewColumnConfig.__index = ColumnViewColumnConfig

--- @param property string
--- @return ColumnViewColumnConfig
function ColumnViewColumnConfig:_new(property)
  ---@type ColumnViewColumnConfig
  local instance = {}
  setmetatable(instance, ColumnViewColumnConfig)

  instance.property = property

  return instance
end

--- @param input string
--- @return ColumnViewColumnConfig?, string
function ColumnViewColumnConfig:parse(input)
  local original = input

  --- @type '%'?, number?, string?, string?, ColumnViewSummaryType?
  local prefix, width, property, title, summaryType

  -- Parse prefix
  prefix, input = parsing.parse_pattern(input, '%%')
  if not prefix then
    return nil, original
  end

  -- Parse width
  width, input = M.parseWidth(input)

  -- Parse property
  property, input = parsing.parse_pattern(input, '%w+')
  if not property then
    return nil, original
  end

  -- Parse title
  title, input = M.parseTitle(input)

  -- Parse summary
  summaryType, input = M.parseSummaryType(input)

  local config = ColumnViewColumnConfig:_new(property)
  config.width = width
  config.title = title
  config.summaryType = summaryType

  return config, input
end

--- @param input string
--- @return integer?, string
function M.parseWidth(input)
  local original = input

  local rawWidth, input = parsing.parse_pattern(input, '%d+')
  if not rawWidth then
    return nil, original
  end

  local width = tonumber(rawWidth)
  if not width then
    return nil, original
  end

  return width, input
end

--- @param input string
--- @return string?, string
function M.parseTitle(input)
  local original = input

  local open, title, close

  -- Parse open
  open, input = parsing.parse_pattern(input, '%(')
  if not open then
    return nil, original
  end

  -- Parse title
  title, input = parsing.parse_pattern(input, '%w+')
  if not title then
    return nil, original
  end

  -- Parse close
  close, input = parsing.parse_pattern(input, '%)')
  if not close then
    return nil, original
  end

  return title, input
end

--- @param input string
--- @return ColumnViewSummaryType?, string
function M.parseSummaryType(input)
  local original = input

  local open, summaryType, close

  -- Parse open
  open, input = parsing.parse_pattern(input, '{')
  if not open then
    return nil, original
  end

  -- Parse fixed value
  summaryType, input = parsing.parse_pattern_choice(
    input,
    '%+',
    '%+%;%%%.1f',
    '%$',
    'min',
    'max',
    'mean',
    'X',
    'X%/',
    'X%%',
    '%:',
    '%:min',
    '%:max',
    '%:mean',
    '%@min',
    '%@max',
    '%@mean',
    'est%+'
  )

  if not summaryType then
    return nil, original
  end

  -- Parse close
  close, input = parsing.parse_pattern(input, '{')
  if not close then
    return nil, original
  end

  return summaryType, input
end

--- https://orgmode.org/manual/Column-attributes.html
--- @alias ColumnViewSummaryType
--- | '+'
--- | '+;%.1f'
--- | '$'
--- | 'min'
--- | 'max'
--- | 'mean'
--- | 'X'
--- | 'X/'
--- | 'X%'
--- | ':'
--- | ':min'
--- | ':max'
--- | ':mean'
--- | '@min'
--- | '@max'
--- | '@mean'
--- | 'est+'

return ColumnViewConfig
