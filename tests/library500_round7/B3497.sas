/* B3497 failure_print_missing_id, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:83 */

data b3497a; do x=1 to 8; output; end; run;
proc print data=b3497a; id b3497absent; var x; run;

proc datasets library=work nolist; delete b3497:; quit;
