/* B3453 failure_union_type_conflict, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data b3453a; x=4; run; data b3453b; length x $12; x='4'; run;
proc sql; create table b3453o as select x from b3453a union select x from b3453b; quit;

proc datasets library=work nolist; delete b3453:; quit;
