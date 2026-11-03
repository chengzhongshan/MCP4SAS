/* B3500 failure_print_missing_id, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:83 */

data b3500a; do x=1 to 11; output; end; run;
proc print data=b3500a; id b3500absent; var x; run;

proc datasets library=work nolist; delete b3500:; quit;
