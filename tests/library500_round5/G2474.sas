/* G2474 failure_summary_where, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data g2474a; do x=1 to 5; output; end; run;
proc sql; create table g2474o as select x from g2474a where sum(x)>5; quit;

proc datasets library=work nolist; delete g2474:; quit;
