/* F1906 sql_missing_weighted_denominator, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1906a; do x=1 to 7+2; if mod(x,2)=0 then y=x; else y=.; output; end; run;
proc sql; create table f1906o as select sum(y*x)/sum(case when y is not missing then x else 0 end) as actual from f1906a; quit;

data _null_; if 0 then set f1906o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1906 rows=' rows;
else do; set f1906o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1906';
else put 'ERROR: ROUND4_FAIL=F1906 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1906:; quit;
