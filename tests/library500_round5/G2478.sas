/* G2478 failure_summary_where, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data g2478a; do x=1 to 9; output; end; run;
proc sql; create table g2478o as select x from g2478a where sum(x)>9; quit;

proc datasets library=work nolist; delete g2478:; quit;
