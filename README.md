# HEIDENHAIN-TNC-Backup
Backup von TNC: als inkrementelles Verzeichnis oder ZIP-Archiv mit TimeStamp der Maschine
## Wozu?
Ich benötigte ein Tool, welches über die Windows Aufgabenplanung täglich ein Backup der TNC: unserer Maschinen erstellt.
Die Varianten von Heidenhein machen das, doch gibt es kein Datum von der Maschine sondern das aktuelle Erstelldatum.
Ich wollte aber dass ich genau den Timestamp der Maschine habe.
## Benötigte Programme:
Da ich mit Windows Boardmitteln nicht weiter gekommen bin habe ich denn doch verschiedene Linux Tools benutzt.

Benötigt werden `gawk.exe` und `touch.exe`.

Download unter: https://sourceforge.net/projects/unxutils/

Die bnötigten Dateien liegen im ZIP-Archiv unter `usr\local\wbin\`

Ebenso wird `rush.exe` als Alternative für xargs benötigt

Download unter: https://github.com/shenwei356/rush/releases/

Zum Archivieren  wird `7Zip` benötigt

Download unter: https://7-zip.de/download.html

Die ganzen ESC Sequencen für den echo Befehl findet man unter:

https://learn.microsoft.com/de-de/windows/console/console-virtual-terminal-sequences

## SYNTAX:
```
Backup_TNC.bat [IP-Adresse oder Hostname] [Archivpfad]
```
Die Parameter sind optional. Ohne Parameter muessen die Variablen
**_TARGET** und **_IP** im Batch gesetzt sein!

## Historie:
 V0.1 2022 Initialversion by Rene Trolldenier
 
 V0.2 2022 DIFF.LST bauen mit sort + comm + findstr durch awk ersetzt
 
 V0.3 2022 TIMESTAMP setzen komplett erneuert mit awk und rush
 
 V0.4 2022 Backupdauer hinzu und etwas Farbe bei der Ausgabe
 
 V0.5 2022 Versuch mit chcp wegen ÄÖÜ Umlauten,  Fehler mit & Zeichen im Namen behoben

## BUGS:
Beim Timestamp setzen mit TOUCH werden Dateinamen mit Umlauten ignoriert

## TODO:
Fehler bei der Ausgabe beheben - NUR OPTIK -> Die Zeitberechnung funktioniert manchmal nicht
Filterlisten erstellen
