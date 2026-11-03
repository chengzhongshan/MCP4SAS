/* B3457 failure_union_type_conflict, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data b3457a; x=8; run; data b3457b; length x $12; x='8'; run;
proc sql; create table b3457o as select x from b3457a union select x from b3457b; quit;

proc datasets library=work nolist; delete b3457:; quit;
