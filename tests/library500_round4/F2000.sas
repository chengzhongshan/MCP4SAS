/* F2000 failure_sql_ambiguous_column, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f2000a; x=11; run; data f2000b; x=12; run;
proc sql; create table f2000o as select x from f2000a a,f2000b b; quit;

proc datasets library=work nolist; delete f2000:; quit;
