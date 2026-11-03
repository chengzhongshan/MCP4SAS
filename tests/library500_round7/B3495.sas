/* B3495 failure_print_missing_id, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:83 */

data b3495a; do x=1 to 6; output; end; run;
proc print data=b3495a; id b3495absent; var x; run;

proc datasets library=work nolist; delete b3495:; quit;
