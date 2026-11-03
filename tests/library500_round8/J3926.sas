/* J3926 rank_normal_tukey_symmetry, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3926a; do x=1 to 7+2; output; end; run;
proc rank data=j3926a out=j3926b normal=tukey; var x; ranks score; run;
proc sql; create table j3926o as select sum(score) as actual from j3926b; quit;

data _null_; if 0 then set j3926o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3926 rows=' rows;
else do; set j3926o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3926';
else put 'ERROR: ROUND8_FAIL=J3926 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3926:; quit;
