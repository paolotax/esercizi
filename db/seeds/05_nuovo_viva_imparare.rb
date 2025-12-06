# 4. NUOVO VIVA IMPARARE 4
puts "\n📚 Creazione corso: Nuovo Viva Imparare"
nvi = Corso.create!(
  nome: "Nuovo Viva Imparare",
  codice: "nvi",
  descrizione: "Sussidiario delle discipline per la scuola primaria"
)

nvi_volume4 = nvi.volumi.create!(
  nome: "Nuovo Viva Imparare 4",
  classe: 4,
  posizione: 4
)

# Matematica
nvi_matematica = nvi_volume4.discipline.create!(
  nome: "Matematica",
  codice: "mat",
  colore: "#A855F7"
)

[
  { numero: 5, titolo: "La Linea dei Numeri", slug: "sussi_pag_5", view_template: "sussi_pag_5" },
  { numero: 14, titolo: "Sistema di Numerazione", slug: "sussi_pag_14", view_template: "sussi_pag_14" }
].each do |pagina_data|
  nvi_matematica.pagine.create!(pagina_data)
end

# Storia
nvi_storia = nvi_volume4.discipline.create!(
  nome: "Storia",
  codice: "sto",
  colore: "#06B6D4"
)

[
  { numero: 154, titolo: "Le Conoscenze dei Babilonesi", slug: "nvi4_sto_p154", view_template: "nvi4_sto_p154" },
  { numero: 155, titolo: "Gli Ittiti", slug: "nvi4_sto_p155", view_template: "nvi4_sto_p155" }
].each do |pagina_data|
  nvi_storia.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{nvi_volume4.nome}' con #{nvi_matematica.pagine.count} pagine di matematica e #{nvi_storia.pagine.count} pagine di storia"

# 5. NUOVO VIVA IMPARARE 5
nvi_volume5 = nvi.volumi.create!(
  nome: "Nuovo Viva Imparare 5",
  classe: 5,
  posizione: 5
)

nvi5_matematica = nvi_volume5.discipline.create!(
  nome: "Matematica",
  codice: "mat",
  colore: "#A855F7"
)

[
  { numero: 1, titolo: "Copertina", slug: "nvi5_mat_p001", view_template: "nvi5_mat_p001", sottotitolo: "", base_color: "pink" },
  { numero: 2, titolo: "Indice", slug: "nvi5_mat_p002", view_template: "nvi5_mat_p002", sottotitolo: "", base_color: "pink" },
  { numero: 4, titolo: "Numeri - Misura - Geometria", slug: "nvi5_mat_p004", view_template: "nvi5_mat_p004", sottotitolo: "PER RICOMINCIARE", base_color: "pink" },
  { numero: 5, titolo: "Le frazioni", slug: "nvi5_mat_p005", view_template: "nvi5_mat_p005", sottotitolo: "PER RICOMINCIARE", base_color: "pink" },
  { numero: 6, titolo: "Misura", slug: "nvi5_mat_p006", view_template: "nvi5_mat_p006", sottotitolo: "PER RICOMINCIARE", base_color: "pink" },
  { numero: 7, titolo: "Geometria", slug: "nvi5_mat_p007", view_template: "nvi5_mat_p007", sottotitolo: "PER RICOMINCIARE", base_color: "pink" },
  { numero: 8, titolo: "Numeri Potenze", slug: "nvi5_mat_p008", view_template: "nvi5_mat_p008", sottotitolo: "PAROLE AL CENTRO", base_color: "pink" },
  { numero: 9, titolo: "Numeri Relativi", slug: "nvi5_mat_p009", view_template: "nvi5_mat_p009", sottotitolo: "PAROLE AL CENTRO", base_color: "pink" },
  { numero: 10, titolo: "Numeri Molto Grandi", slug: "nvi5_mat_p010", view_template: "nvi5_mat_p010", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 11, titolo: "Diverse Scritture dei Numeri", slug: "nvi5_mat_p011", view_template: "nvi5_mat_p011", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 12, titolo: "I Numeri Romani", slug: "nvi5_mat_p012", view_template: "nvi5_mat_p012", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 13, titolo: "I Numeri Grandi", slug: "nvi5_mat_p013", view_template: "nvi5_mat_p013", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 14, titolo: "I Numeri Decimali", slug: "nvi5_mat_p014", view_template: "nvi5_mat_p014", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 15, titolo: "Arrotondamento o Approssimazione", slug: "nvi5_mat_p015", view_template: "nvi5_mat_p015", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 16, titolo: "Le Potenze", slug: "nvi5_mat_p016", view_template: "nvi5_mat_p016", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 17, titolo: "La Scrittura Polinomiale", slug: "nvi5_mat_p017", view_template: "nvi5_mat_p017", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 18, titolo: "I Numeri - Esercizi", slug: "nvi5_mat_p018", view_template: "nvi5_mat_p018", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 19, titolo: "Esercizi", slug: "nvi5_mat_p019", view_template: "nvi5_mat_p019" },
  { numero: 20, titolo: "I Numeri Interi Relativi", slug: "nvi5_mat_p020", view_template: "nvi5_mat_p020" },
  { numero: 21, titolo: "Confrontare e Ordinare i Numeri Interi Relativi", slug: "nvi5_mat_p021", view_template: "nvi5_mat_p021" },
  { numero: 22, titolo: "Operare con i Numeri Interi Relativi", slug: "nvi5_mat_p022", view_template: "nvi5_mat_p022" },
  { numero: 23, titolo: "La Calcolatrice", slug: "nvi5_mat_p023", view_template: "nvi5_mat_p023" },
  { numero: 24, titolo: "I Numeri Decimali e I Numeri Relativi", slug: "nvi5_mat_p024", view_template: "nvi5_mat_p024" },
  { numero: 25, titolo: "Mappa - Il Nostro Sistema di Numerazione", slug: "nvi5_mat_p025", view_template: "nvi5_mat_p025" },
  { numero: 26, titolo: "I Numeri", slug: "nvi5_mat_p026", view_template: "nvi5_mat_p026", sottotitolo: "VERIFICA", base_color: "cyan" },
  { numero: 27, titolo: "I Numeri", slug: "nvi5_mat_p027", view_template: "nvi5_mat_p027", sottotitolo: "MODELLO INVALSI", base_color: "red" },
  { numero: 28, titolo: "I Numeri - Verifica Avanzata", slug: "nvi5_mat_p028", view_template: "nvi5_mat_p028", sottotitolo: "MODELLO INVALSI", base_color: "red" },
  { numero: 29, titolo: "I Numeri - Esercizi Guidati", slug: "nvi5_mat_p029", view_template: "nvi5_mat_p029", sottotitolo: "MODELLO INVALSI", base_color: "red" },
  { numero: 30, titolo: "La Sottrazione", slug: "nvi5_mat_p030", view_template: "nvi5_mat_p030", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 31, titolo: "La Proprietà della Sottrazione", slug: "nvi5_mat_p031", view_template: "nvi5_mat_p031", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 32, titolo: "La Moltiplicazione", slug: "nvi5_mat_p032", view_template: "nvi5_mat_p032", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 33, titolo: "Moltiplicazioni con i Numeri Decimali", slug: "nvi5_mat_p033", view_template: "nvi5_mat_p033", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 34, titolo: "Le Proprietà della Moltiplicazione", slug: "nvi5_mat_p034", view_template: "nvi5_mat_p034", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 35, titolo: "La Divisione", slug: "nvi5_mat_p035", view_template: "nvi5_mat_p035", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 36, titolo: "Divisioni con i Numeri Decimali", slug: "nvi5_mat_p036", view_template: "nvi5_mat_p036", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 37, titolo: "La Proprietà della Divisione", slug: "nvi5_mat_p037", view_template: "nvi5_mat_p037", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 38, titolo: "Moltiplicare e Dividere Numeri Decimali", slug: "nvi5_mat_p038", view_template: "nvi5_mat_p038", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 39, titolo: "Strategie di Calcolo", slug: "nvi5_mat_p039", view_template: "nvi5_mat_p039", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 40, titolo: "Moltiplicazioni per 10, 100, 1000", slug: "nvi5_mat_p040", view_template: "nvi5_mat_p040", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 41, titolo: "Divisioni per 10, 100, 1000", slug: "nvi5_mat_p041", view_template: "nvi5_mat_p041", sottotitolo: "NUMERI", base_color: "blue" },
  { numero: 42, titolo: "Le Quattro Operazioni", slug: "nvi5_mat_p042", view_template: "nvi5_mat_p042", sottotitolo: "ESERCIZI", base_color: "orange" },
  { numero: 43, titolo: "Le Quattro Operazioni", slug: "nvi5_mat_p043", view_template: "nvi5_mat_p043", sottotitolo: "ESERCIZI", base_color: "orange" },
  { numero: 44, titolo: "Le Espressioni Aritmetiche", slug: "nvi5_mat_p044", view_template: "nvi5_mat_p044", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 45, titolo: "Espressioni e Problemi", slug: "nvi5_mat_p045", view_template: "nvi5_mat_p045", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 46, titolo: "Multipli e Divisori", slug: "nvi5_mat_p046", view_template: "nvi5_mat_p046", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 47, titolo: "Criteri di Divisibilità", slug: "nvi5_mat_p047", view_template: "nvi5_mat_p047", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 48, titolo: "I Numeri Primi e la Scomposizione in Fattori Primi", slug: "nvi5_mat_p048", view_template: "nvi5_mat_p048", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 49, titolo: "Espressioni, Divisibilità, Numeri Primi", slug: "nvi5_mat_p049", view_template: "nvi5_mat_p049", sottotitolo: "ESERCIZI", base_color: "orange" },
  { numero: 50, titolo: "Le Operazioni con i Decimali", slug: "nvi5_mat_p050", view_template: "nvi5_mat_p050", sottotitolo: "MAPPA", base_color: "cyan" },
  { numero: 51, titolo: "Espressioni Aritmetiche", slug: "nvi5_mat_p051", view_template: "nvi5_mat_p051", sottotitolo: "MAPPA", base_color: "cyan" },
  { numero: 52, titolo: "Operazioni e Relazioni tra Numeri", slug: "nvi5_mat_p052", view_template: "nvi5_mat_p052", sottotitolo: "VERIFICA", base_color: "cyan" },
  { numero: 53, titolo: "Operazioni e Relazioni tra Numeri", slug: "nvi5_mat_p053", view_template: "nvi5_mat_p053", sottotitolo: "MODELLO INVALSI", base_color: "red" },
  { numero: 54, titolo: "Le Frazioni", slug: "nvi5_mat_p054", view_template: "nvi5_mat_p054", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 55, titolo: "Frazioni Complementari ed Equivalenti", slug: "nvi5_mat_p055", view_template: "nvi5_mat_p055", sottotitolo: "NUMERI", base_color: "purple" },
  { numero: 56, titolo: "LE FRAZIONI", slug: "nvi5_mat_p056", view_template: "nvi5_mat_p056", sottotitolo: "ESERCIZI", base_color: "purple" },
  { numero: 57, titolo: "Frazioni Proprie, Improprie e Apparenti", slug: "nvi5_mat_p057", view_template: "nvi5_mat_p057" },
  { numero: 58, titolo: "Laboratorio - Ricostruiamo l'Intero", slug: "nvi5_mat_p058", view_template: "nvi5_mat_p058" },
  { numero: 59, titolo: "Laboratorio - Ricostruiamo l'Intero (Frazioni Qualsiasi)", slug: "nvi5_mat_p059", view_template: "nvi5_mat_p059" },
  { numero: 60, titolo: "Confrontiamo le Frazioni", slug: "nvi5_mat_p060", view_template: "nvi5_mat_p060", base_color: "purple" },
  { numero: 61, titolo: "Confrontare le Frazioni - Il Prodotto in Croce", slug: "nvi5_mat_p061", view_template: "nvi5_mat_p061" },
  { numero: 62, titolo: "Addizioni e Sottrazioni con le Frazioni", slug: "nvi5_mat_p062", view_template: "nvi5_mat_p062" },
  { numero: 63, titolo: "La Frazione come Operatore", slug: "nvi5_mat_p063", view_template: "nvi5_mat_p063" },
  { numero: 64, titolo: "Dalla Frazione all'Intero", slug: "nvi5_mat_p064", view_template: "nvi5_mat_p064" },
  { numero: 65, titolo: "Frazioni Decimali e Numeri Decimali", slug: "nvi5_mat_p065", view_template: "nvi5_mat_p065" },
  { numero: 66, titolo: "Confronti e Operazioni con le Frazioni", slug: "nvi5_mat_p066", view_template: "nvi5_mat_p066" },
  { numero: 67, titolo: "La Percentuale", slug: "nvi5_mat_p067", view_template: "nvi5_mat_p067" },
  { numero: 68, titolo: "LO SCONTO", sottotitolo: "NUMERI", slug: "nvi5_mat_p068", view_template: "nvi5_mat_p068", base_color: "purple" },
  { numero: 69, sottotitolo: "Esercizi", titolo: "LA PERCENTUALE", slug: "nvi5_mat_p069", view_template: "nvi5_mat_p069", base_color: "blue" },
  { numero: 70, sottotitolo: "Verifica", titolo: "FRAZIONI E PERCENTUALE", slug: "nvi5_mat_p070", view_template: "nvi5_mat_p070", base_color: "red" },
  { numero: 71, sottotitolo: "Modello INVALSI", titolo: "FRAZIONI E PERCENTUALE", slug: "nvi5_mat_p071", view_template: "nvi5_mat_p071", base_color: "pink" },
  { numero: 72, titolo: "Risolvere Problemi - Usare le Immagini", slug: "nvi5_mat_p072", view_template: "nvi5_mat_p072" },
  { numero: 73, titolo: "Esercizi - Risolvere Problemi", slug: "nvi5_mat_p073", view_template: "nvi5_mat_p073" },
  { numero: 74, titolo: "Riflettere sui Dati e sul Risultato", slug: "nvi5_mat_p074", view_template: "nvi5_mat_p074" },
  { numero: 75, titolo: "Problemi con Divisione", slug: "nvi5_mat_p075", view_template: "nvi5_mat_p075", sottotitolo: "RISOLVERE PROBLEMI", base_color: "orange" },
  { numero: 76, titolo: "TUTTOPROBLEMI", slug: "nvi5_mat_p076", view_template: "nvi5_mat_p076", sottotitolo: "RISOLVERE PROBLEMI", base_color: "green" },
  { numero: 77, titolo: "TUTTOPROBLEMI", slug: "nvi5_mat_p077", view_template: "nvi5_mat_p077", sottotitolo: "RISOLVERE PROBLEMI", base_color: "indigo" },
  { numero: 80, titolo: "LE MISURE DI LUNGHEZZA E DI CAPACITÀ", slug: "nvi5_mat_p080", view_template: "nvi5_mat_p080", sottotitolo: "MISURA", base_color: "pink" },
  { numero: 81, titolo: "LE MISURE DI MASSA", slug: "nvi5_mat_p081", view_template: "nvi5_mat_p081", sottotitolo: "MISURA", base_color: "pink" },
  { numero: 82, titolo: "LE EQUIVALENZE", slug: "nvi5_mat_p082", view_template: "nvi5_mat_p082", sottotitolo: "MISURA", base_color: "pink" },
  { numero: 83, titolo: "LUNGHEZZA, CAPACITÀ E MASSA", slug: "nvi5_mat_p083", view_template: "nvi5_mat_p083", sottotitolo: "ESERCIZI", base_color: "orange" },
  { numero: 84, titolo: "LE MISURE DI VALORE", slug: "nvi5_mat_p084", view_template: "nvi5_mat_p084", sottotitolo: "MISURA", base_color: "pink" },
  { numero: 85, titolo: "IL COMMERCIO", slug: "nvi5_mat_p085", view_template: "nvi5_mat_p085", sottotitolo: "MISURA", base_color: "pink" },
  { numero: 86, titolo: "LE MISURE DI TEMPO", slug: "nvi5_mat_p086", view_template: "nvi5_mat_p086", sottotitolo: "MISURA", base_color: "pink" },
  { numero: 87, titolo: "CALCOLARE CON LE MISURE DI TEMPO", slug: "nvi5_mat_p087", view_template: "nvi5_mat_p087", sottotitolo: "MISURA", base_color: "pink" },
  { numero: 88, titolo: "EURO, COMMERCIO E TEMPO", slug: "nvi5_mat_p088", view_template: "nvi5_mat_p088", sottotitolo: "ESERCIZI", base_color: "orange" },
  { numero: 89, titolo: "EURO, COMMERCIO E TEMPO", slug: "nvi5_mat_p089", view_template: "nvi5_mat_p089", sottotitolo: "ESERCIZI", base_color: "orange" },
  { numero: 90, titolo: "MISURE DI LUNGHEZZA, CAPACITÀ E MASSA", slug: "nvi5_mat_p090", view_template: "nvi5_mat_p090", sottotitolo: "MAPPA", base_color: "cyan" },
  { numero: 91, titolo: "MISURE DI VALORE E DI TEMPO", slug: "nvi5_mat_p091", view_template: "nvi5_mat_p091", sottotitolo: "MAPPA", base_color: "cyan" },
  { numero: 92, titolo: "MISURA", slug: "nvi5_mat_p092", view_template: "nvi5_mat_p092", sottotitolo: "VERIFICA", base_color: "pink" },
  { numero: 93, titolo: "MISURA", slug: "nvi5_mat_p093", view_template: "nvi5_mat_p093", sottotitolo: "MODELLO INVALSI", base_color: "pink" },
  { numero: 94, titolo: "GEOMETRIA", slug: "nvi5_mat_p094", view_template: "nvi5_mat_p094", sottotitolo: "PAROLE AL CENTRO", base_color: "pink" },
  { numero: 95, titolo: "GEOMETRIA", slug: "nvi5_mat_p095", view_template: "nvi5_mat_p095", sottotitolo: "PAROLE AL CENTRO", base_color: "pink" },
  { numero: 96, titolo: "LE RETTE", slug: "nvi5_mat_p096", view_template: "nvi5_mat_p096", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 97, titolo: "GLI ANGOLI", slug: "nvi5_mat_p097", view_template: "nvi5_mat_p097", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 98, titolo: "IL PIANO CARTESIANO", slug: "nvi5_mat_p098", view_template: "nvi5_mat_p098", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 99, titolo: "ISOMETRIE: LA SIMMETRIA", slug: "nvi5_mat_p099", view_template: "nvi5_mat_p099", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 100, titolo: "LA ROTAZIONE", slug: "nvi5_mat_p100", view_template: "nvi5_mat_p100", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 101, titolo: "LA TRASLAZIONE", slug: "nvi5_mat_p101", view_template: "nvi5_mat_p101", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 102, titolo: "LA SIMILITUDINE", slug: "nvi5_mat_p102", view_template: "nvi5_mat_p102", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 103, titolo: "ISOMETRIE E SIMILITUDINE", slug: "nvi5_mat_p103", view_template: "nvi5_mat_p103", sottotitolo: "ESERCIZI", base_color: "orange" },
  { numero: 104, titolo: "I POLIGONI", slug: "nvi5_mat_p104", view_template: "nvi5_mat_p104", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 105, titolo: "CLASSIFICARE I POLIGONI", slug: "nvi5_mat_p105", view_template: "nvi5_mat_p105", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 106, titolo: "I TRIANGOLI", slug: "nvi5_mat_p106", view_template: "nvi5_mat_p106", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 107, titolo: "I QUADRILATERI", slug: "nvi5_mat_p107", view_template: "nvi5_mat_p107", sottotitolo: "GEOMETRIA", base_color: "pink" },
  { numero: 108, titolo: "GLI ANGOLI INTERNI DEI POLIGONI", slug: "nvi5_mat_p108", view_template: "nvi5_mat_p108", sottotitolo: "LABORATORIO", base_color: "yellow" },
  { numero: 109, titolo: "I POLIGONI", slug: "nvi5_mat_p109", view_template: "nvi5_mat_p109", sottotitolo: "ESERCIZI", base_color: "orange" },
  { numero: 110, titolo: "IL PERIMETRO DEI POLIGONI", slug: "nvi5_mat_p110", view_template: "nvi5_mat_p110", sottotitolo: "GEOMETRIA", base_color: "pink" }
].each do |pagina_data|
  nvi5_matematica.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{nvi_volume5.nome}' con #{nvi5_matematica.pagine.count} pagine"
