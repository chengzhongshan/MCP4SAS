/* F1994 failure_sql_ambiguous_column, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1994a; x=5; run; data f1994b; x=6; run;
proc sql; create table f1994o as select x from f1994a a,f1994b b; quit;

proc datasets library=work nolist; delete f1994:; quit;
