/* J3934 rank_normal_vw_symmetry, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3934a; do x=1 to 5+2; output; end; run;
proc rank data=j3934a out=j3934b normal=vw; var x; ranks score; run;
proc sql; create table j3934o as select sum(score) as actual from j3934b; quit;

data _null_; if 0 then set j3934o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3934 rows=' rows;
else do; set j3934o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3934';
else put 'ERROR: ROUND8_FAIL=J3934 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3934:; quit;
