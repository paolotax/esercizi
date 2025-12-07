#!/bin/bash

# Script per creare pagine nvi5_mat in batch con Claude Code
# Uso: ./scripts/batch_crea_pagine.sh [batch_number]
# batch_number: 1-8 per eseguire un batch specifico, oppure "all" per tutti

BATCH=$1

run_batch_1() {
    echo "=== BATCH 1: p181-p190 ==="
    for page in 181 182 183 184 185 186 187 188 189 190; do
        echo "Creando pagina $page..."
        claude --dangerously-skip-permissions "/crea-nuova-pagina $page"
        echo "Pagina $page completata."
        echo ""
    done
    echo "Batch 1 completato. Verifica CORREZIONI_BOX_P181-190.md"
}

run_batch_2() {
    echo "=== BATCH 2: p191-p200 ==="
    for page in 191 192 193 194 195 196 197 198 199 200; do
        echo "Creando pagina $page..."
        claude --dangerously-skip-permissions "/crea-nuova-pagina $page"
        echo "Pagina $page completata."
        echo ""
    done
    echo "Batch 2 completato. Verifica CORREZIONI_BOX_P191-200.md"
}

run_batch_3() {
    echo "=== BATCH 3: p201-p210 ==="
    for page in 201 202 203 204 205 206 207 208 209 210; do
        echo "Creando pagina $page..."
        claude --dangerously-skip-permissions "/crea-nuova-pagina $page"
        echo "Pagina $page completata."
        echo ""
    done
    echo "Batch 3 completato. Verifica CORREZIONI_BOX_P201-210.md"
}

run_batch_4() {
    echo "=== BATCH 4: p211-p220 ==="
    for page in 211 212 213 214 215 216 217 218 219 220; do
        echo "Creando pagina $page..."
        claude --dangerously-skip-permissions "/crea-nuova-pagina $page"
        echo "Pagina $page completata."
        echo ""
    done
    echo "Batch 4 completato. Verifica CORREZIONI_BOX_P211-220.md"
}

run_batch_5() {
    echo "=== BATCH 5: p221-p230 ==="
    for page in 221 222 223 224 225 226 227 228 229 230; do
        echo "Creando pagina $page..."
        claude --dangerously-skip-permissions "/crea-nuova-pagina $page"
        echo "Pagina $page completata."
        echo ""
    done
    echo "Batch 5 completato. Verifica CORREZIONI_BOX_P221-230.md"
}

run_batch_6() {
    echo "=== BATCH 6: p231-p240 ==="
    for page in 231 232 233 234 235 236 237 238 239 240; do
        echo "Creando pagina $page..."
        claude --dangerously-skip-permissions "/crea-nuova-pagina $page"
        echo "Pagina $page completata."
        echo ""
    done
    echo "Batch 6 completato. Verifica CORREZIONI_BOX_P231-240.md"
}

run_batch_7() {
    echo "=== BATCH 7: p241-p250 ==="
    for page in 241 242 243 244 245 246 247 248 249 250; do
        echo "Creando pagina $page..."
        claude --dangerously-skip-permissions "/crea-nuova-pagina $page"
        echo "Pagina $page completata."
        echo ""
    done
    echo "Batch 7 completato. Verifica CORREZIONI_BOX_P241-250.md"
}

run_batch_8() {
    echo "=== BATCH 8: p251-p264 ==="
    for page in 251 252 253 254 255 256 257 258 259 260 261 262 263 264; do
        echo "Creando pagina $page..."
        claude --dangerously-skip-permissions "/crea-nuova-pagina $page"
        echo "Pagina $page completata."
        echo ""
    done
    echo "Batch 8 completato. Verifica CORREZIONI_BOX_P251-264.md"
}

case $BATCH in
    1) run_batch_1 ;;
    2) run_batch_2 ;;
    3) run_batch_3 ;;
    4) run_batch_4 ;;
    5) run_batch_5 ;;
    6) run_batch_6 ;;
    7) run_batch_7 ;;
    8) run_batch_8 ;;
    all)
        run_batch_1
        run_batch_2
        run_batch_3
        run_batch_4
        run_batch_5
        run_batch_6
        run_batch_7
        run_batch_8
        ;;
    *)
        echo "Uso: $0 [1-8|all]"
        echo ""
        echo "Batch disponibili:"
        echo "  1: p181-p190"
        echo "  2: p191-p200"
        echo "  3: p201-p210"
        echo "  4: p211-p220"
        echo "  5: p221-p230"
        echo "  6: p231-p240"
        echo "  7: p241-p250"
        echo "  8: p251-p264"
        echo "  all: Tutti i batch"
        exit 1
        ;;
esac

echo ""
echo "=== RIEPILOGO ==="
echo "Pagine create. Ricorda di:"
echo "1. Verificare il file CORREZIONI_BOX appropriato"
echo "2. Eseguire: bin/rails tailwindcss:build"
echo "3. Controllare le pagine nel browser"
