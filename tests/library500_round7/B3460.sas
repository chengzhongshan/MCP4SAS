/* B3460 failure_union_type_conflict, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data b3460a; x=11; run; data b3460b; length x $12; x='11'; run;
proc sql; create table b3460o as select x from b3460a union select x from b3460b; quit;

proc datasets library=work nolist; delete b3460:; quit;
