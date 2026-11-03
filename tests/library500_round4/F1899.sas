/* F1899 sql_standard_error, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1899a; do x=1 to 10; output; end; run;
proc sql; create table f1899o as select stderr(x) as actual from f1899a; quit;

data _null_; if 0 then set f1899o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1899 rows=' rows;
else do; set f1899o; if not missing(actual) and abs(actual-(0.957427107756338))<=1e-9*max(1,abs(0.957427107756338)) then put 'ROUND4_PASS=F1899';
else put 'ERROR: ROUND4_FAIL=F1899 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1899:; quit;
