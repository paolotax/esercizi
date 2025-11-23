# Seeds per Template Esercizi

puts "Creazione template esercizi..."

# Template per ADDIZIONI
EsercizioTemplate.create!(
  name: "Addizioni entro il 10",
  description: "Addizioni semplici con risultato fino a 10",
  category: "Base",
  default_config: {
    operations: [
      {
        type: "addizione",
        config: {
          min_value: 1,
          max_value: 10,
          allow_carry: false,
          count: 5
        }
      }
    ]
  }
)

EsercizioTemplate.create!(
  name: "Addizioni entro il 20",
  description: "Addizioni con risultato fino a 20",
  category: "Base",
  default_config: {
    operations: [
      {
        type: "addizione",
        config: {
          min_value: 1,
          max_value: 20,
          allow_carry: false,
          count: 6
        }
      }
    ]
  }
)

EsercizioTemplate.create!(
  name: "Addizioni con riporto",
  description: "Addizioni a due cifre con riporto",
  category: "Intermedio",
  default_config: {
    operations: [
      {
        type: "addizione",
        config: {
          min_value: 10,
          max_value: 99,
          allow_carry: true,
          count: 4
        }
      }
    ]
  }
)

# Template per SOTTRAZIONI
EsercizioTemplate.create!(
  name: "Sottrazioni entro il 10",
  description: "Sottrazioni semplici con minuendo fino a 10",
  category: "Base",
  default_config: {
    operations: [
      {
        type: "sottrazione",
        config: {
          min_value: 1,
          max_value: 10,
          allow_borrow: false,
          count: 5
        }
      }
    ]
  }
)

EsercizioTemplate.create!(
  name: "Sottrazioni entro il 20",
  description: "Sottrazioni con minuendo fino a 20",
  category: "Base",
  default_config: {
    operations: [
      {
        type: "sottrazione",
        config: {
          min_value: 1,
          max_value: 20,
          allow_borrow: false,
          count: 6
        }
      }
    ]
  }
)

EsercizioTemplate.create!(
  name: "Sottrazioni con prestito",
  description: "Sottrazioni a due cifre con prestito",
  category: "Intermedio",
  default_config: {
    operations: [
      {
        type: "sottrazione",
        config: {
          min_value: 10,
          max_value: 99,
          allow_borrow: true,
          count: 4
        }
      }
    ]
  }
)

# Template per MOLTIPLICAZIONI
EsercizioTemplate.create!(
  name: "Tabelline del 2 e 3",
  description: "Moltiplicazioni con 2 e 3",
  category: "Base",
  default_config: {
    operations: [
      {
        type: "moltiplicazione",
        config: {
          min_table: 2,
          max_table: 3,
          min_multiplier: 1,
          max_multiplier: 10,
          count: 6
        }
      }
    ]
  }
)

EsercizioTemplate.create!(
  name: "Tabelline fino al 5",
  description: "Moltiplicazioni con numeri fino a 5",
  category: "Base",
  default_config: {
    operations: [
      {
        type: "moltiplicazione",
        config: {
          min_table: 1,
          max_table: 5,
          min_multiplier: 1,
          max_multiplier: 10,
          count: 8
        }
      }
    ]
  }
)

EsercizioTemplate.create!(
  name: "Tabelline complete",
  description: "Tutte le tabelline fino al 10",
  category: "Intermedio",
  default_config: {
    operations: [
      {
        type: "moltiplicazione",
        config: {
          min_table: 1,
          max_table: 10,
          min_multiplier: 1,
          max_multiplier: 10,
          count: 10
        }
      }
    ]
  }
)

# Template per ABACO
EsercizioTemplate.create!(
  name: "Abaco fino a 10",
  description: "Rappresentazione numeri fino a 10 con abaco",
  category: "Base",
  default_config: {
    operations: [
      {
        type: "abaco",
        config: {
          min_value: 1,
          max_value: 10,
          show_hundreds: false,
          count: 4
        }
      }
    ]
  }
)

EsercizioTemplate.create!(
  name: "Abaco fino a 100",
  description: "Rappresentazione numeri fino a 100 con abaco",
  category: "Intermedio",
  default_config: {
    operations: [
      {
        type: "abaco",
        config: {
          min_value: 10,
          max_value: 100,
          show_hundreds: false,
          count: 4
        }
      }
    ]
  }
)

EsercizioTemplate.create!(
  name: "Abaco fino a 1000",
  description: "Rappresentazione numeri fino a 1000 con abaco",
  category: "Avanzato",
  default_config: {
    operations: [
      {
        type: "abaco",
        config: {
          min_value: 100,
          max_value: 999,
          show_hundreds: true,
          count: 4
        }
      }
    ]
  }
)

# Template MISTI
EsercizioTemplate.create!(
  name: "Esercitazione Base Mista",
  description: "Mix di addizioni e sottrazioni semplici",
  category: "Esercitazione",
  default_config: {
    operations: [
      {
        type: "addizione",
        config: {
          min_value: 1,
          max_value: 20,
          allow_carry: false,
          count: 3
        }
      },
      {
        type: "sottrazione",
        config: {
          min_value: 1,
          max_value: 20,
          allow_borrow: false,
          count: 3
        }
      }
    ]
  }
)

EsercizioTemplate.create!(
  name: "Verifica Matematica Base",
  description: "Verifica completa con tutte le operazioni base",
  category: "Verifica",
  default_config: {
    operations: [
      {
        type: "addizione",
        config: {
          min_value: 1,
          max_value: 50,
          allow_carry: true,
          count: 3
        }
      },
      {
        type: "sottrazione",
        config: {
          min_value: 1,
          max_value: 50,
          allow_borrow: true,
          count: 3
        }
      },
      {
        type: "moltiplicazione",
        config: {
          min_table: 1,
          max_table: 5,
          min_multiplier: 1,
          max_multiplier: 10,
          count: 3
        }
      },
      {
        type: "abaco",
        config: {
          min_value: 10,
          max_value: 100,
          show_hundreds: false,
          count: 2
        }
      }
    ]
  }
)

EsercizioTemplate.create!(
  name: "Compiti Veloci",
  description: "Esercizi rapidi per compiti a casa",
  category: "Compiti",
  default_config: {
    operations: [
      {
        type: "addizione",
        config: {
          min_value: 1,
          max_value: 30,
          allow_carry: false,
          count: 2
        }
      },
      {
        type: "sottrazione",
        config: {
          min_value: 1,
          max_value: 30,
          allow_borrow: false,
          count: 2
        }
      },
      {
        type: "moltiplicazione",
        config: {
          min_table: 2,
          max_table: 5,
          min_multiplier: 1,
          max_multiplier: 10,
          count: 2
        }
      }
    ]
  }
)

puts "✅ Creati #{EsercizioTemplate.count} template esercizi!"