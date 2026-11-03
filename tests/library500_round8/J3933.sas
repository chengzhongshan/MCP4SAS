/* J3933 rank_normal_vw_symmetry, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3933a; do x=1 to 4+2; output; end; run;
proc rank data=j3933a out=j3933b normal=vw; var x; ranks score; run;
proc sql; create table j3933o as select sum(score) as actual from j3933b; quit;

data _null_; if 0 then set j3933o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3933 rows=' rows;
else do; set j3933o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3933';
else put 'ERROR: ROUND8_FAIL=J3933 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3933:; quit;
