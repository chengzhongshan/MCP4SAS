/* J3961 failure_sort_missing_key, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data j3961a; do x=1 to 2; output; end; run;
proc sort data=j3961a out=j3961b; by j3961absent; run;

proc datasets library=work nolist; delete j3961:; quit;
