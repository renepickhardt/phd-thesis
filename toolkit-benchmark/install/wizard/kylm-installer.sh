#!/bin/bash
#
# Note: This script is not intended to be executed directly.
# It is part of the installation wizard of ULMA.
# Please don't run this script directly, but run the installation wizard instead.
#
# ULMA (unified language model API) supports various tools and toolkits and provides one single API to use any of them.
#
# Authors:
# Sebastian Schlicht (sebastian@jablab.de)
#

# Installs Kylm and its dependencies.
#
# # Kyoto Language Modeling Toolkit (Kylm) 0.0.7
# http://www.phontron.com/kylm/
#
# ## Installation target
# './kylm-0.0.7/' which is stored in `$KYLM`
# Executable JAR will be found in '.'
#
# ## Dependencies
# * Java JRE (via apt)
#
function install_srilm {
  # license agreement
  if ! acceptLicense 'Kylm' 'GNU GPL v3.0' 'http://www.gnu.org/licenses/lgpl-3.0.txt'; then
    return 1
  fi
  
  # download
  KYLM_DIR='kylm-0.0.7'
  KYLM_FILE="$KYLM_DIR"'.jar'
  if [ ! -f $KYLM_FILE ] && [ ! -f "$KYLM_DIR"/"$KYLM_FILE" ]; then
    wget 'http://www.phontron.com/kylm/download/kylm-0.0.7.jar'
    SUCCESS=$?
    
    if [ "$SUCCESS" -ne "0" ]; then
      echo 'Failed to download Kylm!'
      return 2
    fi
    echo 'Download completed.'
  fi
  
  # install dependencies
  if ! checkCommand java; then
    echo "The installation wizard couldn't find Java on this computer."
    echo 'You will need Java in order to use Kylm.'
    echo 'The wizard can install the OpenJDK 7 JRE for you.'
    while true; do
      read -p "Would you like to install Java now? [y/n]" yn
      case $yn in
        [Yy]|Yes|yes ) requirePackage openjdk-7-jre; break;;
        [Nn]|No|no ) echo 'Please install Java manually, if you want to use the Kylm.'; break;;
        * ) echo 'Please answer y (yes) or n (no).';;
      esac
    done
  fi
  
  # install
  if [ ! -d $KYLM_DIR ]; then
    mkdir "$KYLM_DIR"
  fi
  mv "$KYLM_FILE" "$KYLM_DIR"/
  echo 'Kylm was installed successfully.'
}

