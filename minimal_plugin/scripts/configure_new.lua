local logging = require("logging")
local core = require("core")

logging.info('Configuring new device')

local args = ...

local str = args.string or ''
local num = args.numerical or 0

logging.debug('Params: '..str..', '..tostring(num))

local device_id = core.add_device{
		type = 'device',
		device_type_id = 'minimal_device',
		category = 'generic_io',
		subcategory = 'generic_io',
		battery_powered = false,
		gateway_id = core.get_gateway().id,
		name = 'Minimal Device',
}

local address_setting_id = core.add_setting{
	device_id = device_id,
	label = {
		text = "Server Address"
	},
	description = {
		text = "e.g. '127.0.0.1'"
	},
	value_type = "string",
	value = "127.0.0.1",
	status = "synced",
	has_setter = false,
}

local timeout_setting_id = core.add_setting{
	device_id = device_id,
	label = {
		text = "Timeout"
	},
	description = {
		text = "The maximum amount of time to wait for response before trying again (in seconds)"
	},
	value_type = "int",
	value = 10,
	status = "synced",
	has_setter = true,
}

local my_trigger = core.add_item{
	device_id = device_id,
	name = 'My Trigger',
	has_getter = true,
	has_setter = false,
	show = true,
	value_type = 'string',
	value = '',
}

local my_action = core.add_item{
	device_id = device_id,
	name = 'my_action',
	has_getter = false,
	has_setter = true,
	show = true,
	value_type = 'dictionary.string',
	value = {},
}

logging.info('Device created (id '..device_id..')')

core.send_ui_broadcast{
	status = 'success',
	message = 'Success',
}
