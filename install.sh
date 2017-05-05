#!/bin/bash


#
# SQI WORDPRESS - SUPER QUICK INSTALL WORDPRESS
# Version 0.1-alpha - 05-05-2017
# !!! Not for production use (Wait version 0.3 for production use)
# Author: Boris Tronquoy
#
# DESCRIPTION: This script use a command line to download/unzip/modify & install the latest wordpress release.
# FOR DOCUMENTATION USE THE README.MD FILE ;)





# ----------- STEP 1 ++  CONFIGURING ++  WE GET THE ARGUMENT FROM THE COMMAND LINE (SEE README.MD -> USAGE)



# YOU CAN MODIFY THERE VALUES

wUser="user"
wPass="`date +%s|sha256sum|base64|head -c 8`"
wEmail="changemeifyouwant@blablabla.com"

# It's very important to change that if needed: You must put your accessible web root-directory - Example: on Debian/Centos7 it's /var/www/html
wRoot="/var/www/html"


# DON'T TOUCH ;)

foldername=$1
bddname=$2
bdduser=$3
bddpass=$4

# We get the local IP of the machine running this script
localip=`ifconfig|xargs|awk '{print $7}'|sed -e 's/[a-z]*:/''/'`



# ----------- STEP 2 ++ CREATING DIRECTORIES ++  WE GET THE ARGUMENT FROM THE COMMAND LINE (SEE README.MD -> USAGE)

wget https://wordpress.org/latest.zip -P /var/tmp 
unzip /var/tmp/latest.zip -d /var/tmp 
mv /var/tmp/wordpress $wRoot/$foldername 
rm -fr /var/tmp/latest.zip

# ETAPE 3 - MODIFIFATION DU FICHIER WP-CONFIG-SAMPLE.PHP pour inserer nos valeurs

declare -A confs
confs=(
    [database_name_here]=$bddname
    [username_here]=$bdduser
    [password_here]=$bddpass
)

# BACKUP DU FICHIER WP-CONFIG-SAMPLE.PHP
cp $wRoot/$foldername/wp-config-sample.php $wRoot/$foldername/wp-config.php

configurer() {
    # Loop the config array
    for i in "${!confs[@]}"
    do
        search=$i
        replace=${confs[$i]}
        # Note the "" after -i, needed in OS X
        sed -i "s/${search}/${replace}/g" $wRoot/$foldername/wp-config.php
    done
}
configurer


#SUPPRIMER LES PLUGINS POUR FAIRE UNE CLEAN INSTALL
rm -rf $wRoot/$foldername/wp-content/plugins/hello.php
rm -rf $wRoot/$foldername/wp-content/plugins/akismet



#Configuration
curl --silent --data "user_name=$wUser&admin_password=$wPass&admin_password2=$wPass&admin_email=$wEmail&blog_public=unchecked&Submit=submit" "http://$localip/$foldername/wp-admin/install.php?step=2" > /dev/null


#ON NETTOIE LECRAN
clear

# ON MONTRE LES PARAMETRES
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "|                                                             |"
echo "|                                                             |"
echo "             CONGRATULATIONS :)                                "
echo "             YOUR NEW WORDPRESS INSTALL IS AVAILABLE           "
echo "             AT THIS URL: http://$localip/$foldername          "
echo "                                                               "
echo "             Connect with this credentials:                    "
echo "                USER: $wUser                                   "
echo "                PASSWORD: $wPass                               "
echo "                                                               "
echo "|                                                             |"
echo "|                                                             |"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
