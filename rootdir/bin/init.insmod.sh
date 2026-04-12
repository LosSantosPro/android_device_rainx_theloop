#!/vendor/bin/sh

########################################################
### init.insmod.cfg format:                          ###
### -----------------------------------------------  ###
### [insmod|setprop|enable/moprobe] [path|prop name] ###
### ...                                              ###
########################################################

log_msg() {
  echo "init.insmod: $1" > /dev/kmsg
}

if [ $# -eq 1 ]; then
  cfg_file=$1
else
  log_msg "ERROR: no cfg file argument"
  exit 1
fi

# Module loader: invokes real modprobe so that modules.dep is honored
# and inter-module dependencies are resolved in the correct order.
load_modules_modprobe() {
  modules_dir="$1"
  modules_load="${modules_dir}/modules.load"
  modules_dep="${modules_dir}/modules.dep"

  log_msg "load_modules_modprobe: dir=${modules_dir}"

  if [ ! -f "$modules_load" ]; then
    log_msg "ERROR: modules.load not found at ${modules_load}"
    return 1
  fi
  if [ ! -f "$modules_dep" ]; then
    log_msg "ERROR: modules.dep not found at ${modules_dep}"
    return 1
  fi

  # Build space-separated module name list from modules.load
  # (strip .ko suffix, skip blanks and comment lines)
  mods=$(awk '!/^[[:space:]]*#/ && NF { sub(/\.ko$/, ""); printf "%s ", $0 }' "$modules_load")
  if [ -z "$mods" ]; then
    log_msg "WARN: no modules listed in ${modules_load}"
    return 0
  fi

  /vendor/bin/modprobe -a -d "$modules_dir" $mods
  rc=$?
  log_msg "load_modules_modprobe: done, rc=${rc}"
  return $rc
}

log_msg "starting with cfg=${cfg_file}"

if [ -f $cfg_file ]; then
  while IFS="|" read -r action arg
  do
    case $action in
      "insmod") insmod $arg ;;
      "setprop")
        times=1
        setprop $arg 1
        while [ "$?" -ne 0 ]
        do
          if [ $times -gt 128 ]; then
            break
          fi
          let times++
          setprop $arg 1
        done ;;
      "enable") echo 1 > $arg ;;
      "modprobe")
        log_msg "modprobe action triggered"
        for partition in system_dlkm vendor
        do
          modules_dir_base="/${partition}/lib/modules"
          for modules_dir in ${modules_dir_base}/*/ ${modules_dir_base}
          do
            if [ ! -f "${modules_dir}/modules.load" ]; then
              continue
            fi
            log_msg "found modules.load in ${modules_dir}"
            load_modules_modprobe "${modules_dir}"
          done
        done
        log_msg "modprobe action complete"
    esac
  done < $cfg_file
  log_msg "cfg file processing complete"
else
  log_msg "ERROR: cfg file not found: ${cfg_file}"
  exit 2
fi
