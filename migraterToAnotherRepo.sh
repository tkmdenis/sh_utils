#! /bin/bash

echo "The goal of this script is to transfert all the git data (files, folders, branches, tags, history,...) from a git repository to another git repository"
echo "if you encounter problem, please refer to @Denis_Tadie (denis.tuekam@gmail.com)"

ddebut=$(date +"%s")

#---------------------------------------------------------------------------------
#You need to change this data to set project migration folder
MIGRATION_FOLDER=""

#---------------------------------------------------------------------------------
#You need to change this data to set source repository
SRC_REPO_BASE="https://github.com"
SRC_PROJECT_NAME="LeonidasTKM"
SRC_GIT_NAME="sh_utils"
SRC_FOLDER="source"

#---------------------------------------------------------------------------------
#You need to change this data to set destination repository
DEST_REPO_BASE="https://github.com/"
DEST_PROJECT_NAME="LeonidasTKM"
DEST_GIT_NAME="sh_utils"
DEST_BACKUP_FOLDER="destination_backup"
DEST_FOLDER="destination"

#-------------------------------------------------------------------------------
# calcul of script duration
function fEnding {
   ddebut=$1

   dfin=$(date +"%s")
   duree=$(($dfin - $ddebut))
   sec=$(($duree % 60))
   if [ $sec -lt 10 ]; then
      sec="0${sec}"
   fi
   min=$((($duree /60) % 60))
   if [ $min -lt 10 ]; then
      min="0${min}"
   fi
   heure=$((($duree /3600) % 24))
   if [ $heure -lt 10 ]; then
      heure="0${heure}"
   fi
   j=$(($duree /(3600*24)))

   if [ $j -gt 0 ]; then
      echo " Duration  : ${j}j ${heure}:${min}:${sec}  "
   else
      echo " Duration  : ${heure}:${min}:${sec}  "
   fi
   echo "Program ended $(date "+%Y/%m/%d %T")"
   echo "===================================="
   exit
   }

migrate(){

    #Delete previous migration folder if exist
	echo "Deleting previous migration folder..."
	rm -rf ${MIGRATION_FOLDER}

    #Create a folder for migration
    mkdir ${MIGRATION_FOLDER}
    cd ${MIGRATION_FOLDER}

    #Save in your workspace the bootstrap of the destination repository
    mkdir ${DEST_BACKUP_FOLDER}
    git clone "${DEST_REPO_BASE}/${DEST_PROJECT_NAME}/${DEST_GIT_NAME}.git" ${DEST_BACKUP_FOLDER}

    #Create destination repository
    mkdir ${DEST_FOLDER}
    git clone "${DEST_REPO_BASE}/${DEST_PROJECT_NAME}/${DEST_GIT_NAME}.git" ${DEST_FOLDER}
    pushd ${DEST_FOLDER}
	pushd ${DEST_GIT_NAME}
    git revert -m HEAD
    # save and exit when ask to complete merge message
    git push

    #Go back to migration folder
    popd
	popd
    echo "Present folder: $(pwd)"

    #Create a bare clone of the source repository
    mkdir ${SRC_FOLDER}
    git clone --bare "${SRC_REPO_BASE}/${SRC_PROJECT_NAME}/${SRC_GIT_NAME}.git" ${SRC_FOLDER}

    #Mirror-push to the new repository.
	pushd ${SRC_FOLDER}
    git push --mirror "${DEST_REPO_BASE}/${DEST_PROJECT_NAME}/${DEST_GIT_NAME}.git"
	popd

    #Remove the temporary local repository
    cd ${DEST_FOLDER}
    rm -rf ${SRC_GIT_NAME}
}

migrate

fEnding $ddebut
