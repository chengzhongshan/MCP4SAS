/* F1901 sql_missing_weighted_denominator, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1901a; do x=1 to 2+2; if mod(x,2)=0 then y=x; else y=.; output; end; run;
proc sql; create table f1901o as select sum(y*x)/sum(case when y is not missing then x else 0 end) as actual from f1901a; quit;

data _null_; if 0 then set f1901o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1901 rows=' rows;
else do; set f1901o; if not missing(actual) and abs(actual-(3.33333333333333))<=1e-9*max(1,abs(3.33333333333333)) then put 'ROUND4_PASS=F1901';
else put 'ERROR: ROUND4_FAIL=F1901 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1901:; quit;
