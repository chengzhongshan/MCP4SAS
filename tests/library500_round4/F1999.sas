/* F1999 failure_sql_ambiguous_column, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1999a; x=10; run; data f1999b; x=11; run;
proc sql; create table f1999o as select x from f1999a a,f1999b b; quit;

proc datasets library=work nolist; delete f1999:; quit;
