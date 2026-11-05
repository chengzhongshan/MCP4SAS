/* K4504 failure_sql_in_type_mismatch, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4504a; x=5; run; data k4504b; length y $8; y='5'; run;
proc sql; create table k4504o as select * from k4504a where x in (select y from k4504b); quit;

proc datasets library=work nolist; delete k4504:; quit;
