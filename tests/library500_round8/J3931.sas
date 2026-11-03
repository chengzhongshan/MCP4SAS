/* J3931 rank_normal_vw_symmetry, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3931a; do x=1 to 2+2; output; end; run;
proc rank data=j3931a out=j3931b normal=vw; var x; ranks score; run;
proc sql; create table j3931o as select sum(score) as actual from j3931b; quit;

data _null_; if 0 then set j3931o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3931 rows=' rows;
else do; set j3931o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3931';
else put 'ERROR: ROUND8_FAIL=J3931 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3931:; quit;
