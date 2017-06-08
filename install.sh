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







# It's very important to change that if needed: You must put your accessible web root-directory - Example: on Debian/Centos7 it's /var/www/html



# ./ **** DEFAULT VALUES YOU CAN MODIFY THESE DEFAULT VALUES



# Password is created here
wPass="`date +%s|sha256sum|base64|head -c 8`"

# IF NO ARGUMENTS SUPPPLIEDS VIA THE COMMAND LINE WE ASK USER FOR SOME CONFIG VALUES
if [ $# -eq 0 ]
  then
    echo
    echo "ENTERING CUSTOM CONFIGURATION"
    echo
    # ASKING WEB ROOT DIRECTORY
    echo "Enter your web root directory (example: /var/www/html)"
    read wRoot
    echo
    # ASKING FOLDER NAME
    echo "ENTER YOUR DESIRED NAME FOLDER FOR THE INSTALL"
    read foldername
    echo
    echo "---------- DATABASE CONFIG -----------"
    # ASKING DATABASE NAME
    echo "DATABASE NAME"
    read bddname
    echo
    # ASKING DATABASE USER
    echo "DATABASE USER"
    read bdduser
    echo
    # ASKING DATABASE PASSWORD
    echo "DATABASE PASSWORD"
    read bddpass
    echo
    echo "---------- WORDPRESS CONFIG -----------"
    # ASKING Wordpress USER
    echo "Enter the desired user for the wordpress login"
    read wUser
    echo
    # ASKING Wordpress EMAIL
    echo "Enter the desired email for the wordpress install"
    read wEmail
    echo
    echo
    echo "     Password will be generated at the end of this script ;)"
    echo
    sleep 2
    echo "     BEGIN INSTALL IN:"
    sleep 2
    echo "     3"
    sleep 1
    echo "      2"
    sleep 1
    echo "        1"
    sleep 1

else
    wUser="user"
    wEmail="changeme@changeme.com"
    wRoot="/var/www/html"

    foldername=$1
    bddname=$2
    bdduser=$3
    bddpass=$4
fi

# DON'T TOUCH ;)

# We get the local IP of the machine running this script
localip=`ifconfig|xargs|awk '{print $7}'|sed -e 's/[a-z]*:/''/'`

# ----------- STEP 2 ++ CREATING DIRECTORIES ++  GET THE ARGUMENT FROM THE COMMAND LINE (SEE README.MD -> USAGE)

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

# ADD THE SALT VALUES TO CONFIG.PHP
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' $wRoot/$foldername/wp-config.php

# REMOVE OPTIONALS PLUGINS
rm -rf $wRoot/$foldername/wp-content/plugins/hello.php
rm -rf $wRoot/$foldername/wp-content/plugins/akismet



# FINISH INSTALL
curl --silent --data "user_name=$wUser&admin_password=$wPass&admin_password2=$wPass&admin_email=$wEmail&blog_public=unchecked&Submit=submit" "http://$localip/$foldername/wp-admin/install.php?step=2" > /dev/null


#CLEAN THE SCREEN Yo
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
