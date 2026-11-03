/* J3937 rank_normal_vw_symmetry, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3937a; do x=1 to 8+2; output; end; run;
proc rank data=j3937a out=j3937b normal=vw; var x; ranks score; run;
proc sql; create table j3937o as select sum(score) as actual from j3937b; quit;

data _null_; if 0 then set j3937o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3937 rows=' rows;
else do; set j3937o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3937';
else put 'ERROR: ROUND8_FAIL=J3937 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3937:; quit;
