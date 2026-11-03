/* F1910 sql_missing_weighted_denominator, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1910a; do x=1 to 11+2; if mod(x,2)=0 then y=x; else y=.; output; end; run;
proc sql; create table f1910o as select sum(y*x)/sum(case when y is not missing then x else 0 end) as actual from f1910a; quit;

data _null_; if 0 then set f1910o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1910 rows=' rows;
else do; set f1910o; if not missing(actual) and abs(actual-(8.66666666666667))<=1e-9*max(1,abs(8.66666666666667)) then put 'ROUND4_PASS=F1910';
else put 'ERROR: ROUND4_FAIL=F1910 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1910:; quit;
