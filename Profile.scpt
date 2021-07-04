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
 */
function get() {
  const prefs = System.propertyListFiles.byName(TERMINAL_PREFERENCES_PLIST)
  // NSDictionary bridging workaround to get access to record keys.
  return $.NSDictionary.dictionaryWithDictionary(prefs.value()['Window Settings']).allKeys
}

/**
 * Set the Terminal profile for the current window.
 */
function set(name) {
  
}

/**
 * Set the Terminal background color. Override the background defined by
 * the theme. This is equivalent to using the Inspector window or Touch Bar
 * to change the terminal background without affecting the configured profile.
 */
function background(color) {

}

/**
 * Run handler for the Profile library.
 * JXA has little support for any library/modularity functionality,
 * so the purpose of this run handler will be to enable communication with
 * JXA using a small "command language", passing data in via arguments, and out
 * via `osascript`'s return value. Until someone finds a better way to do this,
 * the primary method for calling out to JXA functions will be through the `osascript`
 * binary. For example, get a profile named 'my_profile' from a shell script:
 *
 *  osascript -l JavaScript Profile.scpt get my_profile
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
    default: throw new Error(`Unknown command: "${command.toUpperCase()}"`);
  }
}
