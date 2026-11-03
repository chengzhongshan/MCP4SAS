/* F1991 failure_sql_ambiguous_column, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1991a; x=2; run; data f1991b; x=3; run;
proc sql; create table f1991o as select x from f1991a a,f1991b b; quit;

proc datasets library=work nolist; delete f1991:; quit;
