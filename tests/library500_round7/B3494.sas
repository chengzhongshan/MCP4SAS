/* B3494 failure_print_missing_id, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:83 */

data b3494a; do x=1 to 5; output; end; run;
proc print data=b3494a; id b3494absent; var x; run;

proc datasets library=work nolist; delete b3494:; quit;
