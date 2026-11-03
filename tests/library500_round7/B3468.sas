/* B3468 failure_update_missing_column, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1227 */

data b3468a; x=9; run;
proc sql; update b3468a set b3468absent=9; quit;

proc datasets library=work nolist; delete b3468:; quit;
