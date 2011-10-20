Um `gr_unicode` zu aktivieren, benutze:

	require "gr_unicode"


`gr_unicode` definiert folgende Klassen:

* `unicode.mbb`: Objekte dieser Klasse enthalten den Zustand beim
  Lesen von Unicode-Zeichen.  Der Programmierer benötigt diese
  Klasse beim Programmieren einer Ausnahmebehandlung,
* `unicode.source`:  Das ist eine Unterklasse der im
  [Modul `gr_source`](https://github.com/dying-horse/gr_source#readme)
  eingeführten Klasse `source`.  Objekte dieser Klasse lesen
  unicode-zeichen-weise Zeichen aus einer Quelle, einem Objekt der
  `source`-Klasse, die im Argument der
  Konstruktormethode `unicode.source:new()` angegeben werden muß.
* `unicode.acceptor` definiert einige Parser auf die im
  [Modul `gr_source`](https://github.com/dying-horse/gr_source#readme)
  eingeführte Art.  Der Konstruktor dieser Klasse wird mit einem
  Objekt der Klasse `source` aufgerufen, der angibt, Zeichen aus welcher
  Quelle der Parser verarbeiten soll.

Außerdem enthält das Modul `gr_unicode` einige Routinen zum Handhaben
einzelner Unicode-Zeichen.  Für diese wurde der Lua-Typ `gr_unicode_wc`
eingeführt.

Ein Beispiel illustriert den Gebrauch der Klassen `unicode.mbb` und
`unicode.source`

	require "gr_unicode"
	require "gr_source"
	
	-- Die durch das eingestellte locale bestimmten Einstellungen
	-- werden wirksam gemacht.
	os.setlocale("")
	
	-- Hier wird eine Unterklasse my_mbb von unicode.mbb definiert,
	-- um eine Ausnahmebehandlung definieren zu können.
	my_mbb = {}
	setmetatable(my_mbb, { __index = unicode.mbb })
	
	-- Ausnahmebehandlung durch Überladen der Methode except_invalid_mb
	function my_mbb:except_invalid_mb()
	 print("ungültige Bytefolge")
	end
	
	-- Hier erzeugen wir ein Objekt der Klasse unicode.source.
	-- Dem Konstruktor wird ein source-Objekt als Argument übergeben,
	-- welches angibt, aus welcher Quelle die vom erzeugten Objekt zu
	-- lesenden Zeichen stammen sollen.  Im vorliegenden Falle
	-- entspricht diesem Argument die Datei irgendeine.datei.
	-- Die oben eingeführte Ausnahmebehandlung machen wir wirksam,
	-- indem wir ein Objekt der Klasse my_mbb als optionalen Parameter
	-- mit dem Schlüssel mbb übergeben.
	my_unicode_src =
	 unicode.source:new(source.file:new("irgendeine.datei"),
	 { mbb = my_mbb:new() })
	
	-- Hier wird das Objekt my_unicode_src benutzt.
	for c in my_unicode_src
	do   print(c)
	end

Der Lua-Typ `gr_unicode_wc`
===========================

Dieser Typ repräsentiert ein einzelnes Unicode-Zeichen.
Objekte vom Typ `gr_unicode_wc` werden mit der Funktion `unicode.towc()`
erzeugt. Sie wandelt eine ein mb enthaltende Zeichenkette in ein derartiges
Objekt um.  Auf derartige Objekte können Vergleichsoperationen
(`==`, `~=` u.a.) und die Funktion `tostring` angewandt werden, die ein
wc in das zugehörige mb zurückverwandelt.

Für diese wc gibt es u.a. Funktionen, die wc in Klassen
zuordnen, etwa `unicode.isalpha()` und die
Klein- und Gro&szlig;buchstaben-Umwandlung bewirken, die Funktionen
`unicode.tolower()` und `unicode.toupper()`.

Folgende Funktionen werden bereitgestellt:

towc(mb)
--------
Wandelt das in mb enthaltene mb in ein wc (lua type: `gr_unicode_wc`) um.

@param mb umzuwandelndes Zeichen: muß eine nichtleere (sonst Fehler)
Zeichenkette sein, deren erstes mb umgewandelt wird.

isalnum(wc)
-----------
Stellt wc (lua type: `gr_unicode_wc`) ein alphanumerisches Zeichen dar?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

isalpha(wc)
-----------
Stellt wc (lua type: `gr_unicode_wc`) einen Buchstaben dar?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

iscntrl(wc)
-----------
Stellt wc (lua type: `gr_unicode_wc`) ein Steuerzeichen dar?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

isdigit(wc)
-----------
Stellt wc (lua type: `gr_unicode_wc`) eine Digitalziffer dar?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

isgraph(wc)
-----------
Stellt wc (lua type: `gr_unicode_wc`) ein druckbares Zeichen dar,
welches kein Zwischenraum ist?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

islower(wc)
-----------
Stellt wc (lua type: `gr_unicode_wc`) einen kleinen Buchstaben dar?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

isprint(wc)
-----------
Stellt wc (lua type: `gr_unicode_wc`) ein druckbares Zeichen
(einschließlich Zwischenraum) dar?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

ispunct(wc)
-----------
Stellt wc (lua type: `gr_unicode_wc`) ein druckbares Zeichen dar,
welches kein alphanumerisches Zeichen und auch kein Zwischenraum
ist?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

isspace(wc)
-----------
Stellt wc (lua type: `gr_unicode_wc`) einen Zwischenraum dar?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

isupper(wc)
-----------
Stellt wc (lua type: `gr_unicode_wc`) einen großen Buchstaben dar?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

isxdigit(wc)
------------
Stellt wc (lua type: `gr_unicode_wc`) eine Hexadezimalziffer dar?

@return lua type: `boolean`

@param wc (lua type: `gr_unicode_wc`) zu untersuchendes Zeichen

tolower(wc)
-----------
Wandelt wc (lua type: `gr_unicode_wc`) in einen kleinen Buchstaben um,
wenn wc einen Buchstaben darstellt.  Sonst wird wc übernommen.

@return lua type: `gr_unicode_wc`

@param wc (lua type: `gr_unicode_wc`) umzuwandelndes Zeichen

toupper(wc)
-----------
Wandelt wc (lua type: `gr_unicode_wc`) in einen großen Buchstaben um,
wenn wc einen Buchstaben darstellt.  Sonst wird wc übernommen.

@return lua type: `gr_unicode_wc`

@param wc (lua type: `gr_unicode_wc`) umzuwandelndes Zeichen


Low-level-Routinen der Klasse `unicode.mbb`
===========================================

Diese Routinen werden gewöhnlich nicht direkt aufgerufen.

unicode.mbb.new(self)
---------------------
Konstruktormethode

unicode.mbb.push(self, buf)
---------------------------
setzt Eingabepuffer auf `buf`

unicode.mbb.go(self)
--------------------
verarbeitet Daten im Eingabepuffer.

@return entweder Zeichenkette "push", falls Eingabepuffer leer ist, und
Methode `unicode.mbb.push()` aufgerufen werden müßte oder
Zeichenkette "ok" sonst.  Im letzteren Falle liefert die Methode
`unicode.mbb.go()` als zweiter Rückgabewert außerdem noch ein einzelnes
mb als Zeichenkette zurück.

unicode.mbb.getblk(self)
------------------------
liefert die im Eingabepuffer enthaltenen, noch nicht gelesenen
Zeichen als Zeichenkette zurück.
