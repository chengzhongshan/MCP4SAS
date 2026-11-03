/* J3963 failure_sort_missing_key, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data j3963a; do x=1 to 4; output; end; run;
proc sort data=j3963a out=j3963b; by j3963absent; run;

proc datasets library=work nolist; delete j3963:; quit;
