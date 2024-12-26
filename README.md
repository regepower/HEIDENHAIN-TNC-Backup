# HEIDENHAIN-TNC-Backup
Backup vo TNC:  als inkrementelles Verzeichnis oder ZIP-Archiv mit TimeStamp der Maschine

::---  LINUX/BASH Befehle gawk.exe sowie touch.exe werden benötigt.          ---
::---  Download unter: https://sourceforge.net/projects/unxutils/            ---
::---  Dateien liegen im ZIP-Archiv unter usr\local\wbin\                    ---
::---  FUER WINDOWS wird rush.exe als Alternative für xargs benötigt         ---
::---  Download unter: https://github.com/shenwei356/rush/releases/          ---
::---  7ZIP wird auch benoetigt, Download: https://7-zip.de/download.html    ---
::---  Die ganzen ESC Sequencen für den echo Befehl findet man unter:        ---
::---  https://learn.microsoft.com/de-de/windows/console/console-virtual-terminal-sequences
::---                                                                        ---
::---  SYNTAX:                                                               ---
::---  Backup_TNC.bat [IP-Adresse / Hostname] [Archivpfad]                   ---
::---                                                                        ---
::---  Die Parameter sind optional. Ohne Parameter muessen die Variablen     ---
::---  _TARGET und _IP hier im Batch gesetzt sein!                           ---

::------------------------------------------------------------------------------
::---  V0.1 2022 Initialversion by Rene Trolldenier                          ---
::---  V0.2 2022 DIFF.LST bauen mit sort + comm + findstr durch awk ersetzt  ---
::---  V0.3 2022 TIMESTAMP setzen komplett erneuert mit awk und rush         ---
::---  V0.4 2022 Backupdauer hinzu und etwas Farbe bei der Ausgabe           ---
::---  V0.5 2022 Versuch mit chcp wegen ÄÖÜ                                  ---
::---            FEHLER MIT & ZEICHEN IM NAMEN BEHOBEN                       ---
::--- BUG:                                                                   ---
::--- BEIM DATUM SETZEN MIT TOUCH WERDEN DATEINAMEN MIT ÄÖÜ NICHT GESETZT    ---
::--- TODO:                                                                  ---
::--- BUGS BEI DER AUSGABE BEHEBEN - NUR OPTIK                               ---
::--- FILTERLISTEN ERSTELLEN                                                 ---
