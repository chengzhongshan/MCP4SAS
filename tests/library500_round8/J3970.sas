/* J3970 failure_sort_missing_key, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data j3970a; do x=1 to 11; output; end; run;
proc sort data=j3970a out=j3970b; by j3970absent; run;

proc datasets library=work nolist; delete j3970:; quit;
