# Copyright (c) 2021 Aaron Joseph Sutton. Licensed under the WTFPL license, version 2.
#
# list and change macOS Terminal.app profiles

[ -d "${_PROFILE_DATA:-$HOME/.term_profiles}" ] && {
  echo "ERROR: profile datafile is a directory."
}

__profile_osa_lang="JavaScript"
__profile_script_lib="Profile.scpt"

_profile() {
  __profile_datafile="${_PROFILE_DATA:-$HOME/.termprofiles}" 

  # populate the __profile_datafile cache if it does not exist
  if [ ! -f "$__profile_datafile" ]; then __profile_cache > "$__profile_datafile"; fi;
   
  while [ "$1" ]; do case "$1" in
    -h|--help)
      echo "${_PROFILE_CMD:-profile} [-lsx] <name>" >&2; return;;
    -x)
      [ -f "$__profile_datafile" ] && rm "$__profile_datafile"; return;;
    -l) cut -d':' -f1 < "$__profile_datafile"; return;;
    -s) shift; [ "$1" ] && __profile_set "$1"; return;;
    *) break
  esac; [ "$#" -gt 0 ] && shift; done
  # print the current profile if nothing left to do
  __profile_marked | cut -d':' -f1
}

__profile_marked() {
  grep "^\*.*" < "$__profile_datafile" | cut -c2-
}

__profile_mark() {
  sed -i '.bak' 's/^*//' "$__profile_datafile"
  sed -i '.bak' -re "s/($1)/*\1/" "$__profile_datafile"
}

__profile_set() {
  # using br to do floating point division was rather slow, so the interpolation
  # values are hard-coded.
  local _t_vals=(0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95)

  local profile=$(echo "$1" | sed 's/-/ /')

  [ "$profile" = "$(__profile_marked | cut -d':' -f1)" ] && return;
 
  if [ "$_PROFILE_NOFADE" -eq "0" ]; then
    # get initial and end text/background values
    local b0=$(__profile_marked | cut -d':' -f2)
    local b1=$(__profile_osa_exec settings "$profile" "backgroundColor" | sed 's/ //g')
    local f0=$(__profile_marked | cut -d':' -f3)
    local f1=$(__profile_osa_exec settings "$profile" "normalTextColor" | sed 's/ //g')

    __profile_osa_exec text "$(__profile_lerp3 "$f0" "$f1" 0.5)"

    for t in "${_t_vals[@]}"; do 
      __profile_osa_exec background "$(__profile_lerp3 "$b0" "$b1" "$t")"
    done
  fi

  __profile_osa_exec "profile" "$profile"
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

__profile_osa_exec () {
  osascript -l "$__profile_osa_lang" "$_PROFILE_SCRIPT_LIBRARY" "$@"
}

__profile_cache () {
    echo "Generating profile cache, this may take a few seconds" >&2
    local current=$(__profile_osa_exec profile | tr '[:upper:]' '[:lower:]')

    local all=$(__profile_osa_exec settings | sed -e 's/,/\n/g')

    echo "$all" | while read -r line; do
      local name=$(echo "$line" \
      | sed -e 's/ /-/g' \
      | tr "[:upper:]" "[:lower:]")

      local colors=$(echo "$(__profile_osa_exec settings "$line" backgroundColor):$(__profile_osa_exec settings "$line" normalTextColor)" | sed 's/ //g')
      echo "$name:$colors"

    done
    __profile_mark "$current"
}

# locate the JXA script file
_PROFILE_SCRIPT_LIBRARY=${_PROFILE_SCRIPT_PATH:-"$(realpath "$(dirname "$0")/$__profile_script_lib")"}
if [ ! -f "$_PROFILE_SCRIPT_LIBRARY" ]; then
  >&2 echo "ERROR: could not locate profile OSA script library"
  return 1
fi
export _PROFILE_SCRIPT_LIBRARY;

alias "${_PROFILE_CMD:-profile}"='_profile 2>&1'
