# Copyright (c) 2021 Aaron Joseph Sutton. Licensed under the WTFPL license, version 2.

# manage macOS Terminal.app profiles
# 
# INSTALL: #   * add the following to your .bashrc/.zshrc:
#       . /path/to/profile.sh

[ -d "${_PROFILE_DATA:-$HOME/.term_profiles}" ] && {
  echo "ERROR: profile datafile is a directory."
}

_OSA_LANG="JavaScript"
_SCRIPT_LIB_NAME="Profile.scpt"

_profile() {
  datafile="${_PROFILE_DATA:-$HOME/.term_profiles}" 

  # populate the datafile cache if it does not exist
  if [ ! -f "$datafile" ]; then
    current=$(_osa_exec profile | tr '[:upper:]' '[:lower:]')
    _osa_exec settings \
      # | sed -e "s/^([A-Za-z]+)$/\0 .../" \ <- TODO: sed stuff for stashing the color data also
    | sed -e 's/,/\n/g' -e 's/ /-/g' \
    | tr "[:upper:]" "[:lower:]" \
    | sed -e "s/\(${current}\)/*\1/" > "$datafile"
  fi;
   
  while [ "$1" ]; do case "$1" in
    -h|--help)
      echo "${_PROFILE_CMD:-profile} [-lsx] <name>" >&2; return;;
    -x)
      [ -f "$datafile" ] && rm "$datafile"; return;;
    -l) cat "$datafile"; return;;
    -s) shift; [ "$1" ] && _set_profile "$1"; return;;
    *) break
  esac; [ "$#" -gt 0 ] && shift; done
  # print the current profile if nothing left to do
  grep "^\*.*" < "$datafile" | cut -c2- 
}

_set_profile() {
  # TODO fade api
  _osa_exec "profile" "$1"
}

_osa_exec () {
  osascript -l "$_OSA_LANG" "$_PROFILE_SCRIPT_LIBRARY" "$@"
}

# locate the JXA script file
_PROFILE_SCRIPT_LIBRARY=${_PROFILE_SCRIPT_PATH:-"$(realpath "$(dirname "$0")/$_SCRIPT_LIB_NAME")"}
if [ ! -f "$_PROFILE_SCRIPT_LIBRARY" ]; then
  >&2 echo "ERROR: could not locate profile OSA script library"
  return 1
fi
export _PROFILE_SCRIPT_LIBRARY;

# expansion intended for this alias
# shellcheck disable=SC2139
alias "${_PROFILE_CMD:-profile}"='_profile 2>&1'
