/* B3470 failure_update_missing_column, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1227 */

data b3470a; x=11; run;
proc sql; update b3470a set b3470absent=11; quit;

proc datasets library=work nolist; delete b3470:; quit;
