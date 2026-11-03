/* B3455 failure_union_type_conflict, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data b3455a; x=6; run; data b3455b; length x $12; x='6'; run;
proc sql; create table b3455o as select x from b3455a union select x from b3455b; quit;

proc datasets library=work nolist; delete b3455:; quit;
