/* K4502 failure_sql_in_type_mismatch, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4502a; x=3; run; data k4502b; length y $8; y='3'; run;
proc sql; create table k4502o as select * from k4502a where x in (select y from k4502b); quit;

proc datasets library=work nolist; delete k4502:; quit;
