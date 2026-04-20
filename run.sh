#!/bin/bash

# Configuration
PAYMENTER_PATH="/var/www/paymenter"
REPO_URL="https://github.com/nobita329/Thame.git"

show_menu() {
    echo "------------------------------------------"
    echo " Paymenter Theme Manager (Thame/Obsidian) "
    echo "------------------------------------------"
    echo "1) Install Theme"
    echo "2) Uninstall Theme"
    echo "3) Exit"
    echo "------------------------------------------"
    read -p "Choose an option [1-3]: " choice
}

install_theme() {
    echo "--- Starting Installation ---"
    
    # 1. Dependencies
    apt update && apt install -y git unzip sudo
    
    # 2. Download
    if [ -d "Thame" ]; then rm -rf Thame; fi
    git clone $REPO_URL
    cd Thame

    # 3. Move & Extract
    sudo cp files.zip $PAYMENTER_PATH/
    sudo cp thame.zip $PAYMENTER_PATH/themes/
    sudo cp pages.zip $PAYMENTER_PATH/extensions/Others/

    cd $PAYMENTER_PATH && unzip -o files.zip && rm files.zip
    cd $PAYMENTER_PATH/themes/ && unzip -o thame.zip && rm thame.zip
    cd $PAYMENTER_PATH/extensions/Others/ && unzip -o pages.zip && rm pages.zip

    # 4. Build UI
    cd $PAYMENTER_PATH
    sudo apt update
    sudo apt install nodejs npm -y
    npm install
    npm run build obsidian || npm run build

    # 5. Refresh System
    php artisan migrate --force
    php artisan view:clear
    php artisan cache:clear
    
    # 6. Permissions
    chown -R www-data:www-data $PAYMENTER_PATH/*
    chmod -R 775 $PAYMENTER_PATH/storage
    
    echo "--- Installation Finished! ---"
}

uninstall_theme() {
    echo "--- Starting Uninstallation ---"
    
    # 1. Remove Theme Files (Specific to Thame/Obsidian)
    # Warning: This deletes the 'thame' directory in themes.
    rm -rf $PAYMENTER_PATH/themes/thame
    rm -rf $PAYMENTER_PATH/extensions/Others/pages
    
    # 2. Rebuild Default UI
    cd $PAYMENTER_PATH
    # Resetting the theme to default via Artisan (if possible) 
    # or simply rebuilding the standard assets.
    npm install
    npm run build
    
    # 3. Clear Cache
    php artisan view:clear
    php artisan cache:clear
    php artisan config:clear
    
    # 4. Permissions
    chown -R www-data:www-data $PAYMENTER_PATH/*
    
    echo "--- Uninstalled. System reverted to default build. ---"
}

# Run script as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

show_menu

case $choice in
    1) install_theme ;;
    2) uninstall_theme ;;
    3) exit 0 ;;
    *) echo "Invalid option." ;;
esac
