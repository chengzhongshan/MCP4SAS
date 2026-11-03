/* B3463 failure_update_missing_column, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1227 */

data b3463a; x=4; run;
proc sql; update b3463a set b3463absent=4; quit;

proc datasets library=work nolist; delete b3463:; quit;
