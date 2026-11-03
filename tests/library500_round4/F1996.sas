/* F1996 failure_sql_ambiguous_column, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1996a; x=7; run; data f1996b; x=8; run;
proc sql; create table f1996o as select x from f1996a a,f1996b b; quit;

proc datasets library=work nolist; delete f1996:; quit;
