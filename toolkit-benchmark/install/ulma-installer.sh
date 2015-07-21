#!/bin/bash
# ULMA installer
# Installation wizard for language model toolkits supported by ULMA.
#

# Installs Boost 1.58 locally.
function installBoost {
  # TODO
  return 0
}

# Asks the user to accept the license of a toolkit.
# The choice of the user will be returned as a boolean value.
function acceptLicense {
  cmd=(dialog --title "$1"' license agreement' --no-tags --radiolist 'By selecting '"'"'Yes'"'"' you accept the license of '"$1"'.
You can find a copy of this license at '"$2"'

If you reject the license, the installation will be skipped.' 22 76 16)
  options=(
    0 Yes off
    1 No off
  )
  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
  return $choice
}

cmd=(dialog --title 'ULMA installation wizard' --separate-output --checklist "Select the toolkits you want to install:" 22 76 16)
options=(
  1 "SRILM" on
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

# collect license aggreement
for choice in $choices
do
  case $choice in
    1)
      if acceptLicense 'SRILM' 'http://www.speech.sri.com/projects/srilm/docs/License'; then
        # TODO install SRILM
        exit 0
      fi
      ;;
    2)
      # TODO
      exit 1
      ;;
  esac
done

