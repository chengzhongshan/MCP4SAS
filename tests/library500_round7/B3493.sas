/* B3493 failure_print_missing_id, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:83 */

data b3493a; do x=1 to 4; output; end; run;
proc print data=b3493a; id b3493absent; var x; run;

proc datasets library=work nolist; delete b3493:; quit;
