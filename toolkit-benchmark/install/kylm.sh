#!/bin/bash
#
# Kylm / Kyoto Language Modeling Toolkit (0.0.7)
# Project Page: http://www.phontron.com/kylm/
#
# Usage via Java executable.
#
# Will be located in: local directory
#
# Dependencies:
# * Java - at runtime (OpenJDK 7 JRE via package manager)
#
# NOTE:
# This script doesn't require admin rights and it's not recommended to execute with admin rights, e.g. via sudo.
#

# basic functions
source installer.sh

# resolve dependencies
## Java
if getCommandPath java; then
  echo 'Java seems missing on your system. You need Java to run the Kylm.'
  echo 'Would you like to install Java now? Note: This will install the OpenJDK 7 JRE.'
  while true; do
    read -p "Would you like to install Java now? [y/n]" yn
    case $yn in
      [Yy] ) installPackages openjdk-7-jre; break;;
      [Nn] ) echo 'Please install Java manually, to use the Kylm, if you haven'"'"'t already.'; break;;
      * ) echo 'Please answer y (yes) or n (no).';;
    esac
  done
fi

# Kylm
KYLM=kylm-0.0.7
KYLM_JAR=${KYLM}.jar
## download
if [ ! -f ${KYLM_JAR} ] && [ ! -f ${KYLM}/${KYLM_JAR} ]; then
  wget http://www.phontron.com/kylm/download/kylm-0.0.7.jar
fi
if [ ! -d ${KYLM} ]; then
  mkdir ${KYLM}
  mv ${KYLM_JAR} ${KYLM}/
fi
echo 'KYLM is ready for usage.'

