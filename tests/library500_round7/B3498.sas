/* B3498 failure_print_missing_id, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:83 */

data b3498a; do x=1 to 9; output; end; run;
proc print data=b3498a; id b3498absent; var x; run;

proc datasets library=work nolist; delete b3498:; quit;
