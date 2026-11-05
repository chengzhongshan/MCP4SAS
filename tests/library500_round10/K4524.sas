/* K4524 failure_unassigned_output_libref, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3072 */

data Zk4524.out; x=5; run;

proc datasets library=work nolist; delete k4524:; quit;
