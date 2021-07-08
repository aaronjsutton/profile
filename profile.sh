# Copyright (c) 2021 Aaron Joseph Sutton. Licensed under the WTFPL license, version 2.
# shellcheck disable=SC3030
#
# manage macOS Terminal.app profiles

[ -d "${_PROFILE_DATA:-$HOME/.term_profiles}" ] && {
  echo "ERROR: profile datafile is a directory."
}

_OSA_LANG="JavaScript"
_SCRIPT_LIB_NAME="Profile.scpt"

_profile() {
  datafile="${_PROFILE_DATA:-$HOME/.term_profiles}" 

  # populate the datafile cache if it does not exist
  if [ ! -f "$datafile" ]; then _gen_profile_cache > "$datafile"; fi;
   
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
  _current_profile | cut -d':' -f1
}

_current_profile() {
  grep "^\*.*" < "$datafile" | cut -c2-
}

__profile_mark() {
  sed -i '.bak' 's/^*//' "$datafile"
  sed -i '.bak' -re "s/($1)/*\1/" "$datafile"
}

_set_profile() {
  # using br to do floating point division was rather slow, so the interpolation
  # values are hard-coded.
  local _t_vals=(0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95)

  local profile=$(echo "$1" | sed 's/-/ /')

  [ "$profile" = "$(_current_profile | cut -d':' -f1)" ] && return;
 
  if [ "$_PROFILE_NOFADE" -eq "0" ]; then
    # get initial and end text/background values
    local b0=$(_current_profile | cut -d':' -f2)
    local b1=$(_osa_exec settings "$profile" "backgroundColor" | sed 's/ //g')
    local f0=$(_current_profile | cut -d':' -f3)
    local f1=$(_osa_exec settings "$profile" "normalTextColor" | sed 's/ //g')

    _osa_exec text "$(__profile_lerp3 "$f0" "$f1" 0.5)"

    for t in "${_t_vals[@]}"; do 
      _osa_exec background "$(__profile_lerp3 "$b0" "$b1" "$t")"
    done
  fi

  _osa_exec "profile" "$profile"
  __profile_mark "$profile"
}

# poor man's linear interpolation, used to fade
# comma-separated vectors.
__profile_lerp3() {
  for i in $(seq 1 3); do
    local v0=$(echo "$1" | cut -d',' "-f$i")
    local v1=$(echo "$2" | cut -d',' "-f$i")
    echo $(( (1 - $3) * v0 + $3 * v1))
  done
}

_osa_exec () {
  osascript -l "$_OSA_LANG" "$_PROFILE_SCRIPT_LIBRARY" "$@"
}

_gen_profile_cache () {
    echo "Generating profile cache, this may take a few seconds" >&2
    current=$(_osa_exec profile | tr '[:upper:]' '[:lower:]')

    all=$(_osa_exec settings | sed -e 's/,/\n/g')

    echo "$all" | while read -r line; do
      name=$(echo "$line" \
      | sed -e 's/ /-/g' \
      | tr "[:upper:]" "[:lower:]")

      colors=$(echo "$(_osa_exec settings "$line" backgroundColor):$(_osa_exec settings "$line" normalTextColor)" | sed 's/ //g')
      echo "$name:$colors"

    done
    __profile_mark "$current"
}

# locate the JXA script file
_PROFILE_SCRIPT_LIBRARY=${_PROFILE_SCRIPT_PATH:-"$(realpath "$(dirname "$0")/$_SCRIPT_LIB_NAME")"}
if [ ! -f "$_PROFILE_SCRIPT_LIBRARY" ]; then
  >&2 echo "ERROR: could not locate profile OSA script library"
  return 1
fi
export _PROFILE_SCRIPT_LIBRARY;

# expansion intended for this alias
alias "${_PROFILE_CMD:-profile}"='_profile 2>&1'
