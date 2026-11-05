/* K4510 failure_sql_in_type_mismatch, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4510a; x=11; run; data k4510b; length y $8; y='11'; run;
proc sql; create table k4510o as select * from k4510a where x in (select y from k4510b); quit;

proc datasets library=work nolist; delete k4510:; quit;
