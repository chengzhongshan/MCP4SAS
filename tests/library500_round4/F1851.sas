/* F1851 rank_dense_ties, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1851a; do x=1 to 2; output; output; end; run;
proc rank data=f1851a out=f1851b ties=dense; var x; ranks position; run;
proc sql; create table f1851o as select max(position) as actual from f1851b; quit;

data _null_; if 0 then set f1851o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1851 rows=' rows;
else do; set f1851o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1851';
else put 'ERROR: ROUND4_FAIL=F1851 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1851:; quit;
