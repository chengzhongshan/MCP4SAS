/* F1859 rank_dense_ties, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1859a; do x=1 to 10; output; output; end; run;
proc rank data=f1859a out=f1859b ties=dense; var x; ranks position; run;
proc sql; create table f1859o as select max(position) as actual from f1859b; quit;

data _null_; if 0 then set f1859o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1859 rows=' rows;
else do; set f1859o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1859';
else put 'ERROR: ROUND4_FAIL=F1859 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1859:; quit;
