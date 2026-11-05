/* K4525 failure_unassigned_output_libref, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3072 */

data Zk4525.out; x=6; run;

proc datasets library=work nolist; delete k4525:; quit;
