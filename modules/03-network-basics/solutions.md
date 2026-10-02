# 03 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Break & Fix

Hinweis 1: Die URL enthält einen Port. Hinweis 2: `ss` am Server zeigt 8080, und server-nsg erlaubt nur 8080 vom Client. Lösung: URL auf 8080 korrigieren; unverändert NSG und App prüfen. Bei 8081 kann die NSG statt einer Betriebssystem-RST ein Timeout erzeugen. Der falsche Port allein bestimmt deshalb nicht die genaue sichtbare Fehlermeldung.

## Challenge

Hinweis 1: 32−27 Hostbits. Hinweis 2: Netzwerk ist nicht dasselbe wie einzelne Hostadresse. Referenz: 2^5=32, Azure 32−5=27 nutzbare Adressen. Beispiel 10.20.1.0/27 enthält 10.20.1.4 und .30, aber nicht .32. .0 bis .3 und .31 sind Azure-reserviert. In Linux entscheidet Präfixlänge über on-link versus Gateway; in Azure verwaltest du NIC/Subnetz über die Management Plane.

## Quiz

1. DNS beantwortet Namen/Adresse, nicht Prozesszustand. 2. Serverquelle 8080 antwortet an dynamischen Client-Zielport. 3. ICMP kann separat blockiert sein. 4. 32 insgesamt, 5 reserviert.

## Guided Lab

Ein erfolgreicher `/health`-Aufruf per Private IP beweist für diesen Flow eine funktionierende Kette bis HTTP; er bestätigt keinen TLS-Stack, keinen DNS-Pfad und keinen Public-IP-Webzugang.
