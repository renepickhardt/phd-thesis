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

# Installs SRILM and its dependencies
#
# # SRILM 1.7.1
# http://www.speech.sri.com/projects/srilm/
#
# ## Installation target
# './srilm-1.7.1/' which is stored in `$SRILM`
# Binaries will be found in './bin/<architecture>/'
#
# ## Dependencies
# * g++ 3.4.3+ (via apt)
# * make (via apt)
# 
function install_srilm {
  # license agreement
  if ! acceptLicense 'SRILM' 'http://www.speech.sri.com/projects/srilm/docs/License'; then
    return 1
  fi
  
  # download
  SRILM_DIR='srilm-1.7.1'
  SRILM_FILE=$SRILM_DIR'.tar.gz'
  SRILM_FILE_SIZE="65498380"
  if [ ! -f $SRILM_FILE ]; then
    # collect user data for download form
    echo 'In order to use SRILM SRI requests you to provide some information.'
    echo 'The wizard will forward the information to SRI and download SRILM for you.'
    echo
    ## name
    read -p 'Name: ' NAME
    ## organization
    read -p 'Organization: ' ORGANIZATION
    ## address
    read -p 'Address: ' ADDRESS
    ## email
    read -p 'eMail-Address: ' EMAIL
    ## website (optional)
    read -p 'Website (optional): ' WEBSITE
    ## receive updates per mail
    while true; do
      read -p 'Do you want to retrieve updates per eMail? ' yn
      case $yn in
        [Yy]*) RECUP=true;;
        [Nn]*) RECUP=false;;
        *)
          echo 'Invalid choice. Please answer with yes or no.'
          continue
          ;;
      esac
      break
    done
  
    echo 'Please wait while the wizard downloads your copy of SRILM.'
    wget --post-data="$POST_DATA" 'http://www.speech.sri.com/projects/srilm/srilm_download.php' -O $SRILM_FILE
    SUCCESS=$?
    # TODO: -sS
    #curl -X POST -o srilm-1.7.1.tar.gz -F 'WWW_file=srilm-1.7.1.tar.gz' -F "WWW_name=$NAME" -F "WWW_org=$ORGANIZATION" -F "WWW_address=$ADDRESS" -F "WWW_email=$EMAIL" -F "WWW_url=$WEBSITE" -F "WWW_list=$RECUP" 'http://www.speech.sri.com/projects/srilm/srilm_download.php'
    
    if [ "$SUCCESS" -ne 0 ]; then
      echo 'Failed to download SRILM!'
      return 2
    fi
    echo 'Download completed.'
  fi
  # verify download
  FILE_SIZE=$(wc -c <"$SRILM_FILE")
  if [ ! -f "$SRILM_FILE" -o "$FILE_SIZE" -ne "$SRILM_FILE_SIZE" ]; then
    echo 'The installation file is corrupt.'
    echo 'Please download SRILM manually from http://www.speech.sri.com/projects/srilm/download.html'
    return 3
  fi
  
  # install dependencies
  requirePackage g++
  requirePackage make
  
  # extract
  if [ ! -d $SRILM_DIR ]; then
    # SRILM is a flat archive, we have to create the target directory on our own
    mkdir $SRILM_DIR
    cd $SRILM_DIR
    tar -xf ../$SRILM_FILE
    if [ $? -ne 0 ]; then
      echo 'Failed to extract SRILM!'
      return 4
    fi
    echo 'SRILM was extracted successfully.'
    cd ..
  fi
  
  # install
  ## prepare
  ### set SRILM variable in Makefile (point at SRILM directory)
  DIR=$( getCurrentDir )
  MAKEFILE_SRILM=$( echo "SRILM = ${DIR}/${SRILM_DIR}" | escapeSlashes )
  cd ${SRILM_DIR}
  sed -i "s/^# SRILM =.*/${MAKEFILE_SRILM}/" Makefile
  cd ..
  ## compile
  cd ${SRILM_DIR}
  make && make cleanest
  SUCCESS=$?
  cd ..
  
  if [ $SUCCESS ]; then
    # export installation directory to environment variable
    #setEnvVar 'SRILM="'"$SRILM_DIR"'"'
    echo 'SRILM was installed successfully.'
  fi
  return $SUCCESS
}

