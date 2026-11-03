/* B3491 failure_print_missing_id, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:83 */

data b3491a; do x=1 to 2; output; end; run;
proc print data=b3491a; id b3491absent; var x; run;

proc datasets library=work nolist; delete b3491:; quit;
