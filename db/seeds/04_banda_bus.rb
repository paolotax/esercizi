# 3. BANDA DEL BUS 3
puts "\n📚 Creazione corso: Banda del BUS"
bus = Corso.create!(
  nome: "Banda del BUS",
  codice: "bus",
  descrizione: "Corso di matematica per la scuola primaria"
)

bus_volume3 = bus.volumi.create!(
  nome: "BUS 3",
  classe: 3,
  posizione: 3
)

bus_matematica = bus_volume3.discipline.create!(
  nome: "Matematica",
  codice: "mat",
  colore: "#3B82F6"
)

[
  { numero: 1, titolo: "Copertina", slug: "bus3_mat_p001", view_template: "bus3_mat_p001", base_color: "blue" },
  { numero: 2, titolo: "Indice", slug: "bus3_mat_p002", view_template: "bus3_mat_p002", base_color: "blue" },
  { numero: 4, titolo: "I NUMERI FINO A 99", sottotitolo: "PER RIPASSARE", slug: "bus3_mat_p004", view_template: "bus3_mat_p004", base_color: "cyan" },
  { numero: 5, titolo: "I NUMERI FINO A 99 - Esercizi", sottotitolo: "PER RIPASSARE", slug: "bus3_mat_p005", view_template: "bus3_mat_p005", base_color: "cyan" },
  { numero: 6, titolo: "IL SISTEMA DECIMALE", sottotitolo: "PER RIPASSARE", slug: "bus3_mat_p006", view_template: "bus3_mat_p006", base_color: "cyan" },
  { numero: 7, titolo: "IL SISTEMA POSIZIONALE", sottotitolo: "PER RIPASSARE", slug: "bus3_mat_p007", view_template: "bus3_mat_p007", base_color: "cyan" },
  { numero: 8, titolo: "UNITÀ, DECINE, CENTINAIA", sottotitolo: "PER RIPASSARE", slug: "bus3_mat_p008", view_template: "bus3_mat_p008", base_color: "cyan" },
  { numero: 9, titolo: "NUMERI E OPERAZIONI", sottotitolo: "PER RIPASSARE", slug: "bus3_mat_p009", view_template: "bus3_mat_p009", base_color: "cyan" },
  { numero: 10, titolo: "COMPORRE E SCOMPORRE", sottotitolo: "PER RIPASSARE", slug: "bus3_mat_p010", view_template: "bus3_mat_p010", base_color: "cyan" },
  { numero: 11, titolo: "CONFRONTARE E ORDINARE", sottotitolo: "PER RIPASSARE", slug: "bus3_mat_p011", view_template: "bus3_mat_p011", base_color: "cyan" },
  { numero: 12, titolo: "I NUMERI FINO A 999", sottotitolo: "PER RIPASSARE", slug: "bus3_mat_p012", view_template: "bus3_mat_p012", base_color: "cyan" },
  { numero: 13, titolo: "NUMERI - Esercizi", sottotitolo: "NUMERI", slug: "bus3_mat_p013", view_template: "bus3_mat_p013", base_color: "cyan" },
  { numero: 14, titolo: "IL MIGLIAIO", sottotitolo: "NUMERI", slug: "bus3_mat_p014", view_template: "bus3_mat_p014", base_color: "cyan" },
  { numero: 15, titolo: "IL NUMERO 1000", sottotitolo: "NUMERI", slug: "bus3_mat_p015", view_template: "bus3_mat_p015", base_color: "cyan" },
  { numero: 16, titolo: "OLTRE IL MILLE", sottotitolo: "NUMERI", slug: "bus3_mat_p016", view_template: "bus3_mat_p016", base_color: "cyan" },
  { numero: 17, titolo: "PRECEDENTE E SUCCESSIVO", sottotitolo: "NUMERI", slug: "bus3_mat_p017", view_template: "bus3_mat_p017", base_color: "cyan" },
  { numero: 18, titolo: "I NUMERI FINO A 9999", sottotitolo: "NUMERI", slug: "bus3_mat_p018", view_template: "bus3_mat_p018", base_color: "cyan" },
  { numero: 19, titolo: "CONFRONTARE NUMERI", sottotitolo: "NUMERI", slug: "bus3_mat_p019", view_template: "bus3_mat_p019", base_color: "cyan" },
  { numero: 20, titolo: "QUIZ MATEMATICO", sottotitolo: "PAROLE AL CENTRO", slug: "bus3_mat_p020", view_template: "bus3_mat_p020", base_color: "cyan" },
  { numero: 21, titolo: "GIOCO E RIPASSO", sottotitolo: "NUMERI", slug: "bus3_mat_p021", view_template: "bus3_mat_p021", base_color: "cyan" },
  { numero: 22, titolo: "L'ADDIZIONE", sottotitolo: "ADDIZIONE", slug: "bus3_mat_p022", view_template: "bus3_mat_p022", base_color: "blue" },
  { numero: 23, titolo: "ADDIZIONE - Esercizi", sottotitolo: "ADDIZIONE", slug: "bus3_mat_p023", view_template: "bus3_mat_p023", base_color: "blue" },
  { numero: 24, titolo: "LE PROPRIETÀ DELL'ADDIZIONE", sottotitolo: "ADDIZIONE", slug: "bus3_mat_p024", view_template: "bus3_mat_p024", base_color: "blue" },
  { numero: 25, titolo: "Addizioni in colonna", sottotitolo: "ADDIZIONE", slug: "bus3_mat_p025", view_template: "bus3_mat_p025", base_color: "blue" },
  { numero: 26, titolo: "Addizioni con il cambio", slug: "bus3_mat_p026", view_template: "bus3_mat_p026", base_color: "blue", sottotitolo: "ADDIZIONE" },
  { numero: 27, titolo: "LA PROVA DELL'ADDIZIONE", sottotitolo: "ADDIZIONE", slug: "bus3_mat_p027", view_template: "bus3_mat_p027", base_color: "red" },
  { numero: 28, titolo: "LA SOTTRAZIONE", sottotitolo: "SOTTRAZIONE", slug: "bus3_mat_p028", view_template: "bus3_mat_p028", base_color: "red" },
  { numero: 29, titolo: "Sottrazione - Proprietà", sottotitolo: "SOTTRAZIONE", slug: "bus3_mat_p029", view_template: "bus3_mat_p029", base_color: "red" },
  { numero: 30, titolo: "LA PROPRIETÀ DELLA SOTTRAZIONE", sottotitolo: "SOTTRAZIONE", slug: "bus3_mat_p030", view_template: "bus3_mat_p030", base_color: "red" },
  { numero: 31, titolo: "SOTTRAZIONI IN COLONNA", sottotitolo: "SOTTRAZIONE", slug: "bus3_mat_p031", view_template: "bus3_mat_p031", base_color: "red" },
  { numero: 32, titolo: "Sottrazioni con il cambio", slug: "bus3_mat_p032", view_template: "bus3_mat_p032", sottotitolo: "SOTTRAZIONE", base_color: "red" },
  { numero: 33, titolo: "LA PROVA DELLA SOTTRAZIONE", sottotitolo: "SOTTRAZIONE", slug: "bus3_mat_p033", view_template: "bus3_mat_p033", base_color: "red" },
  { numero: 34, titolo: "Calcoli veloci", slug: "bus3_mat_p034", view_template: "bus3_mat_p034", sottotitolo: "ADDIZIONE E SOTTRAZIONE", base_color: "blue" },
  { numero: 35, titolo: "Calcoli veloci", slug: "bus3_mat_p035", view_template: "bus3_mat_p035", sottotitolo: "ADDIZIONE E SOTTRAZIONE", base_color: "blue" },
  { numero: 36, titolo: "OPERAZIONI A CONFRONTO", sottotitolo: "ADDIZIONE E SOTTRAZIONE", slug: "bus3_mat_p036", view_template: "bus3_mat_p036", base_color: "blue" },
  { numero: 37, titolo: "QUANTE OPERAZIONI!", sottotitolo: "ADDIZIONE E SOTTRAZIONE", slug: "bus3_mat_p037", view_template: "bus3_mat_p037", base_color: "blue" },
  { numero: 38, titolo: "PROBLEMI", sottotitolo: "ADDIZIONE E SOTTRAZIONE", slug: "bus3_mat_p038", view_template: "bus3_mat_p038", base_color: "blue" },
  { numero: 39, titolo: "PROBLEMI", sottotitolo: "ADDIZIONE E SOTTRAZIONE", slug: "bus3_mat_p039", view_template: "bus3_mat_p039", base_color: "blue" },
  { numero: 40, titolo: "SAI LEGGERE NEL PENSIERO?", sottotitolo: "PAROLE AL CENTRO", slug: "bus3_mat_p040", view_template: "bus3_mat_p040", base_color: "purple" },
  { numero: 41, titolo: "GIOCO E RIPASSO", sottotitolo: "PAROLE AL CENTRO", slug: "bus3_mat_p041", view_template: "bus3_mat_p041", base_color: "purple" },
  { numero: 42, titolo: "LA MOLTIPLICAZIONE", sottotitolo: "MOLTIPLICAZIONE", slug: "bus3_mat_p042", view_template: "bus3_mat_p042", base_color: "green" },
  { numero: 43, titolo: "SCHIERAMENTI E INCROCI", sottotitolo: "MOLTIPLICAZIONE", slug: "bus3_mat_p043", view_template: "bus3_mat_p043", base_color: "green" },
  { numero: 44, titolo: "LE PROPRIETÀ... COMMUTATIVA E ASSOCIATIVA", sottotitolo: "MOLTIPLICAZIONE", slug: "bus3_mat_p044", view_template: "bus3_mat_p044", base_color: "green" },
  { numero: 45, titolo: "... DELLA MOLTIPLICAZIONE DISTRIBUTIVA", sottotitolo: "MOLTIPLICAZIONE", slug: "bus3_mat_p045", view_template: "bus3_mat_p045", base_color: "green" },
  { numero: 46, titolo: "LA TABELLA DELLA MOLTIPLICAZIONE", sottotitolo: "MOLTIPLICAZIONE", slug: "bus3_mat_p046", view_template: "bus3_mat_p046", base_color: "green" },
  { numero: 47, titolo: "MOLTIPLICAZIONI CON UNA CIFRA AL MOLTIPLICATORE", sottotitolo: "MOLTIPLICAZIONE", slug: "bus3_mat_p047", view_template: "bus3_mat_p047", base_color: "green" },
  { numero: 48, titolo: "MOLTIPLICAZIONI CON DUE CIFRE AL MOLTIPLICATORE", sottotitolo: "MOLTIPLICAZIONE", slug: "bus3_mat_p048", view_template: "bus3_mat_p048", base_color: "green" },
  { numero: 49, titolo: "MOLTIPLICARE PER 10, 100, 1000", sottotitolo: "MOLTIPLICAZIONE", slug: "bus3_mat_p049", view_template: "bus3_mat_p049", base_color: "green" },
  { numero: 50, titolo: "IL GIOCO DELL'OCA DELLA MOLTIPLICAZIONE", sottotitolo: "PAROLE AL CENTRO", slug: "bus3_mat_p050", view_template: "bus3_mat_p050", base_color: "blue" },
  { numero: 51, titolo: "GIOCO E RIPASSO", sottotitolo: "PAROLE AL CENTRO", slug: "bus3_mat_p051", view_template: "bus3_mat_p051", base_color: "blue" },
  { numero: 52, titolo: "LA DIVISIONE", sottotitolo: "DIVISIONE", slug: "bus3_mat_p052", view_template: "bus3_mat_p052", base_color: "cyan" },
  { numero: 53, titolo: "IL RESTO DELLA DIVISIONE", sottotitolo: "DIVISIONE", slug: "bus3_mat_p053", view_template: "bus3_mat_p053", base_color: "cyan" },
  { numero: 54, titolo: "LA PROPRIETÀ INVARIANTIVA", sottotitolo: "DIVISIONE", slug: "bus3_mat_p054", view_template: "bus3_mat_p054", base_color: "cyan" },
  { numero: 55, titolo: "OPERAZIONI A CONFRONTO", sottotitolo: "DIVISIONE", slug: "bus3_mat_p055", view_template: "bus3_mat_p055", base_color: "cyan" },
  { numero: 56, titolo: "DIVISIONI IN COLONNA", sottotitolo: "DIVISIONE", slug: "bus3_mat_p056", view_template: "bus3_mat_p056", base_color: "cyan" },
  { numero: 57, titolo: "ANCORA DIVISIONI IN COLONNA", sottotitolo: "DIVISIONE", slug: "bus3_mat_p057", view_template: "bus3_mat_p057", base_color: "cyan" },
  { numero: 58, titolo: "CONSIDERO DUE CIFRE AL DIVIDENDO", sottotitolo: "DIVISIONE", slug: "bus3_mat_p058", view_template: "bus3_mat_p058", base_color: "cyan" },
  { numero: 59, titolo: "DIVIDERE PER 10, 100, 1000", sottotitolo: "DIVISIONE", slug: "bus3_mat_p059", view_template: "bus3_mat_p059", base_color: "cyan" },
  { numero: 60, titolo: "PROBLEMI", sottotitolo: "MOLTIPLICAZIONE E DIVISIONE", slug: "bus3_mat_p060", view_template: "bus3_mat_p060", base_color: "blue" },
  { numero: 61, titolo: "PROBLEMI", sottotitolo: "MOLTIPLICAZIONE E DIVISIONE", slug: "bus3_mat_p061", view_template: "bus3_mat_p061", base_color: "blue" },
  { numero: 62, titolo: "ANDIAMO A TEATRO!", sottotitolo: "mateVIVA", slug: "bus3_mat_p062", view_template: "bus3_mat_p062", base_color: "green" },
  { numero: 63, titolo: "ANDIAMO A TEATRO!", sottotitolo: "MATEMATICA DI TUTTI I GIORNI", slug: "bus3_mat_p063", view_template: "bus3_mat_p063", base_color: "green" },
  { numero: 64, titolo: "LA MERENDA", sottotitolo: "PROBLEMI", slug: "bus3_mat_p064", view_template: "bus3_mat_p064", base_color: "blue" },
  { numero: 65, titolo: "LA TAVOLA DEI 7 NANI", sottotitolo: "PROBLEMI", slug: "bus3_mat_p065", view_template: "bus3_mat_p065", base_color: "blue" },
  { numero: 66, titolo: "LE MASCHERE DI CARNEVALE", sottotitolo: "PROBLEMI", slug: "bus3_mat_p066", view_template: "bus3_mat_p066", base_color: "blue" },
  { numero: 67, titolo: "LE PALLINE", sottotitolo: "PROBLEMI", slug: "bus3_mat_p067", view_template: "bus3_mat_p067", base_color: "blue" },
  { numero: 68, titolo: "I DATI DEL PROBLEMA", sottotitolo: "PROBLEMI", slug: "bus3_mat_p068", view_template: "bus3_mat_p068", base_color: "blue" },
  { numero: 69, titolo: "I DATI DEL PROBLEMA", sottotitolo: "PROBLEMI", slug: "bus3_mat_p069", view_template: "bus3_mat_p069", base_color: "blue" },
  { numero: 70, titolo: "LA DOMANDA DEL PROBLEMA", sottotitolo: "PROBLEMI", slug: "bus3_mat_p070", view_template: "bus3_mat_p070", base_color: "blue" },
  { numero: 71, titolo: "QUANTE DOMANDE?", sottotitolo: "PROBLEMI", slug: "bus3_mat_p071", view_template: "bus3_mat_p071", base_color: "blue" },
  { numero: 72, titolo: "LA DOMANDA NASCOSTA", sottotitolo: "PROBLEMI", slug: "bus3_mat_p072", view_template: "bus3_mat_p072", base_color: "blue" },
  { numero: 73, titolo: "RISOLVERE PROBLEMI", sottotitolo: "PROBLEMI", slug: "bus3_mat_p073", view_template: "bus3_mat_p073", base_color: "blue" },
  { numero: 74, titolo: "Le Frazioni", slug: "bus3_mat_p074", view_template: "bus3_mat_p074", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 75, titolo: "Leggere e scrivere le frazioni", slug: "bus3_mat_p075", view_template: "bus3_mat_p075", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 76, titolo: "Frazioni - L'unità frazionaria", slug: "bus3_mat_p076", view_template: "bus3_mat_p076", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 77, titolo: "Le Frazioni Equiestese", slug: "bus3_mat_p077", view_template: "bus3_mat_p077", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 78, titolo: "Dall'Unità Frazionaria all'Intero", slug: "bus3_mat_p078", view_template: "bus3_mat_p078", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 79, titolo: "LE FRAZIONI EQUINUMEROSE", slug: "bus3_mat_p079", view_template: "bus3_mat_p079", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 80, titolo: "LE FRAZIONI DECIMALI", slug: "bus3_mat_p080", view_template: "bus3_mat_p080", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 81, titolo: "I DECIMI", slug: "bus3_mat_p081", view_template: "bus3_mat_p081", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 82, titolo: "I CENTESIMI", slug: "bus3_mat_p082", view_template: "bus3_mat_p082", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 83, titolo: "I MILLESIMI", slug: "bus3_mat_p083", view_template: "bus3_mat_p083", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 84, titolo: "I NUMERI DECIMALI", slug: "bus3_mat_p084", view_template: "bus3_mat_p084", sottotitolo: "NUMERI DECIMALI", base_color: "purple" },
  { numero: 85, titolo: "I NUMERI DECIMALI", slug: "bus3_mat_p085", view_template: "bus3_mat_p085", sottotitolo: "NUMERI DECIMALI", base_color: "purple" },
  { numero: 86, titolo: "I NUMERI DECIMALI E L'EURO", slug: "bus3_mat_p086", view_template: "bus3_mat_p086", sottotitolo: "NUMERI DECIMALI", base_color: "purple" },
  { numero: 87, titolo: "I NUMERI DECIMALI E L'EURO", slug: "bus3_mat_p087", view_template: "bus3_mat_p087", sottotitolo: "NUMERI DECIMALI", base_color: "purple" },
  { numero: 88, titolo: "FRAZIONI IN PASTICCERIA", slug: "bus3_mat_p088", view_template: "bus3_mat_p088", sottotitolo: "PAROLE AL CENTRO", base_color: "purple" },
  { numero: 89, titolo: "GIOCO E RIPASSO", slug: "bus3_mat_p089", view_template: "bus3_mat_p089", sottotitolo: "PAROLE AL CENTRO", base_color: "purple" },
  { numero: 90, titolo: "LE FIGURE SOLIDE", slug: "bus3_mat_p090", view_template: "bus3_mat_p090", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 91, titolo: "FIGURE PIANE E SOLIDE", slug: "bus3_mat_p091", view_template: "bus3_mat_p091", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 92, titolo: "SEGMENTO, SEMIRETTA, RETTA", slug: "bus3_mat_p092", view_template: "bus3_mat_p092", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 93, titolo: "RETTE PARALLELE, INCIDENTI, PERPENDICOLARI", slug: "bus3_mat_p093", view_template: "bus3_mat_p093", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 94, titolo: "GLI ANGOLI", slug: "bus3_mat_p094", view_template: "bus3_mat_p094", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 95, titolo: "ANGOLO ACUTO E ANGOLO OTTUSO", slug: "bus3_mat_p095", view_template: "bus3_mat_p095", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 96, titolo: "I POLIGONI", slug: "bus3_mat_p096", view_template: "bus3_mat_p096", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 97, titolo: "GLI ELEMENTI DI UN POLIGONO", slug: "bus3_mat_p097", view_template: "bus3_mat_p097", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 98, titolo: "POLIGONI ARTISTICI!", slug: "bus3_mat_p098", view_template: "bus3_mat_p098", sottotitolo: "mateVIVA", base_color: "green" },
  { numero: 99, titolo: "TASSELLAZIONI", slug: "bus3_mat_p099", view_template: "bus3_mat_p099", sottotitolo: "mateVIVA", base_color: "green" },
  { numero: 100, titolo: "IL PERIMETRO", slug: "bus3_mat_p100", view_template: "bus3_mat_p100", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 101, titolo: "L'AREA", slug: "bus3_mat_p101", view_template: "bus3_mat_p101", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 102, titolo: "LE FIGURE EQUIESTESE", slug: "bus3_mat_p102", view_template: "bus3_mat_p102", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 103, titolo: "LE FIGURE SIMMETRICHE", slug: "bus3_mat_p103", view_template: "bus3_mat_p103", sottotitolo: "SPAZIO E FIGURE", base_color: "cyan" },
  { numero: 104, titolo: "AGUZZA LA VISTA", slug: "bus3_mat_p104", view_template: "bus3_mat_p104", sottotitolo: "PAROLE AL CENTRO", base_color: "cyan" },
  { numero: 105, titolo: "GIOCO E RIPASSO", slug: "bus3_mat_p105", view_template: "bus3_mat_p105", sottotitolo: "GIOCO E RIPASSO", base_color: "cyan" },
  { numero: 130, titolo: "FACCIAMO I CONTI!", slug: "bus3_mat_p130", view_template: "bus3_mat_p130", sottotitolo: "ECONOMIA A PICCOLI PASSI", base_color: "cyan" },
  { numero: 131, titolo: "IL SALVADANAIO", slug: "bus3_mat_p131", view_template: "bus3_mat_p131", sottotitolo: "ECONOMIA A PICCOLI PASSI", base_color: "cyan" },
  { numero: 132, titolo: "L'ECONOMIA CIRCOLARE", slug: "bus3_mat_p132", view_template: "bus3_mat_p132", sottotitolo: "ECONOMIA A PICCOLI PASSI", base_color: "cyan" },
  { numero: 133, titolo: "PERCORSI IN LABORATORIO", slug: "bus3_mat_p133", view_template: "bus3_mat_p133", sottotitolo: "CODING", base_color: "cyan" },
  { numero: 134, titolo: "ADDIZIONE", slug: "bus3_mat_p134", view_template: "bus3_mat_p134", sottotitolo: "SCHEMI", base_color: "cyan" },
  { numero: 135, titolo: "SOTTRAZIONE", slug: "bus3_mat_p135", view_template: "bus3_mat_p135", sottotitolo: "SCHEMI", base_color: "cyan" },
  { numero: 136, titolo: "MOLTIPLICAZIONE", slug: "bus3_mat_p136", view_template: "bus3_mat_p136", sottotitolo: "SCHEMI", base_color: "cyan" },
  { numero: 137, titolo: "DIVISIONE", slug: "bus3_mat_p137", view_template: "bus3_mat_p137", sottotitolo: "SCHEMI", base_color: "cyan" },
  { numero: 138, titolo: "FRAZIONI", slug: "bus3_mat_p138", view_template: "bus3_mat_p138", sottotitolo: "SCHEMI", base_color: "cyan" },
  { numero: 139, titolo: "SOLIDO", slug: "bus3_mat_p139", view_template: "bus3_mat_p139", sottotitolo: "SCHEMI", base_color: "cyan" },
  { numero: 140, titolo: "NUMERI FINO A 999", slug: "bus3_mat_p140", view_template: "bus3_mat_p140", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 141, titolo: "MILLE E OLTRE", slug: "bus3_mat_p141", view_template: "bus3_mat_p141", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 142, titolo: "CONFRONTO E ORDINO", slug: "bus3_mat_p142", view_template: "bus3_mat_p142", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 143, titolo: "L'ADDIZIONE", slug: "bus3_mat_p143", view_template: "bus3_mat_p143", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 144, titolo: "Proprietà dell'Addizione", slug: "bus3_mat_p144", view_template: "bus3_mat_p144", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 145, titolo: "LA SOTTRAZIONE", slug: "bus3_mat_p145", view_template: "bus3_mat_p145", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 146, titolo: "PROPRIETÀ DELLA SOTTRAZIONE", slug: "bus3_mat_p146", view_template: "bus3_mat_p146", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 147, titolo: "ADDIZIONE O SOTTRAZIONE?", slug: "bus3_mat_p147", view_template: "bus3_mat_p147", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 148, titolo: "LA MOLTIPLICAZIONE", slug: "bus3_mat_p148", view_template: "bus3_mat_p148", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 149, titolo: "PROPRIETÀ DELLA MOLTIPLICAZIONE", slug: "bus3_mat_p149", view_template: "bus3_mat_p149", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 150, titolo: "TANTE MOLTIPLICAZIONI", slug: "bus3_mat_p150", view_template: "bus3_mat_p150", sottotitolo: "ESERCIZI", base_color: "cyan" },
  { numero: 151, titolo: "CON IL MOLTIPLICATORE A DUE CIFRE", slug: "bus3_mat_p151", view_template: "bus3_mat_p151", sottotitolo: "ESERCIZI", base_color: "cyan" }
].each do |pagina_data|
  bus_matematica.pagine.find_or_create_by!(slug: pagina_data[:slug]) do |pagina|
    pagina.numero = pagina_data[:numero]
    pagina.titolo = pagina_data[:titolo]
    pagina.view_template = pagina_data[:view_template]
    pagina.base_color = pagina_data[:base_color] if pagina_data[:base_color]
    pagina.sottotitolo = pagina_data[:sottotitolo] if pagina_data[:sottotitolo]
  end
end

# Pagine generiche per bus3_mat (p001-p192, escludendo le pagine già definite sopra)
existing_pages = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144 ]
generic_pages_created = 0

(1..192).each do |numero|
  next if existing_pages.include?(numero)

  numero_str = numero.to_s.rjust(3, '0')
  slug = "bus3_mat_p#{numero_str}"
  view_template = "bus3_mat_p#{numero_str}"

  # Usa find_or_create_by per rendere il seed idempotente
  bus_matematica.pagine.find_or_create_by(slug: slug) do |pagina|
    pagina.numero = numero
    pagina.titolo = "Pagina #{numero}"
    pagina.view_template = view_template
  end

  generic_pages_created += 1
end

puts "  ✓ Creato volume '#{bus_volume3.nome}' con #{bus_matematica.pagine.count} pagine"
puts "  ✓ Aggiunte #{generic_pages_created} pagine generiche"

# 3b. BANDA DEL BUS 2
bus_volume2 = bus.volumi.create!(
  nome: "BUS 2",
  classe: 2,
  posizione: 2
)

bus2_lettura_grammatica = bus_volume2.discipline.create!(
  nome: "Lettura e Grammatica",
  codice: "lettgr",
  colore: "#F59E0B"
)

[
  { numero: 96, titolo: "Il Rimedio Più Bello (pag. 96-97)", slug: "bus2_lettgr_p096", view_template: "bus2_lettgr_p096" }
].each do |pagina_data|
  bus2_lettura_grammatica.pagine.create!(pagina_data)
end

puts "  ✓ Creato volume '#{bus_volume2.nome}' con #{bus2_lettura_grammatica.pagine.count} pagine"
