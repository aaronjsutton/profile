# Copyright (c) 2021 Aaron Joseph Sutton. Licensed under the WTFPL license, version 2.

# manage macOS Terminal.app profiles
# 
# INSTALL:
#   * add the following to your .bashrc/.zshrc:
#       . /path/to/profile

[ -d "${_PROFILE_DATA:-$HOME/.profile}" ] && {
  echo "ERROR: profile datafile is a directory."
}

_OSA_OPTS="-l JavaScript"
_SCRIPT_LIB_NAME="Profile.scpt"

_profile() {
  datafile="${_PROFILE_DATA:-$HOME/.profiles}" 
  script_lib="$(dirname $0)/${_SCRIPT_LIB_NAME}"

  if [ ! -f $script_lib ]; then
    echo "ERROR: could not locate OSA script library"
    exit 1
  fi

  OSA="osascript ${_OSA_OPTS} ${script_lib}"

  # populate the cache if it does not exist
  [ ! -f $datafile ] && echo $($OSA get) \
    | sed -e 's/,/\n/g' -e 's/ /-/g' \
    | tr "[:upper:]" "[:lower:]" > $datafile

  cat $datafile
}

alias ${_PROFILE_CMD:-profile}='_profile 2>&1'
_profile
