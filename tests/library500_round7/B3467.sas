/* B3467 failure_update_missing_column, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1227 */

data b3467a; x=8; run;
proc sql; update b3467a set b3467absent=8; quit;

proc datasets library=work nolist; delete b3467:; quit;
