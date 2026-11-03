/* F1854 rank_dense_ties, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1854a; do x=1 to 5; output; output; end; run;
proc rank data=f1854a out=f1854b ties=dense; var x; ranks position; run;
proc sql; create table f1854o as select max(position) as actual from f1854b; quit;

data _null_; if 0 then set f1854o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1854 rows=' rows;
else do; set f1854o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1854';
else put 'ERROR: ROUND4_FAIL=F1854 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1854:; quit;
