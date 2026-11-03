/* J3964 failure_sort_missing_key, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data j3964a; do x=1 to 5; output; end; run;
proc sort data=j3964a out=j3964b; by j3964absent; run;

proc datasets library=work nolist; delete j3964:; quit;
