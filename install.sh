#!/bin/bash

orange="\033[0;33m"
green="\e[0;32m\033[1m"
gray='\033[0;37m'
black='\033[0;30m'
clear='\033[0m'
lightred="\033[1;31m"
red="\033[0;31m"
lightpurple="\033[1;35m"
purple="\033[0;35m"
cyan="\033[0;36m"
lightcyan="\033[1;36m"
white="\e[0;37m\033[1m"
blued="\033[1;34m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"

if (( $EUID != 0 )); then
    echo -e "${red}Please run as root"
    exit
fi

clear

Theme(){
    echo -e "${green}Instalando Tema..."
    cd /var/www/
    tar -cvf Backup.tar.gz pterodactyl
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

ThemeQuestion(){
    while true; do
        echo -ne "${cyan}Estas seguro de instalar el tema"; read -p " [y/n]? " yn
        case $yn in
            [Yy]* ) Theme; break;;
            [Nn]* ) exit;;
            * ) echo -e "${red}Elije entre yes o no.";;
        esac
    done
}

PterodactylDependencies(){
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
    curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
    apt update
    apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/
}

WingsDependencies(){
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
    sudo systemctl enable --now docker

    sudo mkdir -p /etc/pterodactyl
    curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
    sudo chmod u+x /usr/local/bin/wings
}

repair(){
    bash <(curl https://raw.githubusercontent.com/Joshet18/pterotheme/main/repair.sh)
}

restoreBackUp(){
    echo -e "${green}Cargando backup..."
    cd /var/www/
    tar -xvf Backup.tar.gz
    rm Backup.tar.gz

    cd /var/www/pterodactyl
    yarn build:production
    sudo php artisan optimize:clear
}

Main(){
    clear
    echo -e "${lightpurple}
███╗  ██╗██╗ ██████╗ ██╗  ██╗████████╗███████╗ █████╗ ██╗     ██╗     
████╗ ██║██║██╔════╝ ██║  ██║╚══██╔══╝██╔════╝██╔══██╗██║     ██║     
██╔██╗██║██║██║  ██╗ ███████║   ██║   █████╗  ███████║██║     ██║     
██║╚████║██║██║  ╚██╗██╔══██║   ██║   ██╔══╝  ██╔══██║██║     ██║     
██║ ╚███║██║╚██████╔╝██║  ██║   ██║   ██║     ██║  ██║███████╗███████╗
╚═╝  ╚══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝
${gray} VPS Utils for Pterodactyl

${purple}[1]${green} Instalar Tema
${purple}[2]${green} Instalar Panel (Dependencias)
${purple}[3]${green} Instalar Wings (Dependencias)
${purple}[4]${green} Cargar Backup
${purple}[5]${green} Reparar Panel
${purple}[6]${green} Salir"
    echo -ne "${lightcyan}[!] ${cyan}Elije una opcion"; read -p ": " choice
    if [ $choice == "1" ]
        then
        ThemeQuestion
    fi
    if [ $choice == "2" ]
        then
        PterodactylDependencies
    fi
    if [ $choice == "3" ]
        then
        WingsDependencies
    fi
    if [ $choice == "4" ]
        then
        restoreBackUp
    fi
    if [ $choice == "5" ]
        then
        repair
    fi
    if [ $choice == "6" ]
        then
        exit
    fi
}
Main
