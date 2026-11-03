/* F1993 failure_sql_ambiguous_column, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1993a; x=4; run; data f1993b; x=5; run;
proc sql; create table f1993o as select x from f1993a a,f1993b b; quit;

proc datasets library=work nolist; delete f1993:; quit;
