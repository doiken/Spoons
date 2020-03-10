# [docs](index.md) » LastKeyRepeat
---

tmux bind-key -r option-like function

Download: [https://github.com/doiken/Spoons/raw/master/Spoons/LastKeyRepeat.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/LastKeyRepeat.spoon.zip)
thanks to this issue
https://github.com/Hammerspoon/hammerspoon/issues/1128

## API Overview
* Variables - Configurable values
 * [_appsDisable](#_appsDisable)
 * [appsDisable](#appsDisable)
 * [mapping](#mapping)
* Methods - API calls which can only be made on an object returned by a constructor
 * [init](#init)
 * [start](#start)
 * [stop](#stop)

## API Documentation

### Variables

| [_appsDisable](#_appsDisable)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `LastKeyRepeat._appsDisable`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | Internal Table for looking up disabled apps.                                                                     |

| [appsDisable](#appsDisable)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `LastKeyRepeat.appsDisable`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | Table of apps which you want to temporary disable LastKeyRepeat functions.                                                                     |

| [mapping](#mapping)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `LastKeyRepeat.mapping`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | when to timeout 2nd stroke                                                                     |

### Methods

| [init](#init)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `LastKeyRepeat:init()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | initializer                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>LastKeyRepeat</li></ul>          |

| [start](#start)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `LastKeyRepeat:start()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Start waching eventtap and application                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>LastKeyRepeat</li></ul>          |

| [stop](#stop)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `LastKeyRepeat:stop()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | stop waching eventtap and application                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>LastKeyRepeat</li></ul>          |

