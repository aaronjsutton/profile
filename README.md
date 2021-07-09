# Profile

`profile` - change terminal profiles

The missing command for macOS. Set your terminal profile from the comfort of your
very own shell. A fade function 

![Terminal fade demo](https://github.com/aaronjsutton/profile/blob/master/media/demo.gif)

## Installation
Clone this repo, and source the script with a line similar to:

  source /your/path/to/profile.sh

in your `$HOME/.bashrc` or `$HOME/.zshrc`

### Customizing Behaviour

To customize `profile`, define the following environment variables before you
`source ... profile.sh`:

- `$_PROFILE_NOFADE`: disable terminal background transitions, defaults to `0`.
- `$_PROFILE_CMD`: alias that points to the profile function, defaults to `profile`.
- `$_PROFILE_SCRIPT_LIBRARY`: path OSA script file that contains bindings for manipulating 
the terminal environment. You probably won't need to change this unless you are working with
the source.

## Usage

**On the first run**, the command may take several seconds to generate a cache of your profiles.

Set the profile named "cobalt2":

  profile -s cobalt2

List available profiles:

  profile -l

Clear the profile cache:
  
  profile -x

Use the `-x` flag any time you install or remove profiles from your Terminal.
