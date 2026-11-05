/* K4530 failure_unassigned_output_libref, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3072 */

data Zk4530.out; x=11; run;

proc datasets library=work nolist; delete k4530:; quit;
