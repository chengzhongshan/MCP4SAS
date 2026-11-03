/* F1907 sql_missing_weighted_denominator, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1907a; do x=1 to 8+2; if mod(x,2)=0 then y=x; else y=.; output; end; run;
proc sql; create table f1907o as select sum(y*x)/sum(case when y is not missing then x else 0 end) as actual from f1907a; quit;

data _null_; if 0 then set f1907o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1907 rows=' rows;
else do; set f1907o; if not missing(actual) and abs(actual-(7.33333333333333))<=1e-9*max(1,abs(7.33333333333333)) then put 'ROUND4_PASS=F1907';
else put 'ERROR: ROUND4_FAIL=F1907 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1907:; quit;
