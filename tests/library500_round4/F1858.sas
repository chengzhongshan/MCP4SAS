/* F1858 rank_dense_ties, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1858a; do x=1 to 9; output; output; end; run;
proc rank data=f1858a out=f1858b ties=dense; var x; ranks position; run;
proc sql; create table f1858o as select max(position) as actual from f1858b; quit;

data _null_; if 0 then set f1858o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1858 rows=' rows;
else do; set f1858o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND4_PASS=F1858';
else put 'ERROR: ROUND4_FAIL=F1858 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1858:; quit;
