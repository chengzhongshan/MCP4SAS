/* K4507 failure_sql_in_type_mismatch, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4507a; x=8; run; data k4507b; length y $8; y='8'; run;
proc sql; create table k4507o as select * from k4507a where x in (select y from k4507b); quit;

proc datasets library=work nolist; delete k4507:; quit;
