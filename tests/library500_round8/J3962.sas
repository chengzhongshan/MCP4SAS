/* J3962 failure_sort_missing_key, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:79 */

data j3962a; do x=1 to 3; output; end; run;
proc sort data=j3962a out=j3962b; by j3962absent; run;

proc datasets library=work nolist; delete j3962:; quit;
