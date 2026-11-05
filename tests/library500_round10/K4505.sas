/* K4505 failure_sql_in_type_mismatch, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4505a; x=6; run; data k4505b; length y $8; y='6'; run;
proc sql; create table k4505o as select * from k4505a where x in (select y from k4505b); quit;

proc datasets library=work nolist; delete k4505:; quit;
