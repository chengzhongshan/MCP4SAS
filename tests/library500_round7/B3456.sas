/* B3456 failure_union_type_conflict, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data b3456a; x=7; run; data b3456b; length x $12; x='7'; run;
proc sql; create table b3456o as select x from b3456a union select x from b3456b; quit;

proc datasets library=work nolist; delete b3456:; quit;
