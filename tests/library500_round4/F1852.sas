/* F1852 rank_dense_ties, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1852a; do x=1 to 3; output; output; end; run;
proc rank data=f1852a out=f1852b ties=dense; var x; ranks position; run;
proc sql; create table f1852o as select max(position) as actual from f1852b; quit;

data _null_; if 0 then set f1852o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1852 rows=' rows;
else do; set f1852o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND4_PASS=F1852';
else put 'ERROR: ROUND4_FAIL=F1852 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1852:; quit;
