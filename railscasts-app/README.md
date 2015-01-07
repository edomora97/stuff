# RailsCasts visualizer

Questa applicazione ti permette di avere i dati di RailsCasts in locale!

Tutti i diritti appartengono a railscasts.com
Un grazie super speciale a Ryan Bates per tutto il lavoro che ha fatto!

I dati per popolare il database non vengono forniti :( anche se le api messe
a disposizione sono abbastanza facili da usare... Ad esempio usando lo script
nel repository https://github.com/edomora97/stuff

## How to install

Installe le gem nel Gemfile! Puoi usare bundle!
```bash
bundle install
```

Rinomina il file config/database.exaple.yml in config/database.yml e aggiusta la
configurazione
```bash
mv config/database.exaple.yml config/database.yml
mate config/database.yml
```

## Requisiti
- Ruby
- Postgres (alcune funzioni sono specifiche di postgres come la ricerca)
- Bundler (molto consigliato)
