#!/bin/bash

execInTermH () {
  "$1" -e bash -c '
  echo "#######################################################";
  echo "################# Arch Update Checker #################";
  echo "######################################## by dhruv8sh ##";
  '"$2"'
  echo "#######################################################";
  echo "#################### Process Ended ####################";
  echo "#######################################################";
  read -p "                 Press Any Key to Exit...              ";'
}

execInTerm () {
  "$1" -e bash -c '
  echo "#######################################################";
  echo "################# Arch Update Checker #################";
  echo "######################################## by dhruv8sh ##";
  '"$2"'
  echo "#######################################################";
  echo "#################### Process Ended ####################";
  echo "#######################################################";'
}

# 1        2      3         4          5          6        7
# terminal toHold usePacman aurWrapper useFlatpak aurFlags flatpakFlags
action_updateSystem() {
  if [ "$3" = true ]; then
    command="sudo pacman -Syu $6; "
  else
    command="pamac upgrade;"
  fi
  if [ -z "$3" ]; then
    command="$command $3 -Syu; $6"
  fi
  if [ "$5" = true ]; then
    command="$command flatpak update $7;"
  fi
  if [ "$2" = true ]; then
    execInTermH "$1" "$command"
  else
    execInTerm "$1" "$command"
  fi
}

action_clearOrphans() {
  if [ "$2" = true ]; then
    command="sudo pacman -Rns $(pacman -Qtdq);"
  else
    command="pamac remove -o;"
  fi
  if [ "$1" = true ]; then
    execInTermH "$3" "$command"
  else
    execInTerm "$3" "$command"
  fi
}
action_showInfo() {

  execInTermH
}
action_installOne() {}
action_uninstall() {}
notification_install() {}
