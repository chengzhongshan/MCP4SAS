/* K4523 failure_unassigned_output_libref, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3072 */

data Zk4523.out; x=4; run;

proc datasets library=work nolist; delete k4523:; quit;
