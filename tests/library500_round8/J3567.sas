/* J3567 standard_preserve_missing, N=8; source: Applied Multivariate Statistics with SAS Software, Second Edition.txt:1131 */

data j3567a; do x=1 to 8; output; end; x=.; output; run;
proc standard data=j3567a out=j3567b mean=10 std=2; var x; run;
proc sql; create table j3567o as select sum(missing(x)) as actual from j3567b; quit;

data _null_; if 0 then set j3567o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3567 rows=' rows;
else do; set j3567o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND8_PASS=J3567';
else put 'ERROR: ROUND8_FAIL=J3567 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3567:; quit;
