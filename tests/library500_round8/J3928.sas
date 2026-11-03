/* J3928 rank_normal_tukey_symmetry, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3928a; do x=1 to 9+2; output; end; run;
proc rank data=j3928a out=j3928b normal=tukey; var x; ranks score; run;
proc sql; create table j3928o as select sum(score) as actual from j3928b; quit;

data _null_; if 0 then set j3928o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3928 rows=' rows;
else do; set j3928o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3928';
else put 'ERROR: ROUND8_FAIL=J3928 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3928:; quit;
