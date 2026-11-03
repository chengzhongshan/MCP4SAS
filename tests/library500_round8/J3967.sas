/* J3967 failure_sort_missing_key, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data j3967a; do x=1 to 8; output; end; run;
proc sort data=j3967a out=j3967b; by j3967absent; run;

proc datasets library=work nolist; delete j3967:; quit;
