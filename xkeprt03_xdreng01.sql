/*
*   Projekt IDS - 2.cast
*   autors: xkeprt03, xdreng01
*/
drop table osoba CASCADE CONSTRAINTS;
drop table certifikat CASCADE CONSTRAINTS;
drop table kurz CASCADE CONSTRAINTS;
drop table lekce CASCADE CONSTRAINTS;
drop table sal CASCADE CONSTRAINTS;
drop table kona_se CASCADE CONSTRAINTS;
drop table vlastni_certifikat CASCADE CONSTRAINTS;
drop table klient_prihlasen_na_kurz CASCADE CONSTRAINTS;
drop table se_ucastni_lekce CASCADE CONSTRAINTS;

create or replace function kontrola_rc(rodne_cislo in varchar)return number deterministic  --vraci 0 pokud je rodne cislo spatne, jinak 1
is
posledni_3 char(4) := cast(substr(rodne_cislo,8,3)as number);
rc_number number := cast(rodne_cislo as number);
mesic number := cast(substr(rodne_cislo,3,2) as number);
den number := cast(substr(rodne_cislo,5,2) as number);
begin
    --dbms_output.put_line('rodne_cislo: '|| rodne_cislo);
    --dbms_output.put_line('rodne_cislo_number: '|| rc_number);
    --dbms_output.put_line('posledni 3: '|| posledni_3);
    --dbms_output.put_line('mesic: '|| mesic); 
    --dbms_output.put_line('den: '|| den);     
    if (VALIDATE_CONVERSION(rodne_cislo AS NUMBER) = 0 or LENGTHB(rodne_cislo) < 9) then
        return 0;
    end if;
    if (LENGTHB(rodne_cislo) = 9 and posledni_3 = 0) then
        return 0;
    end if;
    if (LENGTHB(rodne_cislo) = 10 and mod(rc_number,11)= 1) then 
        return 0;
    end if;    
    if (mesic > 50) then
        mesic := mesic-50;        
    end if;   
    if (mesic < 1 or mesic > 12) then 
        return 0;
    end if;    
    if (mesic = 2 and 29 < den) then 
        return 0;
    end if;
    if (den = 0) then
        return 0;
    end if;
    if ((mesic = 1 or mesic = 3 or mesic = 5 or mesic = 7 or mesic = 8 or mesic = 10 or mesic = 12) and 31 < den) then 
        return 0;
    end if;
    if ((mesic = 4 or mesic = 6 or mesic = 9 or mesic = 11) and 30 < den) then 
        return 0;
    end if;
    return 1;    
end;
/

create table osoba( /*jedna tabulka pro klienta a instruktora, rozliseno typem*/
    rodne_cislo varchar(10) not NULL primary key, -- bez lomitka
    jmeno varchar(30) not NULL,
    prijmeni varchar(30) not NULL,
    tel_cislo varchar(13) not NULL, --9 pro cislo, 4 pro pred cisly
    email varchar(30),
    PSC number(5) not NULL,
    ulice varchar(30) not NULL,
    cislo_domu number not NULL,
    typ char(1) default 'K', --K = klient, I = instruktor
    body number default 0,
    sleva number(3) default 0,   
    rc_checked NUMBER GENERATED ALWAYS AS (kontrola_rc(rodne_cislo)) VIRTUAL, --abych mohl pro check pouzit funkci
    CHECK(rc_checked = 1),
    check(REGEXP_LIKE (tel_cislo,'^\+42[01][0-9]{9}$'))
);

create table certifikat(
    ID_certifikatu number generated by default as identity primary key,
    nazev varchar(50) not NULL,
    uroven varchar(20) not NULL
);

create table vlastni_certifikat( --vazba: certifikat a instruktor
    rodne_cislo varchar(10),
    ID_certifikatu number,
    foreign key(rodne_cislo) references osoba(rodne_cislo),
    foreign key(ID_certifikatu) references certifikat(ID_certifikatu),
    primary key(rodne_cislo,ID_certifikatu)
);

create table kurz(
    ID_kurzu number generated by default as identity primary key,
    typ varchar(20) not NULL,
    popis varchar(100),
    cena number default 0,
    obtiznost varchar(20) not NULL,
    kapacita number not NULL,
    vedouci_kurzu varchar(10) not NULL, 
    datum_zacatku date not NULL,
    datum_konce date not NULL,  
    foreign key(vedouci_kurzu) references osoba(rodne_cislo) --vazba: intruktor a kurz
);

create table klient_prihlasen_na_kurz( --vazba: klient a kurz
    rodne_cislo varchar(10),
    ID_kurzu number,
    foreign key(rodne_cislo) references osoba(rodne_cislo),
    foreign key(ID_kurzu) references kurz(ID_kurzu),
    primary key(rodne_cislo,ID_kurzu)
);

create table lekce(
    ID_lekce number generated by default as identity primary key,
    typ varchar(20) not NULL,
    popis varchar(100),
    cena number default 0,
    obtiznost varchar(20) not NULL,
    kapacita number NOT NULL,
    vedouci_lekce varchar(10) not NULL, 
    delka_lekce number not NULL,
    ID_kurzu number default NULL, --provazani mezi lekci a kurz, lekce ale nemusi byt v zadnem kurzu
    foreign key(ID_kurzu) references kurz(ID_kurzu), --vazba: obsahuje
    foreign key(vedouci_lekce) references osoba(rodne_cislo) --vazba: intruktor a lekce
);

create table se_ucastni_lekce( --vazba: klient a lekce
    rodne_cislo varchar(10),
    ID_lekce number,
    foreign key(rodne_cislo) references osoba(rodne_cislo),
    foreign key(ID_lekce) references lekce(ID_lekce),
    primary key(rodne_cislo,ID_lekce)
);

create table sal(
    cislo_salu number not NULL primary key,
    kapacita number not NULL,
    vybaveni varchar(200)
);

create table kona_se(
    cislo_salu number,
    ID_lekce number,
    datum_cas timestamp, --pri navhu ERD jsme nevedeli, ze ciste promena pro cas neni, proto je zde nahrazeno datum a cas jednou promenou   
    foreign key(cislo_salu) references sal(cislo_salu),
    foreign key(ID_lekce) references lekce(ID_lekce),
    primary key (cislo_salu,ID_lekce)
);

insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ) values ('7111122249','Shay','Drake','+420608239716','ShaaaayDrake@kmail.com',78654,'Prajska 51',4,'I');

insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('6452093747','Henna','Lopez','+420602821936','HLoper@kmail.com',01008,'Tulska 1',13,'K',15,10);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9051116932','Anna','Avila','+420770815138','AAvil33@sos.com',18078,'Bitsburska 8',7,'K',5,5);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9001015342','Yousif','Middleton','+421909656320','Middleton_Yos@kmail.com',46455,'Lutinska 64',7,'K',10,2);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('7111255943','Eoin','Schneider','+421695776182','SchneiderEOIN@kmail.com',77665,'Calska 7',9,'K',60,20);

insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('7504144714','Petr','Suchomel','+420775695183','suchomelp@seznam.cz',78901,'Medkova',2,'K',25,10);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('8656046713','Monika','Bínová','+420698183577','monikabin@seznam.cz',78971,'Květná',165,'K',39,15);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('0003033492','Martin','Kostka','+420725946695','kostkamartan@gmail.cz',78985,'Mírovka',92,'I',75,30);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9861066160','Irena','Vopršálková','+420769756955','irenav25@seznam.cz',78971,'Jeremenkova',132,'K',42,20);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9558095844','Andrea','Minářová','+420735695381','mina1@seznam.cz',78961,'Severovýchod',52,'I',68,27);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9202295377','Ondra','Fričar','+420673596343','frico@seznam.cz',78901,'Krumpach',145,'K',19,5);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9405036025','Radim','Svačina','+420725695496','svacaradim65@seznam.cz',78969,'Palackého',323,'K',49,21);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9807281825','Oliver','Bezděk','+420627895333','bezda@gmail.cz',78901,'Nerudova',42,'K',38,10);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9951256772','Věra','Doleželová','+420658852424','dolezelka@seznam.cz',78972,'Žerotínova',8,'K',25,10);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9954124714','Justýna','Pajchlová','+420766952873','justa@seznam.cz',78972,'Jižní',65,'K',28,10);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9755213952','Jitka','Barvínková','+420639775692','jitkafitko@seznam.cz',78901,'Školská',12,'I',45,30);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9606198646','Pavel','Nývlt','+420748952612','pavkonyvlt@seznam.cz',78961,'Vodní',69,'K',5,10);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('9509228476','Marek','Peroutka','+420674355942','perute333@seznam.cz',78985,'Hálkova',49,'K',35,20);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('8855062161','Pavla','Hýblová','+420678695825','hyblpavla@seznam.cz',78985,'Okružní',72,'I',63,40);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('8710168654','Matěj','Hýbl','+420772183787','hyblmatej@seznam.cz',78985,'Okružní',72,'I',69,40);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('8502054803','Libor','Pecha','+420659775322','libor323@seznam.cz',78901,'Sušilova',61,'K',25,10);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('8756190773','Michaela','Švecová','+420773698648','svec555@seznam.cz',78901,'Uničovská',41,'K',20,10);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('8955041447','Bára','Falátová','+420622183555','falatbara@gmail.cz',78985,'Jeremenkova',139,'K',30,20);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('0158035889','Soňa','Bártová','+420756888183','bartsona15@seznam.cz',78701,'Evaldova',35,'K',35,20);
insert into osoba(rodne_cislo,jmeno,prijmeni, tel_cislo,email,PSC,ulice,cislo_domu,typ,body,sleva) values ('0202140928','Robert','Hošek','+420777542542','hosek@gmail.cz',78701,'Temenická',8,'K',40,25);

insert into certifikat(nazev,uroven) values ('kondicny trening','prva uroven');
insert into certifikat(nazev,uroven) values ('zumba','druha uroven');
insert into certifikat(nazev,uroven) values ('Pilates','prva uroven');

insert into vlastni_certifikat values ('7111122249',1);
insert into vlastni_certifikat values ('7111122249',2);
insert into vlastni_certifikat values ('7111122249',3);

insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Pokojna mysel','Joga pre kazdeho',1500,'zaciatocnik',10,'7111122249',DATE '2022-08-02',DATE '2022-09-03');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Wrong time','Zakladne techniky boxu',1750,'zaciatocnik',20,'7111122249',DATE '2022-06-07',DATE '2022-07-07');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Kondicak','Kondicia na urovni',2500,'mierne pokrocily',15,'7111122249',DATE '2022-01-12',DATE '2022-02-14');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Zumba','taneční fitnes program',2500,'začátečník',25,'8855062161',DATE '2021-04-12',DATE '2021-06-12');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Spinning','jízda na kole',2400,'začátečník',20,'8710168654',DATE '2021-05-01',DATE '2021-07-31');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Jóga','zpevnění těla a relaxace',2000,'začátečník',15,'9755213952',DATE '2021-05-01',DATE '2021-07-31');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Fitnes','cvičení na fitnes přístrojích',1000,'začátečník',25,'0003033492',DATE '2021-05-15',DATE '2021-06-30');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Pilates','cvičení pro tělesnou a duševní kondici',500,'začátečník',30,'9558095844',DATE '2021-05-15',DATE '2021-06-30');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Aerobik','kondiční cvičení při hudbě',800,'mírně pokročilý',35,'9755213952',DATE '2021-04-15',DATE '2021-05-15');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Cvičení s gumou','kondice a pěkná postava s tréninkovou pomůckou',600,'začátečník',20,'8855062161',DATE '2021-04-15',DATE '2021-05-15');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Taekwondo','korejské umění sebeobrany',1500,'začátečník',15,'0003033492',DATE '2021-05-15',DATE '2021-07-15');

insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('technika trhu','Dokladny rozbor techniky trhu',600,'pokrocily',5,'7111122249',120,4);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('zumba','taneční fitnes program',400,'začátečník',25,'8855062161',60,4);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('zumba','taneční fitnes program',600,'mírně pokročilý',25,'8855062161',90,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Spinning','jízda na kole',800,'začátečník',20,'8710168654',60,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Spinning','jízda na kole',800,'mírně pokročilý',20,'8710168654',90,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Spinning','jízda na kole',800,'pokročilý',20,'8710168654',120,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Jóga','zpevnění těla a relaxace',600,'bikram jóga',15,'9755213952',90,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Jóga','zpevnění těla a relaxace',800,'pro zdravá záda',15,'9755213952',90,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Jóga','zpevnění těla a relaxace',600,'pro začátečníky',15,'9755213952',60,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Fitnes','cvičení na fitnes přístrojích',1000,'začátečník',25,'0003033492',60,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Fitnes','cvičení na fitnes přístrojích',1000,'pokročilý',25,'0003033492',120,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Pilates','cvičení pro tělesnou a duševní kondici',500,'začátečník',30,'9558095844',60,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Pilates','cvičení pro tělesnou a duševní kondici',500,'mírně pokročilý',30,'9558095844',90,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Step aerobik','vystupování na step stupínek',800,'mírně pokročilý',35,'9755213952',90,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Dance aerobik','aerobik s využitím tanečních kroků',800,'mírně pokročilý',35,'9755213952',90,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Body styling','silové cvičení určené k formování svalů',800,'mírně pokročilý',35,'9755213952',90,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Cvičení s gumou','kondice a pěkná postava s tréninkovou pomůckou',600,'začátečník',20,'8855062161',90,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Cvičení s gumou','kondice a pěkná postava s tréninkovou pomůckou',600,'pokročilý',20,'8855062161',120,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Taekwondo','korejské umění sebeobrany',1500,'začátečník',15,'0003033492',90,5);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Taekwondo','korejské umění sebeobrany',1500,'pokročilý',15,'0003033492',120,5);

insert into klient_prihlasen_na_kurz values('9051116932',1);
insert into klient_prihlasen_na_kurz values('6452093747',3);
insert into klient_prihlasen_na_kurz values('9001015342',4);
insert into klient_prihlasen_na_kurz values('7111255943',2);

insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('zaklady boxu I','Prva lekcia boxu',200,'zaciatocnik',20,'7111122249',60,2);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Prebudenie','Joga v dennom zivote',180,'zaciatocnik',20,'7111122249',120,1);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Rychlejsi vyhra','Kruhovy trening',200,'mierne pokrocily',20,'7111122249',90,3);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('technika trhu','Dokladny rozbor techniky trhu',600,'pokrocily',5,'7111122249',120,4);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce) values ('technika skoku','Dokladny rozbor techniky trhu',600,'pokrocily',5,'7111122249',120);
 
insert into se_ucastni_lekce values ('9001015342',1);
insert into se_ucastni_lekce values ('6452093747',2);
insert into se_ucastni_lekce values ('9001015342',3);
insert into se_ucastni_lekce values ('9001015342',4);

insert into sal values (1,25,'cinkovy set,olympijska obourucni osa,kettlebell');
insert into sal values (2,25,'stepper,trampolina,ab wheel');
insert into sal values (3,25,'airbike,powerball,plyometrický box,boxovacie vrece');

insert into kona_se values (3,1,TIMESTAMP'2022-06-07 09:30:00.00');
insert into kona_se values (2,2,TIMESTAMP'2022-08-09 08:00:00.00');
insert into kona_se values (1,4,TIMESTAMP'2022-06-15 16:30:00.00');
insert into kona_se values (3,3,TIMESTAMP'2022-01-18 15:00:00.00');