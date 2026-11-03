/* F1853 rank_dense_ties, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1853a; do x=1 to 4; output; output; end; run;
proc rank data=f1853a out=f1853b ties=dense; var x; ranks position; run;
proc sql; create table f1853o as select max(position) as actual from f1853b; quit;

data _null_; if 0 then set f1853o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1853 rows=' rows;
else do; set f1853o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND4_PASS=F1853';
else put 'ERROR: ROUND4_FAIL=F1853 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1853:; quit;
