/* F1995 failure_sql_ambiguous_column, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1995a; x=6; run; data f1995b; x=7; run;
proc sql; create table f1995o as select x from f1995a a,f1995b b; quit;

proc datasets library=work nolist; delete f1995:; quit;
