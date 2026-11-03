/* F1897 sql_standard_error, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1897a; do x=1 to 8; output; end; run;
proc sql; create table f1897o as select stderr(x) as actual from f1897a; quit;

data _null_; if 0 then set f1897o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1897 rows=' rows;
else do; set f1897o; if not missing(actual) and abs(actual-(0.866025403784439))<=1e-9*max(1,abs(0.866025403784439)) then put 'ROUND4_PASS=F1897';
else put 'ERROR: ROUND4_FAIL=F1897 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1897:; quit;
