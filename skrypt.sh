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
REFRESH_INTERVAL=1   # sekundy między odświeżeniami (dla trybu dynamicznego)

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

function generate_raport(){
    basic_info
    cpu_info
    memory_info
    disk_info
    uptime_info
    network_info 
}

function display_info() {
    echo "=== Informacje systemowe ==="
    generate_raport
    echo "Naciśnij Enter, aby kontynuować..."
    read
}

function save_report() {
    echo ">>> Generowanie raportu do $REPORT_FILE..."
    {
        date
        generate_raport
    } > "$REPORT_FILE"
    zenity --info --text="Raport zapisany do $REPORT_FILE"
}

function dynamic_mode() {
    while true; do
        clear
        echo "🟢 TRYB DYNAMICZNY – Odświeżanie co $REFRESH_INTERVAL sekund. Naciśnij 'q', aby wyjść."
        echo "-----------------------------------------"
        generate_raport

        # Sprawdzenie, czy naciśnięto spację
        read -t $REFRESH_INTERVAL -n1 key
        if [[ $key == "q" ]]; then
            echo ">>> Zakończono tryb dynamiczny."
            break
        fi
    done
}

# Funkcja zapisująca raport przez określony czas
function save_report_with_duration() {
    local duration=$1
    local file_name="raport_systemowy_$(date +%Y%m%d_%H%M%S).txt"

    echo ">>> Rozpoczęto zapisywanie raportu do pliku $file_name przez $duration sekund..."
    start_time=$(date +%s)
    end_time=$((start_time + duration))

    # Tworzenie pliku i zapisywanie nagłówka
    echo "Raport systemowy (czas trwania: $duration sekund)" > "$file_name"
    echo "----------------------------------------" >> "$file_name"

    while [[ $(date +%s) -lt $end_time ]]; do
        # Dodanie znacznika czasu i danych systemowych do pliku
        echo "Czas: $(date)" >> "$file_name"
        generate_raport >> "$file_name"
        echo "----------------------------------------" >> "$file_name"
        sleep "$REFRESH_INTERVAL"
    done

    echo ">>> Raport zapisany do pliku $file_name"
    zenity --info --text="Raport zapisany do pliku $file_name"
}

# Funkcja wywołująca zapis raportu z oknem dialogowym
function save_report_with_dialog() {
    local duration=$(zenity --entry --title="Czas trwania raportu" --text="Podaj czas trwania (w sekundach):")

    # Sprawdzenie, czy użytkownik podał wartość
    if [[ -z "$duration" ]]; then
        zenity --error --text="Nie podano czasu trwania!"
        return
    fi

    # Sprawdzenie, czy podano liczbę
    if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Podano nieprawidłowy czas! Wprowadź liczbę całkowitą."
        return
    fi

    # Wywołanie funkcji zapisującej raport
    save_report_with_duration "$duration"
}

# Wyświetlenie pomocy
function show_help() {
    echo "Użycie: ./skrypt.sh [opcje]"
    echo ""
    echo "Opcje:"
    echo "  -h    Wyświetl pomoc"
    echo "  -v    Informacja o wersji i autorze"
    echo ""
}

# Wyświetlenie informacji o wersji i autorze
function show_version() {
    echo "System Info Script"
    echo "Wersja: 0.1"
    echo "Autor: Filip Grela (fgrela09@gmail.com)"
    echo ""
}

function show_menu() {
    echo "=== MENU ==="
    echo "1) Wyświetl informacje systemowe"
    echo "2) Zapisz raport do pliku"
    echo "3) Tryb dynamiczny (monitor na żywo)"
    echo "4) Zapisz raport z określonego okresu (z oknem dialogowym)"
    echo "0) Wyjście"
    
    read -p "Wybierz opcję: " choice

    clear
    # Call the function for the selected option
    case $choice in
        1) display_info ;;
        2) save_report ;;
        3) dynamic_mode ;;
        4) save_report_with_dialog ;;
        0) exit 0 ;;
        *) zenity --error --text="Niepoprawny wybór!";;
    esac
}   

# Obsługa opcji wiersza poleceń
if [[ $# -gt 0 ]]; then
    case $1 in
        -h) show_help; exit 0 ;;
        -v) show_version; exit 0 ;;
        *) echo "Nieznana opcja: $1"; show_help; exit 1 ;;
    esac
fi

while true; do
    clear
    show_menu
done