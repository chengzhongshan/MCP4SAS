/* J3969 failure_sort_missing_key, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data j3969a; do x=1 to 10; output; end; run;
proc sort data=j3969a out=j3969b; by j3969absent; run;

proc datasets library=work nolist; delete j3969:; quit;
