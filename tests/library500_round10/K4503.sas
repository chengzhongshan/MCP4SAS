/* K4503 failure_sql_in_type_mismatch, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4503a; x=4; run; data k4503b; length y $8; y='4'; run;
proc sql; create table k4503o as select * from k4503a where x in (select y from k4503b); quit;

proc datasets library=work nolist; delete k4503:; quit;
