/* B3499 failure_print_missing_id, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:83 */

data b3499a; do x=1 to 10; output; end; run;
proc print data=b3499a; id b3499absent; var x; run;

proc datasets library=work nolist; delete b3499:; quit;
