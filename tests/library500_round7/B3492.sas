/* B3492 failure_print_missing_id, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:83 */

data b3492a; do x=1 to 3; output; end; run;
proc print data=b3492a; id b3492absent; var x; run;

proc datasets library=work nolist; delete b3492:; quit;
