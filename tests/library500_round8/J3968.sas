/* J3968 failure_sort_missing_key, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data j3968a; do x=1 to 9; output; end; run;
proc sort data=j3968a out=j3968b; by j3968absent; run;

proc datasets library=work nolist; delete j3968:; quit;
