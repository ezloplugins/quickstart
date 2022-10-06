# Ezlo Plugin Development: Plugin File Structure

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
