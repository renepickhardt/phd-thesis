#!/bin/bash
# ULMA installer
# Installation wizard for language model toolkits supported by ULMA.
#

# Returns the absolute path to the current directory.
function getCurrentDir {
  echo $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
}

# Escapes slashes for the usage in sed.
function escapeSlashes {
  sed 's/\//\\\//g'
}

# Checks if a command is available.
function checkCommand {
  CMD_PATH=$( which "$1" )
  if [ "$CMD_PATH" == "" ]; then
    return 1
  fi
  return 0
}

# Checks if a package is installed.
function checkPackage {
  PCKG_INSTALLED=$( dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed" 2>/dev/null )
  if [ -n "${PCKG_INSTALLED}" ]; then
    return 0
  fi
  return 1
}

# Installs a package if it's missing.
function requirePackage {
  if ! checkPackage "$1"; then
    echo 'Package '"'$1'"' is missing and will be installed now.'
    sudo apt-get install "$1"
    SUCCESS=$?
    if [ "$SUCCESS" -ne 0 ]; then
      echo 'Failed to install package '"'$1'! Please install the package manually and try again."
    fi
    return "$SUCCESS"
  fi
  return 0
}

# Sets an environment variable permanently.
function setEnvVar {
  echo 'export '"$1" >> ~/.profile
}

# Asks the user to accept the license of a toolkit.
# The choice of the user will be returned as a boolean value.
#
# Usage: acceptLicense application license_title license_url
function acceptLicense {
  cmd=(dialog --title "$1"' license agreement' --no-tags --radiolist 'By selecting '"'Yes'"' you accept the license of '"$1"' ('"$2"').
You can find a copy of this license at '"$3"'

If you reject the license, the installation of '"$1"' will be aborted.' 22 76 16)
  options=(
    0 Yes off
    1 No off
  )
  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
  if [ "$choice" -ne "0" ]; then
    echo "You aborted the installation of $1 by rejecting its license."
  fi
  return $choice
}

# we need dialog for the GUI
if ! requirePackage dialog; then
  exit 9
fi

cmd=(dialog --title 'ULMA installation wizard' --separate-output --checklist "Select the toolkits you want to install:" 22 76 16)
options=(
  1 "SRILM" on
  2 "Kylm" on
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

# collect license aggreement
for choice in $choices
do
  case $choice in
    1)
      # SRILM
      source srilm-installer.sh
      install_srilm
      ;;
    2)
      # Kylm
      source kylm-installer.sh
      install_kylm
      ;;
  esac
done

