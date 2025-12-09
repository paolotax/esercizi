#!/bin/bash

# Script per creare pagine nvi4_mat in batch con Claude Code
# Uso: ./scripts/batch_crea_pagine.sh
# Crea pagine di teoria (016-169) in gruppi di 5, chiedendo conferma tra un batch e l'altro

# Directory del progetto
PROJECT_DIR="/home/paolotax/rails_2023/esercizi"
cd "$PROJECT_DIR"

# Colori per output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Pagine di teoria nvi4_mat (016-169)
PAGINE=(016 017 018 019 020 021 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 067 068 069 070 071 072 073 074 075 076 077 078 079 080 081 082 083 084 085 086 087 088 089 090 091 092 093 094 095 096 097 098 099 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169)

# Dimensione del batch
BATCH_SIZE=5

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Batch Creazione Pagine nvi4_mat${NC}"
echo -e "${BLUE}  Pagine di teoria: 016-169${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Pagine totali: ${GREEN}${#PAGINE[@]}${NC}"
echo -e "Batch size: ${GREEN}${BATCH_SIZE}${NC}"
echo ""

# Indice corrente
i=0
total=${#PAGINE[@]}
batch_num=1

while [ $i -lt $total ]; do
    # Calcola le pagine per questo batch
    batch_pages=""
    batch_end=$((i + BATCH_SIZE))
    if [ $batch_end -gt $total ]; then
        batch_end=$total
    fi

    for ((j=i; j<batch_end; j++)); do
        if [ -n "$batch_pages" ]; then
            batch_pages="$batch_pages ${PAGINE[$j]}"
        else
            batch_pages="${PAGINE[$j]}"
        fi
    done

    # Mostra info batch
    echo -e "${YELLOW}----------------------------------------${NC}"
    echo -e "${YELLOW}BATCH ${batch_num}: Pagine ${batch_pages}${NC}"
    echo -e "${YELLOW}Progresso: $i/${total} completate${NC}"
    echo -e "${YELLOW}----------------------------------------${NC}"
    echo ""

    # Esegui claude con le pagine
    echo -e "${GREEN}Eseguo: claude --dangerously-skip-permissions \"/crea-nuova-pagina ${batch_pages}\"${NC}"
    echo ""

    claude --dangerously-skip-permissions "/crea-nuova-pagina ${batch_pages}"

    # Incrementa indice
    i=$batch_end
    batch_num=$((batch_num + 1))

    # Se non siamo alla fine, chiedi se continuare
    if [ $i -lt $total ]; then
        echo ""
        echo -e "${BLUE}========================================${NC}"
        echo -e "Completate ${GREEN}$i${NC} di ${GREEN}$total${NC} pagine"
        remaining=$((total - i))
        echo -e "Rimanenti: ${YELLOW}$remaining${NC} pagine"
        echo -e "${BLUE}========================================${NC}"
        echo ""
        read -p "Continuare con il prossimo batch? (s/n) [s]: " risposta
        risposta=${risposta:-s}
        if [ "$risposta" != "s" ] && [ "$risposta" != "S" ]; then
            echo ""
            echo -e "${YELLOW}Batch interrotto dall'utente.${NC}"
            echo -e "Prossima pagina: ${RED}${PAGINE[$i]}${NC}"
            echo ""
            echo -e "Per riprendere, modifica l'array PAGINE nello script"
            echo -e "partendo da ${PAGINE[$i]}"
            exit 0
        fi
        echo ""
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Tutte le ${total} pagine sono state create!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Ricorda di:"
echo "1. Eseguire: bin/rails tailwindcss:build"
echo "2. Controllare le pagine nel browser"
echo "3. Aggiornare il seed se necessario"
