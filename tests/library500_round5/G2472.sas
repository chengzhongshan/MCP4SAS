/* G2472 failure_summary_where, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data g2472a; do x=1 to 3; output; end; run;
proc sql; create table g2472o as select x from g2472a where sum(x)>3; quit;

proc datasets library=work nolist; delete g2472:; quit;
