/* F1856 rank_dense_ties, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1856a; do x=1 to 7; output; output; end; run;
proc rank data=f1856a out=f1856b ties=dense; var x; ranks position; run;
proc sql; create table f1856o as select max(position) as actual from f1856b; quit;

data _null_; if 0 then set f1856o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1856 rows=' rows;
else do; set f1856o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND4_PASS=F1856';
else put 'ERROR: ROUND4_FAIL=F1856 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1856:; quit;
