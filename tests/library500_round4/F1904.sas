/* F1904 sql_missing_weighted_denominator, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1904a; do x=1 to 5+2; if mod(x,2)=0 then y=x; else y=.; output; end; run;
proc sql; create table f1904o as select sum(y*x)/sum(case when y is not missing then x else 0 end) as actual from f1904a; quit;

data _null_; if 0 then set f1904o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1904 rows=' rows;
else do; set f1904o; if not missing(actual) and abs(actual-(4.66666666666667))<=1e-9*max(1,abs(4.66666666666667)) then put 'ROUND4_PASS=F1904';
else put 'ERROR: ROUND4_FAIL=F1904 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1904:; quit;
