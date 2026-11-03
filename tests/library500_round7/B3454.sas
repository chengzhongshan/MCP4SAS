/* B3454 failure_union_type_conflict, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data b3454a; x=5; run; data b3454b; length x $12; x='5'; run;
proc sql; create table b3454o as select x from b3454a union select x from b3454b; quit;

proc datasets library=work nolist; delete b3454:; quit;
