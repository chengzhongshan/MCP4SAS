/* K4508 failure_sql_in_type_mismatch, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4508a; x=9; run; data k4508b; length y $8; y='9'; run;
proc sql; create table k4508o as select * from k4508a where x in (select y from k4508b); quit;

proc datasets library=work nolist; delete k4508:; quit;
