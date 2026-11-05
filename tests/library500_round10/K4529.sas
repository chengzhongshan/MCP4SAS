/* K4529 failure_unassigned_output_libref, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3072 */

data Zk4529.out; x=10; run;

proc datasets library=work nolist; delete k4529:; quit;
