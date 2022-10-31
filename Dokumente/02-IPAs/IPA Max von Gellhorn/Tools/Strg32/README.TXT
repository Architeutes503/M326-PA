hus-Struktogrammer
******************

Dieses Windows-Programm zum zeichnen von Struktogrammen nach Nassi-Shneiderman wurde
in erster Linie zu Studienzwecken geschrieben. Das Programm enthält zu diesem Zeitpunkt
noch viele Mängel wodurch es für den professionellen Einsatz kaum verwendet werden kann.
Für schulische Zwecke wie das Erlernen der Struktogramm-Regeln kann es aber bereits sehr
hilfreich sein. 
Der Autor übernimmt keinerlei Garantie auf Fehlerfreiheit insbesondere keine 
kompatibilitäts-Garantie auf spätere Versionen.


						7.9.95 / Steck Hans-Ulrich

V 0.0/38 : - IF-Teilung lässt sich jetzt auch nach dem Laden wieder verschieben
           - Veränderungen am Struktogramm werden festgestellt (durch einen Stern in der
	     Titelzeile sichtbar) und es wird entsprechend gewarnt bevor ein
	     geändertes Struktogramm gelöscht wird.
					       12.9.95 / Steck Hans-Ulrich

V 0.0/40 : - Die Schrift kann für das ganze Struktogramm eingestellt werden. Diese Ein-
	     stellung wird mit dem Struktogramm gespeichert. Wird ein altes Struktogramm
	     geladen, wird eine Default-Schrift (Arial-10) eingestellt.
					       18.9.95 / Steck Hans-Ulrich

V 0.0/43 : - Menupunkte sind nun auch durch Tastaturkommandos ansprechbar.
	   - Neuer Menupunkt 'Neu Zeichnen' um den Bildschirm neu aufzubauen.
	   - diverse Menupunkte sind bei leerem Bildschirm deaktiviert.
	   - Alle Dialoge sind nun Standard-Windows-DLL's, wodurch die 'BWCC.DLL' nicht
	     mehr benötigt wird.
	   - Bei der Initialisierung wird die Papiergrösse des eingestellten Standard-
	     Druckers verwendet.
	   - diverse kleinere Verbesserungen.
						25.9.95 / Steck Hans-Ulrich
V 0.0/44 : - Export in Metadatei
	   - Die Schriftgrösse wird nun immer vom eingestellten Drucker aus berechnet.
	     Bei nicht grafikfähigen Druckern kann dies zu unerwünschten Ergebnissen
	     führen. (Verwenden Sie in diesem Fall den Export via Metadatei mit einer
	     korrekten Druckerwahl)
						4.10.95 / Steck Hans-Ulrich
V 0.0/45 : - Export in Clipboard
	   - Druckerscalierung korrigiert (Grösse stimmt jetzt mit Orginal überein)
						5.10.95 / Steck Hans-Ulrich
----------------------------------------------------------------------------------------
Kurzanleitung:
 linke Maustaste :	- verschieben des ganzen Struktogrammes
			- Einfügen neuer Struktogramm-Elemente
			- Einstellen der Rahmen- und Schlaufenbreite sowie der 
			  Verzweigungs-Einteilung. (Ersichtlich durch den 'links-rechts-
			  Cursor')
			- Doppelklick auf Text, öffnet den Mini-Texteditor
 rechte Maustaste:	- löschen eines Struktogramm-Elementes
 mittlere Maustaste:    - Rahmen-, Schlaufen-Breite und Verzweigungs-Eistellung in Grund-
			  position bringen. (Achtung; geht nur, wenn die mittlere Maustaste
			  nicht von einem Maustreiber für andere Zwecke verwendet wird!)

 Die meisten Menupunkte sind selbsterklärend, so dass ich lediglich kurz das Verfahren
 angeben möchte:

	1.) Menu:'Datei.Neu'	ein neuer Struktogramm-Rahmen wird eröffnet (Achtung: ein bereits
			auf dem Bildschirm existierendes Struktogramm wird ohne Warnung
			gelöscht!)
	    oder Menu:'Datei.Öffnen' einbestehendes Struktogramm öffnen.
	2.) Menu:'StGr-Element' ein entsprechendes Struktogramm-Element auswählen
	3.) Mit der Maus an die gewünschte Einfügeposition fahren. Die genaue Position
	    wird durch einen schwarzen Balken angezeigt. Je nach Position der Maus wird
	    die Selektion über die ganze Breite des Elementes oder nur für einen Zweig
	    (z.B. Ja-Zweig) aktiv.
	4.) Mit der rechten Maustaste das gewählte-Element an der Position einfügen.
	   Bem: Das Struktogramm vergrössert sich automatisch um die Elemente und den Text
		in einer minimalen Grösse anzeigen zu können. Selbstverständlich können Sie
		das Struktogramm auch von Hand noch weiter vergrössern. Wird ein Element
		gelöscht, verkleinert sich das Struktogramm allerdings nicht automatisch!
	5.) Durch Doppelklick auf den Text diesen im geöffneten Editor eingeben. (Mit
	    'Ctrl-Return' kann ein Zeilenvorschub eigegeben werden!)
	6.) Weitere Elemente einfügen....

Bem:  - in der Titelzeile des Struktogramms wird der Filename oder "Struktogramm" angezeigt
      - Das Rechteck im Hauptfenster gibt etwa die gewählte Drucker-Papiergrösse an. Bis
        zur ersten Druckereinstellung ist sie auf A4 eingestellt.
      - Der Menupunkt 'Hilfe.Index' ist noch nicht verfügbar.