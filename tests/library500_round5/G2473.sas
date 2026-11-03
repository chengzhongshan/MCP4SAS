/* G2473 failure_summary_where, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data g2473a; do x=1 to 4; output; end; run;
proc sql; create table g2473o as select x from g2473a where sum(x)>4; quit;

proc datasets library=work nolist; delete g2473:; quit;
