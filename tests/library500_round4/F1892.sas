/* F1892 sql_standard_error, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1892a; do x=1 to 3; output; end; run;
proc sql; create table f1892o as select stderr(x) as actual from f1892a; quit;

data _null_; if 0 then set f1892o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1892 rows=' rows;
else do; set f1892o; if not missing(actual) and abs(actual-(0.577350269189626))<=1e-9*max(1,abs(0.577350269189626)) then put 'ROUND4_PASS=F1892';
else put 'ERROR: ROUND4_FAIL=F1892 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1892:; quit;
