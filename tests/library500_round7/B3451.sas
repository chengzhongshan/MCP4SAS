/* B3451 failure_union_type_conflict, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data b3451a; x=2; run; data b3451b; length x $12; x='2'; run;
proc sql; create table b3451o as select x from b3451a union select x from b3451b; quit;

proc datasets library=work nolist; delete b3451:; quit;
