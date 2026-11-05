/* K4509 failure_sql_in_type_mismatch, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4509a; x=10; run; data k4509b; length y $8; y='10'; run;
proc sql; create table k4509o as select * from k4509a where x in (select y from k4509b); quit;

proc datasets library=work nolist; delete k4509:; quit;
