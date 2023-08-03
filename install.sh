#!/bin/bash

green="\e[0;32m\033[1m"
white='\033[0;37m'
black='\033[0;30m'
clear='\033[0m'
red="\e[0;31m\033[1m"
purple="\e[0;35m\033[1m"
magenta='\033[0;35m'
cyan='\033[0;36m'
gray="\e[0;37m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

clear

installPanel(){
    echo "Installing panel.."
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
    curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
    apt update
    apt-add-repository universe
    apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/
    mysql -u root -p
}

installTheme(){
    cd /var/www/
    tar -cvf Backup.tar.gz pterodactyl
    echo "Installing theme..."
    cd /var/www/pterodactyl
    rm -r pterotheme
    git clone https://github.com/Joshet18/pterotheme.git
    cd pterotheme
    rm /var/www/pterodactyl/resources/scripts/MinecraftPurpleTheme.css
    rm /var/www/pterodactyl/resources/scripts/index.tsx
    rm /var/www/pterodactyl/public/favicons/favicon.ico
    rm /var/www/pterodactyl/public/favicons/apple-touch-icon.png
    rm /var/www/pterodactyl/public/favicons/favicon-16x16.png
    rm /var/www/pterodactyl/public/favicons/favicon-32x32.png
    rm /var/www/pterodactyl/public/favicons/favicon-96x96.png
    mv index.tsx /var/www/pterodactyl/resources/scripts/index.tsx
    mv MinecraftPurpleTheme.css /var/www/pterodactyl/resources/scripts/MinecraftPurpleTheme.css
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

installPanelQuestion(){
    while true; do
        read -p "Are you sure that you want to install the panel [y/n]? " yn
        case $yn in
            [Yy]* ) installPanel; break;;
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
echo "[1] Install Panel"
echo "[2] Install theme"
echo "[3] Restore backup"
echo "[4] Repair panel (use if you have an error in the theme installation)"
echo "[4] Exit"

read -p "Please enter a number: " choice
if [ $choice == "1" ]
    then
    installPanelQuestion
fi
if [ $choice == "2" ]
    then
    installThemeQuestion
fi
if [ $choice == "3" ]
    then
    restoreBackUp
fi
if [ $choice == "4" ]
    then
    repair
fi
if [ $choice == "5" ]
    then
    exit
fi
