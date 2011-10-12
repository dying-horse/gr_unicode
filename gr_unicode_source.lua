local coroutine    = coroutine
local source       = source
local unicode      = unicode


--- <p>Unterklasse der Klasse <code>source</code> aus dem
--  <code>gr_source</code>-Paket</p>
--  Die Objekte dieser Klasse zerlegen Zeichenketten, die von
--  anderen <code>gr_source</code>-Objekten erzeugt werden,
--  in wc vom Typ <code>gr_unicode_wc</code> und werfen diese aus.
module "unicode.source"

--- <p>erzeugt ein Objekt dieser Klasse
--  <a href="/modules/unicode.source.html">unicode.source</a><p>
--  @param src ein <code>source</code>-Objekt, das Zeichenketten
--   auswirft, die dann vom mit dieser Funktion erzeugten Objekt
--   in wc vom Typ <code>gr_unicode_wc</code>zerlegt werden, und
--   seinerseits ausgeworfen werden.
--  @param opt (optional) ein table mit optionalen Parametern
--   <ul>
--    <li>Schl&uuml;ssel <code>"mbb"</code>: ein Objekt der Klasse
--     <code>unicode.mbb</code>.  Dieser Parameter wird gew&ouml;hnlich
--     mit Objekten einer Unterklasse von <code>unicode.mbb</code>,
--     in der die Methoden <code>except_...</code> durch entsprechende
--     Fehlerbehandlungsroutinen &uuml;berladen wurden.</li>
--   </ul>
--  @return das besagte Objekt der Klasse <code>unicode.source</code>
function new(self, src, opt)
 local lopt = opt or {}
 local mbb  = lopt.mbb or unicode.mbb:new()
 local co = coroutine.create(
        function()
         for buf in src
         do     mbb:push(buf)
                while true
                do    local state, wc = mbb:go()
                      if    (state and wc and (state == "ok"))
                      then  coroutine.yield(wc)
                      else  break
                      end
                end
         end
        end
       )
 local ret = source.new(self, co)
 ret.opt   = lopt
 ret.mbb   = mbb
 return ret
end
