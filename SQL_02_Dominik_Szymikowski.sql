--Zad.1.A
SELECT
    pi.product_name AS Nazwa_Produktu,
    cat.category_name AS Nazwa_Kategorii,
    SUBSTR(pi.product_description,INSTR(pi.product_description,'Supra'),6) AS Rodzaj_Napêdu_Supra
FROM
    OE.product_information pi
    JOIN OE.product_descriptions des using (product_id)
    JOIN oe.categories cat using (category_id)
WHERE
   translated_description LIKE '%Supra%'
ORDER BY 3 DESC;  
--ODP: 14 dysków posiada napêdy SUPRA, najnowszy napêd SUPRA posiadaja 3 dyski. 

--Zad.1.B
SELECT
    SUBSTR(c.cust_email, InStr(c.cust_email,'@')+1,InStr(c.cust_email,'.',InStr(c.cust_email,'@'))-1 - InStr(c.cust_email,'@')) AS Dostawca_Poczty,
    Count(*) as Ilosc
FROM
    oe.customers c 
GROUP BY
    SUBSTR(c.cust_email, InStr(c.cust_email,'@')+1,InStr(c.cust_email,'.',InStr(c.cust_email,'@'))-1 - InStr(c.cust_email,'@'))
ORDER BY Ilosc DESC;
--ODP: Najczesciej wystepujacym w bazie klientow dostawca poczty jest DUNALIN.

--Zad.1.C
SELECT
    DISTINCT c.income_level AS Przedzial_Przychodow,
    Substr(c.income_level,1,1) AS Kategoria,
    Substr(c.income_level,3,InStr(replace(c.income_level,'and','-'),'-')-4) AS Pensja_Minimalna,
    SubStr(Trim(c.income_level), CASE 
                                    WHEN InStr(trim(c.income_level),'-')=0 THEN NULL
                                    WHEN InStr(trim(c.income_level),'-')>0 THEN InStr(trim(c.income_level),'-')+2
                                 END )AS Pensja_Maksymalna
FROM
    oe.customers c;
--ODP: Uzyskanko 12 kategorii 

--Zad.2.A
SELECT 
    d.department_name AS Dzial,
    ROUND(AVG(e.salary),2)AS Srednia_Pensja   
FROM
    HR.employees e
JOIN
    hr.departments d USING (department_id)
GROUP BY
    d.department_name
HAVING
    d.department_name IN('Sales', 'Shipping', 'Finance')
ORDER BY
    Srednia_Pensja DESC;
--ODP: Srednia wynagrodzenia w rozpatrywanych dzialach wynosi kolejno: 'Sales' 8955,88, 'Finance' 8601,33, 'Shipping' 3475,56

--Zad.2.B
SELECT
    j.job_title AS Stanowisko,
    AVG(e.salary) AS Srednia_Pensja,
    Count(*) AS Ilosc_Pracownikow
FROM
    HR.employees e
JOIN
    HR.jobs j USING (job_id)
GROUP BY
    j.job_title
HAVING 
    Count(*)>=5
ORDER BY Ilosc_Pracownikow DESC;
--ODP: Sales Representative 8350 Stock Clerk 2785 Shipping Clerk 3215 Stock Manager 7280 Purchasing Clerk 2780 Programmer 5760 Accountant 7920 Sales Manager	12200

--Zad.3.A
SELECT
   TO_CHAR(Order_date,'DD-MM-YYYY')AS Data_Wystêpowania_Promocji
FROM
    OE.orders
WHERE
    promotion_id = 1
GROUP BY TO_CHAR(Order_date,'DD-MM-YYYY');

SELECT
   TO_CHAR(Order_date,'DD-MM-YYYY')AS Data_Wystêpowania_Promocji
FROM
    OE.orders
WHERE
    promotion_id = 2
GROUP BY TO_CHAR(Order_date,'DD-MM-YYYY');
--ODP: Promocja 'Every day low price' obowiazywala w okresie: 01/07/2018 - 31/07/2018, natomiast promocja 'blowoutsale' obowiazywala w okresie:18/03/2019 - 05/04/2019


--Zad.3.B

SELECT
   TO_CHAR(Order_date,'DD-MM-YYYY')AS Data_Wystêpowania_Promocji,
   SUM(order_total) AS Suma_Sprzeda¿y
FROM
    OE.orders
WHERE
    promotion_id = 1 
GROUP BY TO_CHAR(Order_date,'DD-MM-YYYY')
ORDER BY Data_Wystêpowania_Promocji;

SELECT
   TO_CHAR(Order_date,'DD-MM-YYYY')AS Data_Wystêpowania_Promocji,
   SUM(order_total) AS Suma_Sprzeda¿y
FROM
    OE.orders
WHERE
    promotion_id = 2 
GROUP BY TO_CHAR(Order_date,'DD-MM-YYYY')
ORDER BY Data_Wystêpowania_Promocji;

--ZAD.3.C
SELECT
   c.cust_first_name AS Imiê,
   c.cust_last_name AS Nazwisko,
   o.order_date AS Data_Zakupu
FROM
    oe.orders o
    JOIN oe.customers c USING(customer_id)
WHERE
    promotion_id = 1
ORDER BY 
    Data_Zakupu
FETCH FIRST 1 ROWS ONLY;

SELECT
   c.cust_first_name AS Imiê,
   c.cust_last_name AS Nazwisko,
   o.order_date AS Data_Zakupu
FROM
    oe.orders o
    JOIN oe.customers c USING(customer_id)
WHERE
    promotion_id = 2
ORDER BY 
    Data_Zakupu
FETCH FIRST 1 ROWS ONLY;
--ODP:W przypadku promocji 'Every day low price' pierwszym klientem byla: Gena Harris, natomiast w przypadku promocji: 'blowoutsale' Shelley Taylor

--Zad.4
SELECT
    TO_CHAR(LAST_DAY(TRUNC(o.order_date)),'Month') AS Data_Miesiac,
    TO_CHAR(LAST_DAY(TRUNC(o.order_date)),'YYYY') AS Data_Rok,
    c.nls_territory AS Kraj,
    SUM(o.order_total) AS Kwota_Zamowienia
FROM
    OE.orders o
    JOIN OE.customers c USING (customer_id)
WHERE
    o.order_status NOT IN(0,1)
GROUP BY
    TO_CHAR(LAST_DAY(TRUNC(o.order_date)),'Month'),
    TO_CHAR(LAST_DAY(TRUNC(o.order_date)),'YYYY'),
    c.nls_territory
ORDER BY
    Data_Rok,
    Data_Miesiac DESC,
    Kraj;

--Zad.5.A

SELECT
    c.nls_territory AS Kraj,
    c.gender AS Pleæ,
    SUM(o.order_total) AS Kwota_Sprzedazy,
    Rank() OVER(PARTITION BY  c.gender ORDER BY SUM(o.order_total) DESC) AS Rankig_Sprzedazy_Kraj_Plec
FROM
    OE.orders o
    JOIN OE.customers c USING (customer_id)
GROUP BY
    c.nls_territory,
    c.gender
ORDER BY
    Kwota_Sprzedazy DESC,
    Kraj;
    
--Zad.5.B
SELECT
    *
FROM
    (SELECT
        c.nls_territory AS Kraj,
        c.gender AS Pleæ,
        SUM(o.order_total) AS Kwota_Sprzedazy,
        Rank() OVER(PARTITION BY  c.gender ORDER BY SUM(o.order_total) DESC) AS Rankig_Sprzedazy_Kraj_Plec
    FROM
        OE.orders o
        JOIN OE.customers c USING (customer_id)
    GROUP BY
        c.nls_territory,
        c.gender             
    ORDER BY
        Kwota_Sprzedazy DESC,
        Kraj)    
WHERE
      Rankig_Sprzedazy_Kraj_Plec IN (1,2,3)
ORDER BY
      Rankig_Sprzedazy_Kraj_Plec;  
        

