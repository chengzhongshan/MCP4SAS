/* F1857 rank_dense_ties, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1857a; do x=1 to 8; output; output; end; run;
proc rank data=f1857a out=f1857b ties=dense; var x; ranks position; run;
proc sql; create table f1857o as select max(position) as actual from f1857b; quit;

data _null_; if 0 then set f1857o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1857 rows=' rows;
else do; set f1857o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND4_PASS=F1857';
else put 'ERROR: ROUND4_FAIL=F1857 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1857:; quit;
