/* G2475 failure_summary_where, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data g2475a; do x=1 to 6; output; end; run;
proc sql; create table g2475o as select x from g2475a where sum(x)>6; quit;

proc datasets library=work nolist; delete g2475:; quit;
