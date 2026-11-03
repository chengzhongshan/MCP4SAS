/* B3452 failure_union_type_conflict, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data b3452a; x=3; run; data b3452b; length x $12; x='3'; run;
proc sql; create table b3452o as select x from b3452a union select x from b3452b; quit;

proc datasets library=work nolist; delete b3452:; quit;
