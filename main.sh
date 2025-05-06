#!/bin/bash

# Author           : Imie Nazwisko ( Filip Grela )
# Created On       : 29.04.2025
# Last Modified By : Imie Nazwisko ( fgrela09@gmail.com )
# Last Modified On : 06.05.2025 
# Version          : 0.1
#
# Description      :
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


# === KONFIGURACJA ===
REPORT_FILE="raport_systemowy.txt"
REFRESH_INTERVAL=1

# Załaduj funkcje z pliku functions.sh
source ./functions.sh

# Wyświetlenie pomocy
function show_help() {
    echo "Użycie: ./main.sh [opcje]"
    echo ""
    echo "Opcje:"
    echo "  -h    Wyświetl pomoc"
    echo "  -v    Informacja o wersji i autorze"
    echo "  man   Wyświetl manual"
    echo ""
}

# Wyświetlenie informacji o wersji i autorze
function show_version() {
    echo "System Info Script"
    echo "Wersja: 0.1"
    echo "Autor: Filip Grela (fgrela09@gmail.com)"
    echo ""
}

# Obsługa opcji wiersza poleceń
if [[ $# -gt 0 ]]; then
    case $1 in
        -h) show_help; exit 0 ;;
        -v) show_version; exit 0 ;;
        man) man ./skrypt.1; exit 0 ;;
        *) echo "Nieznana opcja: $1"; show_help; exit 1 ;;
    esac
fi

# Menu główne
while true; do
    zenity_menu
done