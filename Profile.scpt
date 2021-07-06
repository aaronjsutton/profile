/* vim: syntax=javascript
 * vim: filetype=javascript
 * OSA Script functions for terminal command bindings.
 *
 * This library exposes a few useful functions that bridge the
 * gap between the shell environment and actions normally accessible
 * via Open Scripting Architecture. The aim is modularize
 * as much as possible, to expose a thin surface layer for interacting
 * with the user's terminal application from a better environment.
 *
 * Most of the scarce documentation found for putting this together comes
 * from OS X 10.10 JXA Release Notes. There are a couple of quirks and oddities
 * about the way this code is implemented, so consult the docs carefully.
 *
 * Copyright (c) 2021 Aaron Joseph Sutton <aaron@aaronjsutton.com>
 * Licensed under the WTFPL license, version 2 */

const Terminal = Application("Terminal");
const System = Application("System Events");
const TERMINAL_PREFERENCES_PLIST = "~/Library/Preferences/com.apple.Terminal.plist"

/** 
 * Get information about available profiles.
 *
 * There is a non-trivial performance hit incurred when calling this method.
 * Keeping a cache of these values is recommended.
 *
 * This command can be called in a few forms:
 *
 * * No arguments will yield a comma-separated list of all profiles available.
 * * Two arguments can be used to get properties of a particular settings set.
 *
 *  For example: 
 *    
 *    ... settings cobalt2 backgroundColor
 *
 *  Will yield a comma-separated string of the RGB components of cobalt2's
 *  background color.
 *
 *  A single argument form is not considered valid.
 *
 * @returns a string, format dependent on arguments
 */
function settings(args) {
  let sets = Terminal.settingsSets
  if (args.length == 0) {
    var names = []
    for (let i = 0; i < sets.length; i++) {
      names[i] = sets[i]().name();
    }
    return names
  } 
  return sets.byName(args[0])[args[1]]()
}

/**
 * Get or set the Terminal profile for the current window. 
 * Profile names are case-insensitive, but must match the full name of the installed profile.
 * @param {String} name - name of the profile
 */
function profile(name) {
  if (name.length == 0) { return Terminal.windows[0].currentSettings.name() }
  let set = Terminal.settingsSets.byName(name);
  Terminal.windows[0].currentSettings = set
}

/**
 * Set the Terminal background color. Override the background defined by
 * the theme. This is equivalent to using the Inspector window or Touch Bar
 * to change the terminal background without affecting the configured profile.
 * Color components are described using a float value between 0 and 1.
 * @param {Array} color - A three element array representing an RGB color.
 */
function background(color) {
  if (color.length == 0) { return Terminal.windows[0].currentSettings.backgroundColor() }
  Terminal.windows[0].currentSettings.backgroundColor = color
}

/**
 * Set the Terminal normal text color.
 * Color components are described using a float value between 0 and 1.
 * @param {Array} color - A three element array representing an RGB color.
 * @see background
 */
function text(color) {
  if (color.length == 0) { return Terminal.windows[0].currentSettings.normalTextColor() }
  Terminal.windows[0].currentSettings.normalTextColor = color
}

/**
 * Set the Terminal bold text color.
 * Color components are described using a float value between 0 and 1.
 * @param {Array} color - A three element array representing an RGB color.
 * @see background
 */
function boldText(color) {
  if (color.length == 0) { return Terminal.windows[0].currentSettings.boldTextColor() }
  Terminal.windows[0].currentSettings.boldTextColor = color
}

/**
 * Run handler for the Profile library.
 * JXA has little support for any library/modularity functionality,
 * so the purpose of this run handler will be to enable communication with
 * JXA using a small and simple "command language", passing data in via arguments, and out
 * via `osascript`'s return value. Until someone finds a better way to do this,
 * the primary method for calling out to JXA functions will be through the `osascript`
 * binary. For example, set a profile named 'cobal2' from a shell script:
 *
 *  osascript -l JavaScript Profile.scpt set cobalt2
 *
 * Execute a command by passings arguments to the script. The first argument is the command
 * itself, and any following arguments will be passing along to the command function.
 * Commands available are documented above.
 */
function run(fncall) {
  if (fncall.length == 0) { throw new Error('No command given') }
  let [command, ...args] = fncall
  switch (command.toUpperCase()) {
    case 'SETTINGS': return settings(args); break;
    case 'PROFILE': return profile(args); break;
    case 'BACKGROUND': return background(args); break;
    case 'TEXT': text(args); break;
    case 'BOLDTEXT': boldText(args); break;
    default: throw new Error(`Unknown command: "${command.toUpperCase()}"`);
  }
}
