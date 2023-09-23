#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

clear

installTheme(){
    cd /var/www/
    tar -cvf Backup.tar.gz pterodactyl
    echo "Installing theme..."
    cd /var/www/pterodactyl
    rm -r pterotheme
    git clone https://github.com/Joshet18/pterotheme.git
    cd pterotheme
    rm /var/www/pterodactyl/resources/scripts/NightFallTheme.css
    rm /var/www/pterodactyl/resources/scripts/index.tsx
    rm /var/www/pterodactyl/public/favicons/favicon.ico
    rm /var/www/pterodactyl/public/favicons/apple-touch-icon.png
    rm /var/www/pterodactyl/public/favicons/favicon-16x16.png
    rm /var/www/pterodactyl/public/favicons/favicon-32x32.png
    rm /var/www/pterodactyl/public/favicons/favicon-96x96.png
    mv index.tsx /var/www/pterodactyl/resources/scripts/index.tsx
    mv NightFallTheme.css /var/www/pterodactyl/resources/scripts/NightFallTheme.css
    mv favicon.ico /var/www/pterodactyl/public/favicons/favicon.ico
    mv apple-touch-icon.png /var/www/pterodactyl/public/favicons/apple-touch-icon.png
    mv favicon-16x16.png /var/www/pterodactyl/public/favicons/favicon-16x16.png
    mv favicon-32x32.png /var/www/pterodactyl/public/favicons/favicon-32x32.png
    mv favicon-96x96.png /var/www/pterodactyl/public/favicons/favicon-96x96.png
    cd /var/www/pterodactyl

    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    apt update
    apt install -y nodejs

    npm i -g yarn
    yarn

    cd /var/www/pterodactyl
    yarn build:production
    sudo php artisan optimize:clear


}

installThemeQuestion(){
    while true; do
        read -p "Are you sure that you want to install the theme [y/n]? " yn
        case $yn in
            [Yy]* ) installTheme; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

repair(){
    bash <(curl https://raw.githubusercontent.com/Joshet18/pterotheme/main/repair.sh)
}

restoreBackUp(){
    echo "Restoring backup..."
    cd /var/www/
    tar -xvf Backup.tar.gz
    rm Backup.tar.gz

    cd /var/www/pterodactyl
    yarn build:production
    sudo php artisan optimize:clear
}
echo "Pterodactyl Theme Installer"
echo ""
echo "[1] Install theme"
echo "[2] Restore backup"
echo "[3] Repair panel (use if you have an error in the theme installation)"
echo "[4] Exit"

read -p "Please enter a number: " choice
if [ $choice == "1" ]
    then
    installThemeQuestion
fi
if [ $choice == "2" ]
    then
    restoreBackUp
fi
if [ $choice == "3" ]
    then
    repair
fi
if [ $choice == "4" ]
    then
    exit
fi
