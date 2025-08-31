#!/bin/bash
#
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Load a bitstream to a Xilinx FPGA using Vivado in tcl mode
# Run from the project root directory.

# Znajdź wszystkie pliki .bit
bitstreams=($(find results -name "*.bit"))

# Sprawdź, ile jest plików
if [ ${#bitstreams[@]} -eq 0 ]; then
    echo "❌ Nie znaleziono żadnego pliku .bit w katalogu results/"
    exit 1
elif [ ${#bitstreams[@]} -eq 1 ]; then
    bitstream_file="${bitstreams[0]}"
    echo "✅ Znaleziono jeden plik: $bitstream_file"
else
    echo "🔎 Znaleziono kilka plików .bit:"
    for i in "${!bitstreams[@]}"; do
        echo "[$i] ${bitstreams[$i]}"
    done

    echo -n "👉 Wybierz numer pliku do załadowania: "
    read choice

    # Sprawdzenie poprawności wyboru
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -ge "${#bitstreams[@]}" ]; then
        echo "❌ Błędny wybór."
        exit 1
    fi

    bitstream_file="${bitstreams[$choice]}"
fi

echo "🚀 Ładowanie bitstreamu: $bitstream_file"
vivado -mode tcl -source fpga/scripts/program_fpga.tcl -tclargs "${bitstream_file}"
