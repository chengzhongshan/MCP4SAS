/* B3466 failure_update_missing_column, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1227 */

data b3466a; x=7; run;
proc sql; update b3466a set b3466absent=7; quit;

proc datasets library=work nolist; delete b3466:; quit;
