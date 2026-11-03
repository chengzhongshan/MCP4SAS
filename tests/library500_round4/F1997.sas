/* F1997 failure_sql_ambiguous_column, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1997a; x=8; run; data f1997b; x=9; run;
proc sql; create table f1997o as select x from f1997a a,f1997b b; quit;

proc datasets library=work nolist; delete f1997:; quit;
