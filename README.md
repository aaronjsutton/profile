# Profile

> A missing command for macOS. Set your terminal profile from the comfort of your
very own shell.

![Terminal fade demo](https://github.com/aaronjsutton/profile/blob/master/media/demo.gif)

As a bonus, `profile` makes use of Terminal background color to build-in a custom fade function,
so transitioning between profiles is less jarring on the eyes during those late-night sessions.

## Installation
Clone this repo, and source the script with a line similar to:

```bash
source /your/path/to/profile.sh
```

in your `$HOME/.bashrc` or `$HOME/.zshrc`

### Customizing Behaviour

To customize `profile`, define the following environment variables before you
`source ... profile.sh`:

- `$_PROFILE_NOFADE`: disable terminal background transitions, defaults to `0`.
- `$_PROFILE_CMD`: alias that points to the profile function, defaults to `profile`.
- `$_PROFILE_DATA`: data file that stores the profile cache, defaults to `$HOME/.termprofiles`
- `$_PROFILE_SCRIPT_LIBRARY`: path OSA script file that contains bindings for manipulating 
the terminal environment. You probably won't need to change this.

## Usage

*On the first run*, the command may take several seconds to generate a cache of your profiles.

Set the profile named "cobalt2":
```bash
profile -s cobalt2
```

List available profiles:
```bash
profile -l
```

Clear the profile cache:
```bash
profile -x
```
Use the `-x` flag any time you install or remove profiles from your Terminal.

### Profile Cache

Calling the underlying OSA script library can incur a performance hit, 
and Terminal profiles is relatively static data, the shell function generates
a cahce file of all terminal profiles, and relevant color data alongside it. This cache never
expires, and is refreshed using the `-x` option noted above or when the cache file is removed.

The cache also tracks the currently set profile, and will refresh this value to avoid the profile
being changed via external events such as using the inspector. The current value is _transient_ and
reflects only the current window. This allows for a single cache file to work for any number 
of Terminal window instances.

### Caveats

Just a couple things to note:

- OSA scripts are not really fast, at all, so the fade engine is capped a certain speed, since OSA
is invoked on every call to background change. The end result is a kind of slower fade, but I still think
it looks pretty good. This can be disabled easily if it wastes time.

- `Profile.scpt` is an attempt to make a sane-*ish* surface out of the hell-swamp that is macOS JavaScript for Automation documentation. 
It's written in JavaScript for automation (JXA), since I find that nicer than terse AppleScript, and types play a little bit nicer.
The bridge between these two is really just passing along data through output and subshells ... (ick). There could
be some complex Objective-C way to put this together, but that's beyond the scope of the project. Just make sure that
`profile` knows how to find the script library file :smile:
