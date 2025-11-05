# Prompt per Creare Nuove Pagine

Usa questo formato semplice per farmi creare una nuova pagina interattiva. Io analizzerò automaticamente l'immagine e creerò tutto.

---

## PROMPT GENERICO

```
Crea la pagina del libro dall'immagine [nome_file].jpg che trovi in ~/Downloads/[nome_cartella]/
Ci sono anche le immagini scomposte. Analizza la pagina, identifica volume, disciplina,
numero pagina, gli esercizi e le loro tipologie. Crea la view interattiva con soluzioni.

[Opzionale: aggiungi qui il testo corretto se serve, altrimenti lo leggo dall'immagine]
```

---

## ESEMPIO 1: Minimalista

```
Crea la pagina del libro dall'immagine bus3_mat_p078.jpg che trovi in ~/Downloads/bus3_mat_p078/
Ci sono anche le immagini scomposte.
```

**Quello che farò io:**
1. ✅ Leggo `bus3_mat_p078.jpg` per capire: corso, volume, disciplina, numero pagina, titolo
2. ✅ Leggo tutte le immagini scomposte nella cartella per capire quanti esercizi ci sono
3. ✅ Identifico automaticamente le tipologie di esercizi (completa, collega, scegli, colora, etc.)
4. ✅ Estrapolo il testo dall'immagine o uso quello che mi fornisci
5. ✅ Deduco le soluzioni corrette analizzando le immagini
6. ✅ Copio le immagini in app/assets/images/
7. ✅ Aggiorno il seed con la nuova pagina
8. ✅ Creo la view interattiva completa
9. ✅ Rigenero il database

---

## ESEMPIO 2: Con testo fornito

```
Crea la pagina del libro dall'immagine cai_met_p055.jpg che trovi in ~/Downloads/cai_met_p055/
Ci sono anche le immagini scomposte.

Il testo corretto della pagina è questo:

LA LETTERA M

1 Scrivi la lettera M come nell'esempio.
2 Collega le parole alle immagini.
3 Completa le parole con MA ME MI MO MU.
```

---

## ESEMPIO 3: Caso reale (Pagina 76 che abbiamo fatto)

```
Crea la pagina del libro dall'immagine bus3_mat_p076.jpg che trovi in ~/Downloads/bus3_mat_p076/
Ci sono anche le immagini scomposte.

Il testo corretto della pagina è questo:

La banda del bus - Il Libro di Matematica vol.3

FRAZIONI
L'UNITÀ FRAZIONARIA

1 Osserva i disegni e completa, come nell'esempio.

• Tutte queste figure sono divise in parti ........ e solo ........ parte è colorata.

Tutte le frazioni che hanno 1 al numeratore si chiamano unità frazionarie.

2 Collega l'unità frazionaria alla sua rappresentazione.

3 Colora l'unità frazionaria e scrivila in cifre e in lettere.

4 GIOCO Osserva le tre costruzioni e indica con una X in quale costruzione
l'unità frazionaria è un quindicesimo.
```

---

## NOTE IMPORTANTI

### Cosa devi fornirmi (minimo):
- ✅ Percorso della cartella con le immagini
- ✅ Nome del file JPG di riferimento
- ⚠️ (Opzionale) Testo corretto se l'OCR non è affidabile

### Cosa farò io automaticamente:
- 🔍 Analizzo l'immagine di riferimento per identificare: corso, volume, classe, disciplina, numero pagina
- 🔍 Leggo tutte le immagini nella cartella per capire la struttura degli esercizi
- 🔍 Identifico le tipologie di esercizi: input di testo, dropdown, radio button, checkbox, drag&drop
- 🔍 Deduco le soluzioni corrette dalle immagini
- 🔍 Identifico lo stile: colori, badge speciali (GIOCO, etc.), mascotte
- 💾 Copio le immagini
- 💾 Aggiorno il seed
- 💾 Creo la view completa
- 💾 Rigenero il database

### Tipologie di esercizi che riconosco automaticamente:
- **Completa**: campi di testo da riempire (frazioni, parole, frasi)
- **Collega**: dropdown o linee per collegare elementi
- **Scegli**: radio button o checkbox per scelte multiple
- **Colora**: aree da colorare (con rilevamento colore o input descrittivo)
- **Ordina**: drag and drop per ordinare elementi
- **Scrivi**: aree di testo libero per scrittura
- **Calcola**: esercizi di matematica con risultati numerici
- **Vero/Falso**: domande con risposta binaria
- **Completa la tabella**: griglie da riempire

---

## FORMATO ULTRA-RAPIDO (Copy-Paste)

```
Crea pagina: ~/Downloads/[cartella]/[immagine].jpg
```

Esempio:
```
Crea pagina: ~/Downloads/bus3_mat_p078/bus3_mat_p078.jpg
```

---

## CASI SPECIALI

### Se ci sono più pagine consecutive (es: pag. 96-97)
```
Crea la pagina del libro dall'immagine bus2_lettgr_p096.jpg in ~/Downloads/bus2_lettgr_p096/
Questa è una pagina doppia (96-97).
```

### Se ci sono esercizi molto particolari
```
Crea la pagina del libro dall'immagine nvl_gr_p020.jpg in ~/Downloads/nvl_gr_p020/

Nota: L'esercizio 3 richiede il riconoscimento vocale per la pronuncia.
```

### Se il volume non esiste ancora nel seed
```
Crea la pagina del libro dall'immagine bus1_mat_p010.jpg in ~/Downloads/bus1_mat_p010/

Nota: Questo è un nuovo volume (BUS 1) che va aggiunto al corso "Banda del BUS".
```

---

## COSA MI SERVE DA TE

**MINIMO INDISPENSABILE:**
1. Percorso della cartella con le immagini
2. Nome del file JPG di riferimento

**OPZIONALE (ma utile):**
3. Testo corretto della pagina (se l'OCR non è preciso)
4. Note su esercizi particolari
5. Indicazioni su volumi nuovi da creare

**Il resto lo faccio io! 🚀**
