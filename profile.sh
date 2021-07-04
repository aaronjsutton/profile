# Copyright (c) 2021 Aaron Joseph Sutton. Licensed under the WTFPL license, version 2.

# manage macOS Terminal.app profiles
# 
# INSTALL: #   * add the following to your .bashrc/.zshrc:
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
  
  current=$($OSA get | tr "[:upper:]" "[:lower:]")

  # populate the datafile cache if it does not exist
  [ ! -f $datafile ] && echo $(${OSA} available) \
    | sed -e 's/,/\n/g' -e 's/ /-/g' \
    | tr "[:upper:]" "[:lower:]" \
    | sed -e "s/\(${current}\)/*\1/" > $datafile
   
  while [ "$1" ]; do case "$1" in
    -h|--help)
      echo "${_PROFILE_CMD:-profile} [-lsx] <name>" >&2; return;;
    -x)
      [ -f $datafile ] && rm $datafile; return;;
    *) 
      cat $datafile | grep "^*" | cut -c2-
      break
  esac; [ "$#" -gt 0 ] && shift; done
  
}

alias ${_PROFILE_CMD:-profile}='_profile 2>&1'
