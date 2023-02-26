--Zad.1 
CREATE TABLE ZADANIE_1(
    ID NUMBER(2) NOT NULL,
    DZIEN VARCHAR2(12) NOT NULL,
    ROK NUMBER(4) NOT NULL,
    SKOCZNIA VARCHAR2(24),
    PUNKT_K NUMBER(3),
    HILL_SIZE NUMBER(6),
    SKOK_1 NUMBER(5,1),
    SKOK_2 NUMBER(6,1), 
    NOTA NUMBER(5,2),
    LOKATA NUMBER(1),
    STRATA NUMBER(6,2),
    ZWYCIEZCA VARCHAR2(21)  
);

INSERT INTO Zadanie_1(ID, Dzien, Rok,Skocznia, Punkt_K, Hill_Size, Skok_1, Skok_2, Nota, Lokata, Strata,Zwyciezca)
SELECT
    to_number(regexp_substr(tekst, '\d'),'999999'),
    to_char(Trim(regexp_substr(tekst, '\s\w+\s\w+'))),
    to_number(trim(regexp_substr(tekst, '\d{4}'))),
    to_char(Trim(regexp_substr(tekst, '\s\w*-{0,1}\w+',1,4))), --brakuje jednego warunku z spacja
    to_number(Trim(SUBSTR(regexp_substr(tekst, 'K\s{0,1}-\d{2,3}'),3,3))),
    to_number(Trim(SUBSTR(regexp_substr(tekst, 'HS\s{0,1}-\d{2,3}'),4,3))),
    to_number(trim(regexp_substr(tekst, '\d{2,3}\,\d{1,2}'))),
    to_number(trim(regexp_substr(tekst, '\d{2,3}\,\d{1,2}',1,2))),
    to_number(trim(regexp_substr(tekst, '\d{2,3}\,\d{1}',1,3))),
    to_number(Trim(REPLACE(regexp_substr(tekst,'\d\.',1,2),'.',''))),
    to_number(trim(SUBSTR(regexp_substr(tekst,'\d{1,3}\,\d{1}\s[pkt]{3}',1,2),1,INSTR(regexp_substr(tekst,'\d{1,3}\,\d{1}\s[pkt]{3}',1,2),'p')-1))),
    to_char(Trim(regexp_substr(tekst,'[^\s]\w*\s{0,1}\w*[^–]\Z',1,1,'i')))
FROM
    dw.skoki;
DROP TABLE Zadanie_1;
--Zad.2
CREATE MATERIALIZED VIEW Zadanie_2 AS
SELECT
    s.time_id AS Data,
    t.calendar_week_number AS Nr_Tygodnia,
    t.calendar_month_name AS Nr_Miesiaca,
    SUM(s.quantity_sold) AS Liczba_Zamowien,
    ROUND(SUM(s.amount_sold),2) AS Suma_Zamowien_Dzien,
    SUM(ROUND(SUM(s.amount_sold),2)) OVER (PARTITION BY t.calendar_week_number) AS Suma_Zamowien_Tydzien,
    RANK () OVER(PARTITION BY t.calendar_month_name ORDER BY ROUND(SUM(s.amount_sold),2)DESC) AS Ranking_Zamowien_Miesiac
FROM
    sh.sales   s
    JOIN sh.times   t ON s.time_id = t.time_id
WHERE
    s.time_id BETWEEN '2000-01-03' AND '2000-12-31'
GROUP BY   
    s.time_id, t.calendar_month_name ,t.calendar_week_number
ORDER BY
    Ranking_Zamowien_Miesiac;


CREATE UNIQUE INDEX Zadanie_2_IDX ON Zadanie_2(Data);








