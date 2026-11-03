/* B3464 failure_update_missing_column, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1227 */

data b3464a; x=5; run;
proc sql; update b3464a set b3464absent=5; quit;

proc datasets library=work nolist; delete b3464:; quit;
