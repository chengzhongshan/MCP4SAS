/* B3461 failure_update_missing_column, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1227 */

data b3461a; x=2; run;
proc sql; update b3461a set b3461absent=2; quit;

proc datasets library=work nolist; delete b3461:; quit;
