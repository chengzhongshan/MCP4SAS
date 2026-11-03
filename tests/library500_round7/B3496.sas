/* B3496 failure_print_missing_id, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:83 */

data b3496a; do x=1 to 7; output; end; run;
proc print data=b3496a; id b3496absent; var x; run;

proc datasets library=work nolist; delete b3496:; quit;
