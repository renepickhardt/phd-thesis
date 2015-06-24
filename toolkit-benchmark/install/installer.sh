#!/bin/bash
#
# Basic script for language model installations.
# Please use the specific installers to install the language models.
#
# Note: All installation scripts start from a clean Debian Wheezy 8.1.0 (XFCE) system.
#

function getCurrentDir {
  echo $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
}

# Escapes slashes for usage in sed.
function escape_slashes {
    sed 's/\//\\\//g' 
}

# Checks if a package is installed.
function checkPackage {
  PCKG_INSTALLED=$( dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed" 2>/dev/null )
  if [ -n "${PCKG_INSTALLED}" ]; then
    return 0
  fi
  return 1
}

# Installs any number of packages.
function installPackages {
  apt-get install $1
}

# Installs Boost to a local repository to avoid conflicts with previous installations.
function getBoost {
  if [ ! -d boost_1_58_0 ]; then
    echo 'Downloading Boost...'
    wget http://cznic.dl.sourceforge.net/project/boost/boost/1.58.0/boost_1_58_0.tar.gz
    tar -xf boost_1_58_0.tar.gz
    echo 'Boost extracted.'
    cd boost_1_58_0
    ./bootstrap.sh
    #./b2 install
    cd ..
    echo 'Boost is ready for usage.'
  fi
}

# gzip
if ! checkPackage gzip; then
  installPackages gzip
fi

