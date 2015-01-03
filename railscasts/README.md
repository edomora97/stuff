# RailsCasts metadata downloader

Scarica alcuni dati relativi ad ogni episodio da railscasts. Salva le informazioni in un database mysql.

I dati salvati sono poi utlizzabili per fare ricerche all'interno del database di RailsCasts.

## Requisiti
- Ruby > 1.9.3
- Bash
- ActiveRecord gem
- MySQL database

## Installazione
- Creare un database usando `database.sql`
- Configurare l'accesso al database nel file `download.rb`
- Aggiornare, se necessario, il file input.txt
- Eseguire il comando `./script.sh` per avviare il processo
