/* K4528 failure_unassigned_output_libref, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3072 */

data Zk4528.out; x=9; run;

proc datasets library=work nolist; delete k4528:; quit;
