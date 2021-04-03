drop table certifikat CASCADE CONSTRAINTS;
drop table kurz CASCADE CONSTRAINTS;
drop table lekce CASCADE CONSTRAINTS;
drop table sal CASCADE CONSTRAINTS;
drop table osoba CASCADE CONSTRAINTS;
drop table kona_se CASCADE CONSTRAINTS;
drop table vlastni_certifikat CASCADE CONSTRAINTS;
drop table klient_prihlasen_na_kurz CASCADE CONSTRAINTS;
drop table se_ucastni_lekce CASCADE CONSTRAINTS;

create table osoba( /*jedna tabulka pro klienta a instruktora, rozliseno typem*/
    rodne_cislo char(11) not NULL primary key, /* pocita se i lomitko*/
    jmeno varchar(30) not NULL,
    prijmeni varchar(30) not NULL,
    tel_cislo varchar(13) not NULL, /*9 pro cislo, 4 pro pred cisly*/
    email varchar(30),
    PSC number(5) not NULL,
    ulice varchar(30) not NULL,
    cislo_domu number not NULL,
    typ char(1) default 'K', /* K = klient, I = instruktor*/
    body number default 0,
    sleva number(3) default 0 /*sleva v procentech -> 0-100 */
);

create table certifikat(
    ID_certifikatu number generated by default as identity primary key,
    nazev varchar(50) not NULL,
    uroven varchar(20) not NULL
);

create table vlastni_certifikat( /*vazba: certifikat a instruktor*/
    rodne_cislo char(11),
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
    vedouci_kurzu char(11) not NULL, 
    datum_zacatku date not NULL,
    datum_konce date not NULL,  
    foreign key(vedouci_kurzu) references osoba(rodne_cislo) /*vazba: intruktor a kurz*/
);

create table klient_prihlasen_na_kurz( /*vazba: klient a kurz*/
    rodne_cislo char(11),
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
    vedouci_lekce char(11) not NULL, 
    delka_lekce number not NULL,
    ID_kurzu number default NULL, /*provazani mezi lekci a kurz, lekce ale nemusi byt v zadnem kurzu*/
    foreign key(ID_kurzu) references kurz(ID_kurzu), /*vazba: obsahuje*/
    foreign key(vedouci_lekce) references osoba(rodne_cislo) /*vazba: intruktor a lekce*/
);

create table se_ucastni_lekce( /*vazba: klient a lekce*/
    rodne_cislo char(11),
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
    datum_cas timestamp, /* pri navhu ERD jsme nevedeli, ze ciste promena pro cas neni, proto je zde nahrazeno datum a cas jednou promenou*/    
    foreign key(cislo_salu) references sal(cislo_salu),
    foreign key(ID_lekce) references lekce(ID_lekce),
    primary key (cislo_salu,ID_lekce)
);
