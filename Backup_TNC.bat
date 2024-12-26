@echo off & setlocal enableDelayedExpansion & chcp 1252 & CLS
:: WENN DEBUG=PAUSE HAELT DAS SCRIPT OEFTER AN ZUM TESTEN
SET _DEBUG=
::------------------------------------------------------------------------------
::---   BACKUP DER TNC:  als inkrementelles Verzeichnis oder ZIP-Archiv      ---
::---   Die Dateien bekommen den TimeStamp der Maschine, anders als TNCcmd   ---
::------------------------------------------------------------------------------
::---  ACHTUNG! Bei dem SET Befehl Leerzeichen vor und nach = weglassen!     ---
::---  auch keine Lehrzeichen hinter dem Dateinamen und keine "              ---
::---  LINUX/BASH Befehle gawk.exe sowie touch.exe werden benötigt.          ---
::---  Download unter: https://sourceforge.net/projects/unxutils/            ---
::---  Dateien liegen im ZIP-Archiv unter usr\local\wbin\                    ---
::---  FUER WINDOWS wird rush.exe als Alternative für xargs benötigt         ---
::---  Download unter: https://github.com/shenwei356/rush/releases/          ---
::---  7ZIP wird auch benoetigt, Download: https://7-zip.de/download.html    ---
::---  Die ganzen ESC Sequencen für den echo Befehl findet man unter:        ---
::---  https://learn.microsoft.com/de-de/windows/console/console-virtual-terminal-sequences
::---                                                                          ---
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
::------------------------------------------------------------------------------
:: **************** BEI STERNCHENREIHEN MUSS WAS GESETZT WERDEN ****************

::------------------------------------------------------------------------------
::         FALLS PARAMETER BEIM SCRIPT UEBERGEBEN WORDEN, DIESE NUTZEN       ---
::              ES MUESSEN IMMER BEIDE PARAMETER UEBERGEBEN WERDEN           ---
if %2.==. goto :SET_PARAMS
set _IP=%1%
set _TARGET=%~2%
GOTO :PARAMS_READY

::******************************************************************************
:SET_PARAMS
::--- IP + ARCHIV-PFAD SETZEN FALLS DAS SCRIPT OHNE PARAMETER GESTARTET WIRD ---
    set _IP=100.4.1.72&set _TARGET=N:\Sicherung_Maschinen\DMU100\

::******************************************************************************
:PARAMS_READY
::---            HIER DIE PFADE ZU DEN EINZELNEN PROGRAMMEN SETZEN           ---
::>> Pfad+Filename zu TNCcmd.exe NICHT zu TNCcmdPlus.exe!
set _TNCCMD=N:\Sicherung_Maschinen\BACKUP_TOOLS\TNCcmd.exe

::>> Pfad fuer das Batch, die .awk Skripte und alle UNIX Befehle
set _TOOLPATH=N:\Sicherung_Maschinen\BACKUP_TOOLS\

::------------------------------------------------------------------------------
::---             LETZTER TEIL DES ZIELORDNERS IST BEI MIR DIE MASCHINE.     ---
::---                       ICH NUTZE DAS FUER DEN ARCHIVNAMEN               ---
::---     FALLS NICHT BENOETIGT, DIE VARIABLE _MASCH EINFACH LEER LASSEN     ---
::---                         ODER NACH BEDARF SETZEN                        ---
for %%f in (%_TARGET:~0,-1%) do set _MASCH=%%~nxf

::******************************************************************************
::---                   HIER DIE KOMMANDOZEILE FUER 7Zip                     ---
set _ZIP="C:\Program Files\7-Zip\7z.exe" u -mx9 -slp %_MASCH%_TNC.ZIP TNC_\

:: DAS HIER WUERDE KEIN ARCHIV ERZEUGEN DA VARIABLE LEER
:: DER ORDNER TNC_\ WIRD DANN AUCH NICHT GELOESCHT
rem set _ZIP=

:: HIER DAS KOMMANDO FUER DAS ORDNER TNC_\ LOESCHEN
set _RMDIR=rmdir /Q /S TNC_\

:: DAS HIER WUERDE TNC_ NICHT LOESCHEN DA VARIABLE LEER
rem set _RMDIR=


::------------------------------------------------------------------------------
::---                   !!!!!HIERNACH NICHTS MEHR AENDERN !!!!!              ---
::------------------------------------------------------------------------------

::------------------------------------------------------------------------------
::---                    INS ZIELLAUFWERK WECHSELN                           ---
cd /d %_TARGET%

::---                           FENSTERTITEL                                 ---
title=**** Backup der TNC: von %_MASCH% IP:[%_IP%] -^> "%_TARGET%" Start: %date:~0% - %time:~0,8% ****

::---                      HIER EIN PAAR SPIELEREIEN:                        ---
::---           STARTZEIT UND ESC-ZEICHEN FUER FARBIGES OUTPUT ERZEUGEN      ---
set /a _starttime=(%time:~0,2%*3600)+(%time:~3,2%*60)+(%time:~6,2%)
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set /a _zeile=1
::------------------------------------------------------------------------------
::------------------------------------------------------------------------------
::------------------------------------------------------------------------------
:: ---                          HIER GEHTS LOS                               ---
::------------------------------------------------------------------------------
:: ---                       PRUEFE OB PFADE PASSEN                          ---

if exist "%_TARGET%" if exist "%_TNCCMD%" if exist "%_TOOLPATH%" goto :ANFANG
echo.%ESC%[91mBitte die Programm- und Archivpfade pruefen! Irgendwas passt nicht...%ESC%[0m
goto :RAUS


:ANFANG
%DEBUG%

::GOTO :ZIP   ::INTERNAL TEST
::------------------------------------------------------------------------------
:: ---  PRUEFE OB MASCHINE ERREICHBAR -w 100 MUSS VIELLEICHT ERHOEHT WERDEN  ---
echo.Versuche %ESC%[93m%_IP%%ESC%[0m zu erreichen...
ping %_IP% -n 1 -w 100 | find "TTL" >NUL
if NOT ERRORLEVEL 1 goto IP_OK
echo.Maschine %ESC%[91m%_IP%%ESC%[0m nicht erreichbar! Beende Backup...
timeout /T 10
goto :EOF

::------------------------------------------------------------------------------
::---           MASCHINE GEFUNDEN, STARTE DATEILISTEN-DOWNLOAD               ---
:IP_OK
cls&echo.Maschine %ESC%[92m%_IP%%ESC%[0m gefunden^^! Los gehts...%ESC%[2r
::------------------------------------------------------------------------------
::---    PRUEFEN AUF CURRENT.LST, WENN NICHT EINE LEERE LISTE ERZEUGEN     ---
if exist CURRENT.LST goto SCAN
echo.Keine "CURRENT.LST" gefunden, baue eine neue Liste...
echo.>CURRENT.LST

::------------------------------------------------------------------------------
::---                  DATEILISTE VON MASCHINE ZIEHEN                        ---
:SCAN
echo.%ESC%7%ESC%[H%ESC%[K%ESC%[93mZiehe Dateiliste...%ESC%[0m%ESC%8

set _KOMMANDO="%_TNCCMD%" -I%_IP% "SCAN MACHINE.LST T TNC:"
%_KOMMANDO%
%_DEBUG%

:: CURSORPOSITION ZURUECKSTELLEN UND ALLES DARUNTER LOESCHEN
echo.%ESC%7%ESC%[H%ESC%[K%ESC%[93mZiehe Dateiliste...%ESC%[92mfertig%ESC%[0m%ESC%8

::------------------------------------------------------------------------------
::---         DIFFERENZLISTE DIFF.LST ERZEUGEN V2 CA. 1000X SCHNELLER        ---
::---                      ALS MIT SORT / COMM UND FIND                      ---
::---          IM "KLARTEXT" LIEGT DAS AWK-SCRIPT FILTER_TNC.AWK             ---
::---               MIT IM ORDNER WO DIE BACKUP_TNC.BAT LIEGT                ---
::---         DAS ZWEITE GAWK FILTERT ALLES RAUS WAS NICHT TNC:\ ENTHAELT    ---
::------------------------------------------------------------------------------
:SORT
"%_TOOLPATH%gawk" -f "%_TOOLPATH%FILTER_TNC.AWK" CURRENT.LST MACHINE.LST | "%_TOOLPATH%gawk" "{ if ( $0 ~ /TNC:\\/ ) { print $0  } }" >DIFF.LST
%_DEBUG%

::------------------------------------------------------------------------------
::---                 GIBT ES UEBERHAUPT NEUE DATEIEN?                       ---
::---           WENN NICHT TEMPORAERE LISTEN LOESCHEN UND RAUS               ---
:FINDEN
find "TNC:\" DIFF.LST >NUL
if NOT ERRORLEVEL 1 goto HEADER
echo.%ESC%[96mKeine neueren Dateien gefunden... Und Tschuess!%ESC%[0m
%_DEBUG%
goto :CLEANUP

::------------------------------------------------------------------------------
::---                      DOWNLOADLISTE GENERIEREN                          ---
::--- DATEIHEADER "ANBAUEN" DIESER WIRD FUER DAS DOWNLOAD KOMMANDO BENOETIGT ---
:HEADER
echo.TNC BACKUP Scan Protocol - Version 1.0>DOWNLOAD.LST
echo.[PATH]>>DOWNLOAD.LST
echo.TNC:>>DOWNLOAD.LST
echo.[SCANLIST]>>DOWNLOAD.LST
more DIFF.LST>>DOWNLOAD.LST
echo.[END OF FILES]>>DOWNLOAD.LST
echo.>>DOWNLOAD.LST
%_DEBUG%
::------------------------------------------------------------------------------
::--- DIE NEUEN DATEIEN IN DEN TARGET-ORDNER INS VERZEICHNIS "TNC_" KOPIEREN ---
:DOWNLOAD
echo.%ESC%8%ESC%[93mLade neuere Dateien herunter...%ESC%[0m%ESC%7

::--- UMSCHALTEN AUF 2. AUSGABESEITE
set _KOMMANDO="%_TNCCMD%" -I%_IP% "DOWNLOAD DOWNLOAD.LST"
%_KOMMANDO%

%_DEBUG%
:: CURSORPOSITION ZURUECKSTELLEN UND ALLES DARUNTER LOESCHEN
echo.%ESC%8%ESC%[9999M%ESC%[93mLade neuere Dateien herunter...%ESC%[92mfertig%ESC%[0m

::------------------------------------------------------------------------------
::---          ORIGINAL TIMESTAMP AUF HERUNTERGELADENE DATEIEN SETZEN        ---
::---  UNIX TOUCH WIRD BENUTZT. DER TIMESTAMP WIRD AUS DER DIFF.LST GEZOGEN  ---
::---    MIT AWK WIRD AUS DER DIFF.LST EINE ARGUMENTZEILE FUER TOUCH GEBAUT. ---
::---     DER RUSH BEFEHL FUEHRT DANN TOUCH MIT DEN ARGUMENTEN IN MEHREREN   ---
::---            INSTANZEN PARALLEL AUS DAMIT ES SCHNELLER GEHT              ---
::******************************************************************************
:SETFILEDATE
echo.%ESC%[93mSetze das Dateidatum vom Timestamp der Maschine...%ESC%[0m%ESC%7
"%_TOOLPATH%gawk" -f "%_TOOLPATH%split_TIMESTAMP.awk" DIFF.LST |"%_TOOLPATH%rush" --eta "%_TOOLPATH%touch" {}
:: CURSORPOSITION ZURUECKSTELLEN UND ALLES DARUNTER LOESCHEN
echo.%ESC%8%ESC%[9999M%ESC%[93mSetze das Dateidatum vom Timestamp der Maschine...%ESC%[92mfertig%ESC%[0m

::------------------------------------------------------------------------------
::---           ALLES GUT DIE NEUE LISTE ALS DIE ALTE LISTE SETZEN           ---
::---                UND DIE TEMPORAEREN LISTEN LOESCHEN                     ---
:CLEANUP
echo.%ESC%[92mAlles fertig, Raeume auf...%ESC%[0m
copy /Y MACHINE.LST CURRENT.LST >NUL
del MACHINE.LST >NUL
del DIFF.LST >NUL
if not exist DOWNLOAD.LST goto :RAUS
del DOWNLOAD.LST >NUL
%_DEBUG%

::------------------------------------------------------------------------------
::---        TOOL.T KOPIEREN IN TARGET-ORDNER FALLS NEUER VORHANDEN          ---
::---   DA DIE TOOL.T ABHAENGIG VON DER STEUERUNG LIEGT EIN KLEINER TRICK    ---
::---     TOOL.T WIRD REKURSIV GESUCHT FALLS NICHT GEFUNDEN KOMMT MELDUNG    ---
:COPY_TOOL_T

cd TNC_\

for /f "delims=" %%a in ('dir /b /s TOOL.T') do (
	(echo.%ESC%[93mErzeuge "%_MASCH%_TOOL.T" aus %ESC%[95m"%%a"...%ESC%[0m)
	copy "%%a" "%_TARGET%%_MASCH%_TOOL.T"
)
cd ..
%_DEBUG%
::------------------------------------------------------------------------------
::---     OPTIONAL: ZIP ARCHIV ERZEUGEN BZW. ERGAENZEN + ORDNER LOESCHEN     ---
:ZIP
if defined _ZIP (
	echo.%ESC%[93mUpdate des Archives...%ESC%[0m
	%_ZIP%
) else (
	echo.%ESC%[96mErstellung bzw Update des Archives deaktiviert. Ordner TNC_\ bleibt erhalten...%ESC%[0m
	goto :RAUS
)

if defined _RMDIR (
	echo.%ESC%[93mEntferne den TNC_ Ordner...%ESC%[0m
	%_RMDIR%
)

::------------------------------------------------------------------------------
::>>> Raus aus dem batch
:RAUS
set /a _endtime=(%time:~0,2%*3600)+(%time:~3,2%*60)+(%time:~6,2%)
set /a _endtime=%_endtime%-!_starttime!
echo.%ESC%[1mBeende das Backup um %time:~0,8%, Dauer: %ESC%[96m!_endtime!%ESC%[37msek.%ESC%[0m
timeout /T 10
echo.%ESC%[r
cls
exit /b
