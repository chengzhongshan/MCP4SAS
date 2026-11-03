/* F1893 sql_standard_error, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1893a; do x=1 to 4; output; end; run;
proc sql; create table f1893o as select stderr(x) as actual from f1893a; quit;

data _null_; if 0 then set f1893o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1893 rows=' rows;
else do; set f1893o; if not missing(actual) and abs(actual-(0.645497224367903))<=1e-9*max(1,abs(0.645497224367903)) then put 'ROUND4_PASS=F1893';
else put 'ERROR: ROUND4_FAIL=F1893 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1893:; quit;
