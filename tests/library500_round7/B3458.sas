/* B3458 failure_union_type_conflict, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data b3458a; x=9; run; data b3458b; length x $12; x='9'; run;
proc sql; create table b3458o as select x from b3458a union select x from b3458b; quit;

proc datasets library=work nolist; delete b3458:; quit;
