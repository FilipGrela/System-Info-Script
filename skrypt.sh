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

# 1. Podstawowe dane o systemie
function basic_info() {
    echo "=== Podstawowe informacje o systemie ==="
    echo "Nazwa hosta: $(hostname)"
    echo "System operacyjny: $(uname -o)"
    echo "Kernel: $(uname -r)"
    echo "Architektura: $(uname -m)"
    echo "Użytkownik: $USER"
    echo ""
}

# 2. Procesor
function cpu_info() {
    echo "=== Informacje o procesorze ==="
    lscpu | grep -E '^Model name|^CPU\(s\)|^Thread|^Core|MHz' 
    echo ""
}

# 3. Pamięć RAM
function memory_info() {
    echo "=== Pamięć RAM ==="
    free -m
    echo ""
}

# 4. Dyski
function disk_info() {
    echo "=== Dyski (użycie) ==="
    df -h | grep -v tmpfs
    echo ""
}

# 5. Czas działania
function uptime_info() {
    echo "=== Czas działania systemu ==="
    uptime -p
    echo ""
}

# 6. Dane sieciowe
function network_info() {
    echo "=== Informacje sieciowe ==="
    ip a | grep inet | grep -v "127.0.0.1"
    echo ""
}

function show_menu() {
    echo "=== MENU ==="
    echo "1) Wyświetl informacje systemowe"
    echo "2) Zapisz raport do pliku"
    echo "3) Tryb dynamiczny (monitor na żywo)"
    echo "0) Wyjście"
    
    read -p "Wybierz opcję: " choice
    

    clear
    # Call the function for the selected option
    case $choice in
        1) basic_info; cpu_info; memory_info; disk_info; uptime_info; network_info ;;
        2) save_report ;;
        3) dynamic_mode ;;
        0) exit 0 ;;
        *) clear; echo "Niepoprawny wybór!"; sleep 1;;
    esac
}

while true; do
    clear
    show_menu
    echo -n "Wciśnij ENTER, aby kontynuować..."
    read
done