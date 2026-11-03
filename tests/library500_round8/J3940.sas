/* J3940 rank_normal_vw_symmetry, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3940a; do x=1 to 11+2; output; end; run;
proc rank data=j3940a out=j3940b normal=vw; var x; ranks score; run;
proc sql; create table j3940o as select sum(score) as actual from j3940b; quit;

data _null_; if 0 then set j3940o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3940 rows=' rows;
else do; set j3940o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3940';
else put 'ERROR: ROUND8_FAIL=J3940 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3940:; quit;
