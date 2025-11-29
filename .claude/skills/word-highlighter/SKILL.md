# Skill: Word Highlighter

Trasforma esercizi "Cerchia/Sottolinea/Colora" in esercizi interattivi con word-highlighter multi-colore.

## Quando Usare

Esercizi che chiedono di:
- Cerchiare/colorare cifre specifiche (centinaia, decimi, ecc.)
- Sottolineare parti di numeri (parte intera, decimale)
- Evidenziare frasi o parole con colori diversi

## Struttura Base

```html
<div class="..." data-controller="word-highlighter" data-word-highlighter-multi-color-value="true">

  <!-- Header con color boxes nel titolo -->
  <p class="text-gray-700"><strong>Colora di
    <span class="w-5 h-5 bg-blue-300 rounded inline-block align-middle cursor-pointer ring-2 ring-transparent hover:ring-blue-500"
          data-word-highlighter-target="colorBox"
          data-color="blue"
          data-action="click->word-highlighter#selectColor"></span>
    <span class="text-blue-500">blu la parte intera</span> e di
    <span class="w-5 h-5 bg-yellow-300 rounded inline-block align-middle cursor-pointer ring-2 ring-transparent hover:ring-yellow-500"
          data-word-highlighter-target="colorBox"
          data-color="yellow"
          data-action="click->word-highlighter#selectColor"></span>
    <span class="text-yellow-500">giallo la parte decimale</span>.</strong></p>

  <!-- Contenuto cliccabile -->
  <div class="cursor-pointer">
    <!-- Elementi cliccabili -->
    <span data-word-highlighter-target="word"
          data-correct="blue"
          data-action="click->word-highlighter#toggleHighlight">testo</span>
  </div>
</div>
```

## Colori Disponibili

| Colore | bg-class | text-class | hover-ring |
|--------|----------|------------|------------|
| blue | bg-blue-300 | text-blue-500 | hover:ring-blue-500 |
| yellow | bg-yellow-300 | text-yellow-500 | hover:ring-yellow-500 |
| red | bg-red-300 | text-red-500 | hover:ring-red-500 |
| green | bg-green-300 | text-green-500 | hover:ring-green-500 |
| pink | bg-pink-300 | text-pink-500 | hover:ring-pink-500 |
| purple | bg-purple-300 | text-purple-500 | hover:ring-purple-500 |
| orange | bg-orange-300 | text-orange-500 | hover:ring-orange-500 |
| cyan | bg-cyan-300 | text-cyan-500 | hover:ring-cyan-500 |

## Tipi di Esercizi

### 1. Cifre Singole (Numeri Decimali)

Per numeri come 2,41 dove ogni cifra deve essere cliccabile:

```html
<!-- Numero 2,41: parte intera=2(blue), decimale=4,1(yellow) -->
<div class="p-3 bg-gray-50 rounded">
  <span data-word-highlighter-target="word" data-correct="blue"
        data-action="click->word-highlighter#toggleHighlight" class="px-1 cursor-pointer">2</span>
  <span class="text-red-500">,</span>
  <span data-word-highlighter-target="word" data-correct="yellow"
        data-action="click->word-highlighter#toggleHighlight" class="px-1 cursor-pointer">4</span>
  <span data-word-highlighter-target="word" data-correct="yellow"
        data-action="click->word-highlighter#toggleHighlight" class="px-1 cursor-pointer">1</span>
</div>
```

### 2. Cifre per Posizione (Centinaia, Decine, Unita)

Per numeri interi dove si colorano posizioni specifiche:

```html
<!-- 152: centinaia=1(green), decine=5, unita=2 -->
<span>
  <span data-word-highlighter-target="word" data-correct="green"
        data-action="click->word-highlighter#toggleHighlight" class="px-1 cursor-pointer">1</span>
  <span data-word-highlighter-target="word" data-correct=""
        data-action="click->word-highlighter#toggleHighlight" class="px-1 cursor-pointer">5</span>
  <span data-word-highlighter-target="word" data-correct=""
        data-action="click->word-highlighter#toggleHighlight" class="px-1 cursor-pointer">2</span>
</span>
```

### 3. Frasi/Parole Intere

Per sottolineare frasi o domande:

```html
<div class="p-4 bg-gray-50 rounded cursor-pointer">
  <p>
    <span data-word-highlighter-target="word" data-correct=""
          data-action="click->word-highlighter#toggleHighlight">Frase introduttiva non da colorare.</span>
    <span data-word-highlighter-target="word" data-correct="blue"
          data-action="click->word-highlighter#toggleHighlight">Prima domanda da colorare?</span>
  </p>
</div>
```

## Regole Importanti

1. **data-correct=""** per elementi che NON devono essere colorati (ma sono comunque cliccabili)
2. **data-correct="colore"** per elementi che devono essere colorati con quel colore
3. **cursor-pointer** sul contenitore quando ci sono frasi, sugli span quando ci sono cifre
4. La **virgola** nei decimali NON e cliccabile: `<span class="text-red-500">,</span>`
5. Cambiare "Cerchia/Sottolinea" con **"Colora"** nel titolo
6. I **color boxes** vanno nel titolo dell'esercizio, inline con il testo

## Mappatura Posizioni Numeri

### Numeri Decimali (es. 15,62)
- Cifre prima della virgola = parte intera
- Cifre dopo la virgola:
  - 1a cifra = decimi
  - 2a cifra = centesimi
  - 3a cifra = millesimi

### Numeri Interi (es. 3848)
Da destra a sinistra:
- 1a cifra = unita
- 2a cifra = decine
- 3a cifra = centinaia
- 4a cifra = migliaia

## Esempio Completo

```html
<!-- Esercizio: Colora parte intera (blu) e decimale (giallo) -->
<div class="p-4 md:p-6 mb-8" data-controller="word-highlighter" data-word-highlighter-multi-color-value="true">
  <div class="flex items-center gap-3 mb-6">
    <div class="bg-red-500 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold">2</div>
    <p class="text-gray-700"><strong>Colora di
      <span class="w-5 h-5 bg-blue-300 rounded inline-block align-middle cursor-pointer ring-2 ring-transparent hover:ring-blue-500"
            data-word-highlighter-target="colorBox"
            data-color="blue"
            data-action="click->word-highlighter#selectColor"></span>
      <span class="text-blue-500">blu la parte intera</span> e di
      <span class="w-5 h-5 bg-yellow-300 rounded inline-block align-middle cursor-pointer ring-2 ring-transparent hover:ring-yellow-500"
            data-word-highlighter-target="colorBox"
            data-color="yellow"
            data-action="click->word-highlighter#selectColor"></span>
      <span class="text-yellow-500">giallo la parte decimale</span>.</strong></p>
  </div>

  <div class="grid grid-cols-3 md:grid-cols-4 gap-4 text-center text-xl">
    <!-- 7,09 -->
    <div class="p-3 bg-gray-50 rounded">
      <span data-word-highlighter-target="word" data-correct="blue" data-action="click->word-highlighter#toggleHighlight" class="px-1 cursor-pointer">7</span>
      <span class="text-red-500">,</span>
      <span data-word-highlighter-target="word" data-correct="yellow" data-action="click->word-highlighter#toggleHighlight" class="px-1 cursor-pointer">0</span>
      <span data-word-highlighter-target="word" data-correct="yellow" data-action="click->word-highlighter#toggleHighlight" class="px-1 cursor-pointer">9</span>
    </div>
  </div>
</div>
```
