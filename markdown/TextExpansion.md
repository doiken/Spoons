# [docs](index.md) » TextExpansion
---

Typing prefix and keyword expands pre-set words or function.

Based on: https://github.com/Hammerspoon/hammerspoon/issues/1042

Download: [https://github.com/doiken/Spoons/raw/master/Spoons/TextExpansion.spoon.zip](https://github.com/doiken/Spoons/raw/master/Spoons/TextExpansion.spoon.zip)

HOW TO USE:
  1. SETUP(see SETUP section)
  2. type prefix and keyword you set. e.g.
     - `;greeting`
     - `;date`
  3. enjoy :)

SETUP:
  install manually
  ```
  te = hs.loadSpoon("TextExpansion")
  te.keywords ={
     greeting = "hello",
     greeting_with_macro = "hello @clipboard",
     date = function() return os.date("%B %d, %Y") end,
  }
  te.prefix = ';'
  te:start()
  ```

  install using SpoonInstall
  ```
  hs.loadSpoon("SpoonInstall")
  spoon.SpoonInstall.repos.doiken = {
     url = "https://github.com/doiken/Spoons",
     desc = "doiken's spoon repository",
  }
  spoon.SpoonInstall:andUse("TextExpansion", {
    repo = 'doiken',
    loglevel = "warning",
    config = {
      keywords = {
        ...
      },
      prefix = ','
    },
    start = true
  })
  ```

MACROS:
  You can use following macros in your return string.
  - `@clipboard`: replace with string in clipboard
  - note: If you want to change macro prefix "@", set character into variable `macroStartBy`.

  You can enable macro replacement to type preset charactor, default: "+".

  Without preset character, macro is just removed.
  e.g.
  - `;greeting_with_macro`  -> hello 
  - `;+greeting_with_macro` -> hello NAME_ON_YOUR_CLIPBOARD

  You can change preset character by setting `secondPrefixEnablingMacro`.

  You can enable macro always without typing preset charactor by setting empty string.

NOTE: TextExpansion expands text via clipboard

## API Overview
* Variables - Configurable values
 * [keywords](#keywords)
 * [logger](#logger)
 * [macroStartBy](#macroStartBy)
 * [prefix](#prefix)
 * [secondPrefixEnablingMacro](#secondPrefixEnablingMacro)
* Methods - API calls which can only be made on an object returned by a constructor
 * [start](#start)
 * [stop](#stop)

## API Documentation

### Variables

| [keywords](#keywords)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `TextExpansion.keywords`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | Map of keywords to strings or functions that return a string to be replaced.                                                                     |

| [logger](#logger)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `TextExpansion.logger`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.                                                                     |

| [macroStartBy](#macroStartBy)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `TextExpansion.macroStartBy`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | Prefix for Macro Keyword.                                                                     |

| [prefix](#prefix)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `TextExpansion.prefix`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | Trigger character for TextExpansion to start watching keywords.                                                                     |

| [secondPrefixEnablingMacro](#secondPrefixEnablingMacro)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `TextExpansion.secondPrefixEnablingMacro`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | Second Prefix to enable replacing macro. If empty, macro always replaced.                                                                     |

### Methods

| [start](#start)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `TextExpansion:start()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Start TextExpansion                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>TextExpansion</li></ul>          |

| [stop](#stop)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `TextExpansion:stop()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Stop TextExpansion                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>TextExpansion</li></ul>          |

