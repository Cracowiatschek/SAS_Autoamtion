/* This code you can use in some process node at SAS CI 360,
you can create some personalized email alert */

PROC SQL; /* get some sample data */
CREATE TABLE work.example_data (
    email VARCHAR(150),
    value VARCHAR(30)
);

INSERT INTO work.example_data VALUES('example1@email.com', '10');
INSERT INTO work.example_data VALUES('example2@email.com', '20');
INSERT INTO work.example_data VALUES('example3@email.com', '30');
INSERT INTO work.example_data VALUES('example4@email.com', '40');
QUIT;

filename mymail email importance="high"
replyto=('example@email.com')
subject=('ALERT')
ct="text/html";

%macro SendEmail;

PROC SQL;
SELECT DISTINCT email INTO :email_list SEPARATED "|" FROM work.example_data;

%let email_count = %SYSFUNC(COUNTW(&email_list, "|"));
%do i=1 %to &email_count;

%let set_email = %SCAN(&email_list, &i, "|");
%let email = "%SYSFUNC(TRANWRD(&set_email, %str(), %str()))";

DATA _null_;
    SET work.example_data (where=(&email));
    file mymail to=(&email);
    put '<html><body>';
    put '<h3>THIS IS SOME TEXT ALERT</h3>';
    put '<p> Your own number = ' value '.</p>'
RUN;
%end
%mend
%SendEmail;