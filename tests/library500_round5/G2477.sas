/* G2477 failure_summary_where, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data g2477a; do x=1 to 8; output; end; run;
proc sql; create table g2477o as select x from g2477a where sum(x)>8; quit;

proc datasets library=work nolist; delete g2477:; quit;
