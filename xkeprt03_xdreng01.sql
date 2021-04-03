drop table certifikat;
drop table kurz;
drop table lekce;
drop table sal;
drop table osoba;

create table certifikat(
    ID_certifikatu number generated by default as identity primary key,
    nazev varchar(50) not NULL,
    uroven varchar(20) not NULL
);

create table kurz(
    ID_kurzu number generated by default as identity primary key,
    typ varchar(20) not NULL,
    cena number = 0,
    datum_zacatku date not NULL,
    datum_konce date not NULL,
    obtiznost varchar(20) not NULL,
    popis varchar(100),
    kapacita number not NULL,
);

create table lekce(
    ID_lekce number generated by default as identity primary key,
    typ varchar(20) not NULL,
    kapacita number NOT NULL,
    cena number = 0,
    obtiznost varchar(20) not NULL,
    delka_lekce number,
    popis varchar(100)
);

create table sal(
    cislo_salu number is not NULL primary key,
    kapacita number not NULL,
    vybaveni varchar(200)
);

create table osoba(
    rodne_cislo char(11),
    jmeno varchar(30),
    prijmeni varchar(30),
    tel_cislo number,
    email varchar(30),
    psc number,
    ulice varchar(30),
    cislo_domu number,
    typ number, 
    body number,
    sleva number
);
