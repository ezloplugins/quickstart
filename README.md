# Ezlo Plugin Development: Quickstart

## Introduction

This document will be a short introduction to plugin development in the ezlogic plugin platform, providing the basic information needed to quickstart development.

## Ezlogic

The end-user interface for the Ezlo hub is the [ezlogic](https://ezlogic.mios) website. This is the website you'll use to upload, install, and test your plugin. In order to access it, you'll need an Ezlo/Vera account. So the first step, is to create an account, and log-in.

After that, you'll be greeted to the dashboard, and a sidebar on the left. 3 Tabs in specific are noteworthy:

- **Automation -> MeshBots** \\
		This is where the end-user will use the capabilities of your plugin to create and manage custom automations.
- **Plugins -> Edge Plugins**
		This is where you can upload, install, configure, and remove plugins from your hub. Two methods of installing are available: Uploading a local file, and downloading from the marketplace. During development, you will be uploading from your local machine. When the plugin is finished, it will be uploaded to the marketplace, where the end-user will install it from.
- **Settings -> Devices**
		This is where devices are displayed. These can be hubs, physical devices connected, or virtual devices created by plugins. From here, they can be manually viewed, reconfigured, and removed by the user.

For the sake of brevity, we will from now on call these "MeshBots tab", "plugins tab", and "devices tab".

## Virtual Hub

If you have no physical Ezlo Hub, the easiest way to start development is with SoftHub. This is a virtual hub, which emulates a physical Ezlo Hub on your computer.

### With Z-Wave Hardware
If you have some Z-Wave hardware, you can just use the instructions in the [community post](https://community.ezlo.com/t/introducing-ezlo-softhub-downloadable-software-for-free/219510).

### Without Z-Wave Hardware
If not, then a simple docker-compose should do the job[^1], by using the vhub docker-compose folder provided[^2] (i.e. running `sudo docker-compose up` inside the folder).

[^1]: These instructions are, currently, linux only.
[^2]: Two versions were provided. An older but stable one, and a bleeding-edge but unstable one.

After that, with the vhub running, use the provision tool to link the hub to your account. The exact command is `./provision.linux.amd64 provision --username <ACCOUNT USERNAME> --password <ACCOUNT PASSWORD> --description <SOME DESCTIPTION>`[^3].

[^3]: You can run `./provision.linux.amd64 --help` for all the options available.

## Minimal file structure

Every plugin uploaded is a `tar.gz` archive, with a `config.json` file, `interface.json` file, and a `scripts` folder.

The minimal file structure for a plugin is the following:

```
plugin_name.tar.gz/
  config.json
  interface.json
  scripts/
    startup.lua
    teardown.lua
```

We'll now go into details for each of these files.

### `config.json`

This file is where you define the internal settings for the plugin. Here's a minimal `config.json`:

```json
{
  "id": "ezlo.minimal",
  "version": "1.0.0",
  "meta": {
    "name": {
      "text": "Minimal Test Plugin"
    },
    "description": {
      "text": "A plugin with the bare minimal configs, and no functionality, used purely for exposition."
    },
    "author": {
      "text": "Ezlo Innovation"
    },
    "type": "node",
    "language": "lua",
    "placement": {
        "static": true,
        "custom": true
    }
  },
  "type": "gateway",
  "dependencies": {
    "firmware": "2.0",
    "addons": [
      {
        "id": "lua",
        "version": "1.0"
      }
    ]
  },
  "permissions": [
    "core",
    "logging",
    "storage"
  ],
  "executionPolicy": "restoreLastScriptState",
  "startup": "scripts/startup",
  "teardown": "scripts/teardown",
  "gateway": {
    "name": "ezlo.minimal",
    "label": "Minimal test plugin",
    "setItemValueCommand": "HUB:ezlo.minimal/scripts/set_item_value",
    "setSettingValueCommand": "HUB:ezlo.minimal/scripts/set_setting_value",
    "forceRemoveDeviceCommand": "HUB:ezlo.minimal/scripts/delete_device"
  }
}
```

Most of these are simply sane defaults. Here are the most noteworthy ones:

- `id`: This is a unique identifier for the plugin. It consists of a prefix and a name. If you're developing a plugin for Ezlo Innovations, the prefix should be `ezlo`. If not, you can grab a prefix for yourself in the 'Plugins -> Plugin Settings' tab on ezlogic. It'll be used throughout the plugin's code, and should be unique for your plugin.
- `version`: This is the version of the plugin. It is mostly decided by you, but it should be $\ge$ 1.0.0
- `meta`: Holds some data about the plugin, such as name, description, and author. These will be displayed in the UI to the user.
- `permissions`: This specifies the [modules](https://developer.mios.com/api/scripting/modules/) the plugin will access. You will \textit{not} be able to `require` a module without specifying it in here.
- `startup`: This file will execute when first installing the plugin. It should contain some initial setup.
- `teardown`: This file will execute when uninstalling or upgrading the plugin. It should contain some cleaup code.
- Gateway Commands: The scripts specified here are executed when certain actions or events happen, such as an item or setting being changed, or a device being removed. The full list of available commands are specified in the [API Docs](https://developer.mios.com/api/hub/plugins/gateway/).

### `interface.json`

In this script, you specify details about the user interface. Here's an example:

```json
{
  "configuration":{
    "type":"static",
    "script":"ezlo.minimal/scripts/configure_new",
    "inputs":[
      {
        "name":"String",
        "description":"String input",
        "field":"input",
        "required":true,
        "type":"string"
      },
      {
        "name":"Integer",
        "description":"Integer input",
        "field":"input",
        "required":false,
        "type":"int"
      }
    ]
  }
}
```

- `configuration.script`: This file will execute when the user creates a new configuration. When it executes, it'll receive all of the inputs specified, which will be present as fields in the "`...`" lua variable.
- `configuration.inputs`: A list of all of the inputs the configuration should take. This includes the UI name and description, type, if it is required or not, and the field that will be used when the configuration script is called.

### `scripts` folder

This folder will contain the code for your plugin. It may contain any amount of (nested) folders and lua files to be executed. Any file can be accessed/executed using the `"HUB:<PLUGIN_ID>/scripts/<FILEPATH>"` idiom by any of the usual lua means (i.e. `require`, `loadfile`, etc).

For example, `require("HUB:ezlo.minimal/scripts/configure_new")` will import the file `configure_new.lua` that is inside the scripts folder.

## Uploading

To execute your plugin, it must be uploaded to the ezlogic platform (in a `tar.gz` format, as specified above).

Go to the plugins tab, click on "Upload New Plugin", and select the archive. The plugin will appear in the list of plugins. Press the plugin's "Manage Installations" icon, install, and configure it. If everything went right, your plugin should now be functioning.

A minimal example plugin will be provided with this document. Feel free to install it, explore its codebase, and use it as a starting point for your own plugin.

## API Basics

The MiOS API is what your plugin will use to interface with the hub, and implement its functionalities. Among a host of other features, the API makes available a full suite of modules, which your plugin may `require` directly into the code, giving you access to services like [UDP/TCP connections](https://developer.mios.com/api/scripting/modules/network/), [bluetooth](https://developer.mios.com/api/scripting/modules/bluetooth/), [HTTP](https://developer.mios.com/api/scripting/modules/http/), [Zwave](https://developer.mios.com/api/scripting/modules/zwave/), [Zigbee](https://developer.mios.com/api/scripting/modules/zigbee/), and many others. Perhaps most importantly, it allows you to interface with the ezlogic platform using the [core](https://developer.mios.com/api/scripting/modules/core/) module, which enables you to create and access devices, items, settings, UI messages, etc.

Almost no plugin will (or should) use all of the modules available, instead only using the ones that are necessary for providing the desired functionality. However, some pieces of the API are so central, that you'll almost certainly use them, or benefit from knowing them. In this section, we'll give them some light.

Note that we'll only discuss \textit{some} parts of \textit{some} of the modules. Your ultimate reference should be the official [MiOS API documentation](https://developer.mios.com/api/), specially the [modules](https://developer.mios.com/api/scripting/modules/) section. When in doubt, refer to it.

All of the code snippets present is this section will also be present in the minimal example plugin provided. So, feel free to explore there as well. Let's start.

### Storage

There are 3 levels of storage: Local, Global, and Persistent.

- Local: Any `local` variable will only be accessible to that script, and to its appropriate scope.
- Global: Any global variable will be accessible to \textit{all} of the plugin's scripts. This is important, as it allows different scripts to communicate/share data.
- Persistent: Any variable stored with the [`storage`](https://developer.mios.com/api/scripting/modules/storage/storage-module-api-require-storage/) module, will be stored persistentently. These are accessible by any script, \textit{and} will survive shutdowns, reboots, power outages, etc.

```lua
-- Importing storage module.
local storage = require("storage")

-- Local variables.
local num_0 = 1
local str_0 = "abc"
local tab_0 = {1, 3, 5}

-- Global variables.
num_1 = 2
str_1 = "def"
_G.tab_1 = {2, 4, 6} -- Alternative way to express it

-- Persistent variables (storing).
storage.set_number("num_2", 3)
storage.set_string("str_2", "ghi")
storage.set_table("tab_2", {3, 5, 7})
-- Persistent variables (retrieving).
local num_2 = storage.get_number("num_2")
local str_2 = storage.get_string("str_2")
local tab_2 = storage.get_table("tab_2")
```

Higher levels of storage are less efficient, so try use the least storage level you need. If there's no reason for something to be persistent, make it global. If there's no reason for something to be global, make it local.

### Logging

You can log data using the [`logging`](https://developer.mios.com/api/scripting/modules/logging/) module. There are different levels of logging, such as `info`, `debug`, and `error`. The [complete list](https://developer.mios.com/api/scripting/modules/logging/module-api-require-logging/) is presented in the documentation.

These different levels are useful for different purposes. For example, `debug` logs will not be generated for end users, so they may be more extensive, and be used more frequetly, without affecting the end-user's storage space.

```lua
-- Importing logging module.
local logging = require("logging")

-- Examples of logging.
logging.info("3 devices added.")
logging.error("Could not create connection")
local t = {1, 'abc'}
logging.debug(t)
```

The logs are written to '`/var/log/firmware/ha-luad.log`' inside the hub[^4]. So, to access them, you need to get into the hub. How you'll do that depends on the type of hub you're using:

[^4]: It's worth noting that there are lot more log files inside `firmware` folder. `ha-luad.log` is simply the one generated by plugins. These other log files contain useful information about different aspects of the hub.

- If you have a physical hub, you can to ssh to it (i.e. `ssh mypc@106.000.0.1`).
- If you have a virtual hub, you can docker exec bash to it (i.e. `sudo docker exec -it vhub_beta bash`).

Once you're in, you can vizulize the logs in whichever way you wish. For example, with tail: `tail -f -n 50 /var/log/firmware/ha-luad.log`.

```
	**** luad Restarted at Fri Sep 23 15:20:45 UTC 2022

	2022-09-23 15:20:45 INFO  : Logs folder was changed: //var/log/firmware
	2022-09-23 15:20:45 INFO  : addon.lua: - [2022-08-10T20:49:14+0000]
	2022-09-23 15:20:45 INFO  : addon.lua: Spread: connected to "4803" with private group "#addon.lua#localhost"
```

### Asynchronous Execution

A lot of the API is based upon asynchronous execution. This means that individual scripts can be called to be executed by asynchronous events, such as a network input, http response, or in a specific timer set by you.

The two common ways to interact are either by subscribing to an event, which will execute execute the script , or manually scheduling the execution of a script. Let's see an example of each.

#### Subscription Example

The [network](https://developer.mios.com/api/scripting/modules/network/) package handles transport-layer connections, such as UDP and TCP. When using a persistent TCP connection, you can send or receive data from these connections. To be sure that your handler script will execute to process that data, you may `subscribe` the script to that connection:

```lua
local network = require("network")

-- The file 'network_handler.lua' will now be called on every network event.
network.subscribe("HUB:ezlo.minimal/scripts/network_handler")

-- We then attempt a connection.
network.connect{
	ip = '127.0.0.1',
	port = '5000',
	connection_type = 'TCP',
}
-- This connection attempt will queue the execution of 'network_handler.lua'.
```

Note that the queued script will get some data about the event that triggered it. This data can be accessed through the scripts' `...` arguments:

```lua
local logging = require("logging")

-- This is getting the arguments, which will include the event's data.
local args = ...

-- Logging event's data.
logging.debug(args)
```

#### Manual Scheduling Example

The [timer](https://developer.mios.com/api/scripting/modules/timer/) module is how your plugin can manually schedule a script to execute:

```lua
-- Importing timer module.
local timer = require("timer")

-- Immediately queues 'script_0.lua' to be executed.
timer.set_timeout(0, "HUB:ezlo.minimal/scripts/script_0")

-- Queues 'script_1.lua' to be executed in 5 seconds.
timer.set_timeout(5000, "HUB:ezlo.minimal/scripts/script_1")

-- Queues 'script_2.lua' to be executed every 5 seconds.
timer.set_interval(5000, "HUB:ezlo.minimal/scripts/script_2")
```

#### Note about asynchronous execution

One important point to emphasize is that the asynchronous system operates in a queue fashion, with new scripts added to the end of the queue. One will finish, before the next executes. There are two major consequences of this:

- The system is \textit{not} multithreaded. So despite its asynchronous nature, data races are not a concern, as no two scripts will execute in parallel.
- If one script falls into an inifinite or particularly long execution loop, the whole plugin halts, since all other queued scripts must wait for the current one to finish before executing. So it may be a good idea to avoid overly long execution times in one script.

### Devices

Devices are a representation of an entity that acts or can be acted upon by automation. It may be a 'model' for a physical device, such as a light bulb, switch, or sensor. It might also be a purely virtual one, like a client that communicates to a server. Devices can be created, accessed, and modified using the [core](https://developer.mios.com/api/scripting/modules/core/) module:

```lua
local core = require("core")

-- Creating new device.
local device_id = core.add_device{
	type = 'device',
	device_type_id = 'api_communication',
	category = 'generic_io',
	subcategory = 'generic_io',
	battery_powered = false,
	gateway_id = core.get_gateway().id,
	-- This name will be displayed in the UI.
	name = "API Communication Client",
}

-- ...
```

There are two major parts of the device that interface with the user: Settings, and Items.

#### Settings

Settings are information about the device that are available to the user through the UI to configure. They may be modifiable, and may be used to affect the workings of the device. For example, if the device represents a persistent connection to a server, some possible setting are the IP address of the server, and the timeout period acceptable.

```lua
-- ...

-- Creating 'id' setting to the device created.
local address_setting_id = core.add_setting{
	device_id = device_id,
	label = {
		text = 'Server Address'
	},
	description = {
		text = "e.g. "127.0.0.1''
	},
	value_type = "string",
	value = '127.0.0.1',
	status = "synced",
	has_setter = false,
}

local timeout_setting_id = core.add_setting{
	device_id = device_id,
	label = {
		text = "Timeout"
	},
	description = {
		text = "The maximum amount of time to wait for a response before trying again (in seconds)"
	},
	value_type = "int",
	value = 10,
	status = "synced",
	has_setter = true,
}

-- ...
```

Most notably:

- `device_id`: The id of the target device.
- `label.text`: The name that is presented to the user.
- `description.text`: The desctiption presented to ther user.
- `value_type`: The type of the setting. 
- `value`: Starting value for the setting. 
- `has_setter`: Whether the user can modify the value of the setting in the UI (otherwise, it can only be modified internally by the plugin).

![settings2](https://user-images.githubusercontent.com/43142209/193704114-52a20890-198b-424a-b991-346e0a6b518d.png)

#### Items (and more generally, the MeshBot Automation System)

The MeshBot Automation system is what allows users to automate their devices, giving them control of their lights, sensors, as well as their virtual devices, created by the plugins they have installed. In this sub-section, we'll take a deeper look at that last category.

As an example, here's a MeshBot Automation that switches a light every 5 seconds:

IMAGE

MeshBot Automations are divided into Triggers and Actions. Triggers are the conditions to trigger the automation to execute. Actions are the actions performed when the automation is executed. When the Triggers in an automation are satisfied, the Actions are executed.

Items are the way that you developer can expose the Triggers/Actions of your plugin, and as such, your plugin's capabilities in the automation system. "Getter" items are considered Triggers (as the API "gets" their values, to decide when the Trigger is set). "Setter" items are considered Actions (as the API "sets" their values when the Action is performed). We'll now see an example of creating two items, the first one being a Trigger, and the second one being an Action (take note of the `has_getter` and `has_setter` attributes):

```lua
-- ...

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
	name = 'My Action',
	has_getter = false,
	has_setter = true,
	show = true,
	value_type = 'dictionary.string',
	value = {},
}
```

There's an additional step to the setter item (the Action): Setting its interface. This is done in the `interface.json` file. This is the specification used for this item:

```json
	...
	{
		"id": "my_action_id",
		"ui": {
			"name": "plugin call",
			"description": "Performs some action to the device",
			"placement": "plugin"
		},
		"type": "setter-api",
		"apply": [
			{
				"element": "item",
				"when": {
					"property": "name",
					"operator": "=",
					"value": "My Action"
				},
				"to_api": "hub.item.value.set"
			}
		],
		"inputs":[
			{
				"name":"First Input",
				"type": "string",
				"required": true,
				"description": "A string input."
			},
			{
				"name":"Second Input",
				"type": "number",
				"required": false,
				"description": "A numerical input."
			}
		]
	},
	...
```

Take note of the `apply.when` property, where we specify "`name = My Action`". This specifies the item we just created. Together with "`to_api: hub.item.value.set`", this means that it'll change the item's value to the `inputs` upon triggering the action. You can see the resulting format of the items in the MeshBot Automations tab:

![MeshBot0](https://user-images.githubusercontent.com/43142209/193703906-d271d915-c3bb-4e1f-badd-015405e7666d.png)

However, more important than changing the item value, is the fact that the `setItemValueCommand` script specified in the `config.json` (refer to that section again if necessary) will be executed with this. That is the place where the logic of your action can go:

```lua
local logging = require("logging")

-- The new values for the item are in the 'value' field of the arguments.
local args = ...
local value = args.value

-- Retrieving the values of the inputs.
local input_string = value["First Input"] or ''
local input_numerical = value["Second Input"] or 0

logging.debug("First Input: "..input_string)
logging.debug("Second Input: "..tostring(input_numerical))

-- Perform some userful action here.
```

This script will be triggered every time the Action is executed by the automation. This way, your plugin can respond to the Actions accordingly, and thus be ready for use in Ezlo's MeshBot Automation System.



