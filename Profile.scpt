/* vim: syntax=javascript
 * vim: filetype=javascript
 * OSA Script functions for terminal command bindings.
 *
 * This library exposes a few useful functions that bridge the
 * gap between the shell environment and actions normally accessible
 * via Open Scripting Architecture. The aim is modularize tasks from
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
 * Get the names all currently installed Terminal profiles.
 *
 * This method uses System Events Property List Suite under the hood,
 * and there is a non-trivial performance hit incurred when calling this method.
 * Keeping a cache of these values is recommended.
 *
 * @returns a string of comma-separated, full profile names.
 */
function get() {
  const prefs = System.propertyListFiles.byName(TERMINAL_PREFERENCES_PLIST)
  // NSDictionary bridging to access to record keys.
  return $.NSDictionary.dictionaryWithDictionary(prefs.value()['Window Settings']).allKeys
}

/**
 * Set the Terminal profile for the current window. Profile names appear to be case-insensitive,
 * but must match the full name of the installed profile.
 * @param {String} name - name of the profile
 */
function set(name) {
  Terminal.windows[0].currentSettings = name
}

/**
 * Set the Terminal background color. Override the background defined by
 * the theme. This is equivalent to using the Inspector window or Touch Bar
 * to change the terminal background without affecting the configured profile.
 * Color components are described using a float value between 0 and 1.
 * @param {Array} color - A three element array representing an RGB color.
 */
function background(color) {
  Terminal.windows[0].currentSettings.backgroundColor = color
}

/**
 * Set the Terminal normal text color.
 * Color components are described using a float value between 0 and 1.
 * @param {Array} color - A three element array representing an RGB color.
 * @see background
 */
function text(color) {
  Terminal.windows[0].currentSettings.normalTextColor = color
}

/**
 * Set the Terminal bold text color.
 * Color components are described using a float value between 0 and 1.
 * @param {Array} color - A three element array representing an RGB color.
 * @see background
 */
function boldText(color) {
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
 *  osascript -l JavaScript Profile.scpt set cobal2
 *
 * Execute a command by passings arguments to the script. The first argument is the command
 * itself, and any following arguments will be passing along to the command function.
 * Commands available are documented above.
 */
function run(fncall) {
  if (fncall.length == 0) { throw new Error('No command given') }
  [command, ...args] = fncall
  switch (command.toUpperCase()) {
    case 'GET': return get(args); break;
    case 'SET': set(args); break;
    case 'BACKGROUND': background(args); break;
    case 'TEXT': text(args); break;
    case 'BOLDTEXT': boldText(args); break;
    default: throw new Error(`Unknown command: "${command.toUpperCase()}"`);
  }
}
