local coroutine       = coroutine
local isalnum         = unicode.isalnum
local isalpha         = unicode.isalpha
local isdigit         = unicode.isdigit
local isspace         = unicode.isspace
local isxdigit        = unicode.isxdigit
local setmetatable    = setmetatable
local tostring        = tostring
local towc            = unicode.towc
local translate_digit = unicode.translate_digit


--- <p>Klasse <a href="/modules/unicode.acceptor.html">unicode.acceptor</a>
--  </p>
--  <p>enth&auml;lt einige Methoden f&uuml;r das Parsen von
--  <code>source</code>-Quellen, wie sie im Paket <code>gr_source</code>
--  eingef&uuml;hrt wurden.
module "unicode.acceptor"

--- <p>erzeugt ein Objekt der Klasse
--  <a href="/modules/unicode.acceptor.html">unicode.acceptor</a></p>
--  @param source Objekt der Klasse <code>source</code>, das wc vom
--   Typ <code>gr_unicode_wc</code> auswirft.  Der von dieser Funktion
--   bereitgestellte Parser wird dann mit diesen wc gef&uuml;ttert.
--  @return besagtes Objekt der Klasse
--   <a href="/modules/unicode.acceptor.html">unicode.acceptor</a>
function new(self, source)
 local ret = {
  source = source,
  row     = 1,
  col     = 1,
  last_nl = "no" }
 setmetatable(ret, { __index = self })
 return ret
end

--- <p>Zustandsfunktion des dem Parser zugrundeliegenden abstrakten
--   Automaten</p>
--  <p>F&uuml;r die Verwendung dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r die Methoden mit demselben Namen
--   aus der Klasse <code>source</code>.  Auch die Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>
--   kann nur aufgerufen werden, wenn zuvor wenigstens einmal die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   aufgerufen wurde, und der letzte Aufruf dieser Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   oder einer anderen der hier vorgestellten Parsermethoden
--   den R&uuml;ckgabewert <code>"go"</code> erbrachte.
--  @return ein wc vom Typ <code>gr_unicode_wc</code>
function cur(self)
 if     (self.last_nl == "no")
 then   return self.source:cur()
 else   return towc('\n')
 end
end

--- <p>Diese Funktion sollte nicht direkt aufgerufen werden.</p>
--  <p>Sie entspricht der Funktionalit&auml;t der Funktion
--   <a href="/modules/unicode.acceptor.html#sc">unicode.acceptor.sc</a>
--   auf niedrigerer Ebene.</p>
function sc_raw(self, c)
 if     (self.source:cur() == towc(c))
 then   return self.source:next()
 else   return "no"
 end
end

--- <p>Zustands&uuml;berf&uuml;hrungsfunktion des im
--  <a href="/modules/unicode.acceptor.html">unicode.acceptor</a>-Objekt
--  enthaltenen Parsers.</p>
--  @return eine der Zeichenketten
--   <ul>
--    <li><code>"stop"</code>, wenn keine Zeichen mehr vorhanden sind,</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
function next(self)
 if     (self.last_nl ~= "no")
 then   if     (self.last_nl == "stop")
        then   return "stop"
        end
 else   local ret = self.source:next()
        if     (ret == "stop")
        then   return "stop"
        end
 end

 local ret = self:sc_raw('\r')

 if     (ret == "stop")
 then   self.last_nl = "stop"
 elseif (ret == "go")
 then   ret = self:sc_raw('\n')
        if     (ret == "stop")
        then   self.last_nl = "stop"
        else   self.last_nl = "go"
        end
 else   self.last_nl =  self:sc_raw('\n')
 end

 if     (self.last_nl == "no")
 then   self.col = self.col + 1
 else   self.col = 1
        self.row = self.row + 1
 end

 return "go"
end

--- <p>Pr&uuml;ft, ob das wc <code>c</code> am Acceptor anliegt.</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @param c ein wc vom Typ <code>gr_unicode_wc</code>
--  @return eine der folgenden Zeichenketten
--   <ul>
--    <li><code>"no"</code>, falls das Zeichen nicht anliegt,</li>
--    <li><code>"stop"</code>, falls das Zeichen anliegt, dieses
--     aber das letzte der Quelle ist,</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
function sc(self, c)
 if     (self:cur() == towc(c))
 then   return self:next()
 else   return "no"
 end
end

--- <p>Pr&uuml;ft, ob das am Acceptor anliegende Zeichen ein
--   Zeilenumbruch darstellt.</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der folgenden Zeichenketten
--   <ul>
--    <li><code>"no"</code>, falls das Zeichen nicht anliegt,</li>
--    <li><code>"stop"</code>, falls das Zeichen anliegt, dieses
--     aber das letzte der Quelle ist,</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
function nl(self)
 if     (self.last_nl == "no")
 then   return "no"
 end

 local ret = self.last_nl
 self.last_nl = "no"

 return ret
end

--- <p>Pr&uuml;ft, ob das am Acceptor anliegende Zeichen ein einzelnes
--   Zwischenraumzeichen darstellt.</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der folgenden Zeichenketten
--   <ul>
--    <li><code>"no"</code>, falls das Zeichen nicht anliegt,</li>
--    <li><code>"stop"</code>, falls das Zeichen anliegt, dieses
--     aber das letzte der Quelle ist,</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
function space(self)
 if     (isspace(self:cur()))
 then   return self:next()
 else   return "no"
 end
end

--- <p>&Uuml;berspringt Zwischenr&auml;me am Acceptor.</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"stop"</code>, falls es keine Zeichen mehr am Acceptor gibt,
--    </li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
function skipspace(self)
 while true
 do    ret = self:space()
       if     (ret == "stop")
       then   return "stop"
       elseif (ret == "no")
       then   return "go"
       end
 end
end

--- <p>F&uuml;hrt zuerst
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   aus und dann
--   <a href="/modules/unicode.acceptor.html#skipspace">
--   unicode.acceptor.skipspace</a></p>
--   Diese Methode sollte nicht aufgerufen werden, falls der vorangegangene
--   Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   oder einer anderen der hier vorgestellten Parsermethoden
--   den R&uuml;ckgabewert <code>"stop"</code> ergab.
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"stop"</code>, falls es keine Zeichen mehr am Acceptor gibt,
--    </li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
function next_n_skipspace(self)
 local ret = self:next()

 if     (ret == "stop")
 then   return "stop"
 else   return self:skipspace()
 end
end

--- <p>Entfernt Zwischenr&auml;ume am Acceptor, nachdem irgendeine
--   der von der Klasse
--   <a href="/modules/unicode.acceptor.html">unicode.acceptor</a>
--   bereitgestellten Parsermethoden den R&uuml;ckgabewert <code>"go"</code>
--   ergab.</p>
--  <p>Beispielaufruf:
--   <pre class="example">
--    ret = parser:space_after(parser:decnr())
--   </pre></p>
--  @see <a href="/modules/unicode.acceptor.html#decnr">
--   unicode.acceptor.decnr</a>
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"stop"</code>, falls es keine Zeichen mehr am Acceptor gibt,
--    </li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
function space_after(self, ret, ...)
 if     (ret ~= "go")
 then   return ret, ...
 end

 local ret = self:skipspace()
 return ret, ...
end

--- <p>Interpretiert Zeichen am Acceptor als Decimalzahl</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"stop"</code>, falls es keine Zeichen mehr am Acceptor gibt,
--    </li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return einen Integerwert, der der gelesenen Decimalzahl entspricht.
--   Lag keine Decimalzahl am Acceptor an, so betr&auml;gt dieser
--   R&uuml;ckgabewert 0.
function decnr(self)
 local ret
 local accu = 0

 while (isdigit(self:cur()))
 do    accu = 10 * accu + translate_digit(self:cur())
       ret  = self:next()
       if     (ret == "stop")
       then   return "stop", accu
       end
 end

 return "go", accu
end

--- <p>&Auml;hnlich wie
--   <a href="/modules/unicode.acceptor.html#decnr">
--    unicode.acceptor.decnr</a>,
--   gibt aber die Zeichenkette <code>"no"</code> im ersten
--   R&uuml;ckgabewert zur&uuml;ck, falls keine Decimalzahl am
--   Acceptor anlag.
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"no"</code>, falls keine Decimalzahl am Acceptor anlag,</li>
--    <li><code>"stop"</code>, falls eine Decimalzahl am Acceptor gelesen
--     werden konnte, nun aber keine Zeichen am Acceptor vorhanden sind.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return einen zweiten R&uuml;ckgabewert gibt es nur, falls der erste
--   nicht <code>"no"</code> ergab.  In den &uuml;brigen F&auml;llen
--   gibt der zweite R&uuml;ckgabewert den Integer-Wert der gelesenen
--   Decimalzahl wider.
function decnr_x(self)
 if   (isdigit(self:cur()))
 then ret, nr = self:decnr()
      return ret, nr
 else return "no"
 end
end

--- <p>Interpretiert Zeichen am Acceptor als Hexadecimalzahl</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"stop"</code>, falls es keine Zeichen mehr am Acceptor gibt,
--    </li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return einen Integerwert, der der gelesenen Hexadecimalzahl entspricht.
--   Lag keine Hexadecimalzahl am Acceptor an, so betr&auml;gt dieser
--   R&uuml;ckgabewert 0.
function hexnr(self)
 local ret
 local accu = 0

 while (isxdigit(self:cur()))
 do    accu = 16 * accu + translate_digit(self:cur())
       ret  = self:next()
       if     (ret == "stop")
       then   return "stop", accu
       end
 end

 return "go", accu
end

--- <p>&Auml;hnlich wie
--   <a href="/modules/unicode.acceptor.html#hexnr">
--    unicode.acceptor.hexnr</a>,
--   gibt aber die Zeichenkette <code>"no"</code> im ersten
--   R&uuml;ckgabewert zur&uuml;ck, falls keine Hexadecimalzahl am
--   Acceptor anlag.
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"no"</code>, falls keine Hexadecimalzahl am Acceptor
--     anlag,</li>
--    <li><code>"stop"</code>, falls eine Hexadecimalzahl am Acceptor
--     gelesen
--     werden konnte, nun aber keine Zeichen am Acceptor vorhanden sind.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return einen zweiten R&uuml;ckgabewert gibt es nur, falls der erste
--   nicht <code>"no"</code> ergab.  In den &uuml;brigen F&auml;llen
--   gibt der zweite R&uuml;ckgabewert den Integer-Wert der gelesenen
--   Hexadecimalzahl wider.
function hexnr_x(self)
 if    (isxdigit(self:cur()))
 then  ret, nr = self:hexnr()
       return ret, nr
 else  return "no"
 end
end

--- <p>Pr&uuml;ft, ob das am Acceptor anliegende Zeichen sich als
--  erstes Zeichen f&uuml;r einen Bezeichner in Computersprachen
--  eignet</p>
--  <p>Gew&ouml;hnlich wird diese Methode &uuml;berladen.</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der Zeichenketten:
--   <ul>
--    <li><code>"no"</code>, falls Zeichen am Acceptor kein geeignetes
--     Zeichen darstellt,</li>
--    <li><code>"stop"</code>, falls das Zeichen am Acceptor geeignet
--     war, nun aber keine Zeichen mehr vorhanden sind.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return einen zweiten R&uuml;ckgabewert gibt es nur, falls der erste
--   nicht <code>"no"</code> ergab.  In den &uuml;brigen F&auml;llen
--   ergibt der zweite R&uuml;ckgabewert das gelesene Zeichen in Form
--   eines wc vom Typ <code>gr_unicode_wc</code>.
function namestartchar(self)
 local wc = self:cur()
 if     (isalpha(wc))
 then   return self:next(), wc
 end

 local ret = self:sc('_')
 if     (ret ~= "no")
 then   return ret, towc('_')
 end

 ret = self:sc(':')
 if     (ret ~= "no")
 then   return ret, towc(':')
 end

 ret = self:sc('-')
 if     (ret ~= "no")
 then   return ret, towc('-')
 end

 ret = self:sc('.')
 if     (ret ~= "no")
 then   return ret, towc('.')
 end

 return "no"
end

--- <p>Pr&uuml;ft, ob das am Acceptor anliegende Zeichen sich als
--  Zeichen f&uuml;r in einem Bezeichner in Computersprachen
--  eignet, mit dem dieser Bezeichner aber nicht beginnt.</p>
--  <p>Gew&ouml;hnlich wird diese Methode &uuml;berladen.</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der Zeichenketten:
--   <ul>
--    <li><code>"no"</code>, falls Zeichen am Acceptor kein geeignetes
--     Zeichen darstellt,</li>
--    <li><code>"stop"</code>, falls das Zeichen am Acceptor geeignet
--     war, nun aber keine Zeichen mehr vorhanden sind.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return einen zweiten R&uuml;ckgabewert gibt es nur, falls der erste
--   nicht <code>"no"</code> ergab.  In den &uuml;brigen F&auml;llen
--   ergibt der zweite R&uuml;ckgabewert das gelesene Zeichen in Form
--   eines wc vom Typ <code>gr_unicode_wc</code>.
function namechar(self)
 local wc = self:cur()
 if     (isalnum(wc))
 then   return self:next(), wc
 end

 local ret, wc = self:namestartchar()
 if     (ret ~= "no")
 then   return ret, wc
 end

 ret = self:sc('-')
 if     (ret ~= "no")
 then   return ret, towc('-')
 end

 ret = self:sc('.')
 if     (ret ~= "no")
 then   return ret, towc('.')
 end

 return "no"
end

--- <p>Pr&uuml;ft, ob am Acceptor ein Bezeichner anliegt.</p>
--  <p>Die Methoden
--   <a href="/modules/unicode.acceptor.html#namechar">
--    unicode.acceptor.namechar</a> und
--   <a href="/modules/unicode.acceptor.html#namestartchar">
--    unicode.accept.namestartchar</a> m&uuml;ssen hierf&uuml;r
--   in geeigneter Weise &uuml;berladen worden sein.</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der Zeichenketten:
--   <ul>
--    <li><code>"no"</code>, falls am Acceptor kein Bezeichner anliegt
--    </li>
--    <li><code>"stop"</code>, falls am Acceptor ein Bezeichner anliegt,
--     nun aber keine Zeichen mehr vorhanden sind.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return einen zweiten R&uuml;ckgabewert gibt es nur, falls der erste
--   nicht <code>"no"</code> ergab.  In den &uuml;brigen F&auml;llen
--   ergibt der zweite R&uuml;ckgabewert den gelesenen Bezeichner in Form
--   einer Zeichenkette.
function name(self)
 local ret, wc = self:namestartchar()
 if     (ret == "no")
 then   return "no"
 end

 local accu = ""
 while true
 do    accu = accu .. tostring(wc)

       if     (ret == "stop")
       then   return "stop", accu
       end

       ret, wc = self:namechar()

       if     (ret == "no")
       then   return "go", accu
       end
 end
end

--- <p>Liest am Acceptor, bis die Zeichenkette <code>cs</code>
--   erreicht wurde.</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @param cs eine Zeichenkette, bis zu dessen Erreichen der Acceptor
--   Zeichen liest.
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"stop"</code>, falls bis zum Erreichen von
--     <code>cs</code> gelesen wurde, nun es aber keine Zeichen mehr
--     zum Lesen gibt,</li>
--    <li><code>"unclosed"</code>, falls der Acceptor die Zeichenkette
--     <code>cs</code> nicht auffinden kann, und alle Zeichen dadurch
--     verbraucht hat.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return die gelesenen Zeichen ohne das abschlie&szlig;ende
--   <code>cs</code>
function stopped_str(self, cs)
 local cc
 local ccs = cs
 local crem = ""
 local accu = ""
 local ret

 while true
 do    if     (ccs == "")
       then   return "go", accu
       end

       cc = ccs:sub(1, 1)
       ccs = ccs:sub(2)
       crem = crem .. tostring(self:cur())
 
       ret = self:sc(cc)
       if     (ret == "no")
       then   accu = accu .. crem
              ccs  = cs
              crem = ""
              ret = self:next()
       end

       if     (ret == "stop")
       then   if     (ccs == "")
              then   return "stop", accu
              else   return "unclosed", accu
              end
       end
 end
end

--- <p>Liest am Acceptor eine in &apos; eingeschlossene Zeichenkette</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"no"</code>, falls eine derartige Zeichenkette nicht
--     am Acceptor anliegt,</li>
--    <li><code>"stop"</code>, falls eine derartige Zeichenkette
--     gelesen wurde, nun es aber keine Zeichen mehr
--     zum Lesen gibt,</li>
--    <li><code>"unclosed"</code>, falls der Acceptor das
--     abschlie&szlig;ende &apos;-Zeichen vermi&szlig;t,
--     und alle Zeichen dadurch verbraucht hat.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return die gelesenen Zeichen ohne die einschlie&szlig;enden
--   &apos;-Zeichen
function sqstr(self)
 local ret = self:sc("'")
 if     (ret == "no")
 then   return "no"
 end

 local ret, accu = self:stopped_str("'")
 return ret, accu
end

--- <p>Liest am Acceptor eine in &quot; eingeschlossene Zeichenkette</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"no"</code>, falls eine derartige Zeichenkette nicht
--     am Acceptor anliegt,</li>
--    <li><code>"stop"</code>, falls eine derartige Zeichenkette
--     gelesen wurde, nun es aber keine Zeichen mehr
--     zum Lesen gibt,</li>
--    <li><code>"unclosed"</code>, falls der Acceptor das
--     abschlie&szlig;ende &quot;-Zeichen vermi&szlig;t,
--     und alle Zeichen dadurch verbraucht hat.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return die gelesenen Zeichen ohne die einschlie&szlig;enden
--   &apos;-Zeichen
function dqstr(self)
 local ret = self:sc('"')
 if     (ret == "no")
 then   return "no"
 end

 local ret, accu = self:stopped_str('"')
 return ret, accu
end

--- <p>Liest am Acceptor eine in &apos; oder &quot;
--   eingeschlossene Zeichenkette</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der folgenden Zeichenketten:
--   <ul>
--    <li><code>"no"</code>, falls eine derartige Zeichenkette nicht
--     am Acceptor anliegt,</li>
--    <li><code>"stop"</code>, falls eine derartige Zeichenkette
--     gelesen wurde, nun es aber keine Zeichen mehr
--     zum Lesen gibt,</li>
--    <li><code>"unclosed"</code>, falls der Acceptor das
--     abschlie&szlig;ende &apos;- bzw. &quot;-Zeichen vermi&szlig;t,
--     und alle Zeichen dadurch verbraucht hat.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return die gelesenen Zeichen ohne die einschlie&szlig;enden
--   &apos;- bzw. &quot;-Zeichen
function anyqstr(self)
 local ret, str = self:sqstr()
 if     (ret == "no")
 then   ret, str = self:dqstr()
        if     (ret == "no")
        then   return "no"
        end
 end
 return ret, str
end

--- <p>Pr&uuml;ft, ob am Acceptor ein in UNIX-Scriptsprachen
--   &uuml;blicher Kommentar anliegt, d.h. einer, der mit
--   "#" beginnt, und bis zum Zeilenende reicht.</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der Zeichenketten:
--   <ul>
--    <li><code>"no"</code>, falls am Acceptor kein UNIX-Kommentar anliegt
--    </li>
--    <li><code>"stop"</code>, falls am Acceptor ein UNIX-Kommentar anliegt,
--     nun aber keine Zeichen mehr vorhanden sind.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return einen zweiten R&uuml;ckgabewert gibt es nur, falls der erste
--   nicht <code>"no"</code> ergab.  In den &uuml;brigen F&auml;llen
--   ergibt der zweite R&uuml;ckgabewert den gelesenen Kommentar in Form
--   einer Zeichenkette.
function unixlike_comment(self)
 local ret = self:sc('#')
 if     (ret == "no")
 then   return "no"
 end

 local accu = ""

 while true
 do if     (ret == "stop")
    then   return "stop", accu
    end

    ret = self:nl()
    if     (ret == "no")
    then   accu = accu .. tostring(self:cur())
           ret = self:next()
    elseif (ret == "go")
    then   return "go", accu
    end
 end
end

--- <p>Pr&uuml;ft, ob am Acceptor ein in LISP
--   &uuml;blicher Kommentar anliegt, d.h. einer, der mit
--   ";" beginnt, und bis zum Zeilenende reicht.</p>
--  <p>F&uuml;r den Aufruf dieser Methode gelten dieselben
--   Einschr&auml;nkungen wie f&uuml;r den Aufruf der Methode
--   <a href="/modules/unicode.acceptor.html#cur">unicode.acceptor.cur</a>.
--   Die Methode
--   <a href="/modules/unicode.acceptor.html#next">unicode.acceptor.next</a>
--   mu&szlig; zuvor wenigstens einmal aufgerufen worden sein, und der
--   letzte Aufruf dieser oder irgendeiner anderen der hier
--   vorgestellten Parsermethoden mu&szlig; den R&uuml;ckgabewert
--   <code>"go"</code> oder <code>"no"</code> ergeben haben.</p>
--  @return eine der Zeichenketten:
--   <ul>
--    <li><code>"no"</code>, falls am Acceptor kein LISP-Kommentar anliegt
--    </li>
--    <li><code>"stop"</code>, falls am Acceptor ein LISP-Kommentar anliegt,
--     nun aber keine Zeichen mehr vorhanden sind.</li>
--    <li><code>"go"</code> sonst</li>
--   </ul>
--  @return einen zweiten R&uuml;ckgabewert gibt es nur, falls der erste
--   nicht <code>"no"</code> ergab.  In den &uuml;brigen F&auml;llen
--   ergibt der zweite R&uuml;ckgabewert den gelesenen Kommentar in Form
--   einer Zeichenkette.
function lisplike_comment(self)
 local ret = self:sc(';')
 if     (ret == "no")
 then   return "no"
 end

 local accu = ""

 while true
 do if     (ret == "stop")
    then   return "stop", accu
    end

    ret = self:nl()
    if     (ret == "no")
    then   accu = accu .. tostring(self:cur())
           ret = self:next()
    elseif (ret == "go")
    then   return "go", accu
    end
 end
end
