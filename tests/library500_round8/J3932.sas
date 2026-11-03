/* J3932 rank_normal_vw_symmetry, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3932a; do x=1 to 3+2; output; end; run;
proc rank data=j3932a out=j3932b normal=vw; var x; ranks score; run;
proc sql; create table j3932o as select sum(score) as actual from j3932b; quit;

data _null_; if 0 then set j3932o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3932 rows=' rows;
else do; set j3932o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3932';
else put 'ERROR: ROUND8_FAIL=J3932 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3932:; quit;
