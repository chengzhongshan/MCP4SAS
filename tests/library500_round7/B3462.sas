/* B3462 failure_update_missing_column, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1227 */

data b3462a; x=3; run;
proc sql; update b3462a set b3462absent=3; quit;

proc datasets library=work nolist; delete b3462:; quit;
