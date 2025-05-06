#!/bin/bash

# Author           : Imie Nazwisko ( Filip Grela )
# Last Modified On : 06.05.2025 
# Last Modified By : Imie Nazwisko ( fgrela09@gmail.com )
# Last Modified On : 06.05.2025 
# Version          : 0.1
#
# Description      :
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


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

# Generowanie raportu
function generate_raport() {
    basic_info
    cpu_info
    memory_info
    disk_info
    uptime_info
    network_info
}

# Wyświetlanie informacji systemowych
display_info() {
    zenity --text-info --width=600 --height=500 --title="Informacje systemowe" --filename=<(generate_raport)
}

# Zapis raportu do pliku
function save_report() {
    echo ">>> Generowanie raportu do $REPORT_FILE..."
    {
        date
        generate_raport
    } > "$REPORT_FILE"
    zenity --info --text="Raport zapisany do $REPORT_FILE"
}

# Tryb dynamiczny
function dynamic_mode() {
    while true; do
        clear
        echo "🟢 TRYB DYNAMICZNY – Odświeżanie co $REFRESH_INTERVAL sekund. Naciśnij 'q', aby wyjść."
        echo "-----------------------------------------"
        generate_raport

        # Sprawdzenie, czy naciśnięto klawisz
        read -t $REFRESH_INTERVAL -n1 key
        if [[ $key == "q" ]]; then
            echo ">>> Zakończono tryb dynamiczny."
            break
        fi
    done
}

# Zapis raportu przez określony czas
function save_report_with_duration() {
    local duration=$1
    local refresh_interval=$2
    local file_name="raport_systemowy_$(date +%Y%m%d_%H%M%S).txt"

    echo ">>> Rozpoczęto zapisywanie raportu do pliku $file_name przez $duration sekund..."
    start_time=$(date +%s)
    end_time=$((start_time + duration))

    # Tworzenie pliku i zapisywanie nagłówka
    echo "Raport systemowy (czas trwania: $duration sekund)" > "$file_name"
    echo "----------------------------------------" >> "$file_name"

    while [[ $(date +%s) -lt $end_time ]]; do
        echo "Czas: $(date)" >> "$file_name"
        generate_raport >> "$file_name"
        echo "----------------------------------------" >> "$file_name"
        sleep "$refresh_interval"
    done

    echo ">>> Raport zapisany do pliku $file_name"
    zenity --info --text="Raport zapisany do pliku $file_name"
}

# Zapis raportu z oknem dialogowym
function save_report_with_dialog() {
    local duration=$(zenity --entry --title="Czas trwania raportu" --text="Podaj czas trwania (w sekundach):")

    if [[ -z "$duration" ]]; then
        zenity --error --text="Nie podano czasu trwania!"
        return
    fi

    if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Podano nieprawidłowy czas! Wprowadź liczbę całkowitą."
        return
    fi

    local refresh_interval=$(zenity --entry --title="Interwał odświeżania" --text="Podaj interwał odświeżania (w sekundach):")

    if [[ -z "$refresh_interval" ]]; then
        zenity --error --text="Nie podano interwału odświeżania!"
        return
    fi

    if ! [[ "$refresh_interval" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Podano nieprawidłowy interwał! Wprowadź liczbę całkowitą."
        return
    fi

    save_report_with_duration "$duration" "$refresh_interval"
}

zenity_menu() {
    local choice
    choice=$(zenity --list --title="sysinfo – menu" --column="Opcja" --column="Opis"             1 "Wyświetl informacje systemowe"             2 "Zapisz raport do pliku"             3 "Tryb dynamiczny (monitor na żywo)"             4 "Zapisz raport z określonego okresu"             5 "Ustawienia"             0 "Wyjście") || exit 0

    case $choice in
        1) display_info ;;
        2) save_report ;;
        3) dynamic_mode ;;
        4) save_report_with_dialog ;;
        5) settings_dialog ;;
        0|"") exit 0 ;;
        *) zenity --error --text="Niepoprawny wybór!" ;;
    esac
}

# --- Konfiguracja ---

# Zapisz bieżące wartości do pliku konfiguracyjnego
function save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" <<EOF
REPORT_FILE=$REPORT_FILE
REFRESH_INTERVAL=$REFRESH_INTERVAL
EOF
}

settings_dialog() {
    local new_report
    new_report=$(zenity --entry --title="Plik raportu" --text="Podaj nazwę pliku:" --entry-text="$REPORT_FILE") || return

    local new_interval
    new_interval=$(zenity --entry --title="Odświeżanie" --text="Podaj interwał (sekundy):" --entry-text="$REFRESH_INTERVAL") || return
    [[ $new_interval =~ ^[0-9]+$ ]] || { zenity --error --text="Interwał musi być liczbą!"; return; }

    REPORT_FILE="$new_report"
    REFRESH_INTERVAL="$new_interval"
    save_config
    zenity --info --text="Zapisano ustawienia w $CONFIG_FILE"
}