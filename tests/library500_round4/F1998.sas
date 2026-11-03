/* F1998 failure_sql_ambiguous_column, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1998a; x=9; run; data f1998b; x=10; run;
proc sql; create table f1998o as select x from f1998a a,f1998b b; quit;

proc datasets library=work nolist; delete f1998:; quit;
