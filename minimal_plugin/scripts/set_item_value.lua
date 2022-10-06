local logging = require("logging")

local args = ...
local value = args.value

local input_string = value["First Input"] or ''
local input_numerical = value["Second Input"] or 0

logging.debug("First Input: "..input_string)
logging.debug("Second Input: "..tostring(input_numerical))
