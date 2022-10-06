local logging = require("logging")
local core = require("logging")

core.send_ui_broadcast{
	status = 'success',
	message = 'A device was removed!',
}

logging.info('Device removed')
logging.debug(...)
