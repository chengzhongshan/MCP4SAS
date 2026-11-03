/* J3965 failure_sort_missing_key, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data j3965a; do x=1 to 6; output; end; run;
proc sort data=j3965a out=j3965b; by j3965absent; run;

proc datasets library=work nolist; delete j3965:; quit;
