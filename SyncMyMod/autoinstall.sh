#!/bin/sh
#####################################################################################################################################################################
#															Installation Script for AA/CP Widget Mod 																#
#####################################################################################################################################################################
#																																									#
#                                                                                                                                                               	#
#  	              AAA                                TTTTTTTTTTTTTTTTTTTTTTTEEEEEEEEEEEEEEEEEEEEEE               AAA               MMMMMMMM               MMMMMMMM  #
#  	             A:::A                               T:::::::::::::::::::::TE::::::::::::::::::::E              A:::A              M:::::::M             M:::::::M  #
#  	            A:::::A                              T:::::::::::::::::::::TE::::::::::::::::::::E             A:::::A             M::::::::M           M::::::::M  #
#  	           A:::::::A                             T:::::TT:::::::TT:::::TEE::::::EEEEEEEEE::::E            A:::::::A            M:::::::::M         M:::::::::M  #
#  	          A:::::::::A                            TTTTTT  T:::::T  TTTTTT  E:::::E       EEEEEE           A:::::::::A           M::::::::::M       M::::::::::M  #
#  	         A:::::A:::::A                                   T:::::T          E:::::E                       A:::::A:::::A          M:::::::::::M     M:::::::::::M  #
#  	        A:::::A A:::::A                                  T:::::T          E::::::EEEEEEEEEE            A:::::A A:::::A         M:::::::M::::M   M::::M:::::::M  #
#  	       A:::::A   A:::::A         ---------------         T:::::T          E:::::::::::::::E           A:::::A   A:::::A        M::::::M M::::M M::::M M::::::M  #
#  	      A:::::A     A:::::A        -:::::::::::::-         T:::::T          E:::::::::::::::E          A:::::A     A:::::A       M::::::M  M::::M::::M  M::::::M  #
#		 A:::::AAAAAAAAA:::::A       ---------------         T:::::T          E::::::EEEEEEEEEE         A:::::AAAAAAAAA:::::A      M::::::M   M:::::::M   M::::::M  #
#		A:::::::::::::::::::::A                              T:::::T          E:::::E                  A:::::::::::::::::::::A     M::::::M    M:::::M    M::::::M  #
#	   A:::::AAAAAAAAAAAAA:::::A                             T:::::T          E:::::E       EEEEEE    A:::::AAAAAAAAAAAAA:::::A    M::::::M     MMMMM     M::::::M  #
#	  A:::::A             A:::::A                          TT:::::::TT      EE::::::EEEEEEEE:::::E   A:::::A             A:::::A   M::::::M               M::::::M  #
#	 A:::::A               A:::::A                         T:::::::::T      E::::::::::::::::::::E  A:::::A               A:::::A  M::::::M               M::::::M  #
#	A:::::A                 A:::::A                        T:::::::::T      E::::::::::::::::::::E A:::::A                 A:::::A M::::::M               M::::::M  #
#  AAAAAAA                   AAAAAAA                       TTTTTTTTTTT      EEEEEEEEEEEEEEEEEEEEEEAAAAAAA                   AAAAAAAMMMMMMMM               MMMMMMMM  #
#																																									#
#####################################################################################################################################################################

# Mod Name      : AA/CP Widget Mod  
# Author        : YuriB (Moded by XroM)
# Creation date : 2024-06-03 
# Version       : 1.1

#####################################################################################################################################################################
#   Environment variables                                                                                                                               
#####################################################################################################################################################################

FILES_DIR="/fs/usb0/SyncMyMod/files"
PATCH_DIR="${FILES_DIR}/patch"
OTHER_DIR="${FILES_DIR}/other"

# Minimum Sync 3 compatible version
SYNC3_MIN_BUILD="3.4.22048"

# Mod Tools string
MODTOOLS="MODS_TOOLS"

# This Mod Name
MODNAME="AACP_WIDGET_MOD_1_1"

# Dependencies MODS_SETTINGS
DEPENDENCY="RVC_ON_DEMAND"


#####################################################################################################################################################################
#   Functions                                                                                                                                           
#####################################################################################################################################################################

POPUP=/tmp/popup.txt
echo "" > $POPUP

function displayMessage {
    echo "${1}" >> $POPUP
    /fs/rwdata/dev/utserviceutility popup $POPUP
}

function reboot {
    /fs/rwdata/dev/utserviceutility reboot
}

function displayImage {
	slay APP_SUM
	slay -s 9 NAV_Manager
	slay -s 9 fordhmi
	slay HMI_AL
	display_image -file=/fs/usb0/SyncMyMod/installation_${1}.png -display=2 &

	while [ -e /fs/usb0 ]; do
		sleep 1
	done

	reboot

	exit 0
}

#####################################################################################################################################################################
#   Check if Mods Tools are installed                                                                                                                   
#####################################################################################################################################################################

grep -q ${MODTOOLS} /fs/rwdata/dev/mods_tools.txt
if [ $? -ne 0 ]; then
    displayImage "aborted"
fi
chmod a+x /fs/rwdata/dev/*

#####################################################################################################################################################################
#	Remount FS as RW																																	
#####################################################################################################################################################################

. /fs/rwdata/dev/remount_rw.sh
sleep 1

#####################################################################################################################################################################
#	Check if mod is already installed																													
#####################################################################################################################################################################

grep -q ${MODNAME} /fs/mp/etc/installed_mods.txt
if [ $? -eq 0 ]; then
   	displayMessage "This mod is already installed in your Sync 3."
   	displayMessage "Remove USB drive to reboot."

	sleep 1
	. /fs/rwdata/dev/remount_ro.sh
	sync
	sync
	sync
	while [ -e /fs/usb0 ]; do
		sleep 1
	done

	reboot

	exit 0
fi

#####################################################################################################################################################################
#   Check if DEPENDENCY is installed                                                                                                              	
#####################################################################################################################################################################

grep -q ${DEPENDENCY} /fs/mp/etc/installed_mods.txt
if [ $? -ne 0 ]; then
	displayMessage "RVC_ON_DEMAND mod not found. Installation aborted."
	displayMessage "This version of AA/CP Widget Mod REQUIRES the RVC_ON_DEMAND mod to be installed. Please install it before retrying."
	displayMessage ""
	
	exit 0
fi


#####################################################################################################################################################################
#   Check if patch can be applied safely                                                                                                                
#####################################################################################################################################################################

/fs/rwdata/dev/patch --ignore-whitespace --dry-run -p0 < ${PATCH_DIR}/master.patch > /fs/usb0/patch.log
if [ "$?" != "0" ]; then
    displayMessage "Patch cannot be applied!"
	displayMessage "Possible reasons are that your Sync version is not supported (this mod supports Sync 3 Build ${SYNC3_MIN_BUILD} or higher!) or there is a mod conflict"
	displayMessage "Try updating your Sync to the latest version."

    exit 0
fi

#####################################################################################################################################################################
#   Apply Patch, Settings File and Entry, add Mod entry                                               				                                                 
#####################################################################################################################################################################

/fs/rwdata/dev/patch --ignore-whitespace -b -p0 < ${PATCH_DIR}/master.patch

# Creating new folders
mkdir -p /fs/rwdata/customSettings/ProjectionWidget

cp ${OTHER_DIR}/cameraPosX	/fs/rwdata/customSettings/ProjectionWidget
cp ${OTHER_DIR}/cameraPosY	/fs/rwdata/customSettings/ProjectionWidget
cp ${OTHER_DIR}/tempPosX	/fs/rwdata/customSettings/ProjectionWidget
cp ${OTHER_DIR}/tempPosY	/fs/rwdata/customSettings/ProjectionWidget

echo ${MODNAME} >> /fs/mp/etc/installed_mods.txt


#####################################################################################################################################################################
#   Remount FS as RO                                                                               			                                                        
#####################################################################################################################################################################

sleep 1
. /fs/rwdata/dev/remount_ro.sh
sync
sync
sync

#####################################################################################################################################################################
#   Display success image and reboot                                                  			                                                                    
#####################################################################################################################################################################

displayImage "completed"