/* G2471 failure_summary_where, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data g2471a; do x=1 to 2; output; end; run;
proc sql; create table g2471o as select x from g2471a where sum(x)>2; quit;

proc datasets library=work nolist; delete g2471:; quit;
