/* G2479 failure_summary_where, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data g2479a; do x=1 to 10; output; end; run;
proc sql; create table g2479o as select x from g2479a where sum(x)>10; quit;

proc datasets library=work nolist; delete g2479:; quit;
