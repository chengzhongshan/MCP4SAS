/* F1891 sql_standard_error, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1891a; do x=1 to 2; output; end; run;
proc sql; create table f1891o as select stderr(x) as actual from f1891a; quit;

data _null_; if 0 then set f1891o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1891 rows=' rows;
else do; set f1891o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND4_PASS=F1891';
else put 'ERROR: ROUND4_FAIL=F1891 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1891:; quit;
