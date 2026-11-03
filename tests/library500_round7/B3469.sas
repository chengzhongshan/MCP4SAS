/* B3469 failure_update_missing_column, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1227 */

data b3469a; x=10; run;
proc sql; update b3469a set b3469absent=10; quit;

proc datasets library=work nolist; delete b3469:; quit;
