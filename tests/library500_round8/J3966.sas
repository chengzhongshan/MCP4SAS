/* J3966 failure_sort_missing_key, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data j3966a; do x=1 to 7; output; end; run;
proc sort data=j3966a out=j3966b; by j3966absent; run;

proc datasets library=work nolist; delete j3966:; quit;
