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
  { numero: 68, titolo: "Lo Sconto e l'Interesse", slug: "nvi5_mat_p068", view_template: "nvi5_mat_p068" },
  { numero: 69, titolo: "Esercizi sulla Percentuale", slug: "nvi5_mat_p069", view_template: "nvi5_mat_p069" },
  { numero: 70, titolo: "Verifica - Frazioni e Percentuale", slug: "nvi5_mat_p070", view_template: "nvi5_mat_p070" },
  { numero: 71, titolo: "Modello INVALSI - Frazioni e Percentuale", slug: "nvi5_mat_p071", view_template: "nvi5_mat_p071" },
  { numero: 72, titolo: "Risolvere Problemi - Usare le Immagini", slug: "nvi5_mat_p072", view_template: "nvi5_mat_p072" },
  { numero: 73, titolo: "Esercizi - Risolvere Problemi", slug: "nvi5_mat_p073", view_template: "nvi5_mat_p073" },
  { numero: 74, titolo: "Riflettere sui Dati e sul Risultato", slug: "nvi5_mat_p074", view_template: "nvi5_mat_p074" },
  { numero: 75, titolo: "Problemi con Divisione", slug: "nvi5_mat_p075", view_template: "nvi5_mat_p075", sottotitolo: "RISOLVERE PROBLEMI", base_color: "orange" },
  { numero: 76, titolo: "TUTTOPROBLEMI", slug: "nvi5_mat_p076", view_template: "nvi5_mat_p076", sottotitolo: "RISOLVERE PROBLEMI", base_color: "green" },
  { numero: 77, titolo: "TUTTOPROBLEMI", slug: "nvi5_mat_p077", view_template: "nvi5_mat_p077", sottotitolo: "RISOLVERE PROBLEMI", base_color: "indigo" }
].each do |pagina_data|
  nvi5_matematica.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{nvi_volume5.nome}' con #{nvi5_matematica.pagine.count} pagine"
