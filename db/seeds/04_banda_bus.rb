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
  { numero: 74, titolo: "Le Frazioni", slug: "bus3_mat_p074", view_template: "bus3_mat_p074", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 75, titolo: "Leggere e scrivere le frazioni", slug: "bus3_mat_p075", view_template: "bus3_mat_p075", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 76, titolo: "Frazioni - L'unità frazionaria", slug: "bus3_mat_p076", view_template: "bus3_mat_p076", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 77, titolo: "Le Frazioni Equiestese", slug: "bus3_mat_p077", view_template: "bus3_mat_p077", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 78, titolo: "Dall'Unità Frazionaria all'Intero", slug: "bus3_mat_p078", view_template: "bus3_mat_p078", sottotitolo: "FRAZIONI", base_color: "purple" },
  { numero: 144, titolo: "Proprietà dell'Addizione", slug: "bus3_mat_p144", view_template: "bus3_mat_p144", sottotitolo: "esercizi", base_color: "cyan" }
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
existing_pages = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 74, 75, 76, 77, 78, 144 ]
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
