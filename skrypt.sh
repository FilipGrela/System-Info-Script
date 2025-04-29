# Author           : Imie Nazwisko ( Filip Grela )
# Created On       : 29.04.2025
# Last Modified By : Imie Nazwisko ( fgrela09@gmail.com )
# Last Modified On : 29.04.2025 
# Version          : 0.1
#
# Description      :
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

#!/bin/bash

# === KONFIGURACJA ===
REPORT_FILE="raport_systemowy.txt"
REFRESH_INTERVAL=0.2   # sekundy między odświeżeniami (dla trybu dynamicznego)

# === FUNKCJE ===

function show_menu() {
    echo "=== MENU ==="
    echo "1) Wyświetl informacje systemowe"
    echo "2) Zapisz raport do pliku"
    echo "3) Tryb dynamiczny (monitor na żywo)"
    echo "0) Wyjście"
    
    read -p "Wybierz opcję: " choice
    

    # Call the function for the selected option
    case $choice in
        1) basic_info ;;
        2) save_report ;;
        3) dynamic_mode ;;
        0) exit 0 ;;
        *) clear; echo "Niepoprawny wybór!"; sleep 1;;
    esac
}

while true; do
    clear
    show_menu
    
done