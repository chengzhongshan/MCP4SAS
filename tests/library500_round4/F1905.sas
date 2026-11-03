/* F1905 sql_missing_weighted_denominator, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1905a; do x=1 to 6+2; if mod(x,2)=0 then y=x; else y=.; output; end; run;
proc sql; create table f1905o as select sum(y*x)/sum(case when y is not missing then x else 0 end) as actual from f1905a; quit;

data _null_; if 0 then set f1905o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1905 rows=' rows;
else do; set f1905o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1905';
else put 'ERROR: ROUND4_FAIL=F1905 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1905:; quit;
