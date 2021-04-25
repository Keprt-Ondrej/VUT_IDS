IDS

TODO:
SQL skript pro vytvoření pokročilých objektů schématu databáze – SQL skript,
který nejprve vytvoří základní objekty schéma databáze a naplní tabulky ukázkovými
daty (stejně jako skript v bodě 2), a poté zadefinuje či vytvoří pokročilá omezení
či objekty databáze dle upřesňujících požadavků zadání. Dále skript bude obsahovat
ukázkové příkazy manipulace dat a dotazy demonstrující použití výše zmiňovaných
omezení a objektů tohoto skriptu (např. pro demonstraci použití indexů zavolá 
nejprve skript EXPLAIN PLAN na dotaz bez indexu, poté vytvoří index, a nakonec
zavolá EXPLAIN PLAN na dotaz s indexem; pro demostranci databázového triggeru
se provede manipulace s daty, která vyvolá daný trigger; atp.).
Dokumentace popisující finální schéma databáze – Dokumentace popisující řešení
ze skriptu v bodě 4 vč. jejich zdůvodnění (např. popisuje výstup příkazu EXPLAIN PLAN 
bez indexu, důvod vytvoření zvoleného indexu, a výstup EXPLAIN PLAN s indexem, atd.).


SQL skript v poslední části projektu musí obsahovat vše z následujících

vytvoření alespoň dvou netriviálních databázových triggerů vč. jejich předvedení,
z toho právě jeden trigger pro automatické generování hotnot primárního klíče nějaké
tabulky ze sekvence (např. pokud bude při vkládání záznamů do dané tabulky hodnota 
primárního klíče nedefinována, tj. NULL), vytvoření alespoň dvou netriviálních uložených
procedur vč. jejich předvedení, ve kterých se musí (dohromady) vyskytovat alespoň jednou
kurzor, ošetření výjimek a použití proměnné s datovým typem odkazujícím se na řádek či
typ sloupce tabulky (table_name.column_name%TYPE nebo table_name%ROWTYPE),
explicitní vytvoření alespoň jednoho indexu tak, aby pomohl optimalizovat zpracování dotazů,
přičemž musí být uveden také příslušný dotaz, na který má index vliv, a v dokumentaci popsán
způsob využití indexu v tomto dotazy (toto lze zkombinovat s EXPLAIN PLAN, vizte dále),
alespoň jedno použití EXPLAIN PLAN pro výpis plánu provedení databazového dotazu se spojením
alespoň dvou tabulek, agregační funkcí a klauzulí GROUP BY, přičemž v dokumentaci musí být
srozumitelně popsáno, jak proběhne dle toho výpisu plánu provedení dotazu, vč. objasnění
použitých prostředků pro jeho urychlení (např. použití indexu, druhu spojení, atp.), a dále
musí být navrnut způsob, jak konkrétně by bylo možné dotaz dále urychlit (např. zavedením 
nového indexu), navržený způsob proveden (např. vytvořen index), zopakován EXPLAIN PLAN a jeho
výsledek porovnán s výsledkem před provedením navrženého způsobu urychlení,
definici přístupových práv k databázovým objektům pro druhého člena týmu,
vytvořen alespoň jeden materializovaný pohled patřící druhému členu týmu a používající tabulky
definované prvním členem týmu (nutno mít již definována přístupová práva), vč. SQL příkazů/dotazů 
ukazujících, jak materializovaný pohled funguje,
