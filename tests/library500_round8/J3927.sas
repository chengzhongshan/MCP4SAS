/* J3927 rank_normal_tukey_symmetry, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3927a; do x=1 to 8+2; output; end; run;
proc rank data=j3927a out=j3927b normal=tukey; var x; ranks score; run;
proc sql; create table j3927o as select sum(score) as actual from j3927b; quit;

data _null_; if 0 then set j3927o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3927 rows=' rows;
else do; set j3927o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3927';
else put 'ERROR: ROUND8_FAIL=J3927 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3927:; quit;
