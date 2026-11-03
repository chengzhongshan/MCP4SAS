/* F1895 sql_standard_error, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1895a; do x=1 to 6; output; end; run;
proc sql; create table f1895o as select stderr(x) as actual from f1895a; quit;

data _null_; if 0 then set f1895o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1895 rows=' rows;
else do; set f1895o; if not missing(actual) and abs(actual-(0.763762615825973))<=1e-9*max(1,abs(0.763762615825973)) then put 'ROUND4_PASS=F1895';
else put 'ERROR: ROUND4_FAIL=F1895 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1895:; quit;
