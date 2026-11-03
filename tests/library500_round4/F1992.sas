/* F1992 failure_sql_ambiguous_column, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1992a; x=3; run; data f1992b; x=4; run;
proc sql; create table f1992o as select x from f1992a a,f1992b b; quit;

proc datasets library=work nolist; delete f1992:; quit;
