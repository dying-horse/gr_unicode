require "unicode_aux"

module  "unicode"

--- <p>Rechnet ein wc, d.h. ein userdata vom Typ <code>gr_unicode_wc</code>
--  in eine Ziffer um, falls das wc eine Ziffer darstellt.</p>
--  @param wc Zeichen vom Typ <code>gr_unicode_wc</code>
--  @return die Ziffer als Integer-Wert, falls <code>wc</code> eine
--  Ziffer darstellt.
function translate_digit(wc)
 local wc = tolower(wc)

 if     (wc == towc('0'))
 then   return 0;
 elseif (wc == towc('1'))
 then   return 1;
 elseif (wc == towc('2'))
 then   return 2;
 elseif (wc == towc('3'))
 then   return 3;
 elseif (wc == towc('4'))
 then   return 4;
 elseif (wc == towc('5'))
 then   return 5;
 elseif (wc == towc('6'))
 then   return 6;
 elseif (wc == towc('7'))
 then   return 7;
 elseif (wc == towc('8'))
 then   return 8;
 elseif (wc == towc('9'))
 then   return 9;
 elseif (wc == towc('a'))
 then   return 10 
 elseif (wc == towc('b'))
 then   return 11;
 elseif (wc == towc('c'))
 then   return 12;
 elseif (wc == towc('d'))
 then   return 13;
 elseif (wc == towc('e'))
 then   return 14;
 elseif (wc == towc('f'))
 then   return 15;
 end
end

