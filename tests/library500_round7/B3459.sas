/* B3459 failure_union_type_conflict, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data b3459a; x=10; run; data b3459b; length x $12; x='10'; run;
proc sql; create table b3459o as select x from b3459a union select x from b3459b; quit;

proc datasets library=work nolist; delete b3459:; quit;
