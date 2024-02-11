/* This code you can use in some process node at SAS CI 360,
you can create some simple email alert */
DATA work.package;
    set &inTable;
RUN;

DATA work.group_i; /* get first group */
    set e_tmp.some_table_I;
RUN;

DATA work.group_ii; /* get second group */
    set e_tmp.some_table_II;
RUN;

PROC SQL;
CREATE TABLE work.precalculated_data AS ( /* simple groups calculate */
    SELECT DISTINCT a.id,
        CASE WHEN a.id = b.id THEN 1 ELSE 0 END AS value_one,
        CASE WHEN a.id = c.id THEN 1 ELSE 0 END AS value_two
    FROM work.package as a
    LEFT JOIN work.group_i as b on a.id = b.id
    LEFT JOIN work.group_ii as c on a.id = c.id
);

CREATE TABLE work.output AS (
    SELECT Count(id) AS total, Sum(value_one) AS group_one, Sum(value_two) AS group_two,
    (Sum(value_one) + Sum(value_two))/Count(id)*100 AS percentage_od_base
    FROM work.precalculated_data
);
QUIT;

/* alert send */
filename mymail email importance="high"
replyto=('example@email.com')
to=('reciver1@email.com', 'reciver2@email.com')
cc=('copy1@email.com')
subject="Subject of the alert"
ct="text/html";

ods html style=HTMLBlue body=mymail;
PROC PRINT DATA=work.output;
title 'Summary';
run;
ods html close;

DATA &outTable;
    SET work.inTable;
RUN;

%macount(&outTable);