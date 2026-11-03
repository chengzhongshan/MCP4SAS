/* B3465 failure_update_missing_column, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1227 */

data b3465a; x=6; run;
proc sql; update b3465a set b3465absent=6; quit;

proc datasets library=work nolist; delete b3465:; quit;
