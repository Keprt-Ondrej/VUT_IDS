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

insert into certifikat(nazev,uroven) values ('kondicny trening','prva uroven');
insert into certifikat(nazev,uroven) values ('zumba','druha uroven');
insert into certifikat(nazev,uroven) values ('Pilates','prva uroven');

insert into vlastni_certifikat values ('7111122249',1);
insert into vlastni_certifikat values ('7111122249',2);
insert into vlastni_certifikat values ('7111122249',3);

insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Pokojna mysel','Joga pre kazdeho',1500,'zaciatocnik',10,'7111122249',DATE '2022-08-02',DATE '2022-09-03');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Wrong time','Zakladne techniky boxu',1750,'zaciatocnik',20,'7111122249',DATE '2022-06-07',DATE '2022-07-07');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Kondicak','Kondicia na urovni',2500,'mierne pokrocily',15,'7111122249',DATE '2022-01-12',DATE '2022-02-14');
insert into kurz(typ,popis,cena,obtiznost,kapacita,vedouci_kurzu,datum_zacatku,datum_konce) values ('Milo of Croton','Vzpieranie pre skusenych',3000,'pokrocily',5,'7111122249',DATE '2022-05-15',DATE '2022-07-20');

insert into klient_prihlasen_na_kurz values('9051116932',1);
insert into klient_prihlasen_na_kurz values('6452093747',3);
insert into klient_prihlasen_na_kurz values('9001015342',4);
insert into klient_prihlasen_na_kurz values('7111255943',2);

insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('zaklady boxu I','Prva lekcia boxu',200,'zaciatocnik',20,'7111122249',60,2);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Prebudenie','Joga v dennom zivote',180,'zaciatocnik',20,'7111122249',120,1);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('Rychlejsi vyhra','Kruhovy trening',200,'mierne pokrocily',20,'7111122249',90,3);
insert into lekce(typ,popis,cena,obtiznost,kapacita,vedouci_lekce,delka_lekce,ID_kurzu) values ('technika trhu','Dokladny rozbor techniky trhu',600,'pokrocily',5,'7111122249',120,4);

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

