# GitHub-stat

Questo programma si occupa di scaricare da **GitHub** alcuni repository, viene poi
applicato un algoritmo per effettuare alcune statistiche sul codice e salvare
i risultati in un file Excel (formato `csv` e `xlsx`).


## Statistica

Le statistiche riguardano lo stile di programmazione utilizzato per scrivere i
1000 repository più popolari per ogni linguaggio.
Le caratteristiche analizzate sono:
- La posizione delle parentesi graffe
	- Alla fine della riga
	- A capo
	- Tutto in una riga
- I caratteri di indentazione
	- Tabulazioni
	- Spazi
	- Un mix di entrambi
- Gli spazi nelle parentesi tonde
	- (primo formato)
	- ( secondo formato )


## Funzionamento

L'analisi è effettuata da un *automa* che ha come input un file testuale (il
sorgente di un programma) e restituisce come output l'analisi statistica su
quel file:
- Numero di parentesi alla fine della riga
- Numero di parentesi all'inizio della riga (esclusa indentazione)
- Numero di parentesi in linea
- Numero di righe indentate con *TAB*
- Numero di righe indentate con *spazio*
- Numero di righe indentate con *TAB* e *spazio*
- Numero di parentesi con gli spazi
- Numero di parentesi senza spazi
- Numero di righe vuote (senza indentazione)
- Numero di righe vuote (con indentazione)


### Automa

L'automa è scritto in `C++` ed è formato da 2 parti:
- Una funzione che scorre ricorsivamente i file nella cartella del progetto,
 selezionando solo i file con delle determinate estensioni
- L'automa vero e proprio

La prima parte seleziona i file sorgente e per ogniuno di quelli esegue l'automa.
Infine somma i risultati dei vari file e stampa le statistiche:
- In stdout: le statistiche nel formato `csv`
- In stderr: le statistiche in un formato *umano*


### GitHub Crawler

La seconda parte del progetto è un crawler di **GitHub**. Utilizza le **API** di
GitHub per effettuare delle ricerche all'interno dei vari repository, selezionando
quelli più interessanti, scritti in un certo linguaggio di programmazione.

GitHub limita i risultati della ricerca a 1000 voci!

Per funzionare ha bisogno di un **TOKEN**, un codice unico per ogni utente,
necessario per effettuare le ricerche attraverso le API. Per generare un token
è necessario visitare https://github.com/settings/applications e premere su
`Generate new token` per creare un token. I permessi necessari per utilizzare
la API di ricerca non sono fondamentali (anche un utente non autenticato potrebbe
effettuare le ricerche), lasciare i permessi di default per sicurezza.

Memorizzare da qualche parte il token generato, **non sarà più visualizzato**!

Una volta che lo script ha scoperto quali sono i repository da analizzare, procede
sequenzialmente, dal più popolare, all'analisi.

Viene scaricato lo zip del progetto (solo il branch principale viene analizzato),
estratto e viene eseguito l'automa sullo zip decompresso.


### Runscript

Per comodità è presente un semplice `runscript` che permette di avviare facilmente
il crawler. Questo runscript è scritto in `bash` (o altra shell Bourne), può
quindi funzionare solo su sistemi Linux o Mac.

Lo script avviare sequenzialmente il crawler specificando il linguaggio di
programmazione e il numero massimo di repository.

Una volta completata l'analisi viene convertito il file `data.csv` in `data.xlsx`.

```
Usage: ./runscript.sh token [max_repo]
```

## Installazione

Per l'installazione dello script è necessario compliare il sorgente dell'automa,
installare ruby e le dipendenze necessarie per lo script.

### Automa

È disponibile un Makefile per facilitare la compilazione del sorgente. È
sufficiente eseguire
```sh
make
```
per avviare la compilazione dell'automa. È necessario aver installato `g++` e
`make` dal pacchetto `build-essential` o simile.

Per compilare manualmente il sorgente è necessario eseguire
```sh
g++ compute.cpp file.cpp -o compute -O3
```

Verrà creato l'eseguibile `compute` che si utilizza nel modo seguente:
```sh
./compute dir
```

Specificando `dir` si avvierà l'analisi all'interno della cartella `dir` e tutte
le sottocartelle.


### Crawler

Per l'utilizzo del crawler è necessario aver installato ruby (versione > ?) ed
alcune dipendenze:
- open-uri
- json
- base64

Non è ovviamente necessaria compilazione, è sufficiente aver installato ruby!


### Runscript

Questo runscript è scritto in bash, è quindi necessario aver installato bash, ed
essere in un sistema Linux o Mac. Per la conversione da `csv` a `xlsx` è necessario
aver installato il paccehtto `gnumeric` e `dos2unix`. Se non si indente convertire
in un formato Excel modificare in `no` la seguente riga in `runscript.sh`
```sh
CONVERT_TO_XLSX=yes
```


## Ambienti testati

Tutto il codice è stato verificato su `Ubuntu 14.04 LTS` con i seguenti pacchetti:
- gcc 4.8.2
- make 3.81
- ruby 2.1.5p273
