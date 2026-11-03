/* J3921 rank_normal_tukey_symmetry, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3921a; do x=1 to 2+2; output; end; run;
proc rank data=j3921a out=j3921b normal=tukey; var x; ranks score; run;
proc sql; create table j3921o as select sum(score) as actual from j3921b; quit;

data _null_; if 0 then set j3921o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3921 rows=' rows;
else do; set j3921o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3921';
else put 'ERROR: ROUND8_FAIL=J3921 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3921:; quit;
