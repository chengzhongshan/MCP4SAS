/* J3570 standard_preserve_missing, N=11; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3570a; do x=1 to 11; output; end; x=.; output; run;
proc standard data=j3570a out=j3570b mean=10 std=2; var x; run;
proc sql; create table j3570o as select sum(missing(x)) as actual from j3570b; quit;

data _null_; if 0 then set j3570o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3570 rows=' rows;
else do; set j3570o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3570';
else put 'ERROR: ROUND8_FAIL=J3570 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3570:; quit;
