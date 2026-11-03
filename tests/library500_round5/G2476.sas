/* G2476 failure_summary_where, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data g2476a; do x=1 to 7; output; end; run;
proc sql; create table g2476o as select x from g2476a where sum(x)>7; quit;

proc datasets library=work nolist; delete g2476:; quit;
