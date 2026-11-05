/* K4506 failure_sql_in_type_mismatch, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4506a; x=7; run; data k4506b; length y $8; y='7'; run;
proc sql; create table k4506o as select * from k4506a where x in (select y from k4506b); quit;

proc datasets library=work nolist; delete k4506:; quit;
