/* K4521 failure_unassigned_output_libref, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3072 */

data Zk4521.out; x=2; run;

proc datasets library=work nolist; delete k4521:; quit;
