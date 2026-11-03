/* F1860 rank_dense_ties, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1860a; do x=1 to 11; output; output; end; run;
proc rank data=f1860a out=f1860b ties=dense; var x; ranks position; run;
proc sql; create table f1860o as select max(position) as actual from f1860b; quit;

data _null_; if 0 then set f1860o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1860 rows=' rows;
else do; set f1860o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND4_PASS=F1860';
else put 'ERROR: ROUND4_FAIL=F1860 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1860:; quit;
