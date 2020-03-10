# [docs](index.md) » SwitchableHotkey
---

HotKeys to which you can switch by each application.

Download: [https://github.com/doiken/Spoons/raw/master/Spoons/SwitchableHotkey.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/SwitchableHotkey.spoon.zip)

## API Overview
* Variables - Configurable values
 * [_acceptOnly](#_acceptOnly)
 * [acceptOnly](#acceptOnly)
* Methods - API calls which can only be made on an object returned by a constructor
 * [bindSpec](#bindSpec)
 * [init](#init)
 * [start](#start)
 * [stop](#stop)

## API Documentation

### Variables

| [_acceptOnly](#_acceptOnly)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SwitchableHotkey._acceptOnly`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | Internal Table for looking up accepted hotkeys.                                                                     |

| [acceptOnly](#acceptOnly)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SwitchableHotkey.acceptOnly`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | Table of app name and enabled hot keys.                                                                     |

### Methods

| [bindSpec](#bindSpec)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SwitchableHotkey:bindSpec()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Binds hotkey                                                                     |
| **Parameters**                              | <ul><li>keyspec</li></ul> |
| **Returns**                                 | <ul><li>SwitchableHotkey</li></ul>          |

| [init](#init)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SwitchableHotkey:init()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | initializer                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>SwitchableHotkey</li></ul>          |

| [start](#start)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SwitchableHotkey:start()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Start Listener                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>SwitchableHotkey</li></ul>          |

| [stop](#stop)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `SwitchableHotkey:stop()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Stop Listener                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>SwitchableHotkey</li></ul>          |

