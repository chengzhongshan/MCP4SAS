/* K4501 failure_sql_in_type_mismatch, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4501a; x=2; run; data k4501b; length y $8; y='2'; run;
proc sql; create table k4501o as select * from k4501a where x in (select y from k4501b); quit;

proc datasets library=work nolist; delete k4501:; quit;
